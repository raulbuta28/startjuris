import React, { useState } from 'react';
import { Button } from '@/components/ui/button';

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

export default function Grile() {
  const [active, setActive] = useState<string>(tabs[0].id);
  const [input, setInput] = useState('');
  const [tests, setTests] = useState<string[]>([]);
  const [selectedTest, setSelectedTest] = useState('');
  const [showAddTest, setShowAddTest] = useState(false);
  const [newTest, setNewTest] = useState('');
  const [questions, setQuestions] = useState<string[]>([]);
  const generate = () => {
    const qs = input
      .trim()
      .split(/\n{2,}/)
      .map((q) => q.trim())
      .filter((q) => q);
    setQuestions(qs);
    if (selectedTest && !tests.includes(selectedTest)) {
      setTests([...tests, selectedTest]);
    }
  };

  const renderTab = () => {
    switch (active) {
      case 'creare':
        return (
          <div className="space-y-4">
            <textarea
              className="w-full border rounded p-2 h-40"
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
            <Button onClick={generate}>Generare</Button>
            {questions.length > 0 && (
              <div className="space-y-4 mt-4">
                <h3 className="text-lg font-semibold">{selectedTest}</h3>
                {questions.map((q, i) => (
                  <div key={i} className="border-t pt-4">
                    {q.split('\n').map((l, idx) => (
                      <p key={idx}>{l}</p>
                    ))}
                  </div>
                ))}
                <div className="text-right">
                  <Button variant="outline">Generează explicații</Button>
                </div>
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
