import React, { useEffect, useState } from 'react';
import { Button } from '@/components/ui/button';
import { filterCodeText } from './codurilelazi/filtru';

interface CodeTab {
  id: string;
  label: string;
}

const codes: CodeTab[] = [
  { id: 'civil', label: 'Codul civil' },
  { id: 'penal', label: 'Codul penal' },
  { id: 'proc_civil', label: 'Codul de procedura civila' },
  { id: 'proc_penal', label: 'Codul de procedura penala' },
];

interface Article {
  number: string;
  title: string;
  content: string[];
  amendments: string[];
}

interface Note {
  type: 'Note' | 'Decision';
  content: string[];
}

interface Section {
  type: string;
  name: string;
  content: (Section | Article | Note)[];
}

export default function CodeTextTabs() {
  const [active, setActive] = useState<string>(codes[0].id);
  const [texts, setTexts] = useState<Record<string, Section[]>>({});
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [editingSection, setEditingSection] = useState<string | null>(null);
  const [editingArticle, setEditingArticle] = useState<string | null>(null);
  const [editingNote, setEditingNote] = useState<string | null>(null);
  const [editSectionName, setEditSectionName] = useState('');
  const [editArticle, setEditArticle] = useState<Article | null>(null);
  const [editNoteContent, setEditNoteContent] = useState('');

  useEffect(() => {
    if (texts[active]) return;
    fetchData();
  }, [active]);

  const fetchData = () => {
    setLoading(true);
    setError('');
    fetch(`/api/code-text-json/${active}`)
      .then(async (r) => {
        if (r.ok) {
          return r.json();
        }
        if (r.status === 404) {
          const res = await fetch(`/api/code-text/${active}`);
          if (!res.ok) throw new Error('Failed to load');
          const txt = await res.text();
          const filtered = filterCodeText(txt);
          return parseText(filtered);
        }
        throw new Error('Failed to load');
      })
      .then((data) => {
        setTexts((t) => ({ ...t, [active]: data }));
      })
      .catch((err: any) => {
        setError(err.message || 'Error');
      })
      .finally(() => setLoading(false));
  };

  const handleRefresh = () => {
    setTexts((prev) => {
      const newTexts = { ...prev };
      delete newTexts[active];
      return newTexts;
    });
    fetchData();
  };

  const handleSaveAll = () => {
    const data = texts[active];
    fetch(`/api/save-code-text/${active}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${localStorage.getItem('token') || ''}`,
      },
      body: JSON.stringify(data),
    }).catch(() => {});
  };

  function parseText(text: string): Section[] {
    const lines = text.split('\n').map(line => line.trim()).filter(line => line);
    const structure: Section[] = [];
    let currentHierarchy: Section[] = [];
    let currentArticle: Article | null = null;
    let currentNote: Note | null = null;
    let currentAmendments: string[] = [];

    const amendmentRegex = /^\(la \d{2}-\d{2}-\d{4},.*\)$/;
    const sectionRegex = /^(Cartea|Titlul|Capitolul|Secţiunea|Subsecţiunea)\s+([IVXLC]+|[a-zA-Z\s\d-]+(\*\*\))?)$/i;
    const articleRegex = /^Articolul\s+(\d+)\s*(?:-\s*(.+))?$/;
    const noteRegex = /^Notă$/;
    const decisionRegex = /^Decizie de admitere:/;

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];

      if (amendmentRegex.test(line)) {
        if (currentArticle) {
          currentAmendments.push(line);
        }
        continue;
      }

      if (noteRegex.test(line) || decisionRegex.test(line)) {
        if (currentArticle) {
          currentArticle.amendments = [...currentAmendments];
          currentAmendments = [];
          const parent = currentHierarchy[currentHierarchy.length - 1] || { content: structure };
          parent.content.push(currentArticle);
          currentArticle = null;
        }
        if (currentNote) {
          const parent = currentHierarchy[currentHierarchy.length - 1] || { content: structure };
          parent.content.push(currentNote);
        }
        currentNote = {
          type: noteRegex.test(line) ? 'Note' : 'Decision',
          content: [line],
        };
        continue;
      }

      const sectionMatch = line.match(sectionRegex);
      if (sectionMatch) {
        if (currentArticle) {
          currentArticle.amendments = [...currentAmendments];
          currentAmendments = [];
          const parent = currentHierarchy[currentHierarchy.length - 1] || { content: structure };
          parent.content.push(currentArticle);
          currentArticle = null;
        }
        if (currentNote) {
          const parent = currentHierarchy[currentHierarchy.length - 1] || { content: structure };
          parent.content.push(currentNote);
          currentNote = null;
        }
        const [, type, name] = sectionMatch;
        const cleanName = name.replace(/\*\*\)/, '').trim();
        const newSection: Section = { type, name: cleanName, content: [] };
        
        if (type === 'Cartea') {
          structure.push(newSection);
          currentHierarchy = [newSection];
        } else {
          const parent = currentHierarchy[currentHierarchy.length - 1] || { content: structure };
          parent.content.push(newSection);
          currentHierarchy.push(newSection);
        }
        continue;
      }

      const articleMatch = line.match(articleRegex);
      if (articleMatch) {
        if (currentArticle) {
          currentArticle.amendments = [...currentAmendments];
          currentAmendments = [];
          const parent = currentHierarchy[currentHierarchy.length - 1] || { content: structure };
          parent.content.push(currentArticle);
        }
        if (currentNote) {
          const parent = currentHierarchy[currentHierarchy.length - 1] || { content: structure };
          parent.content.push(currentNote);
          currentNote = null;
        }
        
        const [, number, title = ''] = articleMatch;
        currentArticle = { number, title, content: [], amendments: [] };
        continue;
      }

      if (currentNote) {
        currentNote.content.push(line);
      } else if (currentArticle) {
        currentArticle.content.push(line);
      } else if (currentHierarchy.length > 0) {
        const parent = currentHierarchy[currentHierarchy.length - 1];
        if (!parent.content.length || 'type' in parent.content[parent.content.length - 1]) {
          const newArticle = { number: '', title: '', content: [line], amendments: [] };
          parent.content.push(newArticle);
        } else {
          (parent.content[parent.content.length - 1] as Article).content.push(line);
        }
      } else {
        const newSection: Section = {
          type: 'Miscellaneous',
          name: 'Introductory Notes',
          content: [{ number: '', title: '', content: [line], amendments: [] }],
        };
        structure.push(newSection);
        currentHierarchy.push(newSection);
      }
    }

    if (currentArticle) {
      currentArticle.amendments = [...currentAmendments];
      const parent = currentHierarchy[currentHierarchy.length - 1] || { content: structure };
      parent.content.push(currentArticle);
    }
    if (currentNote) {
      const parent = currentHierarchy[currentHierarchy.length - 1] || { content: structure };
      parent.content.push(currentNote);
    }

    return structure;
  }

  function handleEditSection(sectionId: string, name: string) {
    setEditingSection(sectionId);
    setEditSectionName(name);
  }

  function handleSaveSection(sectionId: string, sections: Section[]): Section[] {
    return sections.map(section => {
      if (`${section.type}-${section.name}` === sectionId) {
        return { ...section, name: editSectionName };
      }
      return { ...section, content: handleSaveSection(sectionId, section.content) };
    });
  }

  function handleDeleteSection(sectionId: string, sections: Section[] = []): Section[] {
    return sections.filter(section => `${section.type}-${section.name}` !== sectionId);
  }

  function handleEditArticle(articleId: string, article: Article) {
    setEditingArticle(articleId);
    setEditArticle({ ...article });
  }

  function handleSaveArticle(sectionId: string, sections: Section[]): Section[] {
    return sections.map(section => {
      if (`${section.type}-${section.name}` === sectionId) {
        return {
          ...section,
          content: section.content.map(item =>
            'type' in item
              ? item
              : `${item.number}-${item.title}` === editingArticle && editArticle
              ? { ...editArticle }
              : item
          ),
        };
      }
      return { ...section, content: handleSaveArticle(sectionId, section.content) };
    });
  }

  function handleDeleteArticle(articleId: string, sections: Section[]): Section[] {
    return sections.map(section => ({
      ...section,
      content: section.content
        .filter(item => !('number' in item && `${item.number}-${item.title}` === articleId))
        .map(item => 'type' in item ? { ...item, content: handleDeleteArticle(articleId, [item])[0].content } : item),
    }));
  }

  function handleAddArticle(sectionId: string) {
    setTexts((prev) => ({
      ...prev,
      [active]: prev[active].map(section => {
        if (`${section.type}-${section.name}` === sectionId) {
          return {
            ...section,
            content: [
              ...section.content,
              { number: '', title: 'New Article', content: [], amendments: [] },
            ],
          };
        }
        return {
          ...section,
          content: section.content.map(item =>
            'type' in item ? { ...item, content: handleAddArticle(sectionId, [item])[0].content } : item
          ),
        };
      }),
    }));
  }

  function handleEditNote(noteId: string, content: string[]) {
    setEditingNote(noteId);
    setEditNoteContent(content.join('\n'));
  }

  function updateNoteInContent(
    noteId: string,
    updater: (n: Note) => Note,
    content: (Section | Article | Note)[]
  ): (Section | Article | Note)[] {
    return content.map((item, idx) => {
      if ('type' in item) {
        if (item.type === 'Note' || item.type === 'Decision') {
          const currentId = `${item.type}-${idx}`;
          return currentId === noteId ? updater(item) : item;
        }
        return {
          ...item,
          content: updateNoteInContent(noteId, updater, item.content),
        };
      }
      return item;
    });
  }

  function deleteNoteFromContent(
    noteId: string,
    content: (Section | Article | Note)[]
  ): (Section | Article | Note)[] {
    return content.reduce<(Section | Article | Note)[]>((acc, item, idx) => {
      if ('type' in item) {
        if (item.type === 'Note' || item.type === 'Decision') {
          const currentId = `${item.type}-${idx}`;
          if (currentId !== noteId) acc.push(item);
        } else {
          acc.push({
            ...item,
            content: deleteNoteFromContent(noteId, item.content),
          });
        }
      } else {
        acc.push(item);
      }
      return acc;
    }, []);
  }

  function handleSaveNote(noteId: string, sections: Section[]): Section[] {
    return sections.map(section => ({
      ...section,
      content: updateNoteInContent(noteId, n => ({
        ...n,
        content: editNoteContent
          .split('\n')
          .filter(line => line.trim()),
      }), section.content),
    }));
  }

  function handleDeleteNote(noteId: string, sections: Section[]): Section[] {
    return sections.map(section => ({
      ...section,
      content: deleteNoteFromContent(noteId, section.content),
    }));
  }

  function renderSection(section: Section, level: number = 0) {
    const sectionId = `${section.type}-${section.name}`;
    return (
      <div key={sectionId} className={`ml-${level * 2}`}>
        {editingSection === sectionId ? (
          <div className="flex items-center space-x-2">
            <input
              className="border rounded p-1 text-lg"
              value={editSectionName}
              onChange={(e) => setEditSectionName(e.target.value)}
            />
            <Button
              variant="outline"
              onClick={() => {
                setTexts((prev) => ({
                  ...prev,
                  [active]: handleSaveSection(sectionId, prev[active]),
                }));
                setEditingSection(null);
              }}
            >
              Save
            </Button>
            <Button variant="outline" onClick={() => setEditingSection(null)}>
              Cancel
            </Button>
          </div>
        ) : (
          <div className="flex items-center space-x-2">
            <h3 className="font-semibold text-lg mt-2">{section.type} {section.name}</h3>
            <Button variant="outline" size="sm" onClick={() => handleEditSection(sectionId, section.name)}>
              Edit
            </Button>
            <Button
              variant="outline"
              size="sm"
              onClick={() =>
                setTexts((prev) => ({
                  ...prev,
                  [active]: handleDeleteSection(sectionId, prev[active]),
                }))
              }
            >
              Delete
            </Button>
            <Button variant="outline" size="sm" onClick={() => handleAddArticle(sectionId)}>
              Add Article
            </Button>
          </div>
        )}
        {section.content.map((item, index) =>
          'type' in item ? (
            item.type === 'Note' || item.type === 'Decision' ? (
              renderNote(item as Note, index)
            ) : (
              renderSection(item as Section, level + 1)
            )
          ) : (
            renderArticle(item as Article, sectionId, index)
          )
        )}
      </div>
    );
  }

  function renderArticle(article: Article, sectionId: string, index: number) {
    const articleId = `${article.number}-${article.title}`;
    return (
      <div key={articleId} className="my-4">
        {editingArticle === articleId ? (
          <div className="space-y-2">
            <input
              className="border rounded p-1"
              placeholder="Number"
              value={editArticle?.number || ''}
              onChange={(e) => setEditArticle({ ...editArticle!, number: e.target.value })}
            />
            <input
              className="border rounded p-1 w-full"
              placeholder="Title"
              value={editArticle?.title || ''}
              onChange={(e) => setEditArticle({ ...editArticle!, title: e.target.value })}
            />
            <textarea
              className="border rounded p-1 w-full"
              placeholder="Content"
              value={editArticle?.content.join('\n') || ''}
              onChange={(e) => setEditArticle({ ...editArticle!, content: e.target.value.split('\n') })}
            />
            <textarea
              className="border rounded p-1 w-full"
              placeholder="Amendments"
              value={editArticle?.amendments.join('\n') || ''}
              onChange={(e) => setEditArticle({ ...editArticle!, amendments: e.target.value.split('\n') })}
            />
            <Button
              variant="outline"
              onClick={() => {
                setTexts((prev) => ({
                  ...prev,
                  [active]: handleSaveArticle(sectionId, prev[active]),
                }));
                setEditingArticle(null);
                setEditArticle(null);
              }}
            >
              Save
            </Button>
            <Button variant="outline" onClick={() => { setEditingArticle(null); setEditArticle(null); }}>
              Cancel
            </Button>
          </div>
        ) : (
          <>
            {article.number && (
              <div className="flex items-center space-x-2">
                <h4 className="font-bold text-base">
                  Articolul {article.number} {article.title && `- ${article.title}`}
                </h4>
                <Button variant="outline" size="sm" onClick={() => handleEditArticle(articleId, article)}>
                  Edit
                </Button>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() =>
                    setTexts((prev) => ({
                      ...prev,
                      [active]: handleDeleteArticle(articleId, prev[active]),
                    }))
                  }
                >
                  Delete
                </Button>
              </div>
            )}
            {article.title && (
              <p className="text-sm whitespace-pre-wrap mt-1">{article.title}</p>
            )}
            {article.content.map((line, i) => (
              <p key={i} className="text-sm whitespace-pre-wrap">{line}</p>
            ))}
            {article.amendments.length > 0 && (
              <div className="mt-2 p-2 border rounded bg-gradient-to-r from-gray-100 to-gray-200">
                {article.amendments.map((amendment, i) => (
                  <p key={i} className="text-sm text-gray-700">{amendment}</p>
                ))}
              </div>
            )}
          </>
        )}
      </div>
    );
  }

  function renderNote(note: Note, index: number) {
    const noteId = `${note.type}-${index}`;
    return (
      <div key={noteId} className="my-4">
        {editingNote === noteId ? (
          <div className="space-y-2">
            <textarea
              className="border rounded p-1 w-full"
              value={editNoteContent}
              onChange={(e) => setEditNoteContent(e.target.value)}
            />
            <Button
              variant="outline"
              onClick={() => {
                setTexts((prev) => ({
                  ...prev,
                  [active]: handleSaveNote(noteId, prev[active]),
                }));
                setEditingNote(null);
                setEditNoteContent('');
              }}
            >
              Save
            </Button>
            <Button variant="outline" onClick={() => { setEditingNote(null); setEditNoteContent(''); }}>
              Cancel
            </Button>
          </div>
        ) : (
          <div className="p-2 border rounded bg-gray-50">
            <div className="flex items-center space-x-2">
              <span className="text-sm">{note.type}</span>
              <Button variant="outline" size="sm" onClick={() => handleEditNote(noteId, note.content)}>
                Edit
              </Button>
              <Button
                variant="outline"
                size="sm"
                onClick={() =>
                  setTexts((prev) => ({
                    ...prev,
                    [active]: handleDeleteNote(noteId, prev[active]),
                  }))
                }
              >
                Delete
              </Button>
            </div>
            {note.content.map((line, i) => (
              <p key={i} className="text-sm whitespace-pre-wrap">{line}</p>
            ))}
          </div>
        )}
      </div>
    );
  }

  return (
    <div className="space-y-4">
      <div className="border-b mb-4 space-x-2">
        {codes.map((c) => (
          <Button
            key={c.id}
            variant={active === c.id ? 'default' : 'secondary'}
            onClick={() => setActive(c.id)}
          >
            {c.label}
          </Button>
        ))}
        <Button variant="outline" onClick={handleRefresh}>
          Reîmprospătează
        </Button>
        <Button variant="outline" onClick={handleSaveAll}>
          Salvează
        </Button>
      </div>
      {loading ? (
        <div>Loading...</div>
      ) : error ? (
        <div className="text-red-600">{error}</div>
      ) : texts[active] ? (
        <div className="text-sm">
          {texts[active].map(section => renderSection(section))}
        </div>
      ) : null}
    </div>
  );
}
