const { useState, useEffect } = React;

function Login({ onLogin }) {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    if (username === 'admin' && password === 'admin') {
      onLogin();
    } else {
      alert('Invalid credentials');
    }
  };

  return (
    <div className="login">
      <h3>Admin Login</h3>
      <form onSubmit={handleSubmit}>
        <div>
          <input
            placeholder="Username"
            value={username}
            onChange={(e) => setUsername(e.target.value)}
          />
        </div>
        <div style={{ marginTop: 10 }}>
          <input
            type="password"
            placeholder="Password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
          />
        </div>
        <button style={{ marginTop: 10 }} type="submit">Login</button>
      </form>
    </div>
  );
}

const sections = [
  { key: 'materie', label: 'Materie', icon: 'menu_book' },
  { key: 'codes', label: 'Codurile actualizate', icon: 'library_books' },
  { key: 'abonamente', label: 'Abonamente', icon: 'subscriptions' },
  { key: 'comportament', label: 'Comportament', icon: 'psychology' },
  { key: 'utilizatori', label: 'Utilizatori', icon: 'people' },
  { key: 'noutati', label: 'Noutati', icon: 'feed' },
];

function Sidebar({ active, onSelect }) {
  return (
    <div className="sidebar">
      <ul>
        {sections.map((s) => (
          <li
            key={s.key}
            className={active === s.key ? 'active' : ''}
            onClick={() => onSelect(s.key)}
          >
            <span className="material-icons">{s.icon}</span>
            {s.label}
          </li>
        ))}
      </ul>
    </div>
  );
}

function BookCarousel({ title, books, onSelect }) {
  return (
    <div>
      <h3>{title}</h3>
      <div className="carousel">
        {books.map((b) => (
          <div className="book-card" key={b.id} onClick={() => onSelect(b)}>
            <img src={b.image} alt={b.title} />
            <div>{b.title}</div>
          </div>
        ))}
      </div>
    </div>
  );
}

function Materie({ books, onUpdate }) {
  const [selected, setSelected] = useState(null);
  const [form, setForm] = useState({ title: '', image: '', content: '' });

  const categories = [
    { prefix: 'civil', label: 'Drept civil' },
    { prefix: 'dpc', label: 'Drept procesual civil' },
    { prefix: 'dp_', label: 'Drept penal' },
    { prefix: 'dpp', label: 'Drept procesual penal' },
  ];

  const filter = (p) => books.filter((b) => b.id.startsWith(p));

  const handleSelect = (b) => {
    setSelected(b);
    setForm({ title: b.title, image: b.image, content: b.content });
  };

  const save = () => {
    const updated = books.map((b) =>
      b.id === selected.id ? { ...b, ...form } : b
    );
    onUpdate(updated);
    setSelected(null);
  };

  return (
    <div>
      {categories.map((cat) => (
        <BookCarousel
          key={cat.prefix}
          title={cat.label}
          books={filter(cat.prefix)}
          onSelect={handleSelect}
        />
      ))}
      {selected && (
        <div className="editor">
          <h3>Edit {selected.title}</h3>
          <input
            value={form.title}
            onChange={(e) => setForm({ ...form, title: e.target.value })}
            placeholder="Title"
          />
          <input
            value={form.image}
            onChange={(e) => setForm({ ...form, image: e.target.value })}
            placeholder="Image URL"
          />
          <textarea
            rows="6"
            value={form.content}
            onChange={(e) => setForm({ ...form, content: e.target.value })}
            placeholder="Content"
          ></textarea>
          <button onClick={save}>Save</button>
          <button onClick={() => setSelected(null)}>Cancel</button>
        </div>
      )}
    </div>
  );
}

function Dashboard() {
  const [books, setBooks] = useState([]);
  const [section, setSection] = useState('materie');

  useEffect(() => {
    fetch('/api/books')
      .then((r) => r.json())
      .then(setBooks);
  }, []);

  const updateBooks = (updated) => {
    setBooks(updated);
    fetch('/api/save-books', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(updated),
    });
  };

  const renderSection = () => {
    if (section === 'materie') {
      return <Materie books={books} onUpdate={updateBooks} />;
    }
    const s = sections.find((x) => x.key === section);
    return (
      <div className="placeholder">
        <h2>{s.label}</h2>
        <p>Coming soon...</p>
      </div>
    );
  };

  return (
    <div className="dashboard">
      <Sidebar active={section} onSelect={setSection} />
      <div className="content">{renderSection()}</div>
    </div>
  );
}

function App() {
  const [logged, setLogged] = useState(false);
  return logged ? <Dashboard /> : <Login onLogin={() => setLogged(true)} />;
}

ReactDOM.render(<App />, document.getElementById('root'));
