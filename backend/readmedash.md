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

