export function filterCodeText(text: string): string {
  const lines = text.split(/\r?\n/);
  const startIndex = lines.findIndex((line) =>
    /^(titlul|partea|cartea|capitolul|articolul)/i.test(line.trim())
  );
  const sliced = startIndex >= 0 ? lines.slice(startIndex) : lines;
  return sliced.join('\n').trim();
}
