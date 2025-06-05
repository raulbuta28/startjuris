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

