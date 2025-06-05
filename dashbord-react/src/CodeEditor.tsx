import React, { useEffect, useState } from 'react';

interface Article {
  id: string;
  number: string;
  title: string;
  content: string;
}

interface CodeSection {
  id: string;
  title: string;
  subsections: CodeSection[];
  articles: Article[];
}

interface Chapter {
  id: string;
  title: string;
  sections: CodeSection[];
}

interface CodeTitle {
  id: string;
  title: string;
  chapters: Chapter[];
}

interface Book {
  id: string;
  title: string;
  titles: CodeTitle[];
}

interface ParsedCode {
  id: string;
  title: string;
  books: Book[];
}

interface CodeInfo {
  id: string;
  title: string;
  lastUpdated: string;
}

export default function CodeEditor() {
  const [codes, setCodes] = useState<CodeInfo[]>([]);
  const [active, setActive] = useState('');
  const [structure, setStructure] = useState<ParsedCode | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch('/api/codes')
      .then(r => r.json())
      .then((list: CodeInfo[]) => {
        setCodes(list);
        if (list.length > 0) {
          setActive(list[0].id);
        }
      });
  }, []);

  useEffect(() => {
    if (!active) return;
    setLoading(true);
    fetch(`/api/parsed-code/${active}`)
      .then(r => r.json())
      .then((d: ParsedCode) => setStructure(d))
      .finally(() => setLoading(false));
  }, [active]);

  const updateArticle = (id: string, field: keyof Article, value: string) => {
    if (!structure) return;
    const walkSections = (secs: CodeSection[]) => {
      for (const s of secs) {
        for (const a of s.articles) {
          if (a.id === id) {
            (a as any)[field] = value;
            return true;
          }
        }
        if (walkSections(s.subsections)) return true;
      }
      return false;
    };
    for (const b of structure.books) {
      for (const t of b.titles) {
        for (const ch of t.chapters) {
          if (walkSections(ch.sections)) {
            setStructure({ ...structure });
            return;
          }
        }
      }
    }
  };

  const save = () => {
    if (!structure) return;
    fetch(`/api/save-parsed-code/${structure.id}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(structure),
    });
  };

  const renderArticles = (sec: CodeSection) => (
    <div className="ml-4">
      {sec.articles.map(a => (
        <div key={a.id} className="border p-2 my-2 rounded">
          <div className="flex space-x-2 mb-1">
            <input
              className="border p-1 w-16"
              value={a.number}
              onChange={e => updateArticle(a.id, 'number', e.target.value)}
            />
            <input
              className="border p-1 flex-1"
              value={a.title}
              onChange={e => updateArticle(a.id, 'title', e.target.value)}
            />
          </div>
          <textarea
            className="border p-1 w-full text-sm"
            value={a.content}
            onChange={e => updateArticle(a.id, 'content', e.target.value)}
          />
        </div>
      ))}
      {sec.subsections.map(s => renderSection(s))}
    </div>
  );

  const renderSection = (sec: CodeSection) => (
    <details key={sec.id} className="ml-2">
      <summary className="cursor-pointer font-semibold">{sec.title}</summary>
      {renderArticles(sec)}
    </details>
  );

  const renderChapter = (ch: Chapter) => (
    <details key={ch.id} className="ml-2">
      <summary className="cursor-pointer font-semibold">{ch.title}</summary>
      {ch.sections.map(sec => renderSection(sec))}
    </details>
  );

  const renderTitle = (t: CodeTitle) => (
    <details key={t.id} className="ml-2">
      <summary className="cursor-pointer font-semibold">{t.title}</summary>
      {t.chapters.map(ch => renderChapter(ch))}
    </details>
  );

  const renderBook = (b: Book) => (
    <details key={b.id}>
      <summary className="cursor-pointer font-semibold">{b.title}</summary>
      {b.titles.map(t => renderTitle(t))}
    </details>
  );

  if (!structure) return <div>Loading...</div>;

  return (
    <div className="space-y-4">
      <div className="border-b mb-4 space-x-2">
        {codes.map(c => (
          <button
            key={c.id}
            className={`px-4 py-2 rounded-t ${
              active === c.id ? 'bg-blue-600 text-white' : 'bg-gray-200'
            }`}
            onClick={() => setActive(c.id)}
          >
            {c.title}
          </button>
        ))}
      </div>
      <div className="space-y-2">
        {structure.books.map(b => renderBook(b))}
      </div>
      <button className="px-4 py-2 bg-blue-600 text-white rounded" onClick={save}>
        Save
      </button>
    </div>
  );
}
