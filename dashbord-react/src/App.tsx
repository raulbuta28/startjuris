import React, { useEffect, useState, useRef } from 'react';
import BookEditor, { Book as BookType } from './BookEditor';
import NewsEditor, { NewsItem } from './NewsEditor';
import CodurileLaZi from './CodurileLaZi';
import CodeTextTabs from './CodeTextTabs';
import Grile from './Grile';
import GrileAniAnteriori from './GrileAniAnteriori';
import TesteSuplimentare from './TesteSuplimentare';
import TesteCombinate from './TesteCombinate';
import Simulari from './Simulari';
import BancaDeGrile from './BancaDeGrile';
import UtilizatoriAbonamente from './UtilizatoriAbonamente';

interface LoginProps {
  onLogin: () => void;
}

function Login({ onLogin }: LoginProps) {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    try {
      const res = await fetch('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ username, password }),
      });
      const data = await res.json();
      if (!res.ok) {
        setError(data.error || 'Login failed');
        return;
      }
      localStorage.setItem('token', data.token);
      localStorage.setItem('logged', 'true');
      onLogin();
    } catch (err: any) {
      setError(err.message);
    }
  };

  return (
    <div className="max-w-sm mx-auto mt-40 bg-white p-6 rounded shadow">
      <h3 className="text-xl font-semibold mb-4 text-center">Admin Login</h3>
      <form onSubmit={handleSubmit} className="space-y-4">
        <input
          className="w-full border p-2 rounded"
          placeholder="Username"
          value={username}
          onChange={(e) => setUsername(e.target.value)}
        />
        <input
          className="w-full border p-2 rounded"
          type="password"
          placeholder="Password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
        />
        {error && (
          <div className="text-sm text-red-600 text-center">{error}</div>
        )}
        <button className="w-full bg-blue-600 text-white py-2 rounded" type="submit">
          Login
        </button>
      </form>
    </div>
  );
}

const sections = [
  { key: 'materie', label: 'Materie', icon: 'menu_book' },
  { key: 'codurile_la_zi', label: 'Codurile la zi', icon: 'library_books' },
  { key: 'codurile_2_0', label: 'Codurile 2.0', icon: 'library_books' },
  { key: 'noutati', label: 'Noutati', icon: 'feed' },
  { key: 'grile', label: 'Grile', icon: 'view_list' },
  { key: 'grile_anterioare', label: 'Grile anii anteriori', icon: 'history_edu' },
  { key: 'suplimentare', label: 'Teste suplimentare', icon: 'note_add' },
  { key: 'combinate', label: 'Teste combinate', icon: 'playlist_add' },
  { key: 'simulari', label: 'Simulari', icon: 'quiz' },
  { key: 'banca', label: 'Banca de grile', icon: 'library_books' },
  { key: 'meciuri', label: 'Grile meciuri', icon: 'sports_esports' },
  { key: 'utilizatori', label: 'Utilizatori/Abonamente', icon: 'people' },
];

interface SidebarProps {
  active: string;
  onSelect: (key: string) => void;
}

function Sidebar({ active, onSelect }: SidebarProps) {
  return (
    <div className="w-56 bg-white border-r h-full">
      <ul>
        {sections.map((s) => (
          <li
            key={s.key}
            className={`flex items-center p-4 cursor-pointer hover:bg-gray-100 ${active === s.key ? 'bg-gray-100' : ''}`}
            onClick={() => onSelect(s.key)}
          >
            <span className="material-icons mr-3">{s.icon}</span>
            {s.label}
          </li>
        ))}
      </ul>
    </div>
  );
}

type Book = BookType;

interface Theme {
  id: string;
  name: string;
  subject?: string;
  articleInterval?: string;
}

interface BookCarouselProps {
  title: string;
  books: Book[];
  onSelect: (b: Book) => void;
  onDelete: (b: Book) => void;
  onAdd: () => void;
}

function BookCarousel({ title, books, onSelect, onDelete, onAdd }: BookCarouselProps) {
  return (
    <div className="mb-6">
      <h3 className="font-semibold text-lg mb-2">{title}</h3>
      <div className="flex space-x-3 overflow-x-auto pb-2">
        {books.map((b) => (
          <div
            className="relative w-36 flex-shrink-0 bg-white border rounded p-2"
            key={b.id}
          >
            <button
              className="absolute top-0 right-0 text-red-600"
              onClick={() => onDelete(b)}
            >
              <span className="material-icons text-sm">close</span>
            </button>
            <div className="cursor-pointer" onClick={() => onSelect(b)}>
              <img className="w-full" src={b.image} alt={b.title} />
              <div className="mt-2 text-sm text-center">{b.title}</div>
            </div>
          </div>
        ))}
        <button
          className="w-36 h-48 flex-shrink-0 border-2 border-dashed flex items-center justify-center text-gray-500"
          onClick={onAdd}
        >
          <span className="material-icons">add</span>
        </button>
      </div>
    </div>
  );
}

interface MaterieProps {
  books: Book[];
  onUpdate: (books: Book[]) => void;
  onEdit: (b: Book) => void;
}

