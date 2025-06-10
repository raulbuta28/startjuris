import React, { useEffect, useState } from 'react';
import { Button } from '@/components/ui/button';

interface Question {
  text: string;
  answers: string[];
  correct: number[];
  note: string;
  explanation?: string;
}

interface Test {
  id: string;
  name: string;
  subject: string;
  questions: Question[];
}

const subjects = [
  { id: 'civil', label: 'Drept civil' },
  { id: 'dpc', label: 'Drept procesual civil' },
  { id: 'penal', label: 'Drept penal' },
  { id: 'dpp', label: 'Drept procesual penal' },
];

export default function BancaDeGrile() {
  const [tests, setTests] = useState<Test[]>([]);
  const [active, setActive] = useState(subjects[0].id);
  const [query, setQuery] = useState('');

  useEffect(() => {
    const token = localStorage.getItem('token') || '';
    fetch('/api/tests', { headers: { Authorization: `Bearer ${token}` } })
      .then((r) => (r.ok ? r.json() : []))
      .then(setTests)
      .catch(() => {});
  }, []);

  const filtered = tests.filter(
    (t) =>
      t.subject === subjects.find((s) => s.id === active)?.label &&
      (t.name.toLowerCase().includes(query.toLowerCase()) ||
        t.questions.some((q) => q.text.toLowerCase().includes(query.toLowerCase())))
  );

  const grouped: Record<string, Test[]> = {};
  for (const t of filtered) {
    grouped[t.name] = grouped[t.name] ? [...grouped[t.name], t] : [t];
  }

  return (
    <div className="space-y-4">
      <div className="border-b space-x-2 mb-4">
        {subjects.map((s) => (
          <Button
            key={s.id}
            variant={active === s.id ? 'default' : 'secondary'}
            onClick={() => setActive(s.id)}
          >
            {s.label}
          </Button>
        ))}
      </div>
      <input
        className="border p-2 rounded w-full"
        placeholder="Caută grile..."
        value={query}
        onChange={(e) => setQuery(e.target.value)}
      />
      {Object.entries(grouped).map(([name, gtests]) => (
        <div key={name} className="mt-4">
          <h4 className="font-semibold">{name}</h4>
          <ul className="pl-4 list-disc">
            {gtests.map((t) => (
              <li key={t.id}>{t.questions.length} grile</li>
            ))}
          </ul>
        </div>
      ))}
    </div>
  );
}
