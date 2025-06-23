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

The Flutter app communicates with the Go backend found in the `backend/` directory. Start it locally with:

```bash
cd backend
go run .
```

By default the server listens on `localhost:8080`.
If you need to reach it from other devices on your local network you can
change the address in `backend/main.go` to bind to your machine's IP or
`0.0.0.0`.

### Setting the API URL

The Flutter app reads the backend URL from the `API_URL` dart define. If not provided it defaults to an emulator friendly address. When running on an Android emulator pass:

```bash
flutter run --dart-define=API_URL=http://10.0.2.2:8080/api
```

Replace `10.0.2.2` with the IP of your backend when running on a device.

### Local data directory

The backend stores editable content such as uploaded tests or
books inside the `data/` directory. This folder is ignored by Git so
its contents do not travel with the repository. If you start with an
empty `data/` folder the dashboard pages may appear blank.

To restore the default examples the server will automatically copy the
JSON files from the repository if the corresponding files are missing in
`data/`.

