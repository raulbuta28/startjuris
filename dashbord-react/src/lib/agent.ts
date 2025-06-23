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
Citește cu atenție grila de mai jos, apoi explică de ce variantele greșite sunt greșite și de ce varianta/variantele corecte sunt corecte. Folosește DOAR informații din Codul civil, Codul penal, Codul de procedură civilă, Codul de procedură penală din baza KB și citează articolul/alin. exact, menționând numele codului. Evită informații externe. Răspunde în 3-5 fraze clare, compară explicit fiecare variantă. Explicația trebuie să fie puțin mai amplă, împărțită în paragrafe scurte și să includă definiția instituției juridice relevante extrasă din codul aplicabil.

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

export async function generateGrila(prompt: string): Promise<GrilaQuestion & { explanation: string }> {

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
        stream: false,
      }),
    }
  );

  if (!res.ok) throw new Error(`Agent error ${res.status}`);
  const data = await res.json();
  const text = data.choices?.[0]?.message?.content?.trim() ?? "";

  const lines = text.split(/\n+/).map((l: string) => l.trim()).filter((l: string) => l);
  const questionText = lines[0] || "";
  const answers = lines.slice(1, 4).map((l: string) => l.replace(/^\w\.?\s*/, '').replace(/;?$/, '').trim());
  const correctLine = lines[4] || "";
  const explanation = lines[5] || "";
  const correct = correctLine
    .toUpperCase()
    .replace(/[^A-C]/g, ' ')
    .split(/\s+/)
    .filter((c: string) => c)
    .map((c: string) => c.charCodeAt(0) - 65);

  return { text: questionText.replace(/:+$/, ''), answers, correct, explanation };
}

export async function generateGrilaStrict(prompt: string): Promise<GrilaQuestion & { explanation: string }> {

  const res = await fetch(
    `${import.meta.env.VITE_GRILE_AGENT_ENDPOINT || import.meta.env.VITE_AGENT_ENDPOINT}/api/v1/chat/completions`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${import.meta.env.VITE_AGENT_ACCESS_KEY}`,
      },
      body: JSON.stringify({
        messages: [{ role: "user", content: prompt }],
        stream: false,
        max_tokens: Number(import.meta.env.VITE_GRILE_AGENT_MAX_TOKENS ?? 512),
        temperature: Number(import.meta.env.VITE_GRILE_AGENT_TEMPERATURE ?? 0.5),
        top_p: Number(import.meta.env.VITE_GRILE_AGENT_TOP_P ?? 0.9),
        top_k: Number(import.meta.env.VITE_GRILE_AGENT_TOP_K ?? 10),
        retrieval: "none",
      }),
    }
  );

  if (!res.ok) throw new Error(`Agent error ${res.status}`);
  const data = await res.json();
  const text = data.choices?.[0]?.message?.content?.trim() ?? "";

  const lines = text.split(/\n+/).map((l: string) => l.trim()).filter((l: string) => l);
  const questionText = lines[0] || "";
  const answers = lines.slice(1, 4).map((l: string) => l.replace(/^\w\.?\s*/, '').replace(/;?$/, '').trim());
  const correctLine = lines[4] || "";
  const explanation = lines[5] || "";
  const correct = correctLine
    .toUpperCase()
    .replace(/[^A-C]/g, ' ')
    .split(/\s+/)
    .filter((c: string) => c)
    .map((c: string) => c.charCodeAt(0) - 65);

  return { text: questionText.replace(/:+$/, ''), answers, correct, explanation };
}
