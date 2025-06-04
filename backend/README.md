# Golang Backend

This simple backend provides:

- **/auth/register**: POST JSON `{"username":"user","email":"e","password":"pass"}` to create a user.  Usernames and emails must be unique. Legacy `/register` remains for compatibility.
- **/auth/login**: POST JSON to authenticate using either `username` or `email` along with `password`. Legacy `/login` also works.
- **/profile**: GET returns the authenticated user's data using an `Authorization: Bearer <token>` header.
- **/profile**: PUT updates the user's profile fields (`username`, `email`, `bio`, `phone`).
- **/profile/avatar**: POST multipart form with an `avatar` file to upload a profile picture. Files are saved under `uploads/avatars/` and served from `/uploads`.
- **/files**: GET list of all files in the project directory.

All Go dependencies are vendored so the project can be built without network access.

Run with:

```bash
go run .
```

This compiles all Go files in the directory, including `parser.go` which
defines helper functions used by `main.go`.

The server listens on `localhost:8080`.
