import React, { useEffect, useState } from 'react';
import { Button } from '@/components/ui/button';

interface CodeTab {
  id: string;
  label: string;
}

const codes: CodeTab[] = [
  { id: 'civil', label: 'Codul civil' },
  { id: 'penal', label: 'Codul penal' },
  { id: 'proc_civil', label: 'Codul de procedura civila' },
  { id: 'proc_penal', label: 'Codul de procedura penala' },
];

export default function CodeTextTabs() {
  const [active, setActive] = useState<string>(codes[0].id);
  const [texts, setTexts] = useState<Record<string, string>>({});
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    if (texts[active]) return;
    setLoading(true);
    setError('');
    fetch(`/api/code-text/${active}`)
      .then(async (r) => {
        if (!r.ok) throw new Error('Failed to load');
        return r.text();
      })
      .then((txt) => {
        setTexts((t) => ({ ...t, [active]: txt }));
      })
      .catch((err: any) => {
        setError(err.message || 'Error');
      })
      .finally(() => setLoading(false));
  }, [active]);

  return (
    <div className="space-y-4">
      <div className="border-b mb-4 space-x-2">
        {codes.map((c) => (
          <Button
            key={c.id}
            variant={active === c.id ? 'default' : 'secondary'}
            onClick={() => setActive(c.id)}
          >
            {c.label}
          </Button>
        ))}
      </div>
      {loading ? (
        <div>Loading...</div>
      ) : error ? (
        <div className="text-red-600">{error}</div>
      ) : (
        <pre className="whitespace-pre-wrap text-sm">{texts[active]}</pre>
      )}
    </div>
  );
}
