import React, { useState } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import {
  parseRawCode,
  Article,
  CodeSection,
  Chapter,
  CodeTitle,
  Book,
  ParsedCode,
} from "@/lib/parseCode";

export default function RawCodeEditor() {
  const [raw, setRaw] = useState("");
  const [structure, setStructure] = useState<ParsedCode | null>(null);
  const [editingId, setEditingId] = useState<string | null>(null);

  const parse = () => {
    const parsed = parseRawCode(raw);
    setStructure(parsed);
  };

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
    for (const b of structure.books) {
      for (const t of b.titles) {
        for (const ch of t.chapters) {
          if (walk(ch.sections)) {
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
    for (const b of structure.books) {
      if (b.id === id) {
        b.title = value;
        setStructure({ ...structure });
        return;
      }
      for (const t of b.titles) {
        if (t.id === id) {
          t.title = value;
          setStructure({ ...structure });
          return;
        }
        for (const ch of t.chapters) {
          if (ch.id === id) {
            ch.title = value;
            setStructure({ ...structure });
            return;
          }
          if (walk(ch.sections)) {
            setStructure({ ...structure });
            return;
          }
        }
      }
    }
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
                  onChange={(e) => updateArticle(a.id, "number", e.target.value)}
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
              {a.notes.map((n, i) => (
                <div
                  key={i}
                  className="border text-xs rounded p-1 mt-1 bg-gradient-to-r from-yellow-50 to-blue-50"
                >
                  {n}
                </div>
              ))}
            </>
          )}
          <div className="text-right">
            {editing ? (
              <Button size="sm" onClick={() => setEditingId(null)}>
                Save
              </Button>
            ) : (
              <Button variant="ghost" size="sm" onClick={() => setEditingId(a.id)}>
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
            <Button size="sm" onClick={() => setEditingId(null)}>
              Save
            </Button>
          </>
        ) : (
          <>
            <h5 className="font-semibold flex-1">{sec.title}</h5>
            <Button variant="ghost" size="sm" onClick={() => setEditingId(sec.id)}>
              Edit
            </Button>
          </>
        )}
      </div>
      <div className="ml-4 space-y-2">
        {sec.articles.map((a) => renderArticle(a))}
        {sec.subsections.map((s) => renderSection(s))}
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
            <Button size="sm" onClick={() => setEditingId(null)}>
              Save
            </Button>
          </>
        ) : (
          <>
            <h4 className="font-semibold flex-1">{ch.title}</h4>
            <Button variant="ghost" size="sm" onClick={() => setEditingId(ch.id)}>
              Edit
            </Button>
          </>
        )}
      </div>
      {ch.sections.map((sec) => renderSection(sec))}
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
            <Button size="sm" onClick={() => setEditingId(null)}>
              Save
            </Button>
          </>
        ) : (
          <>
            <h3 className="font-semibold flex-1">{t.title}</h3>
            <Button variant="ghost" size="sm" onClick={() => setEditingId(t.id)}>
              Edit
            </Button>
          </>
        )}
      </div>
      {t.chapters.map((ch) => renderChapter(ch))}
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
            <Button size="sm" onClick={() => setEditingId(null)}>
              Save
            </Button>
          </>
        ) : (
          <>
            <h2 className="font-bold flex-1">{b.title}</h2>
            <Button variant="ghost" size="sm" onClick={() => setEditingId(b.id)}>
              Edit
            </Button>
          </>
        )}
      </div>
      {b.titles.map((t) => renderTitle(t))}
    </div>
  );

  return (
    <div className="space-y-4 font-sans text-sm">
      <textarea
        className="w-full border p-2 h-48"
        value={raw}
        onChange={(e) => setRaw(e.target.value)}
        placeholder="Paste raw code text here"
      />
      <Button onClick={parse}>Parse</Button>
      {structure && (
        <div className="space-y-2 mt-4">{structure.books.map((b) => renderBook(b))}</div>
      )}
    </div>
  );
}
