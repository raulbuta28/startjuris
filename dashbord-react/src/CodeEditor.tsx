import React, { useEffect, useState } from "react";

interface Article {
  id: string;
  number: string;
  title: string;
  content: string;
  notes?: string[];
  references?: string[];
}

interface CodeSection {
  id: string;
  title: string;
  subsections: CodeSection[];
  articles: Article[];
}

interface Chapter {
  id: string;
  title: string;
  sections: CodeSection[];
}

interface CodeTitle {
  id: string;
  title: string;
  chapters: Chapter[];
}

interface Book {
  id: string;
  title: string;
  titles: CodeTitle[];
}

interface ParsedCode {
  id: string;
  title: string;
  books: Book[];
}

interface CodeInfo {
  id: string;
  title: string;
  lastUpdated: string;
}

export default function CodeEditor() {
  const [codes, setCodes] = useState<CodeInfo[]>([]);
  const [active, setActive] = useState("");
  const [structure, setStructure] = useState<ParsedCode | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [editingId, setEditingId] = useState<string | null>(null);

  useEffect(() => {
    setLoading(true);
    fetch("/api/codes")
      .then(async (r) => {
        if (!r.ok) throw new Error("Failed to load codes");
        return r.json();
      })
      .then((list: CodeInfo[]) => {
        setCodes(list);
        if (list.length > 0) {
          setActive(list[0].id);
        }
      })
      .catch((err) => setError(err.message))
      .finally(() => setLoading(false));
  }, []);

  useEffect(() => {
    if (!active) return;
    setLoading(true);
    setError("");
    setStructure(null);
    fetch(`/api/parsed-code/${active}`)
      .then(async (r) => {
        const data = await r.json();
        if (!r.ok || (data as any).error) {
          throw new Error((data as any).error || "Failed to load");
        }
        return data;
      })
      .then((d: ParsedCode) => setStructure(d))
      .catch((err) => setError(err.message))
      .finally(() => setLoading(false));
  }, [active]);


  const updateArticle = (id: string, field: keyof Article, value: string) => {
    if (!structure) return;
    const walkSections = (secs: CodeSection[]) => {
      for (const s of secs) {
        for (const a of s.articles) {
          if (a.id === id) {
            (a as any)[field] = value;
            return true;
          }
        }
        if (walkSections(s.subsections)) return true;
      }
      return false;
    };
    for (const b of structure.books || []) {
      for (const t of b.titles || []) {
        for (const ch of t.chapters || []) {
          if (walkSections(ch.sections || [])) {
            setStructure({ ...structure });
            return;
          }
        }
      }
    }
  };

  const save = () => {
    if (!structure) return;
    fetch(`/api/save-parsed-code/${structure.id}`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${localStorage.getItem("token") || ""}`,
      },
      body: JSON.stringify(structure),
    });
  };

  const renderArticles = (sec: CodeSection) => {
    const articles = sec.articles || [];
    return (
      <div className="ml-4">
        {articles.map((a) => {
          const editing = editingId === a.id;
          return (
            <div key={a.id} className="border p-2 my-2 rounded">
              {editing ? (
                <>
                  <div className="flex space-x-2 mb-1">
                    <input
                      className="border p-1 w-16"
                      value={a.number}
                      onChange={(e) => updateArticle(a.id, "number", e.target.value)}
                    />
                    <input
                      className="border p-1 flex-1"
                      value={a.title}
                      onChange={(e) => updateArticle(a.id, "title", e.target.value)}
                    />
                  </div>
                  <textarea
                    className="border p-1 w-full text-sm"
                    value={a.content}
                    onChange={(e) => updateArticle(a.id, "content", e.target.value)}
                  />
                  <button
                    className="mt-1 px-2 py-1 bg-blue-600 text-white rounded"
                    onClick={() => setEditingId(null)}
                  >
                    Done
                  </button>
                </>
              ) : (
                <>
                  <div className="font-semibold">{a.number} {a.title}</div>
                  <pre className="whitespace-pre-wrap text-sm mb-2">{a.content}</pre>
                  {a.notes &&
                    a.notes.map((n, idx) => (
                      <div
                        key={idx}
                        className="border border-gray-300 bg-gray-50 p-2 rounded text-xs mb-2"
                      >
                        {n}
                      </div>
                    ))}
                  {a.references &&
                    a.references.map((r, idx) => (
                      <div
                        key={`ref-${idx}`}
                        className="border border-gray-300 bg-gray-50 p-2 rounded text-xs mb-2"
                      >
                        {r}
                      </div>
                    ))}
                  <button
                    className="mt-1 px-2 py-1 bg-gray-200 rounded"
                    onClick={() => setEditingId(a.id)}
                  >
                    Edit
                  </button>
                </>
              )}
            </div>
          );
        })}
        {(sec.subsections || []).map((s) => renderSection(s))}
      </div>
    );
  };

  const renderSection = (sec: CodeSection) => (
    <div key={sec.id} className="ml-2">
      <h5 className="font-semibold mt-4">{sec.title}</h5>
      {renderArticles(sec)}
    </div>
  );

  const renderChapter = (ch: Chapter) => (
    <div key={ch.id} className="ml-2">
      <h4 className="font-semibold mt-4">{ch.title}</h4>
      {(ch.sections || []).map((sec) => renderSection(sec))}
    </div>
  );

  const renderTitle = (t: CodeTitle) => (
    <div key={t.id} className="ml-2">
      <h3 className="font-semibold mt-4">{t.title}</h3>
      {(t.chapters || []).map((ch) => renderChapter(ch))}
    </div>
  );

  const renderBook = (b: Book) => (
    <div key={b.id}>
      <h2 className="font-bold mt-6">{b.title}</h2>
      {(b.titles || []).map((t) => renderTitle(t))}
    </div>
  );

  if (loading) return <div>Loading...</div>;
  if (error) return <div className="text-red-600">{error}</div>;
  if (!structure) return <div>No data</div>;

  return (
    <div className="space-y-4">
      <div className="border-b mb-4 space-x-2">
        {codes.map((c) => (
          <button
            key={c.id}
            className={`px-4 py-2 rounded-t ${
              active === c.id ? "bg-blue-600 text-white" : "bg-gray-200"
            }`}
            onClick={() => setActive(c.id)}
          >
            {c.title}
          </button>
        ))}
      </div>
      <div className="space-y-2">
        {(structure.books || []).map((b) => renderBook(b))}
      </div>
      <button
        className="px-4 py-2 bg-blue-600 text-white rounded"
        onClick={save}
      >
        Save
      </button>
    </div>
  );
}
