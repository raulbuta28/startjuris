import { type ClassValue, clsx } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

export function extractArticleNumbers(text: string): number[] {
  const numbers: number[] = [];
  const bulletRe = /(?:^|[\n\r])\s*\d+[.)]\s*(\d{1,4})/g;
  text = text.replace(bulletRe, (_, n) => {
    numbers.push(parseInt(n, 10));
    return ' ';
  });

  const matches = text.match(/\b\d{1,4}\b/g) || [];
  for (const m of matches) {
    numbers.push(parseInt(m, 10));
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
  const rangeRe = /(\d{1,4})\s*[–-]\s*(\d{1,4})/g;
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
