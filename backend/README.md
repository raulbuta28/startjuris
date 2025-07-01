# Golang Backend

This simple backend provides:

- **/auth/register**: POST JSON `{"username":"user","email":"e","password":"pass"}` to create a user.  Usernames and emails must be unique. Legacy `/register` remains for compatibility.
- **/auth/login**: POST JSON to authenticate using either `username` or `email` along with `password`. Legacy `/login` also works.
- **/profile**: GET returns the authenticated user's data using an `Authorization: Bearer <token>` header.
- **/profile**: PUT updates the user's profile fields (`username`, `email`, `bio`, `phone`).
- **/profile/avatar**: POST multipart form with an `avatar` file to upload a profile picture. Files are saved under `data/uploads/avatars/` and served from `/uploads`.
- **/books/upload-file**: POST an EPUB file. The server saves it under `data/uploads/ebook/` and automatically extracts the first page as the cover image, returning both the file and cover URLs.
- **/files**: GET list of all files in the project directory.
- **/codes**: GET list of all available legal codes saved from the React dashboard.
- **/codes/:id**: GET the full structure of a specific code in JSON form.
- **/save-code/:id**: POST JSON to update a code from the dashboard.

All Go dependencies are vendored so the project can be built without network access.

Run with:

```bash
go run .
```

This compiles all Go files in the directory, including `parser.go` which
defines helper functions used by `main.go`.

The server listens on `localhost:8080`. Bind to your machine's IP address or
`0.0.0.0` if you need to access it from other devices on your network.

### Persistent data

Uploaded books, tests and other editable content are stored inside the
`data/` directory located at the project root. To keep this information in
a custom location, set the `DATA_DIR` environment variable before starting
the server. Pointing this variable to a directory on a mounted volume is the
recommended way to ensure your files survive server restarts or moving the
application online.
