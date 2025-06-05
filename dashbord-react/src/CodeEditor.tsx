import React, { useEffect, useState } from 'react';

interface Code {
  id: string;
  title: string;
  content: string;
  lastUpdated: string;
}

export default function CodeEditor() {
  const [codes, setCodes] = useState<Code[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch('/api/codes')
      .then(r => r.json())
      .then(setCodes)
      .finally(() => setLoading(false));
  }, []);

  const update = (idx: number, field: keyof Code, value: string) => {
    const copy = [...codes];
    (copy[idx] as any)[field] = value;
    setCodes(copy);
  };

  const save = (code: Code) => {
    fetch(`/api/save-code/${code.id}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(code),
    });
  };

  if (loading) return <div>Loading...</div>;

  return (
    <div className="space-y-6">
      {codes.map((c, i) => (
        <div key={c.id} className="bg-white shadow p-4 rounded">
          <h3 className="font-semibold mb-2">{c.title}</h3>
          <textarea
            className="w-full border p-2 h-40"
            value={c.content}
            onChange={e => update(i, 'content', e.target.value)}
          />
          <button
            className="mt-2 px-3 py-1 bg-blue-600 text-white rounded"
            onClick={() => save(c)}
          >
            Save
          </button>
        </div>
      ))}
    </div>
  );
}
