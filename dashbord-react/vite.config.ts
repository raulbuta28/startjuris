import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  publicDir: '../assets',
  server: {
    open: false,
    fs: {
      allow: ['..']
    },
    proxy: {
      '/api': 'http://localhost:8080'
    }
  }
});
