# Backend and Dashboard Updates

This file documents changes made to improve the code editor and backend.

## Changes
- Paths to `codes.json` and the directory with text codes are now resolved
  relative to the project root so the backend works no matter where it is
  executed.
- New utility to detect the repository root and updated all file operations to
  use absolute paths derived from it.
- Added error checking for `bufio.Scanner` in `parseCodeFile` so parsing failures
  are reported.
- The React `CodeEditor` now handles API errors and displays a loading state.
- Token and user data files are saved relative to the repository root so the
  backend can reload authentication info regardless of the working directory.

## New in this attempt
- Increased the buffer size in `parseCodeFile` to avoid errors on very long lines.
- The backend now prints the detected repository root and reports parsing errors
  when preloading code files to help diagnose missing content issues.

## Changes in this fix
- The React dashboard now persists the login state in `localStorage`, ensuring
  the admin remains logged in even if a page refresh occurs when loading the
  code editor.
- Added a small logout button which clears the stored flag so testing remains
  simple.

## Additional update
- Switched the dashboard login to use the backend `/auth/login` endpoint.
  Successful authentication stores the returned token in `localStorage`.
- All save requests now send this token in an `Authorization` header so the
  backend can verify the admin session.
- The app verifies any stored token on load via `/api/profile` to keep the user
  logged in across refreshes and prevent unintended logouts when opening the
  code editor.

