import React, { useState } from 'react';

export interface Book {
  id: string;
  title: string;
  image: string;
  content: string;
  file?: string;
  subject?: string;
  articleInterval?: string;
}

interface EditorProps {
  book: Book;
  onSave: (b: Book) => void;
  onCancel: () => void;
}


export default function BookEditor({ book, onSave, onCancel }: EditorProps) {
  const [form, setForm] = useState({ ...book });
  const [uploading, setUploading] = useState(false);

  const handleBookFile = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    const fd = new FormData();
    fd.append('file', file);
    setUploading(true);
    try {
      const res = await fetch('/api/books/upload-file', {
        method: 'POST',
        body: fd,
      });
      const data = await res.json();
      setForm({ ...form, file: data.fileUrl || '', image: data.coverUrl || form.image });
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
        {form.image && (
          <img src={form.image} alt="preview" className="w-32" />
        )}
        <input type="file" accept=".epub" onChange={handleBookFile} />
        {uploading && <div className="text-sm text-gray-500">Uploading...</div>}
      </div>
      <button
        className="px-4 py-2 bg-blue-600 text-white rounded"
        onClick={save}
      >
        Save
      </button>
    </div>
  );
}
