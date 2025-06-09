import React, { useState } from 'react';
import { Button } from '@/components/ui/button';
import { cn } from '@/lib/utils';

interface Tab {
  id: string;
  label: string;
}

const tabs: Tab[] = [
  { id: 'creare', label: 'Creare grile' },
  { id: 'teme', label: 'Teme' },
  { id: 'suplimentare', label: 'Teste suplimentare' },
  { id: 'combinate', label: 'Teste combinate' },
  { id: 'simulari', label: 'Simulări' },
  { id: 'ani', label: 'Grile date în anii anteriori' },
];

type Question = {
  text: string;
  answers: string[];
  correct: number[];
  note: string;
};

export default function Grile() {
  const [active, setActive] = useState<string>(tabs[0].id);
  const [step, setStep] = useState(1);
  const [input, setInput] = useState('');
  const [tests, setTests] = useState<string[]>([]);
  const [selectedTest, setSelectedTest] = useState('');
  const [showAddTest, setShowAddTest] = useState(false);
  const [newTest, setNewTest] = useState('');
  const [questions, setQuestions] = useState<Question[]>([]);

  const parseInput = (): Question[] => {
    return input
      .trim()
      .split(/\n{2,}/)
      .map((block) => {
        const lines = block
          .split(/\n/)
          .map((l) => l.trim())
          .filter((l) => l);
        const text = lines[0] || '';
        const answers = lines.slice(1).map((ans) =>
          ans.replace(/^[A-Za-z][.)]\s*/, '').trim()
        );
        return {
          text,
          answers,
          correct: [],
          note: '',
        } as Question;
      })
      .filter((q) => q.text);
  };

  const generate = () => {
    const qs = parseInput();
    setQuestions(qs);
    if (selectedTest && !tests.includes(selectedTest)) {
      setTests([...tests, selectedTest]);
    }
    setStep(2);
  };

  const renderTab = () => {
    switch (active) {
      case 'creare':
        return (
          <div className="space-y-4">
            {step === 1 && (
              <>
                <textarea
                  className="w-full border rounded p-2 h-96"
                  placeholder="Introdu grile aici..."
                  value={input}
                  onChange={(e) => setInput(e.target.value)}
                />
                <div className="flex items-center space-x-2">
                  <select
                    className="border p-2 rounded flex-1"
                    value={selectedTest}
                    onChange={(e) => setSelectedTest(e.target.value)}
                  >
                    <option value="">Selectează testul</option>
                    {tests.map((t) => (
                      <option key={t} value={t}>
                        {t}
                      </option>
                    ))}
                  </select>
                  <Button
                    variant="secondary"
                    size="sm"
                    onClick={() => setShowAddTest((v) => !v)}
                  >
                    +
                  </Button>
                </div>
                {showAddTest && (
                  <div className="flex items-center space-x-2">
                    <input
                      className="border p-2 rounded flex-1"
                      placeholder="Denumire test"
                      value={newTest}
                      onChange={(e) => setNewTest(e.target.value)}
                    />
                    <Button
                      size="sm"
                      onClick={() => {
                        if (newTest.trim()) {
                          setTests([...tests, newTest]);
                          setSelectedTest(newTest);
                          setNewTest('');
                          setShowAddTest(false);
                        }
                      }}
                    >
                      Adaugă
                    </Button>
                  </div>
                )}
                <Button onClick={generate}>Generează automat</Button>
              </>
            )}

            {step === 2 && (
              <>
                <h3 className="text-lg font-semibold">{selectedTest}</h3>
                {questions.map((q, qi) => (
                  <div key={qi} className="border-t pt-4 space-y-1">
                    <p>{q.text}</p>
                    {q.answers.map((a, ai) => (
                      <label
                        key={ai}
                        className={cn(
                          'flex items-center space-x-2 p-2 rounded border',
                          q.correct.includes(ai)
                            ? 'border-blue-500'
                            : 'border-transparent'
                        )}
                      >
                        <input
                          type="checkbox"
                          checked={q.correct.includes(ai)}
                          onChange={(e) => {
                            setQuestions((prev) => {
                              const copy = [...prev];
                              const corr = copy[qi].correct;
                              if (e.target.checked) {
                                if (!corr.includes(ai)) {
                                  corr.push(ai);
                                }
                              } else {
                                copy[qi].correct = corr.filter((c) => c !== ai);
                              }
                              return copy;
                            });
                          }}
                        />
                        <span>{String.fromCharCode(65 + ai)}. {a}</span>
                      </label>
                    ))}
                  </div>
                ))}
                <div className="text-right">
                  <Button onClick={() => setStep(3)}>Mai departe</Button>
                </div>
              </>
            )}

            {step === 3 && (
              <>
                <h3 className="text-lg font-semibold">{selectedTest}</h3>
                {questions.map((q, qi) => (
                  <div key={qi} className="border-t pt-4 space-y-2">
                    <p>{q.text}</p>
                    {q.answers.map((a, ai) => (
                      <p key={ai} className="pl-4">
                        {String.fromCharCode(65 + ai)}. {a}
                      </p>
                    ))}
                    <p className="text-sm italic">
                      Răspuns corect: {q.correct.map((c) => String.fromCharCode(65 + c)).join(', ')}
                    </p>
                    <textarea
                      className="w-full border rounded p-2"
                      placeholder="Nota"
                      value={q.note}
                      onChange={(e) => {
                        const val = e.target.value;
                        setQuestions((prev) => {
                          const copy = [...prev];
                          copy[qi].note = val;
                          return copy;
                        });
                      }}
                    />
                  </div>
                ))}
                <div className="text-right">
                  <Button onClick={() => setStep(4)}>Mai departe</Button>
                </div>
              </>
            )}

            {step === 4 && (
              <div className="space-y-4">
                <div className="flex justify-between items-start">
                  <h3 className="text-lg font-semibold">{selectedTest}</h3>
                  <Button variant="outline">Generează explicații la grile</Button>
                </div>
                {questions.map((q, qi) => (
                  <div key={qi} className="border-t pt-4 space-y-1">
                    <p>{q.text}</p>
                    {q.answers.map((a, ai) => (
                      <p key={ai} className="pl-4">
                        {String.fromCharCode(65 + ai)}. {a}
                      </p>
                    ))}
                    <p className="text-sm italic">
                      Răspuns corect: {q.correct.map((c) => String.fromCharCode(65 + c)).join(', ')}
                      {q.note && (
                        <span className="ml-2 text-xs text-gray-600">Nota: {q.note}</span>
                      )}
                    </p>
                  </div>
                ))}
              </div>
            )}
          </div>
        );
      case 'teme':
        return <div></div>;
      case 'suplimentare':
        return <div></div>;
      case 'combinate':
        return <div></div>;
      case 'simulari':
        return <div></div>;
      case 'ani':
        return <div></div>;
      default:
        return null;
    }
  };

  return (
    <div className="space-y-4">
      <div className="border-b mb-4 space-x-2">
        {tabs.map((t) => (
          <Button
            key={t.id}
            variant={active === t.id ? 'default' : 'secondary'}
            onClick={() => setActive(t.id)}
          >
            {t.label}
          </Button>
        ))}
      </div>
      {renderTab()}
    </div>
  );
}
