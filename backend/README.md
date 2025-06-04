# Golang Backend

This simple backend provides:

- **/register**: POST JSON `{"username":"user","password":"pass"}` to create a user.
- **/login**: POST JSON to authenticate.
- **/files**: GET list of all files in the project directory.

Run with:

```bash
go run main.go
```

The server listens on `localhost:8080`.
