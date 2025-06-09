import React, { useState } from "react";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";

interface Tab {
  id: string;
  label: string;
}

const tabs: Tab[] = [
  { id: "creare", label: "Creare grile" },
  { id: "teme", label: "Teme" },
  { id: "suplimentare", label: "Teste suplimentare" },
  { id: "combinate", label: "Teste combinate" },
  { id: "simulari", label: "Simulări" },
  { id: "ani", label: "Grile date în anii anteriori" },
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
  const [input, setInput] = useState("");
  const [tests, setTests] = useState<string[]>([]);
  const [selectedTest, setSelectedTest] = useState("");
  const [showAddTest, setShowAddTest] = useState(false);
  const [newTest, setNewTest] = useState("");
  const [questions, setQuestions] = useState<Question[]>([]);
  const [editingAnswers, setEditingAnswers] = useState<Record<string, string>>(
    {},
  );
  const [editingQuestions, setEditingQuestions] = useState<
    Record<number, string>
  >({});
  const [addingAnswer, setAddingAnswer] = useState<Record<number, string>>({});

  const stripAnswerPrefix = (t: string) => {
    const m = t.trim().match(/^[A-Za-z][.)]\s*(.+)$/);
    return m ? m[1] : t.trim();
  };

  const toggleCorrect = (qi: number, ai: number) => {
    setQuestions((prev) => {
      const copy = [...prev];
      const corr = copy[qi].correct;
      if (corr.includes(ai)) {
        copy[qi].correct = corr.filter((c) => c !== ai);
      } else {
        corr.push(ai);
      }
      return copy;
    });
  };

  const parseInput = (): Question[] => {
    const lines = input.split(/\r?\n/).map((l) => l.trim());

    const questions: Question[] = [];
    let current: Question | null = null;
    const qReg = /^\d+[.)]\s*(.+)$/;
    const aReg = /^[A-Za-z][.)]\s*(.+)$/;

    for (const line of lines) {
      if (!line) continue;

      const qMatch = line.match(qReg);
      if (qMatch) {
        if (current) questions.push(current);
        current = {
          text: qMatch[1],
          answers: [],
          correct: [],
          note: "",
        };
        continue;
      }

      const aMatch = line.match(aReg);
      if (aMatch) {
        if (!current) {
          current = { text: "", answers: [], correct: [], note: "" };
        }
        current.answers.push(aMatch[1]);
        continue;
      }

      if (current) {
        if (current.answers.length === 0) {
          current.text = `${current.text} ${line}`.trim();
        } else {
          const last = current.answers.length - 1;
          current.answers[last] = `${current.answers[last]} ${line}`.trim();
        }
      }
    }

    if (current) questions.push(current);

    return questions.filter((q) => q.text && q.answers.length);
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
      case "creare":
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
                          setNewTest("");
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
                  <div key={qi} className="border-t pt-4 space-y-2">
                    {editingQuestions[qi] !== undefined ? (
                      <div className="flex items-center space-x-2">
                        <input
                          className="border p-1 rounded flex-1"
                          value={editingQuestions[qi]}
                          onChange={(e) =>
                            setEditingQuestions((s) => ({
                              ...s,
                              [qi]: e.target.value,
                            }))
                          }
                        />
                        <Button
                          size="sm"
                          variant="secondary"
                          onClick={() => {
                            setQuestions((prev) => {
                              const copy = [...prev];
                              copy[qi].text = editingQuestions[qi];
                              return copy;
                            });
                            setEditingQuestions((s) => {
                              const { [qi]: _, ...rest } = s;
                              return rest;
                            });
                          }}
                        >
                          Salvează
                        </Button>
                      </div>
                    ) : (
                      <div className="flex items-center space-x-2">
                        <p className="flex-1">
                          {qi + 1}. {q.text}
                        </p>
                        <Button
                          size="sm"
                          variant="ghost"
                          onClick={() =>
                            setEditingQuestions((s) => ({ ...s, [qi]: q.text }))
                          }
                        >
                          Editează întrebarea
                        </Button>
                      </div>
                    )}
                    {q.answers.map((a, ai) => {
                      const key = `${qi}-${ai}`;
                      const isEditing = editingAnswers[key] !== undefined;
                      return (
                        <div
                          key={ai}
                          className={cn(
                            "flex items-center space-x-2 p-2 rounded border",
                            q.correct.includes(ai)
                              ? "border-blue-500"
                              : "border-transparent",
                          )}
                          onClick={() => toggleCorrect(qi, ai)}
                        >
                          <input
                            type="checkbox"
                            checked={q.correct.includes(ai)}
                            onClick={(e) => e.stopPropagation()}
                            onChange={(e) => toggleCorrect(qi, ai)}
                          />
                          {isEditing ? (
                            <>
                              <input
                                className="border p-1 rounded flex-1"
                                value={editingAnswers[key]}
                                onChange={(e) =>
                                  setEditingAnswers((s) => ({
                                    ...s,
                                    [key]: e.target.value,
                                  }))
                                }
                              />
                              <Button
                                size="sm"
                                variant="secondary"
                                onClick={() => {
                                  setQuestions((prev) => {
                                    const copy = [...prev];
                                    copy[qi].answers[ai] = stripAnswerPrefix(
                                      editingAnswers[key],
                                    );
                                    return copy;
                                  });
                                  setEditingAnswers((s) => {
                                    const { [key]: _, ...rest } = s;
                                    return rest;
                                  });
                                }}
                              >
                                Salvează
                              </Button>
                            </>
                          ) : (
                            <>
                              <span className="flex-1">
                                {String.fromCharCode(65 + ai)}. {a}
                              </span>
                              <Button
                                size="sm"
                                variant="ghost"
                                onClick={() =>
                                  setEditingAnswers((s) => ({ ...s, [key]: a }))
                                }
                              >
                                Editează
                              </Button>
                              <Button
                                size="sm"
                                variant="ghost"
                                onClick={() => {
                                  setQuestions((prev) => {
                                    const copy = [...prev];
                                    copy[qi].answers.splice(ai, 1);
                                    copy[qi].correct = copy[qi].correct
                                      .filter((c) => c !== ai)
                                      .map((c) => (c > ai ? c - 1 : c));
                                    return copy;
                                  });
                                }}
                              >
                                Șterge
                              </Button>
                            </>
                          )}
                        </div>
                      );
                    })}
                    {addingAnswer[qi] !== undefined ? (
                      <div className="flex items-center space-x-2 pl-6">
                        <input
                          className="border p-1 rounded flex-1"
                          value={addingAnswer[qi]}
                          onChange={(e) =>
                            setAddingAnswer((s) => ({
                              ...s,
                              [qi]: e.target.value,
                            }))
                          }
                        />
                        <Button
                          size="sm"
                          variant="secondary"
                          onClick={() => {
                            if (addingAnswer[qi].trim()) {
                              setQuestions((prev) => {
                                const copy = [...prev];
                                copy[qi].answers.push(
                                  stripAnswerPrefix(addingAnswer[qi]),
                                );
                                return copy;
                              });
                              setAddingAnswer((s) => {
                                const { [qi]: _, ...rest } = s;
                                return rest;
                              });
                            }
                          }}
                        >
                          Adaugă
                        </Button>
                      </div>
                    ) : (
                      <Button
                        variant="ghost"
                        size="sm"
                        className="ml-6"
                        onClick={() =>
                          setAddingAnswer((s) => ({ ...s, [qi]: "" }))
                        }
                      >
                        + Adaugă răspuns
                      </Button>
                    )}
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
                    <p>
                      {qi + 1}. {q.text}
                    </p>
                    {q.answers.map((a, ai) => (
                      <p key={ai} className="pl-4">
                        {String.fromCharCode(65 + ai)}. {a}
                      </p>
                    ))}
                    <p className="text-sm italic">
                      Răspuns corect:{" "}
                      {q.correct
                        .map((c) => String.fromCharCode(65 + c))
                        .join(", ")}
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
                  <Button variant="outline">
                    Generează explicații la grile
                  </Button>
                </div>
                {questions.map((q, qi) => (
                  <div key={qi} className="border-t pt-4 space-y-1">
                    <p>
                      {qi + 1}. {q.text}
                    </p>
                    {q.answers.map((a, ai) => (
                      <p key={ai} className="pl-4">
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
                  </div>
                ))}
              </div>
            )}
          </div>
        );
      case "teme":
        return <div></div>;
      case "suplimentare":
        return <div></div>;
      case "combinate":
        return <div></div>;
      case "simulari":
        return <div></div>;
      case "ani":
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
            variant={active === t.id ? "default" : "secondary"}
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
