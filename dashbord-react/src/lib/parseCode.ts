export interface Article {
  id: string;
  number: string;
  title: string;
  content: string;
  notes: string[];
}

export interface CodeSection {
  id: string;
  title: string;
  subsections: CodeSection[];
  articles: Article[];
}

export interface Chapter {
  id: string;
  title: string;
  sections: CodeSection[];
}

export interface CodeTitle {
  id: string;
  title: string;
  chapters: Chapter[];
}

export interface Book {
  id: string;
  title: string;
  titles: CodeTitle[];
}

export interface ParsedCode {
  id: string;
  title: string;
  books: Book[];
}

export function parseRawCode(text: string, id = "custom", title = "Cod personal"): ParsedCode {
  const bookRe = /^Cartea/i;
  const titleRe = /^Titlul/i;
  const chapterRe = /^Capitolul/i;
  const sectionRe = /^Sec[tț]iunea/i;
  const subsectionRe = /^Subsec[tț]iunea/i;
  const articleRe = /^Articolul\s+(\d+)/i;
  const noteRe = /^Not[aă]/i;
  const decisionRe = /^Decizie/i;
  // Lines that start with "(la" denote amendment notes. Previously, any line
  // starting with "(" was treated as an amendment, which incorrectly captured
  // article paragraphs like "(1)" or "(2)". Restrict the pattern so only
  // explicit amendment notes are matched.
  const amendRe = /^\(la\s.*$/i;

  let bookOrder = 0;
  let titleOrder = 0;
  let chapterOrder = 0;
  let sectionOrder = 0;
  let subOrder = 0;
  let articleOrder = 0;

  let currentBook: Book | null = null;
  let currentTitle: CodeTitle | null = null;
  let currentChapter: Chapter | null = null;
  let currentSection: CodeSection | null = null;
  let currentSub: CodeSection | null = null;
  let currentArticle: Article | null = null;
  let expectTitle = false;

  const code: ParsedCode = { id, title, books: [] };

  function finishArticle() {
    if (!currentArticle) return;
    if (currentSub) {
      currentSub.articles.push(currentArticle);
    } else if (currentSection) {
      currentSection.articles.push(currentArticle);
    }
    currentArticle = null;
  }

  const lines = text.split(/\r?\n/);
  for (let raw of lines) {
    const line = raw.trim();
    if (!line) continue;

    if (noteRe.test(line) || decisionRe.test(line) || amendRe.test(line)) {
      if (currentArticle) {
        currentArticle.notes.push(line);
      }
      continue;
    }

    if (bookRe.test(line)) {
      finishArticle();
      titleOrder = chapterOrder = sectionOrder = subOrder = articleOrder = 0;
      bookOrder++;
      const b: Book = { id: `book_${bookOrder}`, title: line, titles: [] };
      code.books.push(b);
      currentBook = b;
      currentTitle = null;
      currentChapter = null;
      currentSection = null;
      currentSub = null;
      continue;
    }

    if (titleRe.test(line)) {
      finishArticle();
      chapterOrder = sectionOrder = subOrder = articleOrder = 0;
      titleOrder++;
      if (!currentBook) {
        bookOrder++;
        currentBook = { id: `book_${bookOrder}`, title: "Intro", titles: [] };
        code.books.push(currentBook);
      }
      const t: CodeTitle = { id: `book_${bookOrder}_title_${titleOrder}`, title: line, chapters: [] };
      currentBook.titles.push(t);
      currentTitle = t;
      currentChapter = null;
      currentSection = null;
      currentSub = null;
      continue;
    }

    if (chapterRe.test(line)) {
      finishArticle();
      sectionOrder = subOrder = articleOrder = 0;
      chapterOrder++;
      if (!currentTitle) {
        titleOrder++;
        if (!currentBook) {
          bookOrder++;
          currentBook = { id: `book_${bookOrder}`, title: "Intro", titles: [] };
          code.books.push(currentBook);
        }
        const untitled: CodeTitle = { id: `book_${bookOrder}_title_${titleOrder}`, title: "Untitled", chapters: [] };
        currentBook.titles.push(untitled);
        currentTitle = untitled;
      }
      const ch: Chapter = { id: `book_${bookOrder}_title_${titleOrder}_ch_${chapterOrder}`, title: line, sections: [] };
      currentTitle.chapters.push(ch);
      currentChapter = ch;
      currentSection = null;
      currentSub = null;
      continue;
    }

    if (sectionRe.test(line)) {
      finishArticle();
      subOrder = articleOrder = 0;
      sectionOrder++;
      if (!currentChapter) {
        chapterOrder++;
        if (!currentTitle) {
          titleOrder++;
          if (!currentBook) {
            bookOrder++;
            currentBook = { id: `book_${bookOrder}`, title: "Intro", titles: [] };
            code.books.push(currentBook);
          }
          const untitled: CodeTitle = { id: `book_${bookOrder}_title_${titleOrder}`, title: "Untitled", chapters: [] };
          currentBook.titles.push(untitled);
          currentTitle = untitled;
        }
        const unnamed: Chapter = { id: `book_${bookOrder}_title_${titleOrder}_ch_${chapterOrder}`, title: "Unnamed", sections: [] };
        currentTitle.chapters.push(unnamed);
        currentChapter = unnamed;
      }
      const sec: CodeSection = { id: `book_${bookOrder}_title_${titleOrder}_ch_${chapterOrder}_sec_${sectionOrder}`, title: line, subsections: [], articles: [] };
      currentChapter.sections.push(sec);
      currentSection = sec;
      currentSub = null;
      continue;
    }

    if (subsectionRe.test(line)) {
      finishArticle();
      articleOrder = 0;
      subOrder++;
      if (!currentSection) {
        sectionOrder++;
        if (!currentChapter) {
          chapterOrder++;
          if (!currentTitle) {
            titleOrder++;
            if (!currentBook) {
              bookOrder++;
              currentBook = { id: `book_${bookOrder}`, title: "Intro", titles: [] };
              code.books.push(currentBook);
            }
            const untitled: CodeTitle = { id: `book_${bookOrder}_title_${titleOrder}`, title: "Untitled", chapters: [] };
            currentBook.titles.push(untitled);
            currentTitle = untitled;
          }
          const unnamed: Chapter = { id: `book_${bookOrder}_title_${titleOrder}_ch_${chapterOrder}`, title: "Unnamed", sections: [] };
          currentTitle.chapters.push(unnamed);
          currentChapter = unnamed;
        }
        const sec: CodeSection = { id: `book_${bookOrder}_title_${titleOrder}_ch_${chapterOrder}_sec_${sectionOrder}`, title: "", subsections: [], articles: [] };
        currentChapter.sections.push(sec);
        currentSection = sec;
      }
      const sub: CodeSection = { id: `book_${bookOrder}_title_${titleOrder}_ch_${chapterOrder}_sec_${sectionOrder}_sub_${subOrder}`, title: line, subsections: [], articles: [] };
      currentSection.subsections.push(sub);
      currentSub = sub;
      continue;
    }

    const artMatch = line.match(articleRe);
    if (artMatch) {
      finishArticle();
      articleOrder++;
      const num = artMatch[1] || "";
      if (!currentSection && !currentSub) {
        // create default section
        sectionOrder++;
        if (!currentChapter) {
          chapterOrder++;
          if (!currentTitle) {
            titleOrder++;
            if (!currentBook) {
              bookOrder++;
              currentBook = { id: `book_${bookOrder}`, title: "Intro", titles: [] };
              code.books.push(currentBook);
            }
            const untitled: CodeTitle = { id: `book_${bookOrder}_title_${titleOrder}`, title: "Untitled", chapters: [] };
            currentBook.titles.push(untitled);
            currentTitle = untitled;
          }
          const unnamed: Chapter = { id: `book_${bookOrder}_title_${titleOrder}_ch_${chapterOrder}`, title: "Unnamed", sections: [] };
          currentTitle.chapters.push(unnamed);
          currentChapter = unnamed;
        }
        const sec: CodeSection = { id: `book_${bookOrder}_title_${titleOrder}_ch_${chapterOrder}_sec_${sectionOrder}`, title: "", subsections: [], articles: [] };
        currentChapter.sections.push(sec);
        currentSection = sec;
      }
      currentArticle = {
        id: currentSub
          ? `book_${bookOrder}_title_${titleOrder}_ch_${chapterOrder}_sec_${sectionOrder}_sub_${subOrder}_art_${articleOrder}`
          : `book_${bookOrder}_title_${titleOrder}_ch_${chapterOrder}_sec_${sectionOrder}_art_${articleOrder}`,
        number: num,
        title: "",
        content: "",
        notes: [],
      };
      expectTitle = true;
      continue;
    }

    // default
    if (currentArticle) {
      if (expectTitle) {
        currentArticle.title = line;
        expectTitle = false;
      } else {
        currentArticle.content += (currentArticle.content ? "\n" : "") + line;
      }
    }
  }

  finishArticle();

  return code;
}
