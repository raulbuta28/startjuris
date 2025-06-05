import React, { useEffect, useState } from 'react';
import ReactQuill from 'react-quill';

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

interface Book {
  id: string;
  title: string;
  image: string;
  content: string;
}

interface Post {
  id: string;
  title: string;
  description: string;
  details: string;
  imageUrl: string;
  date: string;
}

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
}

function Materie({ books, onUpdate }: MaterieProps) {
  const [selected, setSelected] = useState<Book | null>(null);
  const [form, setForm] = useState({ title: '', image: '', content: '' });

  const categories = [
    { prefix: 'civil', label: 'Drept civil' },
    { prefix: 'dpc', label: 'Drept procesual civil' },
    { prefix: 'dp_', label: 'Drept penal' },
    { prefix: 'dpp', label: 'Drept procesual penal' },
  ];

  const filter = (p: string) => books.filter((b) => b.id.startsWith(p));

  const handleSelect = (b: Book) => {
    setSelected(b);
    setForm({ title: b.title, image: b.image, content: b.content });
  };

  const save = () => {
    if (!selected) return;
    const updated = books.map((b) => (b.id === selected.id ? { ...b, ...form } : b));
    onUpdate(updated);
    setSelected(null);
  };

  return (
    <div className="space-y-6">
      {categories.map((cat) => (
        <BookCarousel
          key={cat.prefix}
          title={cat.label}
          books={filter(cat.prefix)}
          onSelect={handleSelect}
        />
      ))}
      {selected && (
        <div className="bg-white border p-4 rounded space-y-4">
          <h3 className="font-semibold text-lg">Edit {selected.title}</h3>
          <input
            className="w-full border p-2 rounded"
            value={form.title}
            onChange={(e) => setForm({ ...form, title: e.target.value })}
            placeholder="Title"
          />
          <input
            className="w-full border p-2 rounded"
            value={form.image}
            onChange={(e) => setForm({ ...form, image: e.target.value })}
            placeholder="Image URL"
          />
          <ReactQuill theme="snow" value={form.content} onChange={(v) => setForm({ ...form, content: v })} />
          <div className="flex space-x-2">
            <button className="px-4 py-2 bg-blue-600 text-white rounded" onClick={save}>Save</button>
            <button className="px-4 py-2 bg-gray-200 rounded" onClick={() => setSelected(null)}>Cancel</button>
          </div>
        </div>
      )}
    </div>
  );
}

interface NoutatiProps {
  posts: Post[];
  onUpdate: (posts: Post[]) => void;
}

function Noutati({ posts, onUpdate }: NoutatiProps) {
  const [form, setForm] = useState({
    title: '',
    description: '',
    details: '',
    imageUrl: '',
  });

  const addPost = () => {
    const newPost: Post = {
      id: Date.now().toString(),
      title: form.title,
      description: form.description,
      details: form.details,
      imageUrl: form.imageUrl,
      date: new Date().toISOString(),
    };
    onUpdate([...posts, newPost]);
    setForm({ title: '', description: '', details: '', imageUrl: '' });
  };

  return (
    <div className="space-y-6">
      <div className="bg-white border p-4 rounded space-y-4">
        <h3 className="font-semibold text-lg">Adauga postare</h3>
        <input
          className="w-full border p-2 rounded"
          placeholder="Titlu"
          value={form.title}
          onChange={(e) => setForm({ ...form, title: e.target.value })}
        />
        <input
          className="w-full border p-2 rounded"
          placeholder="Descriere"
          value={form.description}
          onChange={(e) => setForm({ ...form, description: e.target.value })}
        />
        <input
          className="w-full border p-2 rounded"
          placeholder="Image URL"
          value={form.imageUrl}
          onChange={(e) => setForm({ ...form, imageUrl: e.target.value })}
        />
        <ReactQuill theme="snow" value={form.details} onChange={(v) => setForm({ ...form, details: v })} />
        <button className="px-4 py-2 bg-blue-600 text-white rounded" onClick={addPost}>Save</button>
      </div>
      <div className="space-y-3">
        {posts.map((p) => (
          <div key={p.id} className="bg-white border p-4 rounded">
            <h4 className="font-semibold">{p.title}</h4>
            <p className="text-sm text-gray-600">{p.description}</p>
          </div>
        ))}
      </div>
    </div>
  );
}

function Dashboard() {
  const [books, setBooks] = useState<Book[]>([]);
  const [posts, setPosts] = useState<Post[]>([]);
  const [section, setSection] = useState('materie');

  useEffect(() => {
    fetch('/api/books')
      .then((r) => r.json())
      .then(setBooks);
    fetch('/api/posts')
      .then((r) => r.json())
      .then(setPosts);
  }, []);

  const updateBooks = (updated: Book[]) => {
    setBooks(updated);
    fetch('/api/save-books', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(updated),
    });
  };

  const updatePosts = (updated: Post[]) => {
    setPosts(updated);
    fetch('/api/save-posts', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(updated),
    });
  };

  const renderSection = () => {
    if (section === 'materie') {
      return <Materie books={books} onUpdate={updateBooks} />;
    } else if (section === 'noutati') {
      return <Noutati posts={posts} onUpdate={updatePosts} />;
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
