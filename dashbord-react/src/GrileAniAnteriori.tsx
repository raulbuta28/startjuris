import React, { useState, useEffect } from "react";
import { Button } from "@/components/ui/button";
import {
  cn,
  extractArticleRanges,
  rangeIncludes,
  detectSubject,
  parseArticleStart,
} from "@/lib/utils";
import { explainQuestion, detectSubjectAI } from "@/lib/agent";

interface Tab {
  id: string;
  label: string;
}

interface Test {
  id: string;
  name: string;
  subject?: string;
  questions: Question[];
  categories?: string[];
  order?: number;
  articleInterval?: string;
}

const tabs: Tab[] = [
  { id: "generator", label: "Generator" },
  { id: "creare", label: "Creare grile" },
  { id: "teme", label: "Grile ani anteriori" },
  { id: "articole_teme", label: "Articole teme" },
];

const categoryOptions = ["INM", "Barou", "INR"];

type Question = {
  text: string;
  answers: string[];
  correct: number[];
  note: string;
  explanation?: string;
  categories?: string[];
  inTheme?: boolean;
  articles?: string[];
  theme?: string;
  themes?: string[];
  subject?: string;
};

export default function GrileAniAnteriori() {
  const [active, setActive] = useState<string>(tabs[0].id);
  const [step, setStep] = useState(1);
  const [input, setInput] = useState("");
  const [tests, setTests] = useState<string[]>([]);
  const [selectedTest, setSelectedTest] = useState("");
  const [testCategories, setTestCategories] = useState<string[]>([
    ...categoryOptions,
  ]);
  const [showAddTest, setShowAddTest] = useState(false);
  const [newTest, setNewTest] = useState("");
  const [questions, setQuestions] = useState<Question[]>([]);
  const [editingAnswers, setEditingAnswers] = useState<Record<string, string>>(
    {},
  );
  const [editingQuestions, setEditingQuestions] = useState<
    Record<number, string>
  >({});
  const [editingExplanations, setEditingExplanations] = useState<
    Record<number, string>
  >({});
  const [addingAnswer, setAddingAnswer] = useState<Record<number, string>>({});
  const [savedTests, setSavedTests] = useState<Test[]>([]);
  const [testsLoaded, setTestsLoaded] = useState(false);
  const [selectedTestId, setSelectedTestId] = useState<string | null>(null);
  const [editingTest, setEditingTest] = useState<Test | null>(null);
  const [loadingExp, setLoadingExp] = useState<Record<number, boolean>>({});

  // Themes from "Teme" tab
  const [allThemes, setAllThemes] = useState<Test[]>([]);
  const [addMenuIndex, setAddMenuIndex] = useState<number | null>(null);
  const [selectedThemeId, setSelectedThemeId] = useState("");
  const [themeRanges, setThemeRanges] = useState<Record<string, string>>({});

  const intervalOptions = [
    { label: "1-20", start: 1, end: 20 },
    { label: "51-100", start: 51, end: 100 },
  ];
  const [selectedIntervals, setSelectedIntervals] = useState<string[]>([]);
  const [loadingAllExp, setLoadingAllExp] = useState<Record<string, boolean>>(
    {},
  );
  const [expDone, setExpDone] = useState<Record<string, boolean>>({});

  const [subjectIntervals, setSubjectIntervals] = useState<string[]>([]);
  const [loadingSubjects, setLoadingSubjects] = useState<
    Record<string, boolean>
  >({});
  const [subjectsDone, setSubjectsDone] = useState<Record<string, boolean>>({});

  // Generator manual states
  const [manualQuestion, setManualQuestion] = useState("");
  const [manualAnswers, setManualAnswers] = useState<string[]>(["", "", ""]);
  const [manualCorrect, setManualCorrect] = useState("");
  const [manualExplanation, setManualExplanation] = useState("");
  const [manualTestId, setManualTestId] = useState("");

  const savePrevTestsRequest = async (data: Test[]) => {
    try {
      const token = localStorage.getItem("token") || "";
      const res = await fetch("/api/save-prev-tests", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify(data),
      });
      if (!res.ok) throw new Error("failed");
      localStorage.removeItem("pendingPrevTests");
    } catch {
      localStorage.setItem("pendingPrevTests", JSON.stringify(data));
    }
  };

  const flushPendingPrevTests = () => {
    const stored = localStorage.getItem("pendingPrevTests");
    if (!stored) return;
    try {
      const data = JSON.parse(stored) as Test[];
      savePrevTestsRequest(data);
    } catch {
      /* ignore */
    }
  };

  useEffect(() => {
    flushPendingPrevTests();
    window.addEventListener("online", flushPendingPrevTests);
    return () => window.removeEventListener("online", flushPendingPrevTests);
  }, []);

  const toggleQuestionCategory = (
    qi: number,
    cat: string,
    isEditing: boolean = false,
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
    const token = localStorage.getItem("token") || "";
    fetch("/api/prev-tests", { headers: { Authorization: `Bearer ${token}` } })
      .then((r) => (r.ok ? r.json() : Promise.reject()))
      .then((data) => {
        const withDefaults = data.map((t: any, i: number) => ({
          ...t,
          categories: t.categories ?? ["INM", "Barou", "INR"],
          order: t.order ?? i,
          questions: (t.questions ?? []).map((q: any) => ({
            ...q,
            categories: q.categories ?? ["INM", "Barou", "INR"],
          })),
        }));
        setSavedTests(withDefaults);
        setTests(Array.from(new Set(withDefaults.map((t: Test) => t.name))));
        setTestsLoaded(true);
      })
      .catch(() => {
        const stored = localStorage.getItem("savedPrevTests");
        if (stored) {
          try {
            const parsed = JSON.parse(stored);
            const withDefaults = parsed.map((t: any, i: number) => ({
              ...t,
              categories: t.categories ?? ["INM", "Barou", "INR"],
              order: t.order ?? i,
              questions: (t.questions ?? []).map((q: any) => ({
                ...q,
                categories: q.categories ?? ["INM", "Barou", "INR"],
              })),
            }));
            setSavedTests(withDefaults);
            setTests(
              Array.from(new Set(withDefaults.map((t: Test) => t.name))),
            );
          } catch {
            /* ignore */
          }
        }
        setTestsLoaded(true);
      });
  }, []);

  // Load themes from main tests list
  useEffect(() => {
    const token = localStorage.getItem("token") || "";
    fetch("/api/tests", { headers: { Authorization: `Bearer ${token}` } })
      .then((r) => (r.ok ? r.json() : Promise.reject()))
      .then(setAllThemes)
      .catch(() => {
        const stored = localStorage.getItem("savedTests");
        if (stored) {
          try {
            setAllThemes(JSON.parse(stored));
          } catch {
            /* ignore */
          }
        }
      });
  }, []);

  useEffect(() => {
    setThemeRanges((prev) => {
      const copy = { ...prev };
      allThemes.forEach((t) => {
        if (t.articleInterval !== undefined) {
          copy[t.id] = t.articleInterval;
        }
      });
      return copy;
    });
  }, [allThemes]);

  useEffect(() => {
    if (!allThemes.length) return;
    try {
      localStorage.setItem("savedTests", JSON.stringify(allThemes));
    } catch (err) {
      console.warn("Unable to persist savedTests in localStorage:", err);
    }
    fetch("/api/save-tests", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${localStorage.getItem("token") || ""}`,
      },
      body: JSON.stringify(allThemes),
    }).catch(() => {});
  }, [allThemes]);

  useEffect(() => {
    if (!testsLoaded) return;
    try {
      localStorage.setItem("savedPrevTests", JSON.stringify(savedTests));
    } catch (err) {
      console.warn("Unable to persist savedPrevTests in localStorage:", err);
    }
    savePrevTestsRequest(savedTests);
  }, [savedTests, testsLoaded]);

  useEffect(() => {
    if (!testsLoaded) return;
    const names = Array.from(new Set(savedTests.map((t) => t.name)));
    setTests(names);
  }, [savedTests, testsLoaded]);

  const autoGenRef = React.useRef(false);
  useEffect(() => {
    if (!testsLoaded || autoGenRef.current) return;
    autoGenRef.current = true;
    (async () => {
      for (let ti = 0; ti < savedTests.length; ti++) {
        const t = savedTests[ti];
        const isBarou = t.categories?.includes("Barou");
        const isINR = t.categories?.includes("INR");
        const isINM = t.categories?.includes("INM") && !isBarou && !isINR;
        if (isINM) continue;
        const start = isBarou ? 20 : 0;
        const limit = isINR
          ? Math.min(50, t.questions.length)
          : t.questions.length;
        for (let qi = start; qi < limit; qi += 2) {
          const batch = [qi, qi + 1].filter((x) => x < limit);
          const results = await Promise.allSettled(
            batch.map((i) => explainQuestion(t.questions[i])),
          );
          setSavedTests((prev) => {
            const copy = [...prev];
            const ct = { ...copy[ti], questions: [...copy[ti].questions] };
            batch.forEach((idx, bi) => {
              const r = results[bi];
              if (r.status === "fulfilled") {
                const exp = r.value as string;
                const subject = detectSubject(exp);
                const articles = extractArticleRanges(exp);
                ct.questions[idx] = {
                  ...ct.questions[idx],
                  explanation: exp,
                  subject,
                  articles,
                };
              }
            });
            copy[ti] = ct;
            return copy;
          });
        }
      }
    })();
  }, [testsLoaded]);

  const stripAnswerPrefix = (t: string) => {
    const m = t.trim().match(/^[A-Za-z][.)]\s*(.+)$/);
    return m ? m[1] : t.trim();
  };

  const lettersToIndexes = (letters: string): number[] =>
    letters
      .toUpperCase()
      .replace(/[^A-Z]/g, "")
      .split("")
      .filter((l) => l)
      .map((l) => l.charCodeAt(0) - 65);

  const updateQuestionsState = (
    updater: (prev: Question[]) => Question[],
    isEditing: boolean = false,
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
    const noteReg = /^Not[ăa][:]?\s*(.+)$/i;

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
          explanation: "",
          categories: [...categoryOptions],
          inTheme: false,
          themes: [],
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
            inTheme: false,
            themes: [],
          };
        }
        current.answers.push(aMatch[2] || aMatch[1]);
        continue;
      }

      const noteMatch = line.match(noteReg);
      if (noteMatch && current) {
        current.note = noteMatch[1];
        continue;
      }

      const corrMatch = line.match(correctReg);
      if (corrMatch && current) {
        const letters = corrMatch[1]
          .toUpperCase()
          .replace(/[^A-Z]/g, "")
          .split("")
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
      prev.includes(cat) ? prev.filter((c) => c !== cat) : [...prev, cat],
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

  const addQuestion = (isEditing = false) => {
    const newQ: Question = {
      text: "",
      answers: [],
      correct: [],
      note: "",
      explanation: "",
      categories: [...categoryOptions],
      inTheme: false,
      themes: [],
    };
    updateQuestionsState((prev) => [...prev, newQ], isEditing);
    setEditingQuestions((s) => ({
      ...s,
      [isEditing && editingTest
        ? editingTest.questions.length
        : questions.length]: "",
    }));
  };

  const generateExplanation = async (qi: number, isEditing = false) => {
    setLoadingExp((s) => ({ ...s, [qi]: true }));
    try {
      const targetQuestions =
        isEditing && editingTest ? editingTest.questions : questions;
      const exp = await explainQuestion(targetQuestions[qi]);
      const subject = detectSubject(exp);
      const articles = extractArticleRanges(exp);
      if (isEditing && editingTest) {
        setEditingTest((prev) => {
          if (!prev) return prev;
          const copy = { ...prev, questions: [...prev.questions] };
          copy.questions[qi].explanation = exp;
          copy.questions[qi].subject = subject;
          copy.questions[qi].articles = articles;
          return copy;
        });
      } else {
        setQuestions((prev) => {
          const copy = [...prev];
          copy[qi].explanation = exp;
          copy[qi].subject = subject;
          copy[qi].articles = articles;
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

  const shouldGenerateExp = (index: number) => {
    const nr = index + 1;
    if (selectedIntervals.length === 0) return true;
    return !intervalOptions.some(
      (i) =>
        selectedIntervals.includes(i.label) && nr >= i.start && nr <= i.end,
    );
  };

  const generateAllExplanations = async (id?: string) => {
    const targetId = id || selectedTestId;
    if (!targetId || loadingAllExp[targetId]) return;
    const testIndex = savedTests.findIndex((t) => t.id === targetId);
    if (testIndex === -1) return;
    const qList = [...savedTests[testIndex].questions];
    const indexes = qList
      .map((_, i) => i)
      .filter((i) => shouldGenerateExp(i) && !qList[i].explanation?.trim());
    setLoadingAllExp((s) => ({ ...s, [targetId]: true }));
    try {
      for (let i = 0; i < indexes.length; i += 2) {
        const batch = indexes.slice(i, i + 2);
        const results = await Promise.allSettled(
          batch.map((qi) => explainQuestion(qList[qi])),
        );
        setSavedTests((prev) => {
          const copy = [...prev];
          const t = {
            ...copy[testIndex],
            questions: [...copy[testIndex].questions],
          };
          batch.forEach((qi, idx) => {
            const r = results[idx];
            if (r.status === "fulfilled") {
              const exp = r.value;
              const subject = detectSubject(exp);
              const articles = extractArticleRanges(exp);
              t.questions[qi] = {
                ...t.questions[qi],
                explanation: exp,
                subject,
                articles,
              };
              qList[qi] = t.questions[qi];
            }
          });
          copy[testIndex] = t;
          return copy;
        });
      }
    } catch (err) {
      console.error(err);
      alert("Eroare la generarea explicațiilor");
    } finally {
      setLoadingAllExp((s) => ({ ...s, [targetId]: false }));
      const done = qList.every(
        (q, i) => !shouldGenerateExp(i) || q.explanation?.trim(),
      );
      setExpDone((d) => ({ ...d, [targetId]: done }));
    }
  };

  const regenerateAllExplanations = async (id?: string) => {
    const targetId = id || selectedTestId;
    if (!targetId || loadingAllExp[targetId]) return;
    const testIndex = savedTests.findIndex((t) => t.id === targetId);
    if (testIndex === -1) return;
    const qList = [...savedTests[testIndex].questions];
    const indexes = qList.map((_, i) => i).filter((i) => shouldGenerateExp(i));
    setLoadingAllExp((s) => ({ ...s, [targetId]: true }));
    try {
      setSavedTests((prev) => {
        const copy = [...prev];
        const t = {
          ...copy[testIndex],
          questions: [...copy[testIndex].questions],
        };
        indexes.forEach((qi) => {
          t.questions[qi] = { ...t.questions[qi], explanation: "" };
        });
        copy[testIndex] = t;
        return copy;
      });
      for (let i = 0; i < indexes.length; i += 2) {
        const batch = indexes.slice(i, i + 2);
        const results = await Promise.allSettled(
          batch.map((qi) => explainQuestion(qList[qi])),
        );
        setSavedTests((prev) => {
          const copy = [...prev];
          const t = {
            ...copy[testIndex],
            questions: [...copy[testIndex].questions],
          };
          batch.forEach((qi, idx) => {
            const r = results[idx];
            if (r.status === "fulfilled") {
              const exp = r.value;
              const subject = detectSubject(exp);
              const articles = extractArticleRanges(exp);
              t.questions[qi] = {
                ...t.questions[qi],
                explanation: exp,
                subject,
                articles,
              };
              qList[qi] = t.questions[qi];
            }
          });
          copy[testIndex] = t;
          return copy;
        });
      }
    } catch (err) {
      console.error(err);
      alert("Eroare la generarea explicațiilor");
    } finally {
      setLoadingAllExp((s) => ({ ...s, [targetId]: false }));
      const done = qList.every(
        (q, i) => !shouldGenerateExp(i) || q.explanation?.trim(),
      );
      setExpDone((d) => ({ ...d, [targetId]: done }));
    }
  };

  const generateExplanationsForAllTests = async () => {
    const ids = savedTests.map((t) => t.id);
    await Promise.allSettled(ids.map((id) => generateAllExplanations(id)));
  };

  const assignArticles = () => {
    if (!selectedTestId) return;
    const testIndex = savedTests.findIndex((t) => t.id === selectedTestId);
    if (testIndex === -1) return;
    setSavedTests((prev) => {
      const copy = [...prev];
      const t = {
        ...copy[testIndex],
        questions: [...copy[testIndex].questions],
      };
      t.questions = t.questions.map((q) => {
        if (!q.explanation?.trim()) return q;
        const articles = extractArticleRanges(q.explanation);
        const subject = detectSubject(q.explanation) || q.subject;
        const themeSet = new Set<string>();
        for (const art of articles) {
          const first = parseArticleStart(art);
          if (isNaN(first)) continue;
          for (const [id, rangesStr] of Object.entries(themeRanges)) {
            const ranges = rangesStr
              .split(",")
              .map((r) => r.trim())
              .filter(Boolean);
            if (ranges.some((r) => rangeIncludes(r, first))) {
              const th = allThemes.find((x) => x.id === id);
              if (th) themeSet.add(th.name);
            }
          }
        }
        const themes = Array.from(themeSet);
        const theme = themes[0];
        return { ...q, articles, theme, themes, subject };
      });
      copy[testIndex] = t;
      return copy;
    });
  };

  const shouldAssignSubject = (index: number) => {
    const nr = index + 1;
    if (subjectIntervals.length === 0) return true;
    return !intervalOptions.some(
      (i) => subjectIntervals.includes(i.label) && nr >= i.start && nr <= i.end,
    );
  };

  const assignSubjects = async (id?: string) => {
    const targetId = id || selectedTestId;
    if (!targetId || loadingSubjects[targetId]) return;
    const testIndex = savedTests.findIndex((t) => t.id === targetId);
    if (testIndex === -1) return;
    const qList = [...savedTests[testIndex].questions];
    const indexes = qList
      .map((_, i) => i)
      .filter((i) => shouldAssignSubject(i) && qList[i].explanation?.trim());
    setLoadingSubjects((s) => ({ ...s, [targetId]: true }));
    try {
      for (let i = 0; i < indexes.length; i += 2) {
        const batch = indexes.slice(i, i + 2);
        const results = await Promise.allSettled(
          batch.map((qi) => detectSubjectAI(qList[qi])),
        );
        setSavedTests((prev) => {
          const copy = [...prev];
          const t = {
            ...copy[testIndex],
            questions: [...copy[testIndex].questions],
          };
          batch.forEach((qi, idx) => {
            const r = results[idx];
            if (r.status === "fulfilled") {
              t.questions[qi] = { ...t.questions[qi], subject: r.value };
              qList[qi] = t.questions[qi];
            }
          });
          copy[testIndex] = t;
          return copy;
        });
      }
      const done = qList.every((q, i) => !shouldAssignSubject(i) || q.subject);
      setSubjectsDone((s) => ({ ...s, [targetId]: done }));
    } catch (err) {
      console.error(err);
      alert("Eroare la stabilirea materiei");
    } finally {
      setLoadingSubjects((s) => ({ ...s, [targetId]: false }));
    }
  };

  const addManualQuestion = () => {
    if (
      !manualTestId ||
      !manualQuestion.trim() ||
      manualAnswers.every((a) => !a.trim())
    )
      return;
    const correct = lettersToIndexes(manualCorrect);
    const newQ: Question = {
      text: manualQuestion.trim(),
      answers: manualAnswers.map((a) => a.trim()).filter((a) => a),
      correct,
      note: "",
      explanation: manualExplanation.trim(),
      categories: [...categoryOptions],
      inTheme: false,
      themes: [],
    };
    setSavedTests((prev) =>
      prev.map((t) =>
        t.id === manualTestId ? { ...t, questions: [...t.questions, newQ] } : t,
      ),
    );
    setManualQuestion("");
    setManualAnswers(["", "", ""]);
    setManualCorrect("");
    setManualExplanation("");
    setManualTestId("");
  };

  const addQuestionToTheme = (
    question: Question,
    themeId: string,
    sourceTestId?: string,
    qIndex?: number,
  ) => {
    const th = allThemes.find((t) => t.id === themeId);
    setAllThemes((prev) =>
      prev.map((t) =>
        t.id === themeId ? { ...t, questions: [...t.questions, question] } : t,
      ),
    );
    if (sourceTestId && qIndex !== undefined) {
      setSavedTests((prev) =>
        prev.map((t) => {
          if (t.id !== sourceTestId) return t;
          const qs = [...t.questions];
          const existing = qs[qIndex].themes || [];
          const newThemes = th
            ? Array.from(new Set([...existing, th.name]))
            : existing;
          qs[qIndex] = {
            ...qs[qIndex],
            inTheme: true,
            themes: newThemes,
            theme: newThemes[0],
          };
          return { ...t, questions: qs };
        }),
      );
    }
  };

  const saveThemeRange = (id: string) => {
    const value = themeRanges[id] || "";
    setAllThemes((prev) =>
      prev.map((t) => (t.id === id ? { ...t, articleInterval: value } : t)),
    );
  };

  const autoAssignQuestionToTheme = (
    question: Question,
    qIndex: number,
    sourceTestId: string,
  ) => {
    // ensure we have articles and subject extracted from the explanation
    let subject = question.subject?.trim();
    let arts = question.articles || [];
    if ((!subject || subject === "") && question.explanation) {
      subject = detectSubject(question.explanation) || undefined;
    }
    if (arts.length === 0 && question.explanation) {
      arts = extractArticleRanges(question.explanation);
    }
    if (!subject) {
      alert("Selectează materia apoi trimite grila");
      return;
    }

    const themeIds = new Set<string>();
    for (const art of arts) {
      const first = parseArticleStart(art);
      if (isNaN(first)) continue;
      for (const [id, rangesStr] of Object.entries(themeRanges)) {
        const ranges = rangesStr
          .split(",")
          .map((r) => r.trim())
          .filter(Boolean);
        if (ranges.some((r) => rangeIncludes(r, first))) {
          themeIds.add(id);
        }
      }
    }
    const matched = Array.from(themeIds).filter((id) => {
      const th = allThemes.find((t) => t.id === id);
      return th && th.subject && th.subject.trim().toLowerCase() === subject!.toLowerCase();
    });

    if (matched.length === 0) {
      alert("Nu s-a găsit tema potrivită pentru articolele selectate");
      return;
    }

    matched.forEach((id) => {
      addQuestionToTheme({ ...question, articles: arts, subject }, id, sourceTestId, qIndex);
    });
  };

  const publishTest = () => {
    if (!selectedTest) return;

    const test: Test = {
      id: Date.now().toString(),
      name: selectedTest,
      questions: questions.map((q) => ({ ...q, inTheme: q.inTheme ?? false })),
      categories: Array.from(new Set(testCategories)),
      order: Math.max(0, ...savedTests.map((t) => t.order ?? 0)) + 1,
    };

    setSavedTests((prev) => [...prev, test]);
    setTests((prev) => Array.from(new Set([...prev, selectedTest])));
    setSelectedTest("");
    setTestCategories([...categoryOptions]);
    setQuestions([]);
    setStep(1);
    setActive("teme");
  };

  const publishTestsByNote = () => {
    if (questions.length === 0) return;

    const groups: Record<string, Question[]> = {};
    const noteOrder: string[] = [];
    questions.forEach((q) => {
      const note = q.note.trim() || "Fara nota";
      if (!groups[note]) {
        groups[note] = [];
        noteOrder.push(note);
      }
      groups[note].push({ ...q, inTheme: q.inTheme ?? false });
    });

    let baseOrder = Math.max(0, ...savedTests.map((t) => t.order ?? 0));

    const newTests: Test[] = noteOrder.map((note) => ({
      id: `${Date.now()}-${Math.random()}`,
      name: note,
      questions: groups[note],
      categories: Array.from(new Set(testCategories)),
      order: ++baseOrder,
    }));

    setSavedTests((prev) => [...prev, ...newTests]);
    setTests((prev) =>
      Array.from(new Set([...prev, ...newTests.map((t) => t.name)])),
    );
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
      categories: Array.from(
        new Set(editingTest.categories ?? [...categoryOptions]),
      ),
    };

    setSavedTests((prev) =>
      prev.map((t) => (t.id === editingTest.id ? withCategories : t)),
    );
    setEditingTest(null);
  };

  const deleteTest = (id: string) => {
    if (!window.confirm("Sigur dorești să ștergi testul?")) return;
    const updated = savedTests.filter((t) => t.id !== id);
    setSavedTests(updated);
    setTests(Array.from(new Set(updated.map((t) => t.name))));
    if (selectedTestId === id) setSelectedTestId(null);
    if (editingTest && editingTest.id === id) setEditingTest(null);
    savePrevTestsRequest(updated);
  };

  const deleteAllTests = () => {
    if (!window.confirm("Sigur dorești să ștergi toate testele?")) return;
    setSavedTests([]);
    setTests([]);
    setSelectedTestId(null);
    setEditingTest(null);
    savePrevTestsRequest([]);
  };

  const moveTest = (id: string, dir: number) => {
    setSavedTests((prev) => {
      const idx = prev.findIndex((t) => t.id === id);
      if (idx === -1) return prev;
      const test = prev[idx];
      const sameSubject = prev.sort((a, b) => (a.order ?? 0) - (b.order ?? 0));
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
      }),
    );
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
                {(editingTest ? editingTest.questions : questions).map(
                  (q, qi) => (
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
                                copy[qi].text =
                                  editingQuestions[qi].trim() || copy[qi].text;
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
                              setEditingQuestions((s) => ({
                                ...s,
                                [qi]: q.text,
                              }))
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
                              onChange={() =>
                                toggleCorrect(qi, ai, !!editingTest)
                              }
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
                                        editingAnswers[key].trim() || a,
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
                                  onClick={() =>
                                    toggleCorrect(qi, ai, !!editingTest)
                                  }
                                >
                                  {String.fromCharCode(65 + ai)}. {a}
                                </span>
                                <Button
                                  size="sm"
                                  variant="ghost"
                                  onClick={() =>
                                    setEditingAnswers((s) => ({
                                      ...s,
                                      [key]: a,
                                    }))
                                  }
                                >
                                  Editează
                                </Button>
                                <Button
                                  size="sm"
                                  variant="ghost"
                                  onClick={() =>
                                    deleteAnswer(qi, ai, !!editingTest)
                                  }
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
                  ),
                )}
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
                          <span>Regenerează explicația</span>
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
                      value={editingExplanations[qi] ?? q.explanation ?? ""}
                      onChange={(e) =>
                        setEditingExplanations((s) => ({
                          ...s,
                          [qi]: e.target.value,
                        }))
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
                    <input
                      className="w-full border rounded p-2 mt-2"
                      placeholder="Materia"
                      value={q.subject || ""}
                      onChange={(e) => {
                        const val = e.target.value;
                        setQuestions((prev) => {
                          const copy = [...prev];
                          copy[qi].subject = val;
                          return copy;
                        });
                      }}
                    />
                    <input
                      className="w-full border rounded p-2 mt-2"
                      placeholder="Articole"
                      value={(q.articles || []).join(", ")}
                      onChange={(e) => {
                        const parts = e.target.value
                          .split(",")
                          .map((x) => x.trim())
                          .filter(Boolean);
                        setQuestions((prev) => {
                          const copy = [...prev];
                          copy[qi].articles = parts;
                          return copy;
                        });
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
                    {(q.articles && q.articles.length > 0) || q.subject ? (
                      <p className="text-sm text-gray-500">
                        {q.articles && q.articles.length > 0 && (
                          <>Articole: {q.articles.join("; ")} </>
                        )}
                        {q.subject && `Materia: ${q.subject}`}
                      </p>
                    ) : null}
                    {(q.themes?.length || q.theme) && (
                      <p className="text-sm text-gray-500">
                        Stabilire tema:{" "}
                        {q.themes ? q.themes.join(", ") : q.theme}
                      </p>
                    )}
                    <div className="flex items-center space-x-2">
                      {categoryOptions.map((cat) => (
                        <label
                          key={cat}
                          className="flex items-center space-x-1"
                        >
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
                  <Button onClick={publishTest} disabled={!selectedTest}>
                    Publică
                  </Button>
                  <Button
                    onClick={publishTestsByNote}
                    disabled={questions.length === 0}
                  >
                    Publică pe notă
                  </Button>
                </div>
              </div>
            )}
          </div>
        );
      case "teme":
        return (
          <div className="space-y-4">
            {!selectedTestId && !editingTest && (
              <>
                <div className="flex items-center justify-between mb-4">
                  <h3 className="text-lg font-semibold">Teste</h3>
                  <div className="space-x-2">
                    <Button
                      onClick={generateExplanationsForAllTests}
                      disabled={Object.values(loadingAllExp).some(Boolean)}
                    >
                      Generează pentru toate
                    </Button>
                    <Button variant="destructive" onClick={deleteAllTests}>
                      Șterge toate
                    </Button>
                  </div>
                </div>
                <ul className="pl-4 space-y-1">
                  {savedTests
                    .sort((a, b) => (a.order ?? 0) - (b.order ?? 0))
                    .map((test) => (
                      <li key={test.id} className="flex items-center space-x-1">
                        <span
                          className="flex-1 cursor-pointer hover:text-blue-500 text-sm whitespace-nowrap"
                          onClick={() => setSelectedTestId(test.id)}
                        >
                          {test.name}
                          {expDone[test.id] && (
                            <span className="text-green-600 text-xs ml-1">
                              ✓
                            </span>
                          )}
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
                        <Button
                          size="sm"
                          onClick={() => generateAllExplanations(test.id)}
                          disabled={loadingAllExp[test.id]}
                        >
                          {loadingAllExp[test.id] ? "..." : "Generează"}
                        </Button>
                        {intervalOptions.map((opt) => (
                          <label
                            key={opt.label}
                            className="flex items-center space-x-1 text-xs"
                          >
                            <input
                              type="checkbox"
                              checked={selectedIntervals.includes(opt.label)}
                              onChange={() =>
                                setSelectedIntervals((prev) =>
                                  prev.includes(opt.label)
                                    ? prev.filter((i) => i !== opt.label)
                                    : [...prev, opt.label],
                                )
                              }
                            />
                            <span>{opt.label}</span>
                          </label>
                        ))}
                        <Button
                          size="sm"
                          onClick={() => assignSubjects(test.id)}
                          disabled={loadingSubjects[test.id]}
                        >
                          {loadingSubjects[test.id]
                            ? "..."
                            : "Stabilește materia"}
                        </Button>
                        {subjectsDone[test.id] && (
                          <span className="text-green-600 text-xs">✓</span>
                        )}
                        {intervalOptions.map((opt) => (
                          <label
                            key={`s-${opt.label}`}
                            className="flex items-center space-x-1 text-xs"
                          >
                            <input
                              type="checkbox"
                              checked={subjectIntervals.includes(opt.label)}
                              onChange={() =>
                                setSubjectIntervals((prev) =>
                                  prev.includes(opt.label)
                                    ? prev.filter((i) => i !== opt.label)
                                    : [...prev, opt.label],
                                )
                              }
                            />
                            <span>{opt.label}</span>
                          </label>
                        ))}
                      </li>
                    ))}
                </ul>
              </>
            )}
            {(selectedTestId || editingTest) && (
              <>
                <Button
                  variant="secondary"
                  className="mb-4"
                  onClick={() => {
                    setSelectedTestId(null);
                    setEditingTest(null);
                  }}
                >
                  Înapoi la teste
                </Button>
                {selectedTestId && !editingTest && (
                  <>
                    <div className="flex justify-between items-start mb-4">
                      <div>
                        <h3 className="text-lg font-semibold">
                          {
                            savedTests.find((t) => t.id === selectedTestId)
                              ?.name
                          }
                        </h3>
                        <div className="flex items-center space-x-2 mt-1">
                          {categoryOptions.map((cat) => (
                            <label
                              key={cat}
                              className="flex items-center space-x-1"
                            >
                              <input
                                type="checkbox"
                                checked={savedTests
                                  .find((t) => t.id === selectedTestId)
                                  ?.categories?.includes(cat)}
                                onChange={() =>
                                  toggleSavedTestCategory(selectedTestId, cat)
                                }
                              />
                              <span>{cat}</span>
                            </label>
                          ))}
                        </div>
                        <div className="flex items-center space-x-2 mt-2 flex-wrap">
                          <Button
                            onClick={() => generateAllExplanations()}
                            disabled={loadingAllExp[selectedTestId ?? ""]}
                          >
                            {loadingAllExp[selectedTestId ?? ""]
                              ? "Se generează..."
                              : "Activează explicațiile"}
                          </Button>
                          {expDone[selectedTestId ?? ""] && (
                            <span className="text-green-600 text-xs">✓</span>
                          )}
                          <Button
                            onClick={() => regenerateAllExplanations()}
                            disabled={loadingAllExp[selectedTestId ?? ""]}
                          >
                            {loadingAllExp[selectedTestId ?? ""]
                              ? "Se generează..."
                              : "Regenerează explicațiile"}
                          </Button>
                          <Button
                            onClick={assignArticles}
                            disabled={loadingAllExp[selectedTestId ?? ""]}
                          >
                            Stabilește articolele
                          </Button>
                          <Button
                            onClick={() => assignSubjects()}
                            disabled={loadingSubjects[selectedTestId ?? ""]}
                          >
                            {loadingSubjects[selectedTestId ?? ""]
                              ? "..."
                              : "Stabilește materia"}
                          </Button>
                          {subjectsDone[selectedTestId ?? ""] && (
                            <span className="text-green-600 text-xs">✓</span>
                          )}
                          {intervalOptions.map((opt) => (
                            <label
                              key={opt.label}
                              className="flex items-center space-x-1 text-sm"
                            >
                              <input
                                type="checkbox"
                                checked={selectedIntervals.includes(opt.label)}
                                onChange={() =>
                                  setSelectedIntervals((prev) =>
                                    prev.includes(opt.label)
                                      ? prev.filter((i) => i !== opt.label)
                                      : [...prev, opt.label],
                                  )
                                }
                              />
                              <span>{opt.label}</span>
                            </label>
                          ))}
                          {intervalOptions.map((opt) => (
                            <label
                              key={`s-${opt.label}`}
                              className="flex items-center space-x-1 text-sm"
                            >
                              <input
                                type="checkbox"
                                checked={subjectIntervals.includes(opt.label)}
                                onChange={() =>
                                  setSubjectIntervals((prev) =>
                                    prev.includes(opt.label)
                                      ? prev.filter((i) => i !== opt.label)
                                      : [...prev, opt.label],
                                  )
                                }
                              />
                              <span>{opt.label}</span>
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
                              const t = savedTests.find(
                                (x) => x.id === selectedTestId,
                              );
                              return t
                                ? {
                                    ...t,
                                    categories: t.categories ?? [
                                      "INM",
                                      "Barou",
                                      "INR",
                                    ],
                                  }
                                : null;
                            })
                          }
                        >
                          Editează
                        </Button>
                      </div>
                    </div>
                    {savedTests
                      .find((t) => t.id === selectedTestId)
                      ?.questions.map((q, qi) => (
                        <div
                          key={qi}
                          className={cn(
                            "border-t pt-4 space-y-1",
                            q.inTheme && "bg-green-100",
                          )}
                        >
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
                            <p className="text-sm text-gray-600">
                              Nota: {q.note}
                            </p>
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
                          {(q.articles && q.articles.length > 0) ||
                          q.subject ? (
                            <p className="text-sm text-gray-500">
                              {q.articles && q.articles.length > 0 && (
                                <>Articole: {q.articles.join("; ")} </>
                              )}
                              {q.subject && `Materia: ${q.subject}`}
                            </p>
                          ) : null}
                          {(q.themes?.length || q.theme) && (
                            <p className="text-sm text-gray-500">
                              Stabilire tema:{" "}
                              {q.themes ? q.themes.join(", ") : q.theme}
                            </p>
                          )}
                          {addMenuIndex === qi ? (
                            <div className="flex items-center space-x-2 pl-4">
                              <select
                                className="border p-1 rounded flex-1"
                                value={selectedThemeId}
                                onChange={(e) =>
                                  setSelectedThemeId(e.target.value)
                                }
                              >
                                <option value="">Selectează tema</option>
                                {allThemes.map((t) => (
                                  <option key={t.id} value={t.id}>
                                    {t.name}
                                    {t.subject ? ` - ${t.subject}` : ""}
                                  </option>
                                ))}
                              </select>
                              <Button
                                size="sm"
                                onClick={() => {
                                  if (!selectedThemeId) return;
                                  if (!q.subject || !q.subject.trim()) {
                                    alert(
                                      "Selectează materia apoi trimite grila",
                                    );
                                    return;
                                  }
                                  const th = allThemes.find(
                                    (t) => t.id === selectedThemeId,
                                  );
                                  if (
                                    th &&
                                    th.subject &&
                                    q.subject.trim().toLowerCase() !==
                                      th.subject.trim().toLowerCase()
                                  ) {
                                    alert(
                                      "Materia grilei nu corespunde cu materia temei",
                                    );
                                    return;
                                  }
                                  addQuestionToTheme(
                                    q,
                                    selectedThemeId,
                                    selectedTestId!,
                                    qi,
                                  );
                                  setAddMenuIndex(null);
                                  setSelectedThemeId("");
                                }}
                              >
                                Adaugă
                              </Button>
                            </div>
                          ) : (
                            <Button
                              variant="ghost"
                              size="sm"
                              className="ml-4"
                              onClick={() => setAddMenuIndex(qi)}
                            >
                              + Adaugă în temă
                            </Button>
                          )}
                          <button
                            className="ml-2 text-blue-600"
                            onClick={() =>
                              selectedTestId &&
                              autoAssignQuestionToTheme(q, qi, selectedTestId)
                            }
                          >
                            <span className="material-icons text-sm">send</span>
                          </button>
                        </div>
                      ))}
                  </>
                )}
                {editingTest && (
                  <>
                    <input
                      className="border p-2 rounded w-full mb-2"
                      value={editingTest.name}
                      onChange={(e) =>
                        setEditingTest((prev) =>
                          prev ? { ...prev, name: e.target.value } : prev,
                        )
                      }
                    />
                    <div className="flex items-center space-x-2 mb-2">
                      {categoryOptions.map((cat) => (
                        <label
                          key={cat}
                          className="flex items-center space-x-1"
                        >
                          <input
                            type="checkbox"
                            checked={editingTest.categories?.includes(cat)}
                            onChange={() =>
                              setEditingTest((prev) => {
                                if (!prev) return prev;
                                const current = prev.categories ?? [
                                  ...categoryOptions,
                                ];
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
                      <Button
                        size="sm"
                        variant="secondary"
                        onClick={() => addQuestion(true)}
                      >
                        Adaugă grilă
                      </Button>
                    </div>
                    {editingTest.questions.map((q, qi) => (
                      <div
                        key={qi}
                        className={cn(
                          "border-t pt-4 space-y-1",
                          q.inTheme && "bg-green-100",
                        )}
                      >
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
                                  const copy = {
                                    ...prev,
                                    questions: [...prev.questions],
                                  };
                                  copy.questions[qi].text =
                                    editingQuestions[qi].trim() ||
                                    copy.questions[qi].text;
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
                                setEditingQuestions((s) => ({
                                  ...s,
                                  [qi]: q.text,
                                }))
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
                              disabled={
                                qi === (editingTest?.questions.length ?? 0) - 1
                              }
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
                                ? "Se generează..."
                                : "Regenerează explicația"}
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
                                        const copy = {
                                          ...prev,
                                          questions: [...prev.questions],
                                        };
                                        copy.questions[qi].answers[ai] =
                                          stripAnswerPrefix(
                                            editingAnswers[key].trim() || a,
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
                                      setEditingAnswers((s) => ({
                                        ...s,
                                        [key]: a,
                                      }))
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
                                    const copy = {
                                      ...prev,
                                      questions: [...prev.questions],
                                    };
                                    copy.questions[qi].answers.push(
                                      stripAnswerPrefix(addingAnswer[qi]),
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
                              const copy = {
                                ...prev,
                                questions: [...prev.questions],
                              };
                              copy.questions[qi].note = val;
                              return copy;
                            });
                          }}
                        />
                        <textarea
                          className="w-full border rounded p-2 mt-2"
                          placeholder="Explicație"
                          value={q.explanation || ""}
                          onChange={(e) => {
                            const val = e.target.value;
                            setEditingTest((prev) => {
                              if (!prev) return prev;
                              const copy = {
                                ...prev,
                                questions: [...prev.questions],
                              };
                              copy.questions[qi].explanation = val;
                              return copy;
                            });
                          }}
                        />
                        <input
                          className="w-full border rounded p-2 mt-2"
                          placeholder="Materia"
                          value={q.subject || ""}
                          onChange={(e) => {
                            const val = e.target.value;
                            setEditingTest((prev) => {
                              if (!prev) return prev;
                              const copy = {
                                ...prev,
                                questions: [...prev.questions],
                              };
                              copy.questions[qi].subject = val;
                              return copy;
                            });
                          }}
                        />
                        <input
                          className="w-full border rounded p-2 mt-2"
                          placeholder="Articole"
                          value={(q.articles || []).join(", ")}
                          onChange={(e) => {
                            const parts = e.target.value
                              .split(",")
                              .map((x) => x.trim())
                              .filter(Boolean);
                            setEditingTest((prev) => {
                              if (!prev) return prev;
                              const copy = {
                                ...prev,
                                questions: [...prev.questions],
                              };
                              copy.questions[qi].articles = parts;
                              return copy;
                            });
                          }}
                        />
                        <div className="flex items-center space-x-2 mt-1">
                          {categoryOptions.map((cat) => (
                            <label
                              key={cat}
                              className="flex items-center space-x-1"
                            >
                              <input
                                type="checkbox"
                                checked={q.categories?.includes(cat)}
                                onChange={() =>
                                  toggleQuestionCategory(qi, cat, true)
                                }
                              />
                              <span>{cat}</span>
                            </label>
                          ))}
                        </div>
                      </div>
                    ))}
                    <div className="text-right">
                      <Button onClick={updateTest}>Publică</Button>
                    </div>
                  </>
                )}
              </>
            )}
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
                    {t.name}
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
      case "articole_teme":
        return (
          <div className="space-y-4">
            {allThemes.map((t) => (
              <div key={t.id} className="space-y-1 border-b pb-2">
                <p className="font-semibold">
                  {t.name}
                  {t.subject ? ` - ${t.subject}` : ""}
                </p>
                <input
                  className="border p-1 rounded w-full"
                  placeholder="Ex: 230-270, 300-320"
                  value={themeRanges[t.id] || ""}
                  onChange={(e) =>
                    setThemeRanges((prev) => ({
                      ...prev,
                      [t.id]: e.target.value,
                    }))
                  }
                />
                <Button size="sm" onClick={() => saveThemeRange(t.id)}>
                  Salvează
                </Button>
              </div>
            ))}
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
