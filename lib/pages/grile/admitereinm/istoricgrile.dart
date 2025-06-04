import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Istoric grile',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      home: const IstoricGrilePage(),
    );
  }
}

class IstoricGrilePage extends StatefulWidget {
  const IstoricGrilePage({super.key});

  @override
  _IstoricGrilePageState createState() => _IstoricGrilePageState();
}

class _IstoricGrilePageState extends State<IstoricGrilePage> {
  String _selectedMaterie = 'Drept civil'; // Materia selectată implicit

  // Date simulate pentru fiecare materie
  final Map<String, List<Map<String, dynamic>>> grileByMaterie = {
    'Drept civil': List.generate(8, (index) => {
      'intrebare': 'Ce este un contract sinalagmatic? ${index + 1}',
      'raspunsSelectat': 'Un contract unilateral',
      'raspunsCorect': 'Un contract cu obligații reciproce',
      'explicatie': 'Contractul sinalagmatic implică obligații reciproce între părți.',
      'data': '2025-05-24 14:${30 - index}',
      'test': 'Test combinat - ${index % 2 == 0 ? 3 : 5}',
    }),
    'Drept procesual civil': List.generate(5, (index) => {
      'intrebare': 'Ce este o cerere reconvențională? ${index + 1}',
      'raspunsSelectat': 'O cerere de apel',
      'raspunsCorect': 'O cerere formulată de pârât împotriva reclamantului',
      'explicatie': 'Cererea reconvențională este o pretenție a pârâtului în cadrul aceluiași proces.',
      'data': '2025-05-22 16:${45 - index}',
      'test': 'Test combinat - ${index % 2 == 0 ? 3 : 5}',
    }),
    'Drept penal': List.generate(6, (index) => {
      'intrebare': 'Ce este infracțiunea continuată? ${index + 1}',
      'raspunsSelectat': 'O infracțiune comisă de mai multe persoane',
      'raspunsCorect': 'O infracțiune cu acte repetate sub o singură rezoluție',
      'explicatie': 'Infracțiunea continuată presupune mai multe acte sub o singură intenție.',
      'data': '2025-05-21 11:${20 - index}',
      'test': 'Simulare finală - ${index % 2 == 0 ? 5 : 3}',
    }),
    'Drept procesual penal': List.generate(4, (index) => {
      'intrebare': 'Care este termenul pentru plângerea prealabilă? ${index + 1}',
      'raspunsSelectat': '6 luni',
      'raspunsCorect': '3 luni',
      'explicatie': 'Plângerea prealabilă trebuie formulată în 3 luni de la data faptei.',
      'data': '2025-05-20 13:${10 - index}',
      'test': 'Test combinat - ${index % 2 == 0 ? 3 : 5}',
    }),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [Colors.white, Color(0xFFF5F7FA)],
          ),
        ),
        child: Column(
          children: [
            // Taburi fixe cu text unul sub altul și număr grile
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTabButton('Drept civil', ['Drept', 'civil'], grileByMaterie['Drept civil']!.length),
                  _buildTabButton('Drept procesual civil', ['Dr. pr.', 'civil'], grileByMaterie['Drept procesual civil']!.length),
                  _buildTabButton('Drept penal', ['Drept', 'penal'], grileByMaterie['Drept penal']!.length),
                  _buildTabButton('Drept procesual penal', ['Dr. pr.', 'penal'], grileByMaterie['Drept procesual penal']!.length),
                ],
              ),
            ),
            // Lista de grile pentru materia selectată
            Expanded(
              child: _buildGrileList(_selectedMaterie),
            ),
          ],
        ),
      ),
    );
  }

  // Construiește butonul pentru un tab
  Widget _buildTabButton(String materie, List<String> words, int numarGrile) {
    final isSelected = _selectedMaterie == materie;
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        transform: Matrix4.identity()..scale(isSelected ? 1.05 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextButton(
          onPressed: () {
            setState(() {
              _selectedMaterie = materie;
            });
          },
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...words.map((word) => Text(
                  word,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    overflow: TextOverflow.ellipsis,
                  ),
                  textAlign: TextAlign.center,
                )),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$numarGrile grile',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Construiește lista de grile pentru o materie
  Widget _buildGrileList(String materie) {
    final grile = grileByMaterie[materie] ?? [];
    if (grile.isEmpty) {
      return const Center(
        child: Text(
          'Nicio grilă greșită pentru această materie.',
          style: TextStyle(color: Colors.black54),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: grile.length,
      itemBuilder: (context, index) {
        final grila = grile[index];
        return _buildGrilaCard(grila, index);
      },
    );
  }

  // Widget pentru cardul unei grile
  Widget _buildGrilaCard(Map<String, dynamic> grila, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ExpansionTile(
          title: Text(
            grila['intrebare'],
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const FaIcon(
                    FontAwesomeIcons.clock,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    grila['data'],
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Test: ${grila['test']}',
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.xmark,
                        size: 16,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Răspuns selectat: ${grila['raspunsSelectat']}',
                          style: const TextStyle(
                            color: Color(0xFFF44336),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.check,
                        size: 16,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Răspuns corect: ${grila['raspunsCorect']}',
                          style: const TextStyle(
                            color: Color(0xFF4CAF50),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Explicație:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    grila['explicatie'],
                    style: const TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}