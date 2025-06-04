// filename: simulari.dart
// ────────────────────────────────────────────────────────────────────────────
// IMPORTURI
// ────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'models.dart';   // Answer, Question
import 'simulari2.dart';    // SimularePage

// ────────────────────────────────────────────────────────────────────────────
// CONSTANTE & STILURI
// ────────────────────────────────────────────────────────────────────────────
const Color kPrimaryPastel = Color(0xFFB7E4F7); // cyan pal
const Color kSecondaryPastel = Color(0xFFE3D7F3); // lila pal

LinearGradient get pastelGradient =>
    const LinearGradient(colors: [kPrimaryPastel, kSecondaryPastel]);

// ────────────────────────────────────────────────────────────────────────────
// 1. PROVIDER PENTRU TEMA
// ────────────────────────────────────────────────────────────────────────────
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeData get themeData => _isDarkMode ? _darkTheme : _lightTheme;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

final _lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.white,
  textTheme: GoogleFonts.poppinsTextTheme(),
  colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryPastel),
);

final _darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF121212),
  textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
  colorScheme:
      ColorScheme.fromSeed(seedColor: kSecondaryPastel, brightness: Brightness.dark),
);

// ────────────────────────────────────────────────────────────────────────────
// 2. STRUCTURI
// ────────────────────────────────────────────────────────────────────────────
class SimulareItem {
  final String title;
  final List<Question> questions;
  const SimulareItem({required this.title, required this.questions});
}

// Placeholder questions for each subject
const _dreptCivilQuestions = [
  Question(
    id: 1,
    text: 'Care este definiția proprietății private?',
    answers: [
      Answer(letter: 'A', text: 'Dreptul de a dispune și folosi un bun'),
      Answer(letter: 'B', text: 'Dreptul statului asupra bunurilor'),
      Answer(letter: 'C', text: 'Dreptul comunității de a gestiona un bun'),
    ],
    correctAnswers: ['A'],
    explanation:
        'Proprietatea privată reprezintă dreptul subiectiv al titularului de a deține, folosi și dispune de bun în mod exclusiv.',
  ),
  Question(
    id: 2,
    text: 'Ce este consimțământul în actul juridic civil?',
    answers: [
      Answer(letter: 'A', text: 'Acordul liber al părților'),
      Answer(letter: 'B', text: 'O formalitate administrativă'),
      Answer(letter: 'C', text: 'Un document scris'),
    ],
    correctAnswers: ['A'],
    explanation: 'Consimțământul este acordul liber și neviciat al părților.',
  ),
  Question(
    id: 3,
    text: 'Ce este uzucapiunea?',
    answers: [
      Answer(letter: 'A', text: 'Dobândirea proprietății prin posesie îndelungată'),
      Answer(letter: 'B', text: 'Un tip de contract'),
      Answer(letter: 'C', text: 'O sancțiune civilă'),
    ],
    correctAnswers: ['A'],
    explanation: 'Uzucapiunea permite dobândirea proprietății prin posesie continuă.',
  ),
  Question(
    id: 4,
    text: 'Ce înseamnă nulitatea absolută a unui contract?',
    answers: [
      Answer(letter: 'A', text: 'Contractul este lovit de nulitate din motive de ordine publică'),
      Answer(letter: 'B', text: 'Contractul poate fi anulat doar de o parte'),
      Answer(letter: 'C', text: 'Contractul este valabil condiționat'),
    ],
    correctAnswers: ['A'],
    explanation: 'Nulitatea absolută intervine pentru încălcarea normelor de ordine publică.',
  ),
  Question(
    id: 5,
    text: 'Ce este ipoteca?',
    answers: [
      Answer(letter: 'A', text: 'Un drept real de garanție asupra unui bun'),
      Answer(letter: 'B', text: 'Un contract de vânzare'),
      Answer(letter: 'C', text: 'O donație condiționată'),
    ],
    correctAnswers: ['A'],
    explanation: 'Ipoteca este un drept real care garantează o creanță.',
  ),
];

