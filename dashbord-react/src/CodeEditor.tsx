import React, { useEffect, useState } from 'react';

interface Article {
  id: string;
  number: string;
  title: string;
  content: string;
  notes: string[];
  references: string[];
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

const codes = [
  { id: 'civil', label: 'Codul Civil' },
  { id: 'penal', label: 'Codul Penal' },
  { id: 'proc_civil', label: 'Codul de Procedură Civilă' },
  { id: 'proc_penal', label: 'Codul de Procedură Penală' },
];

export default function CodeEditor() {
  const [selected, setSelected] = useState<string>('civil');
  const [code, setCode] = useState<ParsedCode | null>(null);
  const [mode, setMode] = useState<'form' | 'json'>('form');
  const [json, setJson] = useState('');

  useEffect(() => {
    fetch(`/api/codes/${selected}`)
      .then(r => r.json())
      .then((data: ParsedCode) => {
        setCode(data);
        setJson(JSON.stringify(data, null, 2));
      });
  }, [selected]);

  const updateArticle = (id: string, field: keyof Article, value: string) => {
    if (!code) return;
    const copy = { ...code };
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
    for (const b of copy.books) {
      for (const t of b.titles) {
        for (const ch of t.chapters) {
          if (walkSections(ch.sections)) {
            setCode(copy);
            setJson(JSON.stringify(copy, null, 2));
            return;
          }
        }
      }
    }
  };

  const save = () => {
    if (!code) return;
    fetch(`/api/save-code/${selected}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(code),
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

  return (
    <div className="p-4 space-y-4">
      <div className="space-x-2">
        {codes.map(c => (
          <button
            key={c.id}
            className={`px-3 py-1 rounded border ${selected === c.id ? 'bg-blue-600 text-white' : ''}`}
            onClick={() => setSelected(c.id)}
          >
            {c.label}
          </button>
        ))}
        <button
          className="ml-4 px-3 py-1 border rounded"
          onClick={() => setMode(mode === 'form' ? 'json' : 'form')}
        >
          {mode === 'form' ? 'JSON' : 'Form'}
        </button>
      </div>
      {mode === 'json' ? (
        <textarea
          className="w-full h-96 border p-2 font-mono text-sm"
          value={json}
          onChange={e => setJson(e.target.value)}
        />
      ) : (
        <div className="space-y-2">
          {code && code.books.map(b => renderBook(b))}
        </div>
      )}
      <button className="px-4 py-2 bg-blue-600 text-white rounded" onClick={save}>
        Save
      </button>
    </div>
  );
}
