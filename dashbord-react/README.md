# Dashbord React

This folder contains a simple admin dashboard implemented with React and TypeScript using [Vite](https://vitejs.dev/).

## Development

Install dependencies and start the development server:

```bash
npm install
npm run dev
```

The application will be available at `http://localhost:5173` by default.
API requests to paths starting with `/api` are proxied to the Go backend
running on `http://localhost:8080`. Make sure the backend server is running
for the dashboard to load the books data correctly.

## Production build

To serve the dashboard through the Go backend, first create the static files:

```bash
npm run build
```

This generates a `dist/` folder that the Go server exposes at
`http://localhost:8080/controlpanel` when running `go run ./backend` from the
project root.

