import React, { useEffect, useState } from "react"
import { Card, CardContent } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { motion, AnimatePresence } from "framer-motion"

interface Article {
  id: string
  number: string
  title: string
  content: string
  notes?: string[]
  references?: string[]
}

interface CodeSection {
  id: string
  title: string
  subsections: CodeSection[]
  articles: Article[]
}

interface Chapter {
  id: string
  title: string
  sections: CodeSection[]
}

interface CodeTitle {
  id: string
  title: string
  chapters: Chapter[]
}

interface Book {
  id: string
  title: string
  titles: CodeTitle[]
}

interface ParsedCode {
  id: string
  title: string
  books: Book[]
}

interface CodeInfo {
  id: string
  title: string
  lastUpdated: string
}

export default function CodeEditor() {
  const [codes, setCodes] = useState<CodeInfo[]>([])
  const [active, setActive] = useState("")
  const [structure, setStructure] = useState<ParsedCode | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState("")
  const [editingId, setEditingId] = useState<string | null>(null)

  useEffect(() => {
    setLoading(true)
    fetch("/api/codes")
      .then(async (r) => {
        if (!r.ok) throw new Error("Failed to load codes")
        return r.json()
      })
      .then((list: CodeInfo[]) => {
        setCodes(list)
        if (list.length > 0) setActive(list[0].id)
      })
      .catch((err) => setError(err.message))
      .finally(() => setLoading(false))
  }, [])

  useEffect(() => {
    if (!active) return
    setLoading(true)
    setError("")
    setStructure(null)
    fetch(`/api/parsed-code/${active}`)
      .then(async (r) => {
        const data = await r.json()
        if (!r.ok || (data as any).error) {
          throw new Error((data as any).error || "Failed to load")
        }
        return data
      })
      .then((d: ParsedCode) => setStructure(d))
      .catch((err) => setError(err.message))
      .finally(() => setLoading(false))
  }, [active])

  const updateArticle = (id: string, field: keyof Article, value: string) => {
    if (!structure) return
    const walk = (sections: CodeSection[]): boolean => {
      for (const sec of sections) {
        for (const art of sec.articles) {
          if (art.id === id) {
            ;(art as any)[field] = value
            return true
          }
        }
        if (walk(sec.subsections)) return true
      }
      return false
    }
    for (const b of structure.books || []) {
      for (const t of b.titles || []) {
        for (const ch of t.chapters || []) {
          if (walk(ch.sections || [])) {
            setStructure({ ...structure })
            return
          }
        }
      }
    }
  }

  const save = () => {
    if (!structure) return
    fetch(`/api/save-parsed-code/${structure.id}`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${localStorage.getItem("token") || ""}`,
      },
      body: JSON.stringify(structure),
    })
  }

  const renderArticles = (sec: CodeSection) => (
    <div className="ml-4 space-y-2">
      {sec.articles?.map((a) => {
        const editing = editingId === a.id
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
                  <div className="whitespace-pre-wrap">{a.content}</div>
                </>
              )}

              <AnimatePresence>
                {(a.notes || []).map((n, idx) => (
                  <motion.div
                    key={idx}
                    className="border border-gray-300 bg-gray-50 p-2 text-xs"
                    initial={{ opacity: 0, y: -2 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: -2 }}
                  >
                    {n}
                  </motion.div>
                ))}
                {(a.references || []).map((r, idx) => (
                  <motion.div
                    key={`ref-${idx}`}
                    className="border border-gray-300 bg-gray-50 p-2 text-xs"
                    initial={{ opacity: 0, y: -2 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: -2 }}
                  >
                    {r}
                  </motion.div>
                ))}
              </AnimatePresence>
              <div className="text-right">
                {editing ? (
                  <Button size="sm" onClick={() => { setEditingId(null); save(); }}>
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
        )
      })}
      {sec.subsections?.map((s) => (
        <div key={s.id} className="ml-4">
          <h5 className="font-semibold mt-4">{s.title}</h5>
          {renderArticles(s)}
        </div>
      ))}
    </div>
  )

  const renderChapter = (ch: Chapter) => (
    <div key={ch.id} className="ml-2">
      <h4 className="font-semibold mt-4">{ch.title}</h4>
      {ch.sections?.map((sec) => (
        <div key={sec.id} className="ml-2">
          <h5 className="font-semibold mt-4">{sec.title}</h5>
          {renderArticles(sec)}
        </div>
      ))}
    </div>
  )

  const renderTitle = (t: CodeTitle) => (
    <div key={t.id} className="ml-2">
      <h3 className="font-semibold mt-4">{t.title}</h3>
      {t.chapters?.map((ch) => renderChapter(ch))}
    </div>
  )

  const renderBook = (b: Book) => (
    <div key={b.id}>
      <h2 className="font-bold mt-6">{b.title}</h2>
      {b.titles?.map((t) => renderTitle(t))}
    </div>
  )

  if (loading) return <div>Loading...</div>
  if (error) return <div className="text-red-600">{error}</div>
  if (!structure) return <div>No data</div>

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
  )
}
