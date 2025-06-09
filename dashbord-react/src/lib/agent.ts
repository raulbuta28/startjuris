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

const generationBasePrompt = `Eşti profesor universitar de Drept şi redactezi o SINGURĂ grilă tip examen, nivel licenţă, strict pe articolele cerute de către utilizator.

❗ Respectă STRICT cerinţele:

1. Structură fixă
   - Rândul 1 – Enunţ general: o propoziţie declarativă (fără semn de întrebare) care introduce subiectul şi se leagă logic de alternative, terminată cu două puncte, nu menţiona articole de lege cu număr şi nici termeni ca „codul civil”, „codul penal”, „codul de procedura civila”, „codul de procedura penala”.
   - Rândurile 2-4 – Alternative: exact trei fraze scurte (max. 25 cuvinte fiecare), numerotate „A.” „B.” „C.”, despărţite prin punct şi virgulă „;”, fără a menţiona articole de lege.
   - Răspunsul corect
   - Explicaţia – la explicaţie poţi folosi numerele articolelor într-un mod coerent şi explicativ.

2. Conţinut
   - Tema poate fi din orice capitol de drept civil/comercial, NU exclusiv drepturi reale.
   - Foloseşte limbaj juridic precis, clar şi concis.
   - Formulează distractori plauzibili şi cel puţin un răspuns corect.
   - NU insera semnul „?” la finalul enunţului.
   - NU introduce numărul de articol în textul alternativelor; apar doar la explicaţie.

3. Exemplu de FORMĂ (nu-l copia, ci doar urmează-i forma)

Obligaţia de confidenţialitate în contractele comerciale se caracterizează prin:
A. nerespectarea ei atrage de regulă doar răspundere civilă contractuală;
B. poate fi asumată exclusiv de profesionist, nu şi de consumator;
C. se poate stinge prin acordul părţilor înainte de expirarea termenului stabilit;
A,C
1182,1270

➡︎ Livrează DOAR grila finală.`;

export async function generateGrila(promptText: string): Promise<GrilaQuestion & { explanation: string }> {
  const prompt = `${generationBasePrompt}\n\nTema: ${promptText}`;

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