function Materie({ books, onUpdate, onEdit }: MaterieProps) {

  const categories = [
    { prefix: 'civil', label: 'Drept civil' },
    { prefix: 'dpc', label: 'Drept procesual civil' },
    { prefix: 'dp_', label: 'Drept penal' },
    { prefix: 'dpp', label: 'Drept procesual penal' },
    { prefix: 'inm', label: 'Admitere INM' },
    { prefix: 'barou', label: 'Admitere Barou' },
    { prefix: 'not', label: 'Admitere INR (notariat)' },
    { prefix: 'sng', label: 'Admitere SNG' },
    { prefix: 'sj', label: 'Colectia startJuris' },
  ];

  const filter = (p: string) => books.filter((b) => b.id.startsWith(p));

  const nextId = (prefix: string) => {
    const nums = books
      .filter((b) => b.id.startsWith(prefix))
      .map((b) => parseInt(b.id.replace(prefix, '').replace('_', ''), 10))
      .filter((n) => !isNaN(n));
    const max = nums.length ? Math.max(...nums) : 0;
    return `${prefix}${prefix.endsWith('_') ? '' : '_'}${max + 1}`;
  };

  const handleDelete = (b: Book) => {
    const updated = books.filter((x) => x.id !== b.id);
    onUpdate(updated);
  };

  const handleAdd = (prefix: string) => {
    const nb: Book = { id: nextId(prefix), title: 'New Book', image: '', content: '', subject: '', articleInterval: '' };
    onEdit(nb);
  };

  return (
    <div className="space-y-6">
      {categories.map((cat) => (
        <BookCarousel
          key={cat.prefix}
          title={cat.label}
          books={filter(cat.prefix)}
          onSelect={onEdit}
          onDelete={handleDelete}
          onAdd={() => handleAdd(cat.prefix)}
        />
      ))}
    </div>
  );
}

interface NewsProps {
  items: NewsItem[];
  onUpdate: (items: NewsItem[]) => void;
  onEdit: (n: NewsItem) => void;
}

function NewsList({ items, onUpdate, onEdit }: NewsProps) {
  const handleDelete = (n: NewsItem) => {
    const updated = items.filter((x) => x.id !== n.id);
    onUpdate(updated);
  };

  const handleAdd = () => {
    const n: NewsItem = {
      id: Date.now().toString(),
      title: 'New News',
      description: '',
      details: '',
      imageUrl: '',
      date: new Date().toISOString(),
    };
    onEdit(n);
  };

  return (
    <div className="space-y-4">
      {items.map((n) => (
        <div key={n.id} className="border p-2 flex items-center">
          {n.imageUrl && (
            <img src={n.imageUrl} alt={n.title} className="w-24 h-16 object-cover mr-4" />
          )}
          <div className="flex-1">
            <div className="font-semibold">{n.title}</div>
            <div className="text-sm text-gray-600">{n.description}</div>
          </div>
          <button className="text-red-600 mr-2" onClick={() => handleDelete(n)}>
            <span className="material-icons text-sm">close</span>
          </button>
          <button className="text-blue-600" onClick={() => onEdit(n)}>
            <span className="material-icons text-sm">edit</span>
          </button>
        </div>
      ))}
      <button
        className="w-36 h-24 border-2 border-dashed flex items-center justify-center text-gray-500"
        onClick={handleAdd}
      >
        <span className="material-icons">add</span>
      </button>
    </div>
  );
}

interface DashboardProps {
  onLogout: () => void;
}

