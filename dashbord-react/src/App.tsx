import React, { useEffect, useState } from 'react';
import BookEditor, { Book as BookType } from './BookEditor';

interface LoginProps {
  onLogin: () => void;
}

function Login({ onLogin }: LoginProps) {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (username === 'admin' && password === 'admin') {
      onLogin();
    } else {
      alert('Invalid credentials');
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
        <button className="w-full bg-blue-600 text-white py-2 rounded" type="submit">
          Login
        </button>
      </form>
    </div>
  );
}

const sections = [
  { key: 'materie', label: 'Materie', icon: 'menu_book' },
  { key: 'codes', label: 'Codurile actualizate', icon: 'library_books' },
  { key: 'noutati', label: 'Noutati', icon: 'feed' },
  { key: 'grile', label: 'Grile', icon: 'view_list' },
  { key: 'meciuri', label: 'Grile meciuri', icon: 'sports_esports' },
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

interface BookCarouselProps {
  title: string;
  books: Book[];
  onSelect: (b: Book) => void;
}

function BookCarousel({ title, books, onSelect }: BookCarouselProps) {
  return (
    <div className="mb-6">
      <h3 className="font-semibold text-lg mb-2">{title}</h3>
      <div className="flex space-x-3 overflow-x-auto pb-2">
        {books.map((b) => (
          <div
            className="w-36 flex-shrink-0 bg-white border rounded p-2 cursor-pointer"
            key={b.id}
            onClick={() => onSelect(b)}
          >
            <img className="w-full" src={b.image} alt={b.title} />
            <div className="mt-2 text-sm text-center">{b.title}</div>
          </div>
        ))}
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

  return (
    <div className="space-y-6">
      {categories.map((cat) => (
        <BookCarousel
          key={cat.prefix}
          title={cat.label}
          books={filter(cat.prefix)}
          onSelect={onEdit}
        />
      ))}
    </div>
  );
}

function Dashboard() {
  const [books, setBooks] = useState<Book[]>([]);
  const [section, setSection] = useState('materie');
  const [editing, setEditing] = useState<Book | null>(null);

  useEffect(() => {
    fetch('/api/books')
      .then((r) => r.json())
      .then(setBooks);
  }, []);

  const updateBooks = (updated: Book[]) => {
    setBooks(updated);
    fetch('/api/save-books', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(updated),
    });
  };

  const renderSection = () => {
    if (editing) {
      return (
        <BookEditor
          book={editing}
          onSave={(b) => {
            const updated = books.map((x) => (x.id === b.id ? b : x));
            updateBooks(updated);
            setEditing(null);
          }}
          onCancel={() => setEditing(null)}
        />
      );
    }
    if (section === 'materie') {
      return <Materie books={books} onUpdate={updateBooks} onEdit={setEditing} />;
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
      <div className="flex-1 overflow-y-auto p-6">{renderSection()}</div>
    </div>
  );
}

function App() {
  const [logged, setLogged] = useState(false);
  return logged ? <Dashboard /> : <Login onLogin={() => setLogged(true)} />;
}

export default App;
