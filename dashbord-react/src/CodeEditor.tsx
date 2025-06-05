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
  const [active, setActive] = useState('');

  useEffect(() => {
    fetch('/api/codes')
      .then((r) => r.json())
      .then((list: Code[]) => {
        setCodes(list);
        if (list.length > 0) {
          setActive(list[0].id);
          list.forEach((c) => {
            fetch(`/api/codes/${c.id}`)
              .then((r) => r.json())
              .then((d) => {
                setCodes((prev) =>
                  prev.map((x) =>
                    x.id === c.id ? { ...x, content: d.content } : x
                  )
                );
              });
          });
        }
      })
      .finally(() => setLoading(false));
  }, []);

  const activeCode = codes.find((c) => c.id === active);

  const updateActive = (value: string) => {
    setCodes((prev) =>
      prev.map((c) => (c.id === active ? { ...c, content: value } : c))
    );
  };

  const saveActive = () => {
    const code = codes.find((c) => c.id === active);
    if (!code) return;
    fetch(`/api/save-code/${code.id}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(code),
    });
  };

  if (loading) return <div>Loading...</div>;

  return (
    <div>
      <div className="border-b mb-4 space-x-2">
        {codes.map((c) => (
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
      {activeCode && (
        <div className="bg-white shadow p-4 rounded">
          <textarea
            className="w-full border p-2 h-96"
            value={activeCode.content || ''}
            onChange={(e) => updateActive(e.target.value)}
          />
          <button
            className="mt-2 px-3 py-1 bg-blue-600 text-white rounded"
            onClick={saveActive}
          >
            Save
          </button>
        </div>
      )}
    </div>
  );
}
