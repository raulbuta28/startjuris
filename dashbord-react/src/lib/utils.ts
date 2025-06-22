import { type ClassValue, clsx } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

export function extractArticleNumbers(text: string): number[] {
  return Array.from(
    new Set((text.match(/\b\d{1,4}\b/g) || []).map((n) => parseInt(n, 10)))
  ).sort((a, b) => a - b);
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
  const numbers = extractArticleNumbers(text);
  return collapseNumberRanges(numbers);
}

export function rangeIncludes(range: string, n: number): boolean {
  const [s, e] = range.split('-').map((x) => parseInt(x, 10));
  if (isNaN(e)) return n === s;
  return n >= s && n <= e;
}
