class Answer {
  final String letter;
  final String text;

  const Answer({
    required this.letter,
    required this.text,
  });
}

class Question {
  final int id;
  final String text;
  final List<Answer> answers;
  final List<String> correctAnswers;
  final String explanation;

  const Question({
    required this.id,
    required this.text,
    required this.answers,
    required this.correctAnswers,
    required this.explanation,
  });
}

const sampleQuestions = [
  Question(
    id: 1,
    text: 'Care este definiția proprietății private?',
    answers: [
      Answer(letter: 'A', text: 'Dreptul de a dispune și folosi un bun în mod exclusiv și absolut'),
      Answer(letter: 'B', text: 'Dreptul statului asupra bunurilor publice'),
      Answer(letter: 'C', text: 'Dreptul comunității de a gestiona un bun'),
      Answer(letter: 'D', text: 'Dreptul de folosință temporară asupra unui bun'),
    ],
    correctAnswers: ['A'],
    explanation: 'Proprietatea privată reprezintă dreptul subiectiv al titularului de a deține, folosi și dispune de bun în mod exclusiv și absolut, în limitele legii.',
  ),
  Question(
    id: 2,
    text: 'Care dintre următoarele reprezintă caracteristici ale dreptului de proprietate?',
    answers: [
      Answer(letter: 'A', text: 'Perpetuitatea'),
      Answer(letter: 'B', text: 'Temporalitatea'),
      Answer(letter: 'C', text: 'Exclusivitatea'),
      Answer(letter: 'D', text: 'Absolutitatea'),
    ],
    correctAnswers: ['A', 'C', 'D'],
    explanation: 'Dreptul de proprietate are ca principale caracteristici: perpetuitatea (durează cât există bunul), exclusivitatea (proprietarul poate exercita singur atributele dreptului său) și absolutitatea (este opozabil tuturor).',
  ),
  Question(
    id: 3,
    text: 'Ce reprezintă dezmembrămintele dreptului de proprietate?',
    answers: [
      Answer(letter: 'A', text: 'Dreptul de uzufruct'),
      Answer(letter: 'B', text: 'Dreptul de servitute'),
      Answer(letter: 'C', text: 'Dreptul de superficie'),
      Answer(letter: 'D', text: 'Dreptul de abitație'),
    ],
    correctAnswers: ['A', 'B', 'C', 'D'],
    explanation: 'Dezmembrămintele dreptului de proprietate sunt drepturi reale principale derivate din dreptul de proprietate și includ: uzufructul, servitutea, superficia și abitația.',
  ),
  Question(
    id: 4,
    text: 'Care este durata maximă a dreptului de uzufruct constituit în favoarea unei persoane juridice?',
    answers: [
      Answer(letter: 'A', text: '30 de ani'),
      Answer(letter: 'B', text: '49 de ani'),
      Answer(letter: 'C', text: '99 de ani'),
      Answer(letter: 'D', text: 'Este perpetuu'),
    ],
    correctAnswers: ['A'],
    explanation: 'Conform art. 707 Cod Civil, dreptul de uzufruct constituit în favoarea unei persoane juridice poate fi stabilit cel mult pe durata de 30 de ani.',
  ),
  Question(
    id: 5,
    text: 'Care dintre următoarele modalități de dobândire a dreptului de proprietate sunt originare?',
    answers: [
      Answer(letter: 'A', text: 'Accesiunea'),
      Answer(letter: 'B', text: 'Uzucapiunea'),
      Answer(letter: 'C', text: 'Ocupațiunea'),
      Answer(letter: 'D', text: 'Moștenirea'),
    ],
    correctAnswers: ['A', 'B', 'C'],
    explanation: 'Modurile originare de dobândire a proprietății sunt cele prin care se dobândește un drept nou, neafectat de viciile dreptului anterior. Acestea includ accesiunea, uzucapiunea și ocupațiunea. Moștenirea este un mod derivat de dobândire.',
  ),
  Question(
    id: 6,
    text: 'În ce condiții operează accesiunea imobiliară artificială?',
    answers: [
      Answer(letter: 'A', text: 'Când construcția este realizată cu materiale proprii pe terenul altuia'),
      Answer(letter: 'B', text: 'Când construcția este realizată cu materialele altuia pe terenul propriu'),
      Answer(letter: 'C', text: 'Când construcția este realizată parțial pe terenul proprietarului'),
      Answer(letter: 'D', text: 'Când construcția este realizată cu acordul proprietarului terenului'),
    ],
    correctAnswers: ['A', 'B'],
    explanation: 'Accesiunea imobiliară artificială operează în două situații principale: când se construiește cu materiale proprii pe terenul altuia și când se construiește cu materialele altuia pe terenul propriu.',
  ),
  Question(
    id: 7,
    text: 'Care este efectul principal al uzucapiunii?',
    answers: [
      Answer(letter: 'A', text: 'Dobândirea dreptului de proprietate'),
      Answer(letter: 'B', text: 'Pierderea posesiei'),
      Answer(letter: 'C', text: 'Constituirea unei servituți'),
      Answer(letter: 'D', text: 'Stingerea dreptului de proprietate'),
    ],
    correctAnswers: ['A'],
    explanation: 'Efectul principal al uzucapiunii este dobândirea dreptului de proprietate prin posesia îndelungată a bunului, în condițiile prevăzute de lege.',
  ),
  Question(
    id: 8,
    text: 'Care sunt condițiile uzucapiunii extratabulare?',
    answers: [
      Answer(letter: 'A', text: 'Posesia de 10 ani'),
      Answer(letter: 'B', text: 'Posesia utilă și de bună-credință'),
      Answer(letter: 'C', text: 'Înscrierea în cartea funciară'),
      Answer(letter: 'D', text: 'Existența unui just titlu'),
    ],
    correctAnswers: ['A', 'B'],
    explanation: 'Uzucapiunea extratabulară necesită o posesie utilă și de bună-credință pentru o perioadă de 10 ani. Nu este necesară înscrierea în cartea funciară sau existența unui just titlu.',
  ),
];