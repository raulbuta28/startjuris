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

    setUploading(true);
    let cover = form.image;

    if (file.type === 'application/pdf') {
      try {
        const pdfjs = await import('pdfjs-dist/legacy/build/pdf.mjs');
        pdfjs.GlobalWorkerOptions.workerSrc =
          `https://cdn.jsdelivr.net/npm/pdfjs-dist@${pdfjs.version}/legacy/build/pdf.worker.min.mjs`;
        const buf = await file.arrayBuffer();
        const doc = await pdfjs.getDocument({ data: buf }).promise;
        const page = await doc.getPage(1);
        const viewport = page.getViewport({ scale: 1.5 });
        const canvas = document.createElement('canvas');
        canvas.width = viewport.width;
        canvas.height = viewport.height;
        const ctx = canvas.getContext('2d');
        if (ctx) {
          await page.render({ canvasContext: ctx, viewport }).promise;
          const blob: Blob | null = await new Promise((res) =>
            canvas.toBlob(res, 'image/png')
          );
          if (blob) {
            const fd = new FormData();
            fd.append('image', blob, 'cover.png');
            const up = await fetch('/api/books/upload-image', {
              method: 'POST',
              body: fd,
            });
            const d = await up.json();
            if (d.url) cover = d.url;
          }
        }
      } catch (err) {
        console.error('Failed to extract PDF cover', err);
      }
    }

    const fd = new FormData();
    fd.append('file', file);
    try {
      const res = await fetch('/api/books/upload-file', {
        method: 'POST',
        body: fd,
      });
      const data = await res.json();
      setForm({ ...form, file: data.fileUrl || '', image: cover || form.image });
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
        <input type="file" accept=".epub,.pdf" onChange={handleBookFile} />
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
