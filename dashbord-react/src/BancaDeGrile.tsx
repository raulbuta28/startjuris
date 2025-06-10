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
        <div key={name} className="mt-4 space-y-2">
          <h4 className="font-semibold">{name}</h4>
          {gtests.map((t) => (
            <div key={t.id} className="pl-4 space-y-2">
              {t.questions.map((q, qi) => (
                <div key={qi} className="border-t pt-2 space-y-1">
                  <p className="font-bold leading-tight">
                    {qi + 1}. {q.text}
                  </p>
                  {q.answers.map((a, ai) => (
                    <p key={ai} className="pl-4 leading-tight">
                      {String.fromCharCode(65 + ai)}. {a}
                    </p>
                  ))}
                  <p className="text-sm italic">
                    Răspuns corect:{" "}
                    {q.correct
                      .map((c) => String.fromCharCode(65 + c))
                      .join(", ")}
                    {q.note && (
                      <span className="ml-2 text-xs text-gray-600">
                        Nota: {q.note}
                      </span>
                    )}
                  </p>
                  {q.explanation && (
                    <div className="text-sm space-y-1">
                      <p className="font-medium">Explicație:</p>
                      {q.explanation
                        .split(/\n+/)
                        .filter((p) => p.trim())
                        .map((p, i) => (
                          <p key={i} className="indent-4">
                            {p}
                          </p>
                        ))}
                    </div>
                  )}
                </div>
              ))}
            </div>
          ))}
        </div>
      ))}
    </div>
  );
}
