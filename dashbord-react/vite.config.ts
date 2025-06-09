import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  envDir: '..',
  base: '/controlpanel/',
  plugins: [react()],
  publicDir: '../assets',
  resolve: {
    alias: {
      '@': path.resolve(__dirname, 'src'),
    },
  },
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
