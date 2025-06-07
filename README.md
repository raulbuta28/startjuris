# startjuris

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Backend API

The Flutter app communicates with the Go backend to load and update the legal
codes. The backend exposes a WebSocket endpoint at `/api/code-updates` which
emits a message whenever a code is modified from the React dashboard. The
`ModernCodeReader` page listens to this WebSocket so changes made in the
dashboard appear in the app automatically.

When running the app you can specify the backend base URL with
`--dart-define=API_URL=http://your-server:8080`.