const _dreptProcesualCivilQuestions = [
  Question(
    id: 6,
    text: 'Ce este competența materială a instanței?',
    answers: [
      Answer(letter: 'A', text: 'Capacitatea instanței de a judeca anumite categorii de cauze'),
      Answer(letter: 'B', text: 'Dreptul părților de a apela'),
      Answer(letter: 'C', text: 'Obligația de a depune probe'),
    ],
    correctAnswers: ['A'],
    explanation: 'Competența materială se referă la tipurile de cauze pe care le poate judeca o instanță.',
  ),
  Question(
    id: 7,
    text: 'Ce este acțiunea civilă?',
    answers: [
      Answer(letter: 'A', text: 'Cererea prin care se solicită protecția unui drept'),
      Answer(letter: 'B', text: 'Un contract între părți'),
      Answer(letter: 'C', text: 'O decizie judecătorească'),
    ],
    correctAnswers: ['A'],
    explanation: 'Acțiunea civilă este mijlocul procedural de apărare a unui drept.',
  ),
  Question(
    id: 8,
    text: 'Ce înseamnă termenul procedural?',
    answers: [
      Answer(letter: 'A', text: 'Perioada în care se poate efectua un act de procedură'),
      Answer(letter: 'B', text: 'Durata unui proces'),
      Answer(letter: 'C', text: 'Data fixată pentru apel'),
    ],
    correctAnswers: ['A'],
    explanation: 'Termenul procedural limitează temporal actele de procedură.',
  ),
  Question(
    id: 9,
    text: 'Ce este executarea silită?',
    answers: [
      Answer(letter: 'A', text: 'Procedura de realizare forțată a unei obligații'),
      Answer(letter: 'B', text: 'Un acord între părți'),
      Answer(letter: 'C', text: 'O cerere de mediere'),
    ],
    correctAnswers: ['A'],
    explanation: 'Executarea silită asigură îndeplinirea obligațiilor prin forța legii.',
  ),
  Question(
    id: 10,
    text: 'Ce sunt căile de atac?',
    answers: [
      Answer(letter: 'A', text: 'Mijloacele de contestare a hotărârilor judecătorești'),
      Answer(letter: 'B', text: 'Probe admisibile în instanță'),
      Answer(letter: 'C', text: 'Reguli de procedură'),
    ],
    correctAnswers: ['A'],
    explanation: 'Căile de atac permit revizuirea hotărârilor judecătorești.',
  ),
];

const _dreptPenalQuestions = [
  Question(
    id: 11,
    text: 'Ce este infracțiunea?',
    answers: [
      Answer(letter: 'A', text: 'Fapta prevăzută de legea penală, săvârșită cu vinovăție'),
      Answer(letter: 'B', text: 'Un contract ilegal'),
      Answer(letter: 'C', text: 'O sancțiune administrativă'),
    ],
    correctAnswers: ['A'],
    explanation: 'Infracțiunea este fapta care întrunește elementele prevăzute de legea penală.',
  ),
  Question(
    id: 12,
    text: 'Ce este legitima apărare?',
    answers: [
      Answer(letter: 'A', text: 'Reacția la un atac injust'),
      Answer(letter: 'B', text: 'O pedeapsă aplicată de instanță'),
      Answer(letter: 'C', text: 'Un acord între părți'),
    ],
    correctAnswers: ['A'],
    explanation: 'Legitima apărare exclude răspunderea penală pentru reacția la un atac.',
  ),
  Question(
    id: 13,
    text: 'Ce este recidiva?',
    answers: [
      Answer(letter: 'A', text: 'Săvârșirea unei noi infracțiuni după o condamnare anterioară'),
      Answer(letter: 'B', text: 'O infracțiune minoră'),
      Answer(letter: 'C', text: 'Anularea unei pedepse'),
    ],
    correctAnswers: ['A'],
    explanation: 'Recidiva implică o nouă infracțiune după o condamnare definitivă.',
  ),
  Question(
    id: 14,
    text: 'Ce este amnistia?',
    answers: [
      Answer(letter: 'A', text: 'Iertarea unei infracțiuni prin lege'),
      Answer(letter: 'B', text: 'O pedeapsă redusă'),
      Answer(letter: 'C', text: 'O procedură de apel'),
    ],
    correctAnswers: ['A'],
    explanation: 'Amnistia șterge răspunderea penală pentru anumite infracțiuni.',
  ),
  Question(
    id: 15,
    text: 'Ce este tentativa?',
    answers: [
      Answer(letter: 'A', text: 'Începerea executării unei infracțiuni fără finalizare'),
      Answer(letter: 'B', text: 'O infracțiune comisă din neglijență'),
      Answer(letter: 'C', text: 'O decizie judecătorească'),
    ],
    correctAnswers: ['A'],
    explanation: 'Tentativa este pedepsită ca infracțiune neconsumată.',
  ),
];

