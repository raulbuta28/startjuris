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

function Dashboard() {
  const [books, setBooks] = useState([]);
  const [selected, setSelected] = useState(null);
  const [text, setText] = useState('');

  useEffect(() => {
    fetch('/api/books')
      .then((r) => r.json())
      .then(setBooks);
  }, []);

  const save = () => {
    const updated = books.map((b) =>
      b.id === selected.id ? { ...b, content: text } : b
    );
    setBooks(updated);
    setSelected(null);
    fetch('/api/save-books', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(updated),
    });
  };

  return (
    <div className="dashboard">
      <h2>Book Manager</h2>
      <div className="book-list">
        {books.map((b) => (
          <div key={b.id} className="book-item" onClick={() => { setSelected(b); setText(b.content); }}>
            <img src={b.image} width="100%" />
            <div>{b.title}</div>
          </div>
        ))}
      </div>
      {selected && (
        <div className="editor">
          <h3>Edit {selected.title}</h3>
          <textarea rows="10" cols="50" value={text} onChange={(e) => setText(e.target.value)} />
          <br />
          <button onClick={save}>Save</button>
        </div>
      )}
    </div>
  );
}

function App() {
  const [logged, setLogged] = useState(false);
  return logged ? <Dashboard /> : <Login onLogin={() => setLogged(true)} />;
}

ReactDOM.render(<App />, document.getElementById('root'));
