import React, { useEffect, useState } from "react";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";


interface Article {
  id: string;
  number: string;
  title: string;
  content: string;
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
        if (list.length > 0) setActive(list[0].id);
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
    const walk = (sections: CodeSection[]): boolean => {
      for (const sec of sections) {
        for (const art of sec.articles) {
          if (art.id === id) {
            (art as any)[field] = value;
            return true;
          }
        }
        if (walk(sec.subsections)) return true;
      }
      return false;
    };
    for (const b of structure.books || []) {
      for (const t of b.titles || []) {
        for (const ch of t.chapters || []) {
          if (walk(ch.sections || [])) {
            setStructure({ ...structure });
            return;
          }
        }
      }
    }
  };

  const updateTitle = (id: string, value: string) => {
    if (!structure) return;
    const walk = (sections: CodeSection[]): boolean => {
      for (const sec of sections) {
        if (sec.id === id) {
          sec.title = value;
          return true;
        }
        if (walk(sec.subsections)) return true;
      }
      return false;
    };
    for (const b of structure.books || []) {
      if (b.id === id) {
        b.title = value;
        setStructure({ ...structure });
        return;
      }
      for (const t of b.titles || []) {
        if (t.id === id) {
          t.title = value;
          setStructure({ ...structure });
          return;
        }
        for (const ch of t.chapters || []) {
          if (ch.id === id) {
            ch.title = value;
            setStructure({ ...structure });
            return;
          }
          if (walk(ch.sections || [])) {
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

  const renderArticle = (a: Article) => {
    const editing = editingId === a.id;
    return (
      <Card key={a.id} className="p-2">
        <CardContent className="space-y-2">
          {editing ? (
            <>
              <div className="flex space-x-2">
                <input
                  className="border p-1 w-16"
                  value={a.number}
                  onChange={(e) =>
                    updateArticle(a.id, "number", e.target.value)
                  }
                />
                <input
                  className="border p-1 flex-1"
                  value={a.title}
                  onChange={(e) => updateArticle(a.id, "title", e.target.value)}
                />
              </div>
              <textarea
                className="w-full p-1 border"
                value={a.content}
                onChange={(e) => updateArticle(a.id, "content", e.target.value)}
              />
            </>
          ) : (
            <>
              <div className="font-semibold">{`Articolul ${a.number} - ${a.title}`}</div>
              <div className="whitespace-pre-wrap leading-snug">{a.content}</div>
            </>
          )}

          <div className="text-right">
            {editing ? (
              <Button
                size="sm"
                onClick={() => {
                  setEditingId(null);
                  save();
                }}
              >
                Save
              </Button>
            ) : (
              <Button
                variant="ghost"
                size="sm"
                onClick={() => setEditingId(a.id)}
              >
                Edit
              </Button>
            )}
          </div>
        </CardContent>
      </Card>
    );
  };

  const renderSection = (sec: CodeSection) => (
    <div key={sec.id} className="ml-4">
      <div className="flex items-center mt-4 space-x-2">
        {editingId === sec.id ? (
          <>
            <input
              className="border p-1 flex-1"
              value={sec.title}
              onChange={(e) => updateTitle(sec.id, e.target.value)}
            />
            <Button
              size="sm"
              onClick={() => {
                setEditingId(null);
                save();
              }}
            >
              Save
            </Button>
          </>
        ) : (
          <>
            <h5 className="font-semibold flex-1">{sec.title}</h5>
            <Button
              variant="ghost"
              size="sm"
              onClick={() => setEditingId(sec.id)}
            >
              Edit
            </Button>
          </>
        )}
      </div>
      <div className="ml-4 space-y-2">
        {sec.articles?.map((a) => renderArticle(a))}
        {sec.subsections?.map((s) => renderSection(s))}
      </div>
    </div>
  );

  const renderChapter = (ch: Chapter) => (
    <div key={ch.id} className="ml-2">
      <div className="flex items-center mt-4 space-x-2">
        {editingId === ch.id ? (
          <>
            <input
              className="border p-1 flex-1"
              value={ch.title}
              onChange={(e) => updateTitle(ch.id, e.target.value)}
            />
            <Button
              size="sm"
              onClick={() => {
                setEditingId(null);
                save();
              }}
            >
              Save
            </Button>
          </>
        ) : (
          <>
            <h4 className="font-semibold flex-1">{ch.title}</h4>
            <Button
              variant="ghost"
              size="sm"
              onClick={() => setEditingId(ch.id)}
            >
              Edit
            </Button>
          </>
        )}
      </div>
      {ch.sections?.map((sec) => renderSection(sec))}
    </div>
  );

  const renderTitle = (t: CodeTitle) => (
    <div key={t.id} className="ml-2">
      <div className="flex items-center mt-4 space-x-2">
        {editingId === t.id ? (
          <>
            <input
              className="border p-1 flex-1"
              value={t.title}
              onChange={(e) => updateTitle(t.id, e.target.value)}
            />
            <Button
              size="sm"
              onClick={() => {
                setEditingId(null);
                save();
              }}
            >
              Save
            </Button>
          </>
        ) : (
          <>
            <h3 className="font-semibold flex-1">{t.title}</h3>
            <Button
              variant="ghost"
              size="sm"
              onClick={() => setEditingId(t.id)}
            >
              Edit
            </Button>
          </>
        )}
      </div>
      {t.chapters?.map((ch) => renderChapter(ch))}
    </div>
  );

  const renderBook = (b: Book) => (
    <div key={b.id}>
      <div className="flex items-center mt-6 space-x-2">
        {editingId === b.id ? (
          <>
            <input
              className="border p-1 flex-1"
              value={b.title}
              onChange={(e) => updateTitle(b.id, e.target.value)}
            />
            <Button
              size="sm"
              onClick={() => {
                setEditingId(null);
                save();
              }}
            >
              Save
            </Button>
          </>
        ) : (
          <>
            <h2 className="font-bold flex-1">{b.title}</h2>
            <Button
              variant="ghost"
              size="sm"
              onClick={() => setEditingId(b.id)}
            >
              Edit
            </Button>
          </>
        )}
      </div>
      {b.titles?.map((t) => renderTitle(t))}
    </div>
  );

  if (loading) return <div>Loading...</div>;
  if (error) return <div className="text-red-600">{error}</div>;
  if (!structure) return <div>No data</div>;

  return (
    <div className="space-y-4 font-sans text-sm">
      <div className="border-b mb-4 space-x-2">
        {codes?.map((c) => (
          <Button
            key={c.id}
            variant={active === c.id ? "default" : "secondary"}
            onClick={() => setActive(c.id)}
          >
            {c.title}
          </Button>
        ))}
      </div>
      <div className="space-y-2">
        {structure.books?.map((b) => renderBook(b))}
      </div>
      <Button onClick={save}>Save</Button>
    </div>
  );
}
