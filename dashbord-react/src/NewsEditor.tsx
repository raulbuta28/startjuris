import React, { useState } from 'react';
import ReactQuill from 'react-quill';

export interface NewsItem {
  id: string;
  title: string;
  description: string;
  details: string;
  date: string;
  imageUrl: string;
}

interface EditorProps {
  news: NewsItem;
  onSave: (n: NewsItem) => void;
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

export default function NewsEditor({ news, onSave, onCancel }: EditorProps) {
  const [form, setForm] = useState({ ...news });
  const [uploading, setUploading] = useState(false);

  const handleFile = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    const fd = new FormData();
    fd.append('image', file);
    setUploading(true);
    try {
      const res = await fetch('/api/news/upload-image', {
        method: 'POST',
        body: fd,
      });
      const data = await res.json();
      if (data.url) {
        setForm({ ...form, imageUrl: data.url });
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
      <input
        className="w-full border p-2 rounded"
        value={form.description}
        onChange={e => setForm({ ...form, description: e.target.value })}
        placeholder="Short description"
      />
      <div className="space-y-2">
        <input
          className="w-full border p-2 rounded"
          value={form.imageUrl}
          onChange={e => setForm({ ...form, imageUrl: e.target.value })}
          placeholder="Image URL"
        />
        <input type="file" accept="image/*" onChange={handleFile} />
        {uploading && <div className="text-sm text-gray-500">Uploading...</div>}
        {form.imageUrl && (
          <img src={form.imageUrl} alt="preview" className="w-32" />
        )}
      </div>
      <ReactQuill
        theme="snow"
        modules={modules}
        formats={formats}
        value={form.details}
        onChange={v => setForm({ ...form, details: v })}
        style={{ height: '40vh' }}
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
