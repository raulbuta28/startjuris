import React, { useState } from 'react';
import ReactQuill from 'react-quill';

export interface Book {
  id: string;
  title: string;
  image: string;
  content: string;
}

interface EditorProps {
  book: Book;
  onSave: (b: Book) => void;
  onCancel: () => void;
}

const modules = {
  toolbar: [
    [{ font: [] }],
    [{ header: [1, 2, 3, false] }],
    ['bold', 'italic', 'underline', 'strike'],
    [{ color: [] }, { background: [] }],
    [{ list: 'ordered' }, { list: 'bullet' }],
    ['link', 'image'],
    ['clean']
  ]
};

const formats = [
  'header', 'font',
  'bold', 'italic', 'underline', 'strike',
  'color', 'background',
  'list', 'bullet',
  'link', 'image'
];

export default function BookEditor({ book, onSave, onCancel }: EditorProps) {
  const [form, setForm] = useState({ ...book });
  const [uploading, setUploading] = useState(false);

  const handleFile = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    const fd = new FormData();
    fd.append('image', file);
    setUploading(true);
    try {
      const res = await fetch('/api/books/upload-image', {
        method: 'POST',
        body: fd,
      });
      const data = await res.json();
      if (data.url) {
        setForm({ ...form, image: data.url });
      }
    } finally {
      setUploading(false);
    }
  };

  const save = () => {
    onSave(form);
  };

  return (
    <div className="p-6 space-y-4">
      <button className="text-blue-600" onClick={onCancel}>&larr; Back</button>
      <input
        className="w-full border p-2 rounded"
        value={form.title}
        onChange={e => setForm({ ...form, title: e.target.value })}
        placeholder="Title"
      />
      <div className="space-y-2">
        <input
          className="w-full border p-2 rounded"
          value={form.image}
          onChange={e => setForm({ ...form, image: e.target.value })}
          placeholder="Image URL"
        />
        <input type="file" accept="image/*" onChange={handleFile} />
        {uploading && <div className="text-sm text-gray-500">Uploading...</div>}
        {form.image && (
          <img src={form.image} alt="preview" className="w-32" />
        )}
      </div>
      <ReactQuill
        theme="snow"
        modules={modules}
        formats={formats}
        value={form.content}
        onChange={v => setForm({ ...form, content: v })}
        style={{ height: '70vh' }}
      />
      <button
        className="px-4 py-2 bg-blue-600 text-white rounded"
        onClick={save}
      >
        Save
      </button>
    </div>
  );
}
