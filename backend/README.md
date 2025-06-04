# Golang Backend

This simple backend provides:

- **/auth/register**: POST JSON `{"username":"user","email":"e","password":"pass"}` to create a user. Legacy `/register` remains for compatibility.
 - **/auth/login**: POST JSON to authenticate using either `username` or `email` along with `password`. Legacy `/login` also works.
- **/profile**: GET returns the authenticated user's data using an `Authorization: Bearer <token>` header.
- **/files**: GET list of all files in the project directory.

All Go dependencies are vendored so the project can be built without network access.

Run with:

```bash
go run .
```

This compiles all Go files in the directory, including `parser.go` which
defines helper functions used by `main.go`.

The server listens on `localhost:8080`.
