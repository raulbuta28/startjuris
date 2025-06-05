package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
	"strings"
)

type Article struct {
	ID          string   `json:"id"`
	Number      string   `json:"number"`
	Title       string   `json:"title"`
	Content     string   `json:"content"`
	Notes       []string `json:"notes"`
	References  []string `json:"references"`
	IsImportant bool     `json:"isImportant"`
	Keywords    []string `json:"keywords"`
	Order       int      `json:"order"`
}

type CodeSection struct {
	ID          string        `json:"id"`
	Title       string        `json:"title"`
	Subtitle    string        `json:"subtitle,omitempty"`
	Subsections []CodeSection `json:"subsections"`
	Articles    []Article     `json:"articles"`
	Order       int           `json:"order"`
}

type Chapter struct {
	ID       string        `json:"id"`
	Title    string        `json:"title"`
	Subtitle string        `json:"subtitle,omitempty"`
	Sections []CodeSection `json:"sections"`
	Order    int           `json:"order"`
}

type CodeTitle struct {
	ID       string    `json:"id"`
	Title    string    `json:"title"`
	Subtitle string    `json:"subtitle,omitempty"`
	Chapters []Chapter `json:"chapters"`
	Order    int       `json:"order"`
}

type Book struct {
	ID       string      `json:"id"`
	Title    string      `json:"title"`
	Subtitle string      `json:"subtitle,omitempty"`
	Titles   []CodeTitle `json:"titles"`
	Order    int         `json:"order"`
}

type ParsedCode struct {
	ID            string            `json:"id"`
	Title         string            `json:"title"`
	Type          string            `json:"type"`
	Books         []Book            `json:"books"`
	Metadata      map[string]string `json:"metadata"`
	LastUpdated   string            `json:"lastUpdated"`
	TotalArticles int               `json:"totalArticles"`
	Articles      []Article         `json:"articles"`
}

