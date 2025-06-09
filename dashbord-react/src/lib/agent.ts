export interface GrilaQuestion {
  text: string;
  answers: string[];
  correct: number[];
}

/**
 * Trimite întrebarea la Agent-Juridic și întoarce explicația.
 * !!! Atenție: cheia este expusă în bundle. Ține repo-ul privat sau adaugă un proxy server dacă vrei mai multă securitate.
 */
export async function explainQuestion(q: GrilaQuestion): Promise<string> {
  const prompt = `
Citește cu atenție grila de mai jos, apoi explică de ce variantele greșite sunt greșite și de ce varianta/variantele corecte sunt corecte. Folosește DOAR informații din Codul civil și Codul penal din baza KB și citează articolul/alin. exact. Evită informații externe. Răspunde în 3-5 fraze clare, compară explicit fiecare variantă.

Întrebare:
${q.text}

Variante:
${q.answers.map((a,i)=>`${String.fromCharCode(65+i)}. ${a}`).join("\n")}

Răspuns corect: ${q.correct.map(i=>String.fromCharCode(65+i)).join(", ")}
`.trim();

  const res = await fetch(
    `${import.meta.env.VITE_AGENT_ENDPOINT}/api/v1/chat/completions`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${import.meta.env.VITE_AGENT_ACCESS_KEY}`,
      },
      body: JSON.stringify({
        messages: [{ role: "user", content: prompt }],
        stream: false
      })
    }
  );

  if (!res.ok) throw new Error(`Agent error ${res.status}`);
  const data = await res.json();
  return data.choices?.[0]?.message?.content?.trim() ?? "";
}