const _dreptProcesualPenalQuestions = [
  Question(
    id: 16,
    text: 'Ce este urmărirea penală?',
    answers: [
      Answer(letter: 'A', text: 'Faza procesului penal de strângere a probelor'),
      Answer(letter: 'B', text: 'Sentința finală a instanței'),
      Answer(letter: 'C', text: 'Apelul unei decizii'),
    ],
    correctAnswers: ['A'],
    explanation: 'Urmărirea penală identifică și strânge probele împotriva suspectului.',
  ),
  Question(
    id: 17,
    text: 'Ce este camera preliminară?',
    answers: [
      Answer(letter: 'A', text: 'Etapa de verificare a legalității sesizării instanței'),
      Answer(letter: 'B', text: 'Faza de judecată propriu-zisă'),
      Answer(letter: 'C', text: 'O procedură de mediere'),
    ],
    correctAnswers: ['A'],
    explanation: 'Camera preliminară verifică legalitatea actelor procesuale.',
  ),
  Question(
    id: 18,
    text: 'Ce sunt măsurile preventive?',
    answers: [
      Answer(letter: 'A', text: 'Măsuri de restrângere a libertății suspectului'),
      Answer(letter: 'B', text: 'Sancțiuni administrative'),
      Answer(letter: 'C', text: 'Probe admisibile'),
    ],
    correctAnswers: ['A'],
    explanation: 'Măsurile preventive asigură buna desfășurare a procesului penal.',
  ),
  Question(
    id: 19,
    text: 'Ce este proba în procesul penal?',
    answers: [
      Answer(letter: 'A', text: 'Mijlocul de stabilire a adevărului'),
      Answer(letter: 'B', text: 'O cerere a părților'),
      Answer(letter: 'C', text: 'O decizie a instanței'),
    ],
    correctAnswers: ['A'],
    explanation: 'Proba servește la stabilirea faptelor în procesul penal.',
  ),
  Question(
    id: 20,
    text: 'Ce este judecata în fond?',
    answers: [
      Answer(letter: 'A', text: 'Examinarea cauzei pe fond de către instanță'),
      Answer(letter: 'B', text: 'O procedură de apel'),
      Answer(letter: 'C', text: 'Strângerea probelor'),
    ],
    correctAnswers: ['A'],
    explanation: 'Judecata în fond analizează fondul cauzei pentru pronunțarea sentinței.',
  ),
];

// Combined questions for each simulation (5 from each subject)
List<Question> _getCombinedQuestions() => [
      ..._dreptCivilQuestions,
      ..._dreptProcesualCivilQuestions,
      ..._dreptPenalQuestions,
      ..._dreptProcesualPenalQuestions,
    ];

// ────────────────────────────────────────────────────────────────────────────
// 3. LISTA SIMULĂRI FINALE
// ────────────────────────────────────────────────────────────────────────────
final List<SimulareItem> _simulari = List.generate(
  30,
  (index) => SimulareItem(
    title: 'Simulare finală - ${index + 1}',
    questions: _getCombinedQuestions(),
  ),
);

// ────────────────────────────────────────────────────────────────────────────
// 4. SimulariListView
// ────────────────────────────────────────────────────────────────────────────
class SimulariListView extends StatelessWidget {
  const SimulariListView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      children: [
        // Titlu centrat
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: Text(
              'Simulări finale tip examen din toată materia',
              style: GoogleFonts.playfairDisplay(
                fontSize: screenWidth * 0.04, // Smaller font size
                fontWeight: FontWeight.w500, // Medium weight for elegance
                color: isDark ? Colors.white : Colors.grey[900],
                letterSpacing: 0.5, // Refined spacing
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        // Lista simulări
        ..._simulari.map((simulare) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SimularePage(
                      simulareTitle: simulare.title, questions: simulare.questions),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? Colors.white24 : Colors.black12,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black54 : Colors.black12,
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        simulare.title,
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: screenWidth * 0.04, color: Colors.black),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// 5. PAGINA PRINCIPALĂ (FĂRĂ APPBAR)
// ────────────────────────────────────────────────────────────────────────────
class SimulariPage extends StatelessWidget {
  const SimulariPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SimulariListView(),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// 6. MAIN
// ────────────────────────────────────────────────────────────────────────────
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (_, p, __) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Simulări Finale App',
        theme: p.themeData,
        home: const SimulariPage(),
      ),
    );
  }
}