func parseCodeFile(path, codeID, codeTitle string) (*ParsedCode, error) {
	file, err := os.Open(path)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)

	bookRe := regexp.MustCompile(`(?i)^Cartea`)
	titleRe := regexp.MustCompile(`(?i)^Titlul`)
	chapterRe := regexp.MustCompile(`(?i)^Capitolul`)
	sectionRe := regexp.MustCompile(`(?i)^Sec[tț]iunea`)
	subsectionRe := regexp.MustCompile(`(?i)^Subsec[tț]iunea`)
	articleRe := regexp.MustCompile(`(?i)^Articolul\s+(\d+)`)
	noteRe := regexp.MustCompile(`(?i)^Not[aă]`)
	refRe := regexp.MustCompile(`(?i)(monitorul oficial|legea nr|ril nr|decizia)`)

	code := &ParsedCode{
		ID:       codeID,
		Title:    codeTitle,
		Type:     codeID,
		Books:    []Book{},
		Metadata: map[string]string{},
	}

	var currentBook *Book
	var currentTitle *CodeTitle
	var currentChapter *Chapter
	var currentSection *CodeSection
	var currentSubsection *CodeSection
	var currentArticle *Article
	var expectTitle bool

	var bookOrder, titleOrder, chapterOrder, sectionOrder, subsectionOrder, articleOrder int

	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line == "" {
			continue
		}

		switch {
		case bookRe.MatchString(line):
			if currentArticle != nil {
				if currentSubsection != nil {
					currentSubsection.Articles = append(currentSubsection.Articles, *currentArticle)
				} else if currentSection != nil {
					currentSection.Articles = append(currentSection.Articles, *currentArticle)
				}
				currentArticle = nil
			}
			titleOrder, chapterOrder, sectionOrder, subsectionOrder, articleOrder = 0, 0, 0, 0, 0
			bookOrder++
			b := Book{ID: fmt.Sprintf("book_%d", bookOrder), Title: line, Order: bookOrder}
			code.Books = append(code.Books, b)
			currentBook = &code.Books[len(code.Books)-1]
		case titleRe.MatchString(line):
			if currentArticle != nil {
				if currentSubsection != nil {
					currentSubsection.Articles = append(currentSubsection.Articles, *currentArticle)
				} else if currentSection != nil {
					currentSection.Articles = append(currentSection.Articles, *currentArticle)
				}
				currentArticle = nil
			}
			chapterOrder, sectionOrder, subsectionOrder, articleOrder = 0, 0, 0, 0
			titleOrder++
			t := CodeTitle{ID: fmt.Sprintf("book_%d_title_%d", bookOrder, titleOrder), Title: line, Order: titleOrder}
			if currentBook == nil {
				// create default book if none exists
				bookOrder++
				code.Books = append(code.Books, Book{ID: fmt.Sprintf("book_%d", bookOrder), Title: "Intro", Order: bookOrder})
				currentBook = &code.Books[len(code.Books)-1]
			}
			currentBook.Titles = append(currentBook.Titles, t)
			currentTitle = &currentBook.Titles[len(currentBook.Titles)-1]
		case chapterRe.MatchString(line):
			if currentArticle != nil {
				if currentSubsection != nil {
					currentSubsection.Articles = append(currentSubsection.Articles, *currentArticle)
				} else if currentSection != nil {
					currentSection.Articles = append(currentSection.Articles, *currentArticle)
				}
				currentArticle = nil
			}
			sectionOrder, subsectionOrder, articleOrder = 0, 0, 0
			chapterOrder++
			ch := Chapter{ID: fmt.Sprintf("book_%d_title_%d_ch_%d", bookOrder, titleOrder, chapterOrder), Title: line, Order: chapterOrder}
			if currentTitle == nil {
				// create default title
				titleOrder++
				if currentBook == nil {
					bookOrder++
					code.Books = append(code.Books, Book{ID: fmt.Sprintf("book_%d", bookOrder), Title: "Intro", Order: bookOrder})
					currentBook = &code.Books[len(code.Books)-1]
				}
				currentBook.Titles = append(currentBook.Titles, CodeTitle{ID: fmt.Sprintf("book_%d_title_%d", bookOrder, titleOrder), Title: "Untitled", Order: titleOrder})
				currentTitle = &currentBook.Titles[len(currentBook.Titles)-1]
			}
			currentTitle.Chapters = append(currentTitle.Chapters, ch)
			currentChapter = &currentTitle.Chapters[len(currentTitle.Chapters)-1]
		case sectionRe.MatchString(line):
			if currentArticle != nil {
				if currentSubsection != nil {
					currentSubsection.Articles = append(currentSubsection.Articles, *currentArticle)
				} else if currentSection != nil {
					currentSection.Articles = append(currentSection.Articles, *currentArticle)
				}
				currentArticle = nil
			}
			articleOrder = 0
			subsectionOrder = 0
			sectionOrder++
                        sec := CodeSection{ID: fmt.Sprintf("book_%d_title_%d_ch_%d_sec_%d", bookOrder, titleOrder, chapterOrder, sectionOrder), Title: line, Order: sectionOrder, Subsections: []CodeSection{}, Articles: []Article{}}
			if currentChapter == nil {
				// create default chapter
				chapterOrder++
				if currentTitle == nil {
					titleOrder++
					if currentBook == nil {
						bookOrder++
						code.Books = append(code.Books, Book{ID: fmt.Sprintf("book_%d", bookOrder), Title: "Intro", Order: bookOrder})
						currentBook = &code.Books[len(code.Books)-1]
					}
					currentBook.Titles = append(currentBook.Titles, CodeTitle{ID: fmt.Sprintf("book_%d_title_%d", bookOrder, titleOrder), Title: "Untitled", Order: titleOrder})
					currentTitle = &currentBook.Titles[len(currentBook.Titles)-1]
				}
				currentTitle.Chapters = append(currentTitle.Chapters, Chapter{ID: fmt.Sprintf("book_%d_title_%d_ch_%d", bookOrder, titleOrder, chapterOrder), Title: "Unnamed", Order: chapterOrder})
				currentChapter = &currentTitle.Chapters[len(currentTitle.Chapters)-1]
			}
			currentChapter.Sections = append(currentChapter.Sections, sec)
			currentSection = &currentChapter.Sections[len(currentChapter.Sections)-1]
			currentSubsection = nil
		case subsectionRe.MatchString(line):
			if currentArticle != nil {
				if currentSubsection != nil {
					currentSubsection.Articles = append(currentSubsection.Articles, *currentArticle)
				} else if currentSection != nil {
					currentSection.Articles = append(currentSection.Articles, *currentArticle)
				}
				currentArticle = nil
			}
			articleOrder = 0
			subsectionOrder++
                        sub := CodeSection{ID: fmt.Sprintf("book_%d_title_%d_ch_%d_sec_%d_sub_%d", bookOrder, titleOrder, chapterOrder, sectionOrder, subsectionOrder), Title: line, Order: subsectionOrder, Subsections: []CodeSection{}, Articles: []Article{}}
			if currentSection == nil {
				// create a default section
				sectionOrder++
				if currentChapter == nil {
					chapterOrder++
					if currentTitle == nil {
						titleOrder++
						if currentBook == nil {
							bookOrder++
							code.Books = append(code.Books, Book{ID: fmt.Sprintf("book_%d", bookOrder), Title: "Intro", Order: bookOrder})
							currentBook = &code.Books[len(code.Books)-1]
						}
						currentBook.Titles = append(currentBook.Titles, CodeTitle{ID: fmt.Sprintf("book_%d_title_%d", bookOrder, titleOrder), Title: "Untitled", Order: titleOrder})
						currentTitle = &currentBook.Titles[len(currentBook.Titles)-1]
					}
					currentTitle.Chapters = append(currentTitle.Chapters, Chapter{ID: fmt.Sprintf("book_%d_title_%d_ch_%d", bookOrder, titleOrder, chapterOrder), Title: "Unnamed", Order: chapterOrder})
					currentChapter = &currentTitle.Chapters[len(currentTitle.Chapters)-1]
				}
                                sec := CodeSection{ID: fmt.Sprintf("book_%d_title_%d_ch_%d_sec_%d", bookOrder, titleOrder, chapterOrder, sectionOrder), Title: "Uncategorized", Order: sectionOrder, Subsections: []CodeSection{}, Articles: []Article{}}
				currentChapter.Sections = append(currentChapter.Sections, sec)
				currentSection = &currentChapter.Sections[len(currentChapter.Sections)-1]
			}
			currentSection.Subsections = append(currentSection.Subsections, sub)
			currentSubsection = &currentSection.Subsections[len(currentSection.Subsections)-1]
		case articleRe.MatchString(line):
			if currentArticle != nil {
				if currentSubsection != nil {
					currentSubsection.Articles = append(currentSubsection.Articles, *currentArticle)
				} else if currentSection != nil {
					currentSection.Articles = append(currentSection.Articles, *currentArticle)
				}
			}
			if currentSubsection == nil && currentSection == nil {
				// create a default section if none exists
				sectionOrder++
				if currentChapter == nil {
					// ensure we have a chapter
					chapterOrder++
					if currentTitle == nil {
						// ensure we have a title and book
						titleOrder++
						if currentBook == nil {
							bookOrder++
							code.Books = append(code.Books, Book{ID: fmt.Sprintf("book_%d", bookOrder), Title: "Intro", Order: bookOrder})
							currentBook = &code.Books[len(code.Books)-1]
						}
						currentBook.Titles = append(currentBook.Titles, CodeTitle{ID: fmt.Sprintf("book_%d_title_%d", bookOrder, titleOrder), Title: "Untitled", Order: titleOrder})
						currentTitle = &currentBook.Titles[len(currentBook.Titles)-1]
					}
					currentTitle.Chapters = append(currentTitle.Chapters, Chapter{ID: fmt.Sprintf("book_%d_title_%d_ch_%d", bookOrder, titleOrder, chapterOrder), Title: "Unnamed", Order: chapterOrder})
					currentChapter = &currentTitle.Chapters[len(currentTitle.Chapters)-1]
				}
                                sec := CodeSection{ID: fmt.Sprintf("book_%d_title_%d_ch_%d_sec_%d", bookOrder, titleOrder, chapterOrder, sectionOrder), Title: "Uncategorized", Order: sectionOrder, Subsections: []CodeSection{}, Articles: []Article{}}
				currentChapter.Sections = append(currentChapter.Sections, sec)
				currentSection = &currentChapter.Sections[len(currentChapter.Sections)-1]
			}
			articleOrder++
			matches := articleRe.FindStringSubmatch(line)
			num := ""
			if len(matches) > 1 {
				num = matches[1]
			}
			if currentSubsection != nil {
				currentArticle = &Article{ID: fmt.Sprintf("book_%d_title_%d_ch_%d_sec_%d_sub_%d_art_%d", bookOrder, titleOrder, chapterOrder, sectionOrder, subsectionOrder, articleOrder), Number: num, Order: articleOrder}
			} else {
				currentArticle = &Article{ID: fmt.Sprintf("book_%d_title_%d_ch_%d_sec_%d_art_%d", bookOrder, titleOrder, chapterOrder, sectionOrder, articleOrder), Number: num, Order: articleOrder}
			}
			expectTitle = true
		default:
			if currentArticle != nil {
				if noteRe.MatchString(line) {
					currentArticle.Notes = append(currentArticle.Notes, line)
				} else if refRe.MatchString(strings.ToLower(line)) || strings.HasPrefix(line, "(") {
					currentArticle.References = append(currentArticle.References, line)
				} else if expectTitle {
					currentArticle.Title = line
					expectTitle = false
				} else {
					if currentArticle.Content != "" {
						currentArticle.Content += "\n" + line
					} else {
						currentArticle.Content = line
					}
				}
			}
		}
	}

	if currentArticle != nil {
		if currentSubsection != nil {
			currentSubsection.Articles = append(currentSubsection.Articles, *currentArticle)
		} else if currentSection != nil {
			currentSection.Articles = append(currentSection.Articles, *currentArticle)
		}
	}

	// gather all articles into code.Articles and count
	var all []Article
	for i := range code.Books {
		for j := range code.Books[i].Titles {
			for k := range code.Books[i].Titles[j].Chapters {
				for l := range code.Books[i].Titles[j].Chapters[k].Sections {
					sec := code.Books[i].Titles[j].Chapters[k].Sections[l]
					all = append(all, sec.Articles...)
					for m := range sec.Subsections {
						all = append(all, sec.Subsections[m].Articles...)
					}
				}
			}
		}
	}
	code.TotalArticles = len(all)
	code.Articles = all
	return code, nil
}
