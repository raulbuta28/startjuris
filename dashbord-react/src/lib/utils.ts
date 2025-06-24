import { type ClassValue, clsx } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

export function extractArticleNumbers(text: string): number[] {
  const numbers: number[] = [];
  const artPattern = '(?:art\\.?|articol(?:ul|ele)?)';

  // Patterns like "art. 1.697" should be treated as article 1697
  const dottedRe = new RegExp(`${artPattern}\\s*(\\d{1,3})\\.(\\d{2,3})`, 'gi');
  text = text.replace(dottedRe, (_, a, b) => {
    numbers.push(parseInt(`${a}${b}`, 10));
    return ' ';
  });

  // Remove bullet indexes like "1. Art. 10" so they don't get captured
  const bulletRe = /(?:^|[\n\r])\s*\d+[.)]\s*/g;
  text = text.replace(bulletRe, '\n');

  // Remove references to article paragraphs like "alin. (1)"
  const alinRe = /alin\.\s*\(?\d{1,4}\)?/gi;
  text = text.replace(alinRe, ' ');

  // Ignore references to points or letters such as "pct. 1" or "lit. a)"
  const pctRe = /pct\.\s*\d{1,4}/gi;
  text = text.replace(pctRe, ' ');
  const punctRe = /punct(?:ul)?\s*\d{1,4}/gi;
  text = text.replace(punctRe, ' ');
  const litRe = /lit(?:era)?\.\s*[a-zăâîșț]/gi;
  text = text.replace(litRe, ' ');

  // Remove standalone numbers in parentheses that are not article numbers
  const parenRe = /\(\s*\d{1,4}\s*\)/g;
  text = text.replace(parenRe, ' ');

  const singleRe = new RegExp(`${artPattern}\\s*(\\d{1,4})`, 'gi');
  let m: RegExpExecArray | null;
  while ((m = singleRe.exec(text)) !== null) {
    numbers.push(parseInt(m[1], 10));
  }

  return Array.from(new Set(numbers)).sort((a, b) => a - b);
}

export function collapseNumberRanges(nums: number[]): string[] {
  const ranges: string[] = [];
  if (nums.length === 0) return ranges;
  let start = nums[0];
  let prev = nums[0];
  for (const n of nums.slice(1)) {
    if (n === prev + 1) {
      prev = n;
    } else {
      ranges.push(start === prev ? String(start) : `${start}-${prev}`);
      start = prev = n;
    }
  }
  ranges.push(start === prev ? String(start) : `${start}-${prev}`);
  return ranges;
}

export function extractArticleRanges(text: string): string[] {
  const ranges: string[] = [];
  const artPattern = '(?:art\\.?|articol(?:ul|ele)?)';
  const rangeRe = new RegExp(`${artPattern}\\s*(\\d{1,4})\\s*[–-]\\s*(\\d{1,4})`, 'gi');
  text = text.replace(rangeRe, (_, a, b) => {
    const start = parseInt(a, 10);
    const end = parseInt(b, 10);
    if (!isNaN(start) && !isNaN(end)) {
      ranges.push(`${start}-${end}`);
    }
    return ' ';
  });

  const numbers = extractArticleNumbers(text);
  ranges.push(...collapseNumberRanges(numbers));

  return Array.from(new Set(ranges)).sort((a, b) => {
    const as = parseInt(a.split('-')[0], 10);
    const bs = parseInt(b.split('-')[0], 10);
    return as - bs;
  });
}

export function rangeIncludes(range: string, n: number): boolean {
  const [s, e] = range.split('-').map((x) => parseInt(x, 10));
  if (isNaN(e)) return n === s;
  return n >= s && n <= e;
}

export function detectSubject(text: string): string | undefined {
  const lower = text.toLowerCase();
  if (
    lower.includes('codul de procedura penala') ||
    lower.includes('cod de procedura penala') ||
    lower.includes('procedura penala') ||
    /c\.?\s*proc\.?\s*pen/.test(lower) ||
    /\bcpp\b/.test(lower) ||
    /c\.pr\.pen/.test(lower)
  ) {
    return 'Drept procesual penal';
  }
  if (lower.includes('cod penal') || /\bcp\b/.test(lower)) {
    return 'Drept penal';
  }
  if (
    lower.includes('codul de procedura civila') ||
    lower.includes('cod de procedura civila') ||
    lower.includes('procedura civila') ||
    /c\.?\s*proc\.?\s*civ/.test(lower) ||
    /\bcpc\b/.test(lower) ||
    /c\.pr\.civ/.test(lower)
  ) {
    return 'Drept procesual civil';
  }
  if (lower.includes('cod civil') || /\bcc\b/.test(lower) || /c\.\s*civ/.test(lower)) {
    return 'Drept civil';
  }
  return undefined;
}
