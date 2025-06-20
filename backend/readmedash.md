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

## Final adjustment
- The profile verification on app load now retains the stored token unless the server explicitly returns a 401 response. Network or server errors no longer force a logout, preventing the admin from being kicked out when opening the code editor.

## Raw code endpoint
- Added `/api/code-text/:id` in the backend to serve the plain text of each legal code.
- The React `CodeEditor` fetches this text and shows it below the structured view so the admin can confirm the raw contents.
## Fix for null sections
- Parser now initializes Books, CodeTitles, and Chapters with empty slices to prevent null arrays in JSON.
- CodeEditor guards against missing arrays when rendering.

## Article parsing tweak
- Updated the parser to treat lines starting with parentheses as part of the article
  content instead of references. This ensures every article correctly includes
  its paragraphs when displayed in the dashboard.

## Layout update
- CodeEditor now renders the entire code hierarchy expanded using headings
  instead of collapsible `<details>` elements. Articles are listed directly
  without virtualization so the full text is visible.

## Display fix
- Removed the raw text preview from CodeEditor to avoid duplicate article content.

## Editor UX update
- Articles are shown read-only by default with a new **Edit** button on each one.
- Clicking the button reveals input fields so updates are intentional and clearer.
- Parser now adds lines starting with parentheses directly to the article text before checking for notes or references, ensuring all paragraphs appear.

## Flutter reader fix
- The `ModernCodeReader` screen now checks the API response type before casting
  to a map and gracefully handles missing lists when rendering. This prevents
  `List<dynamic>`/`String` cast errors when loading the parsed codes from the
  dashboard.
- CodeEditor now shows articles as plain text with a uniform font and a compact
  layout. Each article has an **Edit** button on the right which turns into a
  **Save** button when modifying the text.
