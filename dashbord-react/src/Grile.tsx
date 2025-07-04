import React, { useState, useEffect } from "react";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { explainQuestion } from "@/lib/agent";

interface Tab {
  id: string;
  label: string;
}

interface Test {
  id: string;
  name: string;
  subject: string;
  questions: Question[];
  categories?: string[];
  order?: number;
  sections?: string[];
}

const tabs: Tab[] = [
  { id: "generator", label: "Generator" },
  { id: "creare", label: "Creare grile" },
  { id: "teme", label: "Teme" },
];

const subjects = [
  "Drept civil",
  "Drept procesual civil",
  "Drept penal",
  "Drept procesual penal",
];

const categoryOptions = ['INM', 'Barou', 'INR'];

type Question = {
  text: string;
  answers: string[];
  correct: number[];
  note: string;
  explanation?: string;
  section?: string;
  categories?: string[];
  verified?: boolean;
};

export default function Grile() {
  const [active, setActive] = useState<string>(tabs[0].id);
  const [step, setStep] = useState(1);
  const [input, setInput] = useState("");
  const [tests, setTests] = useState<string[]>([]);
  const [selectedTest, setSelectedTest] = useState("");
  const [testCategories, setTestCategories] = useState<string[]>([...categoryOptions]);
  const [showAddTest, setShowAddTest] = useState(false);
  const [newTest, setNewTest] = useState("");
  const [questions, setQuestions] = useState<Question[]>([]);
  const [editingAnswers, setEditingAnswers] = useState<Record<string, string>>({});
  const [editingQuestions, setEditingQuestions] = useState<Record<number, string>>({});
  const [editingExplanations, setEditingExplanations] = useState<Record<number, string>>({});
  const [addingAnswer, setAddingAnswer] = useState<Record<number, string>>({});
  const [sectionInputs, setSectionInputs] = useState<Record<number, string>>({});
  const [selectedSubject, setSelectedSubject] = useState("");
  const [savedTests, setSavedTests] = useState<Test[]>([]);
  const [testsLoaded, setTestsLoaded] = useState(false);
  const [selectedTestId, setSelectedTestId] = useState<string | null>(null);
  const [editingTest, setEditingTest] = useState<Test | null>(null);
  const [loadingExp, setLoadingExp] = useState<Record<number, boolean>>({});

  // Add test form state
  const [addingTestSubject, setAddingTestSubject] = useState<string | null>(null);
  const [newTestName, setNewTestName] = useState('');

  // Generator manual states
  const [manualQuestion, setManualQuestion] = useState('');
  const [manualAnswers, setManualAnswers] = useState<string[]>(['', '', '']);
  const [manualCorrect, setManualCorrect] = useState('');
  const [manualExplanation, setManualExplanation] = useState('');
  const [manualTestId, setManualTestId] = useState('');

  // Move question between themes
  const [moveIndex, setMoveIndex] = useState<number | null>(null);
  const [moveTargetId, setMoveTargetId] = useState('');

  // Sections
  const [addingSection, setAddingSection] = useState(false);
  const [newSectionName, setNewSectionName] = useState('');


  const toggleQuestionCategory = (
    qi: number,
    cat: string,
    isEditing: boolean = false
  ) => {
    updateQuestionsState((prev) => {
      const copy = [...prev];
      const q = { ...copy[qi] };
      const current = q.categories ?? [...categoryOptions];
      q.categories = current.includes(cat)
        ? current.filter((c) => c !== cat)
        : [...current, cat];
      copy[qi] = q;
      return copy;
    }, isEditing);
  };

  useEffect(() => {
    const token = localStorage.getItem('token') || '';
    fetch('/api/tests', { headers: { Authorization: `Bearer ${token}` } })
      .then((r) => (r.ok ? r.json() : Promise.reject()))
      .then((data) => {
        const withDefaults = data.map((t: any, i: number) => ({
          ...t,
          categories: t.categories ?? ['INM', 'Barou', 'INR'],
          order: t.order ?? i,
          sections: t.sections ?? [],
          questions: (t.questions ?? []).map((q: any) => ({
            ...q,
            categories: q.categories ?? ['INM', 'Barou', 'INR'],
            verified: q.verified ?? false,
            section: q.section ?? '',
          })),
        }));
        setSavedTests(withDefaults);
        setTests(Array.from(new Set(withDefaults.map((t: Test) => t.name))));
        setTestsLoaded(true);
      })
      .catch(() => {
        const stored = localStorage.getItem('savedTests');
        if (stored) {
          try {
            const parsed = JSON.parse(stored);
            const withDefaults = parsed.map((t: any, i: number) => ({
              ...t,
              categories: t.categories ?? ['INM', 'Barou', 'INR'],
              order: t.order ?? i,
              sections: t.sections ?? [],
              questions: (t.questions ?? []).map((q: any) => ({
                ...q,
                categories: q.categories ?? ['INM', 'Barou', 'INR'],
                verified: q.verified ?? false,
                section: q.section ?? '',
              })),
            }));
            setSavedTests(withDefaults);
            setTests(Array.from(new Set(withDefaults.map((t: Test) => t.name))));
          } catch {
            /* ignore */
          }
        }
        setTestsLoaded(true);
      });
  }, []);

  useEffect(() => {
    if (!testsLoaded) return;
    try {
      localStorage.setItem('savedTests', JSON.stringify(savedTests));
    } catch (err) {
      console.warn('Unable to persist savedTests in localStorage:', err);
    }
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
    const names = Array.from(new Set(savedTests.map((t) => t.name)));
    setTests(names);
  }, [savedTests, testsLoaded]);

  const stripAnswerPrefix = (t: string) => {
    const m = t.trim().match(/^[A-Za-z][.)]\s*(.+)$/);
    return m ? m[1] : t.trim();
  };

  const lettersToIndexes = (letters: string): number[] =>
    letters
      .toUpperCase()
      .replace(/[^A-Z]/g, '')
      .split('')
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
    const qAltReg = /^.+[:?]$/;
    const aReg = /^(?:R(?:ă|a)spuns\s+)?([A-Za-z])[.)]\s*(.+)$/;
    const correctReg = /^R(?:ă|a)spuns(?:uri)?\s+corect[e]?[:]?\s*(.+)$/i;
    const lettersOnlyReg = /^[A-Za-z](?:\s*,\s*[A-Za-z])+$/;
    const noteReg = /^Not[ăa]?:?\s*(.+)$/i;
    const ignoreReg = /^Admitere\s/i;

    for (const line of lines) {
      if (!line) continue;
      if (ignoreReg.test(line)) continue;

      const qMatch = line.match(qReg);
      if (qMatch) {
        if (current) questions.push(current);
        current = {
          text: qMatch[1],
          answers: [],
          correct: [],
          note: "",
          explanation: "",
          categories: [...categoryOptions],
          verified: false,
          section: '',
        };
        continue;
      }

      const qAltMatch = line.match(qAltReg);
      if (qAltMatch) {
        if (current) questions.push(current);
        current = {
          text: line.replace(/[:?]$/, ''),
          answers: [],
          correct: [],
          note: "",
          explanation: "",
          categories: [...categoryOptions],
          verified: false,
          section: '',
        };
        continue;
      }

      const aMatch = line.match(aReg);
      if (aMatch) {
        if (!current) {
          current = {
            text: "",
            answers: [],
            correct: [],
            note: "",
            explanation: "",
            categories: [...categoryOptions],
            verified: false,
            section: '',
          };
        }
        current.answers.push(aMatch[2] || aMatch[1]);
        continue;
      }

      const corrMatch = line.match(correctReg);
      if (corrMatch && current) {
        const letters = corrMatch[1]
          .toUpperCase()
          .replace(/[^A-Z]/g, '')
          .split('')
          .filter((l) => l);
        current.correct = letters
          .map((l) => l.charCodeAt(0) - 65)
          .filter((i) => i >= 0 && i < current.answers.length);
        continue;
      }

      const lettersMatch = line.match(lettersOnlyReg);
      if (lettersMatch && current) {
        const letters = line
          .toUpperCase()
          .replace(/[^A-Z]/g, '')
          .split('')
          .filter((l) => l);
        current.correct = letters
          .map((l) => l.charCodeAt(0) - 65)
          .filter((i) => i >= 0 && i < current.answers.length);
        continue;
      }

      const noteMatch = line.match(noteReg);
      if (noteMatch && current) {
        current.note = noteMatch[1].trim();
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
    setTestCategories([...categoryOptions]);
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

  const toggleTestCategory = (cat: string) => {
    setTestCategories((prev) =>
      prev.includes(cat) ? prev.filter((c) => c !== cat) : [...prev, cat]
    );
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

  const toggleVerified = (qi: number, isEditing = false) => {
    if (isEditing && editingTest) {
      setEditingTest((prev) => {
        if (!prev) return prev;
        const qs = [...prev.questions];
        qs[qi] = { ...qs[qi], verified: !qs[qi].verified };
        return { ...prev, questions: qs };
      });
    } else if (selectedTestId) {
      setSavedTests((prev) =>
        prev.map((t) => {
          if (t.id !== selectedTestId) return t;
          const qs = [...t.questions];
          qs[qi] = { ...qs[qi], verified: !qs[qi].verified };
          return { ...t, questions: qs };
        })
      );
    }
  };

  const moveQuestionToTest = (
    sourceId: string,
    qIndex: number,
    targetId: string
  ) => {
    if (!targetId) return;
    setSavedTests((prev) => {
      const sIdx = prev.findIndex((t) => t.id === sourceId);
      const tIdx = prev.findIndex((t) => t.id === targetId);
      if (sIdx === -1 || tIdx === -1) return prev;
      const from = { ...prev[sIdx], questions: [...prev[sIdx].questions] };
      const to = { ...prev[tIdx], questions: [...prev[tIdx].questions] };
      const [q] = from.questions.splice(qIndex, 1);
      if (!q) return prev;
      to.questions.push(q);
      const arr = [...prev];
      arr[sIdx] = from;
      arr[tIdx] = to;
      return arr;
    });
  };

  const addQuestion = (isEditing = false) => {
    const newQ: Question = {
      text: "",
      answers: [],
      correct: [],
      note: "",
      explanation: "",
      section: '',
      categories: [...categoryOptions],
      verified: false,
    };
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


  const addManualQuestion = () => {
    if (!manualTestId || !manualQuestion.trim() || manualAnswers.every((a) => !a.trim())) return;
    const correct = lettersToIndexes(manualCorrect);
    const newQ: Question = {
      text: manualQuestion.trim(),
      answers: manualAnswers.map((a) => a.trim()).filter((a) => a),
      correct,
      note: '',
      explanation: manualExplanation.trim(),
      section: '',
      categories: [...categoryOptions],
      verified: false,
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
      categories: Array.from(new Set(testCategories)),
      order:
        Math.max(
          0,
          ...savedTests
            .filter((t) => t.subject === selectedSubject)
            .map((t) => t.order ?? 0)
        ) + 1,
    };

    setSavedTests((prev) => [...prev, test]);
    setTests((prev) => Array.from(new Set([...prev, selectedTest])));
    setSelectedSubject("");
    setSelectedTest("");
    setTestCategories([...categoryOptions]);
    setQuestions([]);
    setStep(1);
    setActive("teme");
  };

  const updateTest = () => {
    if (!editingTest) return;

    const withCategories = {
      ...editingTest,
      categories: Array.from(new Set(editingTest.categories ?? [...categoryOptions])),
      sections: Array.from(new Set(editingTest.sections ?? [])),
    };

    setSavedTests((prev) =>
      prev.map((t) => (t.id === editingTest.id ? withCategories : t))
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

  const moveTest = (id: string, dir: number) => {
    setSavedTests((prev) => {
      const idx = prev.findIndex((t) => t.id === id);
      if (idx === -1) return prev;
      const test = prev[idx];
      const sameSubject = prev
        .filter((t) => t.subject === test.subject)
        .sort((a, b) => (a.order ?? 0) - (b.order ?? 0));
      const pos = sameSubject.findIndex((t) => t.id === id);
      const target = pos + dir;
      if (target < 0 || target >= sameSubject.length) return prev;
      const other = sameSubject[target];
      const updatedPrev = prev.map((t) => {
        if (t.id === test.id) return { ...t, order: other.order };
        if (t.id === other.id) return { ...t, order: test.order };
        return t;
      });
      return updatedPrev;
    });
  };

  const toggleSavedTestCategory = (id: string, cat: string) => {
    setSavedTests((prev) =>
      prev.map((t) => {
        if (t.id !== id) return t;
        const current = t.categories ?? [...categoryOptions];
        const updated = current.includes(cat)
          ? current.filter((c) => c !== cat)
          : [...current, cat];
        return { ...t, categories: updated };
      })
    );
  };

  const moveSavedQuestion = (qi: number, dir: number) => {
    if (!selectedTestId) return;
    setSavedTests((prev) => {
      const idx = prev.findIndex((t) => t.id === selectedTestId);
      if (idx === -1) return prev;
      const test = { ...prev[idx], questions: [...prev[idx].questions] };
      const ni = qi + dir;
      if (ni < 0 || ni >= test.questions.length) return prev;
      const tmp = test.questions[qi];
      test.questions[qi] = test.questions[ni];
      test.questions[ni] = tmp;
      const arr = [...prev];
      arr[idx] = test;
      return arr;
    });
  };

  const setQuestionSection = (
    qi: number,
    section: string,
    isEditing = false
  ) => {
    if (isEditing && editingTest) {
      setEditingTest((prev) => {
        if (!prev) return prev;
        const qs = [...prev.questions];
        qs[qi] = { ...qs[qi], section };
        return { ...prev, questions: qs };
      });
    } else if (selectedTestId) {
      setSavedTests((prev) =>
        prev.map((t) => {
          if (t.id !== selectedTestId) return t;
          const qs = [...t.questions];
          qs[qi] = { ...qs[qi], section };
          return { ...t, questions: qs };
        })
      );
    }
  };

  const renderQuestionView = (q: Question, qi: number, arr: Question[]) => (
    <div key={qi} className="border-t pt-4 space-y-1">
      {sectionInputs[qi] !== undefined ? (
        <div className="flex items-center space-x-2">
          <input
            className="border p-1 rounded flex-1"
            value={sectionInputs[qi]}
            onChange={(e) =>
              setSectionInputs((s) => ({
                ...s,
                [qi]: e.target.value,
              }))
            }
          />
          <Button
            size="sm"
            onClick={() => {
              setQuestionSection(qi, sectionInputs[qi]);
              setSectionInputs((s) => {
                const copy = { ...s };
                delete copy[qi];
                return copy;
              });
            }}
          >
            Salvează
          </Button>
        </div>
      ) : q.section ? (
        <div className="inline-flex items-center border border-black bg-white px-2 py-1 text-sm">
          <span>{q.section}</span>
          <button
            className="ml-1 text-red-600"
            onClick={() => setQuestionSection(qi, '')}
          >
            ×
          </button>
        </div>
      ) : (
        <Button
          size="sm"
          variant="secondary"
          className="mb-1"
          onClick={() => setSectionInputs((s) => ({ ...s, [qi]: '' }))}
        >
          Adaugă secțiunea
        </Button>
      )}
      <div className="flex items-start">
        <p className="flex-1 font-bold leading-tight">
          {qi + 1}. {q.text}{' '}
          {q.verified && <span className="text-green-600 ml-1">✓</span>}
        </p>
        <input
          type="checkbox"
          className="mt-1 mr-2"
          checked={q.verified || false}
          onChange={() => toggleVerified(qi)}
        />
        <div className="flex flex-col border-l ml-2 pl-2">
          <button
            onClick={() => moveSavedQuestion(qi, -1)}
            disabled={qi === 0}
            className="text-2xl leading-none"
          >
            ↑
          </button>
          <button
            onClick={() => moveSavedQuestion(qi, 1)}
            disabled={qi === arr.length - 1}
            className="text-2xl leading-none"
          >
            ↓
          </button>
        </div>
      </div>
      {q.answers.map((a, ai) => (
        <p key={ai} className="pl-4 leading-tight">
          {String.fromCharCode(65 + ai)}. {a}
        </p>
      ))}
      <p className="text-sm italic">
        Răspuns corect:{' '}
        {q.correct.map((c) => String.fromCharCode(65 + c)).join(', ')}
      </p>
      {q.note && <p className="text-sm text-gray-600">Nota: {q.note}</p>}
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
      {moveIndex === qi ? (
        <div className="pl-4 flex items-center space-x-2">
          <select
            className="border p-1 rounded flex-1"
            value={moveTargetId}
            onChange={(e) => setMoveTargetId(e.target.value)}
          >
            <option value="">Selectează tema</option>
            {savedTests
              .filter((t) => t.id !== selectedTestId)
              .map((t) => (
                <option key={t.id} value={t.id}>
                  {t.name} - {t.subject}
                </option>
              ))}
          </select>
          <Button
            size="sm"
            onClick={() => {
              if (!moveTargetId || selectedTestId === null) return;
              moveQuestionToTest(selectedTestId, qi, moveTargetId);
              setMoveIndex(null);
              setMoveTargetId('');
            }}
          >
            Trimite
          </Button>
          <Button
            size="sm"
            variant="ghost"
            onClick={() => {
              setMoveIndex(null);
              setMoveTargetId('');
            }}
          >
            Renunță
          </Button>
        </div>
      ) : (
        <Button
          variant="secondary"
          size="sm"
          className="ml-4"
          onClick={() => setMoveIndex(qi)}
        >
          Mutare grilă
        </Button>
      )}
    </div>
  );

  const addSectionToTest = (name: string, isEditing = false) => {
    if (!name.trim()) return;
    if (isEditing && editingTest) {
      setEditingTest((prev) => {
        if (!prev) return prev;
        const secs = Array.from(new Set([...(prev.sections ?? []), name.trim()]));
        return { ...prev, sections: secs };
      });
    } else if (selectedTestId) {
      setSavedTests((prev) =>
        prev.map((t) =>
          t.id === selectedTestId
            ? { ...t, sections: Array.from(new Set([...(t.sections ?? []), name.trim()])) }
            : t
        )
      );
    }
  };

  const deleteSectionFromTest = (name: string, isEditing = false) => {
    if (isEditing && editingTest) {
      setEditingTest((prev) => {
        if (!prev) return prev;
        return {
          ...prev,
          sections: (prev.sections ?? []).filter((s) => s !== name),
          questions: prev.questions.map((q) => (q.section === name ? { ...q, section: '' } : q)),
        };
      });
    } else if (selectedTestId) {
      setSavedTests((prev) =>
        prev.map((t) => {
          if (t.id !== selectedTestId) return t;
          return {
            ...t,
            sections: (t.sections ?? []).filter((s) => s !== name),
            questions: t.questions.map((q) => (q.section === name ? { ...q, section: '' } : q)),
          };
        })
      );
    }
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
                    <div className="flex items-center space-x-2">
                      {categoryOptions.map((cat) => (
                        <label key={cat} className="flex items-center space-x-1">
                          <input
                            type="checkbox"
                            checked={q.categories?.includes(cat)}
                            onChange={() => toggleQuestionCategory(qi, cat)}
                          />
                          <span>{cat}</span>
                        </label>
                      ))}
                    </div>
                  </div>
                ))}
                <div className="flex items-center space-x-2 mt-2">
                  {categoryOptions.map((cat) => (
                    <label key={cat} className="flex items-center space-x-1">
                      <input
                        type="checkbox"
                        checked={testCategories.includes(cat)}
                        onChange={() => toggleTestCategory(cat)}
                      />
                      <span>{cat}</span>
                    </label>
                  ))}
                </div>
                <div className="flex items-center space-x-2 mt-2">
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
                  <div className="flex items-center mb-1">
                    <h4 className="font-medium flex-1">{subject}</h4>
                    <button
                      className="text-sm px-1"
                      onClick={() => {
                        setAddingTestSubject(subject);
                        setNewTestName('');
                      }}
                    >
                      +
                    </button>
                  </div>
                  {addingTestSubject === subject && (
                    <div className="flex items-center space-x-2 mb-1">
                      <input
                        className="border p-1 rounded flex-1"
                        placeholder="Denumire test"
                        value={newTestName}
                        onChange={(e) => setNewTestName(e.target.value)}
                      />
                      <Button
                        size="sm"
                        onClick={() => {
                          if (!newTestName.trim()) return;
                          const order =
                            Math.max(
                              0,
                              ...savedTests
                                .filter((t) => t.subject === subject)
                                .map((t) => t.order ?? 0)
                            ) + 1;
                          const test: Test = {
                            id: Date.now().toString(),
                            name: newTestName.trim(),
                            subject,
                            questions: [],
                            categories: [...categoryOptions],
                            order,
                            sections: [],
                          };
                          setSavedTests((prev) => [...prev, test]);
                          setAddingTestSubject(null);
                          setNewTestName('');
                          setSelectedTestId(test.id);
                        }}
                      >
                        Salvează
                      </Button>
                    </div>
                  )}
                  <ul className="pl-4">
                    {savedTests
                      .filter((t) => t.subject === subject)
                      .sort((a, b) => (a.order ?? 0) - (b.order ?? 0))
                      .map((test) => (
                        <li key={test.id} className="flex items-center space-x-1">
                          <span
                            className="flex-1 cursor-pointer hover:text-blue-500"
                            onClick={() => setSelectedTestId(test.id)}
                          >
                            {test.name}
                          </span>
                          <button
                            onClick={() => moveTest(test.id, -1)}
                            className="text-xs px-1"
                          >
                            ↑
                          </button>
                          <button
                            onClick={() => moveTest(test.id, 1)}
                            className="text-xs px-1"
                          >
                            ↓
                          </button>
                        </li>
                      ))}
                  </ul>
                </div>
              ))}
            </div>
            <div className="w-3/4">
              {selectedTestId && !editingTest && (
                <>
                  <div className="flex justify-between items-start mb-4">
                    <div>
                      <h3 className="text-lg font-semibold">
                        {savedTests.find((t) => t.id === selectedTestId)?.name}
                      </h3>
                      <div className="flex items-center space-x-2 mt-1">
                        {categoryOptions.map((cat) => (
                          <label key={cat} className="flex items-center space-x-1">
                            <input
                              type="checkbox"
                              checked={
                                savedTests
                                  .find((t) => t.id === selectedTestId)
                                  ?.categories?.includes(cat)
                              }
                              onChange={() => toggleSavedTestCategory(selectedTestId, cat)}
                            />
                            <span>{cat}</span>
                          </label>
                        ))}
                      </div>
                    </div>
                    <div className="space-x-2">
                      <Button
                        variant="destructive"
                        onClick={() => deleteTest(selectedTestId)}
                      >
                        Șterge test
                      </Button>
                      <Button
                        onClick={() =>
                          setEditingTest(() => {
                            const t = savedTests.find((x) => x.id === selectedTestId);
                            return t
                              ? {
                                  ...t,
                                  categories: t.categories ?? ['INM', 'Barou', 'INR'],
                                  sections: t.sections ?? [],
                                }
                              : null;
                          })
                      }
                      >
                        Editează
                      </Button>
                    </div>
                  </div>
                  <div className="mb-4">
                    {savedTests
                      .find((t) => t.id === selectedTestId)
                      ?.sections.map((sec) => (
                        <div key={sec} className="border border-black p-2 mb-2">
                          <div className="flex justify-between items-center mb-2">
                            <span className="font-semibold">{sec}</span>
                            <button
                              className="text-red-600"
                              onClick={() => deleteSectionFromTest(sec)}
                            >
                              ×
                            </button>
                          </div>
                          {savedTests
                            .find((t) => t.id === selectedTestId)
                            ?.questions.map((q, qi, arr) =>
                              q.section === sec ? renderQuestionView(q, qi, arr) : null
                            )}
                        </div>
                      ))}
                    {addingSection ? (
                      <div className="flex items-center space-x-2 mb-2">
                        <input
                          className="border p-1 rounded flex-1"
                          value={newSectionName}
                          onChange={(e) => setNewSectionName(e.target.value)}
                        />
                        <Button
                          size="sm"
                          onClick={() => {
                            addSectionToTest(newSectionName);
                            setNewSectionName('');
                            setAddingSection(false);
                          }}
                        >
                          Salvează
                        </Button>
                      </div>
                    ) : (
                      <Button
                        size="sm"
                        variant="secondary"
                        className="mb-2"
                        onClick={() => setAddingSection(true)}
                      >
                        Adaugă secțiune
                      </Button>
                    )}
                  </div>
                  {savedTests
                    .find((t) => t.id === selectedTestId)
                    ?.questions.map((q, qi, arr) =>
                      q.section ? null : renderQuestionView(q, qi, arr)
                    )}
                </>
              )}
              {editingTest && (
                <>
                  <input
                    className="border p-2 rounded w-full mb-2"
                    value={editingTest.name}
                    onChange={(e) =>
                      setEditingTest((prev) =>
                        prev ? { ...prev, name: e.target.value } : prev
                      )
                    }
                  />
                  <div className="flex items-center space-x-2 mb-2">
                    {categoryOptions.map((cat) => (
                      <label key={cat} className="flex items-center space-x-1">
                        <input
                          type="checkbox"
                          checked={editingTest.categories?.includes(cat)}
                          onChange={() =>
                            setEditingTest((prev) => {
                              if (!prev) return prev;
                              const current = prev.categories ?? [...categoryOptions];
                              const updated = current.includes(cat)
                                ? current.filter((c) => c !== cat)
                                : [...current, cat];
                              return { ...prev, categories: updated };
                            })
                          }
                        />
                        <span>{cat}</span>
                      </label>
                    ))}
                  </div>
                  <div className="mb-4 text-right">
                    <Button size="sm" variant="secondary" onClick={() => addQuestion(true)}>
                      Adaugă grilă
                    </Button>
                  </div>
                  {editingTest.questions.map((q, qi, arr) => (
                    <div key={qi} className="border-t pt-4 space-y-1">
                      {sectionInputs[qi] !== undefined ? (
                        <div className="flex items-center space-x-2">
                          <input
                            className="border p-1 rounded flex-1"
                            value={sectionInputs[qi]}
                            onChange={(e) =>
                              setSectionInputs((s) => ({
                                ...s,
                                [qi]: e.target.value,
                              }))
                            }
                          />
                          <Button
                            size="sm"
                            onClick={() => {
                              setQuestionSection(qi, sectionInputs[qi], true);
                              setSectionInputs((s) => {
                                const copy = { ...s };
                                delete copy[qi];
                                return copy;
                              });
                            }}
                          >
                            Salvează
                          </Button>
                        </div>
                      ) : q.section ? (
                        <div className="inline-flex items-center border border-black bg-white px-2 py-1 text-sm">
                          <span>{q.section}</span>
                          <button
                            className="ml-1 text-red-600"
                            onClick={() => setQuestionSection(qi, '', true)}
                          >
                            ×
                          </button>
                        </div>
                      ) : (
                        <Button
                          size="sm"
                          variant="secondary"
                          className="mb-1"
                          onClick={() => setSectionInputs((s) => ({ ...s, [qi]: '' }))}
                        >
                          Adaugă secțiunea
                        </Button>
                      )}
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
                            {qi + 1}. {q.text}{" "}
                            {q.verified && (
                              <span className="text-green-600 ml-1">✓</span>
                            )}
                          </p>
                          <input
                            type="checkbox"
                            className="mr-2"
                            checked={q.verified || false}
                            onChange={() => toggleVerified(qi, true)}
                          />
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
                      <div className="flex items-center space-x-2 mt-1">
                        {categoryOptions.map((cat) => (
                          <label key={cat} className="flex items-center space-x-1">
                            <input
                              type="checkbox"
                              checked={q.categories?.includes(cat)}
                              onChange={() => toggleQuestionCategory(qi, cat, true)}
                            />
                            <span>{cat}</span>
                          </label>
                        ))}
                      </div>
                      {moveIndex === qi ? (
                        <div className="flex items-center space-x-2 mt-2">
                          <select
                            className="border p-1 rounded flex-1"
                            value={moveTargetId}
                            onChange={(e) => setMoveTargetId(e.target.value)}
                          >
                            <option value="">Selectează tema</option>
                            {savedTests
                              .filter((t) => t.id !== editingTest!.id)
                              .map((t) => (
                                <option key={t.id} value={t.id}>
                                  {t.name} - {t.subject}
                                </option>
                              ))}
                          </select>
                          <Button
                            size="sm"
                            onClick={() => {
                              if (!moveTargetId) return;
                              moveQuestionToTest(editingTest!.id, qi, moveTargetId);
                              setMoveIndex(null);
                              setMoveTargetId('');
                            }}
                          >
                            Trimite
                          </Button>
                          <Button
                            size="sm"
                            variant="ghost"
                            onClick={() => {
                              setMoveIndex(null);
                              setMoveTargetId('');
                            }}
                          >
                            Renunță
                          </Button>
                        </div>
                      ) : (
                        <Button
                          variant="secondary"
                          size="sm"
                          className="mt-2"
                          onClick={() => setMoveIndex(qi)}
                        >
                          Mutare grilă
                        </Button>
                      )}
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
            className="border"
          >
            {t.label}
          </Button>
        ))}
      </div>
      {renderTab()}
    </div>
  );
}
