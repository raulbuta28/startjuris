import React, { useState, useEffect } from "react";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { explainQuestion, generateGrila } from "@/lib/agent";

interface Tab {
  id: string;
  label: string;
}

interface Test {
  id: string;
  name: string;
  subject: string;
  questions: Question[];
}

const tabs: Tab[] = [
  { id: "creare", label: "Creare grile" },
  { id: "teme", label: "Teme" },
  { id: "suplimentare", label: "Teste suplimentare" },
  { id: "combinate", label: "Teste combinate" },
  { id: "simulari", label: "Simulări" },
  { id: "ani", label: "Grile date în anii anteriori" },
  { id: "generator", label: "Generator" },
];

const subjects = [
  "Drept civil",
  "Drept procesual civil",
  "Drept penal",
  "Drept procesual penal",
];

type Question = {
  text: string;
  answers: string[];
  correct: number[];
  note: string;
  explanation?: string;
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
  const [editingAnswers, setEditingAnswers] = useState<Record<string, string>>({});
  const [editingQuestions, setEditingQuestions] = useState<Record<number, string>>({});
  const [editingExplanations, setEditingExplanations] = useState<Record<number, string>>({});
  const [addingAnswer, setAddingAnswer] = useState<Record<number, string>>({});
  const [selectedSubject, setSelectedSubject] = useState("");
  const [savedTests, setSavedTests] = useState<Test[]>([]);
  const [testsLoaded, setTestsLoaded] = useState(false);
  const [selectedTestId, setSelectedTestId] = useState<string | null>(null);
  const [editingTest, setEditingTest] = useState<Test | null>(null);
  const [loadingExp, setLoadingExp] = useState<Record<number, boolean>>({});
  const [generatePrompt, setGeneratePrompt] = useState('');
  const [loadingGenerate, setLoadingGenerate] = useState(false);
  const [generateTestId, setGenerateTestId] = useState('');

  // Generator manual states
  const [manualQuestion, setManualQuestion] = useState('');
  const [manualAnswers, setManualAnswers] = useState<string[]>(['', '', '']);
  const [manualCorrect, setManualCorrect] = useState('');
  const [manualExplanation, setManualExplanation] = useState('');
  const [manualTestId, setManualTestId] = useState('');

  useEffect(() => {
    const token = localStorage.getItem('token') || '';
    fetch('/api/tests', { headers: { Authorization: `Bearer ${token}` } })
      .then((r) => (r.ok ? r.json() : Promise.reject()))
      .then((data) => {
        setSavedTests(data);
        setTests(Array.from(new Set(data.map((t: Test) => t.name))));
        setTestsLoaded(true);
      })
      .catch(() => {
        const stored = localStorage.getItem('savedTests');
        if (stored) {
          try {
            const parsed = JSON.parse(stored);
            setSavedTests(parsed);
            setTests(Array.from(new Set(parsed.map((t: Test) => t.name))));
          } catch {
            /* ignore */
          }
        }
        setTestsLoaded(true);
      });
  }, []);

  useEffect(() => {
    if (!testsLoaded) return;
    localStorage.setItem('savedTests', JSON.stringify(savedTests));
    fetch('/api/save-tests', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${localStorage.getItem('token') || ''}`,
      },
      body: JSON.stringify(savedTests),
    }).catch(() => {});
  }, [savedTests, testsLoaded]);

  useEffect(() => {
    if (!testsLoaded) return;
    setTests((prev) => {
      const names = savedTests.map((t) => t.name);
      const unique = Array.from(new Set([...prev, ...names]));
      return unique.length === prev.length ? prev : unique;
    });
  }, [savedTests, testsLoaded]);

  const stripAnswerPrefix = (t: string) => {
    const m = t.trim().match(/^[A-Za-z][.)]\s*(.+)$/);
    return m ? m[1] : t.trim();
  };

  const lettersToIndexes = (letters: string): number[] =>
    letters
      .toUpperCase()
      .replace(/[^A-Z]/g, ' ')
      .split(/\s+/)
      .filter((l) => l)
      .map((l) => l.charCodeAt(0) - 65);

  const updateQuestionsState = (
    updater: (prev: Question[]) => Question[],
    isEditing: boolean = false
  ) => {
    if (isEditing && editingTest) {
      setEditingTest((prev) => {
        if (!prev) return prev;
        const questions = updater(prev.questions);
        return { ...prev, questions };
      });
    } else {
      setQuestions(updater);
    }
  };

  const toggleCorrect = (qi: number, ai: number, isEditing = false) => {
    updateQuestionsState((prev) => {
      const copy = [...prev];
      const question = { ...copy[qi] };
      const corr = [...question.correct];
      if (corr.includes(ai)) {
        question.correct = corr.filter((c) => c !== ai);
      } else {
        question.correct = [...corr, ai];
      }
      copy[qi] = question;
      console.log(`Toggled answer ${ai} for question ${qi}:`, question.correct);
      return copy;
    }, isEditing);
  };

  const parseInput = (): Question[] => {
    const lines = input.split(/\r?\n/).map((l) => l.trim());
    const questions: Question[] = [];
    let current: Question | null = null;
    const qReg = /^(?:\d+[.)]|[IiÎî]ntrebare)\s*[:.)]?\s*(.+)$/;
    const aReg = /^(?:R(?:ă|a)spuns\s+)?([A-Za-z])[.)]\s*(.+)$/;
    const correctReg = /^R(?:ă|a)spuns(?:uri)?\s+corect[e]?[:]?\s*(.+)$/i;

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
        current.answers.push(aMatch[2] || aMatch[1]);
        continue;
      }

      const corrMatch = line.match(correctReg);
      if (corrMatch && current) {
        const letters = corrMatch[1]
          .toUpperCase()
          .replace(/[^A-Z]/g, " ")
          .split(/\s+/)
          .filter((l) => l);
        current.correct = letters
          .map((l) => l.charCodeAt(0) - 65)
          .filter((i) => i >= 0 && i < current.answers.length);
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

  const deleteAnswer = (qi: number, ai: number, isEditing = false) => {
    updateQuestionsState((prev) => {
      const copy = [...prev];
      copy[qi].answers.splice(ai, 1);
      copy[qi].correct = copy[qi].correct
        .filter((c) => c !== ai)
        .map((c) => (c > ai ? c - 1 : c));
      return copy;
    }, isEditing);
  };

  const deleteQuestion = (qi: number, isEditing = false) => {
    updateQuestionsState((prev) => {
      const copy = [...prev];
      copy.splice(qi, 1);
      return copy;
    }, isEditing);
  };

  const moveQuestion = (qi: number, dir: number, isEditing = false) => {
    updateQuestionsState((prev) => {
      const copy = [...prev];
      const ni = qi + dir;
      if (ni < 0 || ni >= copy.length) return copy;
      const tmp = copy[qi];
      copy[qi] = copy[ni];
      copy[ni] = tmp;
      return copy;
    }, isEditing);
  };

  const addQuestion = (isEditing = false) => {
    const newQ: Question = { text: "", answers: [], correct: [], note: "", explanation: "" };
    updateQuestionsState((prev) => [...prev, newQ], isEditing);
    setEditingQuestions((s) => ({
      ...s,
      [isEditing && editingTest ? editingTest.questions.length : questions.length]: "",
    }));
  };

  const generateExplanation = async (qi: number, isEditing = false) => {
    setLoadingExp((s) => ({ ...s, [qi]: true }));
    try {
      const targetQuestions = isEditing && editingTest ? editingTest.questions : questions;
      const exp = await explainQuestion(targetQuestions[qi]);
      if (isEditing && editingTest) {
        setEditingTest((prev) => {
          if (!prev) return prev;
          const copy = { ...prev, questions: [...prev.questions] };
          copy.questions[qi].explanation = exp;
          return copy;
        });
      } else {
        setQuestions((prev) => {
          const copy = [...prev];
          copy[qi].explanation = exp;
          return copy;
        });
      }
    } catch (err) {
      console.error(err);
      alert("Eroare la generarea explicației");
    } finally {
      setLoadingExp((s) => ({ ...s, [qi]: false }));
    }
  };

  const generateNewQuestion = async () => {
    if (!generateTestId || !generatePrompt.trim()) return;
    setLoadingGenerate(true);
    try {
      const q = await generateGrila(generatePrompt.trim());
      const newQ: Question = {
        text: q.text,
        answers: q.answers,
        correct: q.correct,
        note: '',
        explanation: q.explanation,
      };
      setSavedTests((prev) =>
        prev.map((t) =>
          t.id === generateTestId ? { ...t, questions: [...t.questions, newQ] } : t
        )
      );
      setGeneratePrompt('');
      setGenerateTestId('');
    } catch (err) {
      console.error(err);
      alert('Eroare la generarea grilei');
    } finally {
      setLoadingGenerate(false);
    }
  };

  const addManualQuestion = () => {
    if (!manualTestId || !manualQuestion.trim() || manualAnswers.every((a) => !a.trim())) return;
    const correct = lettersToIndexes(manualCorrect);
    const newQ: Question = {
      text: manualQuestion.trim(),
      answers: manualAnswers.map((a) => a.trim()).filter((a) => a),
      correct,
      note: '',
      explanation: manualExplanation.trim(),
    };
    setSavedTests((prev) =>
      prev.map((t) => (t.id === manualTestId ? { ...t, questions: [...t.questions, newQ] } : t))
    );
    setManualQuestion('');
    setManualAnswers(['', '', '']);
    setManualCorrect('');
    setManualExplanation('');
    setManualTestId('');
  };

  const publishTest = () => {
    if (!selectedSubject || !selectedTest) return;

    const test: Test = {
      id: Date.now().toString(),
      name: selectedTest,
      subject: selectedSubject,
      questions: questions.map((q) => ({ ...q })),
    };

    setSavedTests((prev) => [...prev, test]);
    setTests((prev) => Array.from(new Set([...prev, selectedTest])));
    setSelectedSubject("");
    setSelectedTest("");
    setQuestions([]);
    setStep(1);
    setActive("teme");
  };

  const updateTest = () => {
    if (!editingTest) return;

    setSavedTests((prev) =>
      prev.map((t) => (t.id === editingTest.id ? editingTest : t))
    );
    setEditingTest(null);
  };

  const deleteTest = (id: string) => {
    if (!window.confirm('Sigur dorești să ștergi testul?')) return;
    const updated = savedTests.filter((t) => t.id !== id);
    setSavedTests(updated);
    setTests(Array.from(new Set(updated.map((t) => t.name))));
    if (selectedTestId === id) setSelectedTestId(null);
    if (editingTest && editingTest.id === id) setEditingTest(null);
    fetch('/api/save-tests', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${localStorage.getItem('token') || ''}`,
      },
      body: JSON.stringify(updated),
    }).catch(() => {});
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
                <Button onClick={generate}>Generează</Button>
              </>
            )}
            {step === 2 && (
              <>
                <h3 className="text-lg font-semibold">{selectedTest}</h3>
                {(editingTest ? editingTest.questions : questions).map((q, qi) => (
                  <div key={qi} className="border-t pt-4 space-y-1">
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
                            updateQuestionsState((prev) => {
                              const copy = [...prev];
                              copy[qi].text = editingQuestions[qi].trim() || copy[qi].text;
                              return copy;
                            }, !!editingTest);
                            setEditingQuestions({});
                          }}
                        >
                          Salvează
                        </Button>
                      </div>
                    ) : (
                      <div className="flex items-center space-x-2">
                        <p className="flex-1 font-bold leading-tight">
                          {qi + 1}. {q.text}
                        </p>
                        <Button
                          size="sm"
                          variant="ghost"
                          onClick={() =>
                            setEditingQuestions((s) => ({ ...s, [qi]: q.text }))
                          }
                        >
                          Editează
                        </Button>
                      </div>
                    )}
                    {q.answers.map((a, ai) => {
                      const key = `${qi}-${ai}`;
                      const isEditing = editingAnswers[key] !== undefined;
                      return (
                        <div
                          key={`${key}-${q.correct.includes(ai)}`}
                          className={cn(
                            "flex items-center space-x-2 p-2 rounded border",
                            q.correct.includes(ai)
                              ? "border-blue-500 bg-blue-100"
                              : "border-transparent",
                          )}
                        >
                          <input
                            type="checkbox"
                            checked={q.correct.includes(ai)}
                            onChange={() => toggleCorrect(qi, ai, !!editingTest)}
                            className="mr-2"
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
                                  updateQuestionsState((prev) => {
                                    const copy = [...prev];
                                    copy[qi].answers[ai] = stripAnswerPrefix(
                                      editingAnswers[key].trim() || a
                                    );
                                    return copy;
                                  }, !!editingTest);
                                  setEditingAnswers({});
                                }}
                              >
                                Salvează
                              </Button>
                            </>
                          ) : (
                            <>
                              <span
                                className="flex-1 cursor-pointer"
                                onClick={() => toggleCorrect(qi, ai, !!editingTest)}
                              >
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
                                onClick={() => deleteAnswer(qi, ai, !!editingTest)}
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
                              updateQuestionsState((prev) => {
                                const copy = [...prev];
                                copy[qi].answers.push(
                                  stripAnswerPrefix(addingAnswer[qi]),
                                );
                                return copy;
                              }, !!editingTest);
                              setAddingAnswer({});
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
                  <div key={qi} className="border-t pt-4 space-y-1">
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
                <h3 className="text-lg font-semibold">{selectedTest}</h3>
                {questions.map((q, qi) => (
                  <div key={qi} className="border-t pt-4 space-y-1">
                    <div className="flex justify-between items-center">
                      <p className="font-bold leading-tight">
                        {qi + 1}. {q.text}
                      </p>
                      <Button
                        size="sm"
                        variant="outline"
                        onClick={() => generateExplanation(qi)}
                        className="flex items-center space-x-1"
                        disabled={loadingExp[qi]}
                      >
                        {loadingExp[qi] ? (
                          <span>Se generează...</span>
                        ) : q.explanation ? (
                          <span>Explicație generată</span>
                        ) : (
                          <>
                            <svg
                              xmlns="http://www.w3.org/2000/svg"
                              className="h-4 w-4"
                              fill="none"
                              viewBox="0 0 24 24"
                              stroke="currentColor"
                            >
                              <path
                                strokeLinecap="round"
                                strokeLinejoin="round"
                                strokeWidth={2}
                                d="M9 19c-5 1.5-5-2.5-7-3m14 6v-3.87a3.37 3.37 0 0 0-.94-2.61c3.14-.35 6.44-1.54 6.44-7A5.44 5.44 0 0 0 20 4.77 5.07 5.07 0 0 0 19.91 1S18.73.65 16 2.48a13.38 13.38 0 0 0-7 0C6.27.65 5.09 1 5.09 1A5.07 5.07 0 0 0 5 4.77a5.44 5.44 0 0 0-1.5 3.78c0 5.42 3.3 6.61 6.44 7A3.37 3.37 0 0 0 9 18.13V22"
                              />
                            </svg>
                            <span>Explicație AI</span>
                          </>
                        )}
                      </Button>
                    </div>
                    <textarea
                      className="w-full border rounded p-2"
                      placeholder="Explicație"
                      value={editingExplanations[qi] ?? q.explanation ?? ''}
                      onChange={(e) =>
                        setEditingExplanations((s) => ({ ...s, [qi]: e.target.value }))
                      }
                      onBlur={() => {
                        const val = editingExplanations[qi];
                        if (val !== undefined) {
                          setQuestions((prev) => {
                            const copy = [...prev];
                            copy[qi].explanation = val;
                            return copy;
                          });
                        }
                      }}
                    />
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
                  </div>
                ))}
                <div className="text-right">
                  <Button onClick={() => setStep(5)}>Mai departe</Button>
                </div>
              </div>
            )}
            {step === 5 && (
              <div className="space-y-4">
                <h3 className="text-lg font-semibold">{selectedTest}</h3>
                {questions.map((q, qi) => (
                  <div key={qi} className="border-t pt-4 space-y-1">
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
                    </p>
                    {q.note && (
                      <p className="text-sm text-gray-600">Nota: {q.note}</p>
                    )}
                    {q.explanation && (
                      <p className="text-sm">Explicație: {q.explanation}</p>
                    )}
                  </div>
                ))}
                <div className="flex items-center space-x-2">
                  <select
                    className="border p-2 rounded flex-1"
                    value={selectedSubject}
                    onChange={(e) => setSelectedSubject(e.target.value)}
                  >
                    <option value="">Selectează materia</option>
                    {subjects.map((s) => (
                      <option key={s} value={s}>
                        {s}
                      </option>
                    ))}
                  </select>
                  <Button
                    onClick={publishTest}
                    disabled={!selectedSubject || !selectedTest}
                  >
                    Publică
                  </Button>
                </div>
              </div>
            )}
          </div>
        );
      case "teme":
        return (
          <div className="flex space-x-4">
            <div className="w-1/4 border-r pr-4">
              <h3 className="text-lg font-semibold mb-4">Materii</h3>
              {subjects.map((subject) => (
                <div key={subject} className="mb-4">
                  <h4 className="font-medium">{subject}</h4>
                  <ul className="pl-4">
                    {savedTests
                      .filter((t) => t.subject === subject)
                      .sort((a, b) => a.name.localeCompare(b.name))
                      .map((test) => (
                        <li
                          key={test.id}
                          className="cursor-pointer hover:text-blue-500"
                          onClick={() => setSelectedTestId(test.id)}
                        >
                          {test.name}
                        </li>
                      ))}
                  </ul>
                </div>
              ))}
            </div>
            <div className="w-3/4">
              {selectedTestId && !editingTest && (
                <>
                  <div className="flex justify-between items-center mb-4">
                    <h3 className="text-lg font-semibold">
                      {savedTests.find((t) => t.id === selectedTestId)?.name}
                    </h3>
                    <div className="space-x-2">
                      <Button
                        variant="destructive"
                        onClick={() => deleteTest(selectedTestId)}
                      >
                        Șterge test
                      </Button>
                      <Button
                        onClick={() =>
                          setEditingTest(savedTests.find((t) => t.id === selectedTestId) || null)
                        }
                      >
                        Editează
                      </Button>
                    </div>
                  </div>
                  {savedTests
                    .find((t) => t.id === selectedTestId)
                    ?.questions.map((q, qi) => (
                      <div key={qi} className="border-t pt-4 space-y-1">
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
                        </p>
                        {q.note && (
                          <p className="text-sm text-gray-600">Nota: {q.note}</p>
                        )}
                        {q.explanation && (
                          <p className="text-sm">Explicație: {q.explanation}</p>
                        )}
                      </div>
                    ))}
                </>
              )}
              {editingTest && (
                <>
                  <h3 className="text-lg font-semibold mb-4">{editingTest.name}</h3>
                  <div className="mb-4 text-right">
                    <Button size="sm" variant="secondary" onClick={() => addQuestion(true)}>
                      Adaugă grilă
                    </Button>
                  </div>
                  {editingTest.questions.map((q, qi) => (
                    <div key={qi} className="border-t pt-4 space-y-1">
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
                              setEditingTest((prev) => {
                                if (!prev) return prev;
                                const copy = { ...prev, questions: [...prev.questions] };
                                copy.questions[qi].text = editingQuestions[qi].trim() || copy.questions[qi].text;
                                return copy;
                              });
                              setEditingQuestions({});
                            }}
                          >
                            Salvează
                          </Button>
                        </div>
                      ) : (
                        <div className="flex items-center space-x-2">
                          <p className="flex-1 font-bold leading-tight">
                            {qi + 1}. {q.text}
                          </p>
                          <Button
                            size="sm"
                            variant="ghost"
                            onClick={() =>
                              setEditingQuestions((s) => ({ ...s, [qi]: q.text }))
                            }
                          >
                            Editează
                          </Button>
                          <Button
                            size="sm"
                            variant="ghost"
                            onClick={() => moveQuestion(qi, -1, true)}
                            disabled={qi === 0}
                          >
                            ↑
                          </Button>
                          <Button
                            size="sm"
                            variant="ghost"
                            onClick={() => moveQuestion(qi, 1, true)}
                            disabled={qi === (editingTest?.questions.length ?? 0) - 1}
                          >
                            ↓
                          </Button>
                          <Button
                            size="sm"
                            variant="ghost"
                            onClick={() => deleteQuestion(qi, true)}
                          >
                            Șterge
                          </Button>
                          <Button
                            size="sm"
                            variant="outline"
                            onClick={() => generateExplanation(qi, true)}
                            className="ml-2"
                            disabled={loadingExp[qi]}
                          >
                            {loadingExp[qi]
                              ? 'Se generează...'
                              : q.explanation
                              ? 'Explicație generată'
                              : 'Explicație AI'}
                          </Button>
                        </div>
                      )}
                      {q.answers.map((a, ai) => {
                        const key = `${qi}-${ai}`;
                        const isEditing = editingAnswers[key] !== undefined;
                        return (
                          <div
                            key={`${key}-${q.correct.includes(ai)}`}
                            className={cn(
                              "flex items-center space-x-2 p-2 rounded border",
                              q.correct.includes(ai)
                                ? "border-blue-500 bg-blue-100"
                                : "border-transparent",
                            )}
                          >
                            <input
                              type="checkbox"
                              checked={q.correct.includes(ai)}
                              onChange={() => toggleCorrect(qi, ai, true)}
                              className="mr-2"
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
                                    setEditingTest((prev) => {
                                      if (!prev) return prev;
                                      const copy = { ...prev, questions: [...prev.questions] };
                                      copy.questions[qi].answers[ai] = stripAnswerPrefix(
                                        editingAnswers[key].trim() || a
                                      );
                                      return copy;
                                    });
                                    setEditingAnswers({});
                                  }}
                                >
                                  Salvează
                                </Button>
                              </>
                            ) : (
                              <>
                                <span
                                  className="flex-1 cursor-pointer"
                                  onClick={() => toggleCorrect(qi, ai, true)}
                                >
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
                                  onClick={() => deleteAnswer(qi, ai, true)}
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
                                setEditingTest((prev) => {
                                  if (!prev) return prev;
                                  const copy = { ...prev, questions: [...prev.questions] };
                                  copy.questions[qi].answers.push(
                                    stripAnswerPrefix(addingAnswer[qi])
                                  );
                                  return copy;
                                });
                                setAddingAnswer({});
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
                      <textarea
                        className="w-full border rounded p-2 mt-2"
                        placeholder="Nota"
                        value={q.note}
                        onChange={(e) => {
                          const val = e.target.value;
                          setEditingTest((prev) => {
                            if (!prev) return prev;
                            const copy = { ...prev, questions: [...prev.questions] };
                            copy.questions[qi].note = val;
                            return copy;
                          });
                        }}
                      />
                      <textarea
                        className="w-full border rounded p-2 mt-2"
                        placeholder="Explicație"
                        value={q.explanation || ''}
                        onChange={(e) => {
                          const val = e.target.value;
                          setEditingTest((prev) => {
                            if (!prev) return prev;
                            const copy = { ...prev, questions: [...prev.questions] };
                            copy.questions[qi].explanation = val;
                            return copy;
                          });
                        }}
                      />
                    </div>
                  ))}
                  <div className="text-right">
                    <Button onClick={updateTest}>Publică</Button>
                  </div>
                </>
              )}
            </div>
          </div>
        );
      case "suplimentare":
        return <div></div>;
      case "combinate":
        return <div></div>;
      case "simulari":
        return <div></div>;
      case "ani":
        return <div></div>;
      case "generator":
        return (
          <div className="flex space-x-4">
            <div className="w-1/2 space-y-2 border-r pr-4">
              <h3 className="text-lg font-semibold">Adaugă manual</h3>
              <select
                className="border p-2 rounded w-full"
                value={manualTestId}
                onChange={(e) => setManualTestId(e.target.value)}
              >
                <option value="">Selectează testul</option>
                {savedTests.map((t) => (
                  <option key={t.id} value={t.id}>
                    {t.name} - {t.subject}
                  </option>
                ))}
              </select>
              <input
                className="border p-2 rounded w-full"
                placeholder="Întrebare"
                value={manualQuestion}
                onChange={(e) => setManualQuestion(e.target.value)}
              />
              {manualAnswers.map((ans, idx) => (
                <input
                  key={idx}
                  className="border p-2 rounded w-full"
                  placeholder={`Răspuns ${String.fromCharCode(65 + idx)}`}
                  value={ans}
                  onChange={(e) =>
                    setManualAnswers((a) => {
                      const copy = [...a];
                      copy[idx] = e.target.value;
                      return copy;
                    })
                  }
                />
              ))}
              <input
                className="border p-2 rounded w-full"
                placeholder="Răspuns corect (ex: A,B)"
                value={manualCorrect}
                onChange={(e) => setManualCorrect(e.target.value)}
              />
              <textarea
                className="border p-2 rounded w-full"
                placeholder="Explicație"
                value={manualExplanation}
                onChange={(e) => setManualExplanation(e.target.value)}
              />
              <Button onClick={addManualQuestion}>Adaugă grilă</Button>
            </div>
            <div className="w-1/2 space-y-2 pl-4">
              <h3 className="text-lg font-semibold">Generează cu AI</h3>
              <select
                className="border p-2 rounded w-full"
                value={generateTestId}
                onChange={(e) => setGenerateTestId(e.target.value)}
              >
                <option value="">Selectează testul</option>
                {savedTests.map((t) => (
                  <option key={t.id} value={t.id}>
                    {t.name} - {t.subject}
                  </option>
                ))}
              </select>
              <textarea
                className="border p-2 rounded w-full h-32"
                placeholder="Prompt pentru AI"
                value={generatePrompt}
                onChange={(e) => setGeneratePrompt(e.target.value)}
              />
              <Button onClick={generateNewQuestion} disabled={loadingGenerate}>
                {loadingGenerate ? 'Se generează...' : 'Generează grila'}
              </Button>
            </div>
          </div>
        );
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
