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

const codes = [
  { id: 'civil', label: 'Codul Civil' },
  { id: 'penal', label: 'Codul Penal' },
  { id: 'proc_civil', label: 'Codul de Procedură Civilă' },
  { id: 'proc_penal', label: 'Codul de Procedură Penală' },
];

export default function CodeEditor() {
  const [selected, setSelected] = useState<string>('civil');
  const [code, setCode] = useState<ParsedCode | null>(null);
  const [text, setText] = useState('');

  useEffect(() => {
    fetch(`/api/codes/${selected}`)
      .then((r) => r.json())
      .then((data) => {
        setCode(data);
        setText(JSON.stringify(data, null, 2));
      });
  }, [selected]);

  const save = () => {
    try {
      const parsed = JSON.parse(text);
      setCode(parsed);
      fetch(`/api/save-code/${selected}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(parsed),
      });
    } catch (e) {
      alert('Invalid JSON');
    }
  };

  return (
    <div className="p-4 space-y-4">
      <div className="space-x-2">
        {codes.map((c) => (
          <button
            key={c.id}
            className={`px-3 py-1 rounded border ${selected === c.id ? 'bg-blue-600 text-white' : ''}`}
            onClick={() => setSelected(c.id)}
          >
            {c.label}
          </button>
        ))}
      </div>
      <textarea
        className="w-full h-96 border p-2 font-mono text-sm"
        value={text}
        onChange={(e) => setText(e.target.value)}
      ></textarea>
      <button className="px-4 py-2 bg-blue-600 text-white rounded" onClick={save}>
        Save
      </button>
    </div>
  );
}