function Dashboard({ onLogout }: DashboardProps) {
  const [books, setBooks] = useState<Book[]>([]);
  const [news, setNews] = useState<NewsItem[]>([]);
  const [themes, setThemes] = useState<Theme[]>([]);
  const [section, setSection] = useState('materie');
  const [editingBook, setEditingBook] = useState<Book | null>(null);
  const [editingNews, setEditingNews] = useState<NewsItem | null>(null);

  useEffect(() => {
    const token = localStorage.getItem('token') || '';

    fetch('/api/books', { headers: { Authorization: `Bearer ${token}` } })
      .then(async (r) => {
        if (!r.ok) {
          const txt = await r.text().catch(() => '');
          console.error('failed to fetch books', txt);
          return [] as Book[];
        }
        return (await r.json()) as Book[];
      })
      .then((data) => {
        if (Array.isArray(data)) setBooks(data);
      });

    fetch('/api/news', { headers: { Authorization: `Bearer ${token}` } })
      .then(async (r) => {
        if (!r.ok) {
          const txt = await r.text().catch(() => '');
          console.error('failed to fetch news', txt);
          return [] as NewsItem[];
        }
        return (await r.json()) as NewsItem[];
      })
      .then((data) => {
        if (Array.isArray(data)) setNews(data);
      });

    fetch('/api/tests', { headers: { Authorization: `Bearer ${token}` } })
      .then((r) => (r.ok ? r.json() : []))
      .then((data: Theme[]) => {
        if (Array.isArray(data)) setThemes(data);
      })
      .catch(() => {});
  }, []);

  const updateBooks = (updated: Book[]) => {
    setBooks(updated);
    fetch('/api/save-books', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${localStorage.getItem('token') || ''}`,
      },
      body: JSON.stringify(updated),
    });
  };

  const updateNews = (updated: NewsItem[]) => {
    setNews(updated);
    fetch('/api/save-news', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${localStorage.getItem('token') || ''}`,
      },
      body: JSON.stringify(updated),
    });
  };

  const importedRef = useRef(false);
  useEffect(() => {
    if (importedRef.current || themes.length === 0) return;
    importedRef.current = true;
    const prefixMap: Record<string, string> = {
      'Drept civil': 'civil',
      'Drept procesual civil': 'dpc',
      'Drept penal': 'dp_',
      'Drept procesual penal': 'dpp',
    };
    const existing = new Set(books.map((b) => b.id));
    const extra: Book[] = [];
    themes.forEach((t) => {
      const base = {
        title: t.name,
        image: '',
        content: '',
        subject: t.subject,
        articleInterval: t.articleInterval,
      } as Book;
      const pref = prefixMap[t.subject || ''];
      if (pref) {
        const id = `${pref}_t${t.id}`;
        if (!existing.has(id)) {
          extra.push({ ...base, id });
          existing.add(id);
        }
      }
      ['inm', 'barou', 'not'].forEach((p) => {
        const id = `${p}_t${t.id}`;
        if (!existing.has(id)) {
          extra.push({ ...base, id });
          existing.add(id);
        }
      });
    });
    if (extra.length) {
      const updated = [...books, ...extra];
      updateBooks(updated);
    }
  }, [themes, books]);

  const renderSection = () => {
    if (editingBook) {
      return (
        <BookEditor
          book={editingBook}
          onSave={(b) => {
            let updated: Book[];
            if (books.some((x) => x.id === b.id)) {
              updated = books.map((x) => (x.id === b.id ? b : x));
            } else {
              updated = [...books, b];
            }
            updateBooks(updated);
            setEditingBook(null);
          }}
          onCancel={() => setEditingBook(null)}
        />
      );
    }
    if (editingNews) {
      return (
        <NewsEditor
          news={editingNews}
          onSave={(n) => {
            let updated: NewsItem[];
            if (news.some((x) => x.id === n.id)) {
              updated = news.map((x) => (x.id === n.id ? n : x));
            } else {
              updated = [...news, n];
            }
            updateNews(updated);
            setEditingNews(null);
          }}
          onCancel={() => setEditingNews(null)}
        />
      );
    }
    if (section === 'materie') {
      return <Materie books={books} onUpdate={updateBooks} onEdit={setEditingBook} />;
    }
    if (section === 'noutati') {
      return <NewsList items={news} onUpdate={updateNews} onEdit={setEditingNews} />;
    }
    if (section === 'codurile_la_zi') {
      return <CodurileLaZi />;
    }
    if (section === 'codurile_2_0') {
      return <CodeTextTabs />;
    }
    if (section === 'suplimentare') {
      return <TesteSuplimentare />;
    }
    if (section === 'combinate') {
      return <TesteCombinate />;
    }
    if (section === 'simulari') {
      return <Simulari />;
    }
    if (section === 'banca') {
      return <BancaDeGrile />;
    }
    if (section === 'utilizatori') {
      return <UtilizatoriAbonamente />;
    }
    if (section === 'grile_anterioare') {
      return <GrileAniAnteriori />;
    }
    if (section === 'grile') {
      return <Grile />;
    }
    const s = sections.find((x) => x.key === section);
    return (
      <div className="p-6">
        <h2 className="text-xl font-semibold mb-2">{s?.label}</h2>
        <p>Coming soon...</p>
      </div>
    );
  };

  return (
    <div className="flex h-screen">
      <Sidebar active={section} onSelect={setSection} />
      <div className="flex-1 overflow-y-auto p-6">
        <div className="text-right mb-4">
          <button
            className="text-sm text-blue-600"
          onClick={() => {
              localStorage.removeItem('logged');
              localStorage.removeItem('token');
              onLogout();
            }}
          >
            Logout
          </button>
        </div>
        {renderSection()}
      </div>
    </div>
  );
}

function App() {
  const [logged, setLogged] = useState(
    () => localStorage.getItem('token') !== null
  );

  useEffect(() => {
    if (logged) {
      localStorage.setItem('logged', 'true');
    } else {
      localStorage.removeItem('logged');
      localStorage.removeItem('token');
    }
  }, [logged]);

  useEffect(() => {
    const token = localStorage.getItem('token');
    if (!token) return;
    fetch('/api/profile', {
      headers: { Authorization: `Bearer ${token}` },
    })
      .then((r) => {
        if (!r.ok) {
          if (r.status === 401) {
            // remove the token only if the server reports it is invalid
            localStorage.removeItem('token');
            setLogged(false);
          }
        } else {
          setLogged(true);
        }
      })
      .catch((err) => {
        // network or server error should not immediately log the user out
        console.error('profile check failed', err);
      });
  }, []);

  return logged ? (
    <Dashboard onLogout={() => setLogged(false)} />
  ) : (
    <Login onLogin={() => setLogged(true)} />
  );
}

export default App;
