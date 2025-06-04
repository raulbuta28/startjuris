import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class StudyItem {
  final String id;
  final String title;
  final String type;
  bool isCompleted;

  StudyItem({
    required this.id,
    required this.title,
    required this.type,
    this.isCompleted = false,
  });
}

class StudyPlan {
  List<StudyItem> items;
  double progress;
  double? grade;
  int hoursPerDay;
  DateTime? examDate;
  List<String> preferences;

  StudyPlan({
    required this.items,
    this.progress = 0.0,
    this.grade,
    this.hoursPerDay = 2,
    this.examDate,
    this.preferences = const [],
  }) {
    _updateProgress();
  }

  void completeItem(String id) {
    final item = items.firstWhere((i) => i.id == id);
    item.isCompleted = true;
    _updateProgress();
  }

  void _updateProgress() {
    progress = items.isEmpty
        ? 0.0
        : items.where((i) => i.isCompleted).length / items.length;
  }

  void calculateGrade() {
    final temaItems = items.where((i) => i.type == 'tema');
    final testItems = items.where((i) => i.type == 'test');
    final temaScore = temaItems.isNotEmpty
        ? temaItems.where((i) => i.isCompleted).length / temaItems.length * 70
        : 0.0;
    final testScore = testItems.isNotEmpty
        ? testItems.where((i) => i.isCompleted).length / testItems.length * 30
        : 0.0;
    grade = temaScore + testScore;
  }
}

class StudyPlanProvider with ChangeNotifier {
  final StudyPlan _plan = StudyPlan(
    items: [
      StudyItem(id: Uuid().v4(), title: 'Cartea: Despre persoane', type: 'materia'),
      StudyItem(id: Uuid().v4(), title: 'Tema 2 - Despre persoane', type: 'tema'),
      StudyItem(id: Uuid().v4(), title: 'Test suplimentar 1,2,3', type: 'test'),
    ],
  );

  StudyPlan get plan => _plan;

  void updateSettings({int? hours, DateTime? examDate, List<String>? prefs}) {
    if (hours != null) _plan.hoursPerDay = hours;
    if (examDate != null) _plan.examDate = examDate;
    if (prefs != null) _plan.preferences = prefs;
    notifyListeners();
  }

  void completeItem(String id) {
    _plan.completeItem(id);
    if (_plan.items.every((i) => i.isCompleted)) _plan.calculateGrade();
    notifyListeners();
  }
}

class PlanuriPage extends StatelessWidget {
  const PlanuriPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('ro').then((_) {
      if (context.mounted) {
        (context as Element).markNeedsBuild();
      }
    });

    return ChangeNotifierProvider(
      create: (_) => StudyPlanProvider(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: const SafeArea(child: PlanuriContent()),
      ),
    );
  }
}

class PlanuriContent extends StatelessWidget {
  const PlanuriContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StudyPlanProvider>(context);
    final plan = provider.plan;
    final todos = plan.items;
    final isMatDone = todos.where((i) => i.type == 'materia').every((i) => i.isCompleted);
    final isTemaDone = todos.where((i) => i.type == 'tema').every((i) => i.isCompleted);

    const List<List<Color>> miniCardGradients = [
      [
        Color(0xFF0288D1),
        Color(0xFF03A9F4),
        Color(0xFF4FC3F7),
      ],
      [
        Color(0xFFD81B60),
        Color(0xFFF06292),
        Color(0xFFF8BBD0),
      ],
      [
        Color(0xFF388E3C),
        Color(0xFF4CAF50),
        Color(0xFFA5D6A7),
      ],
      [
        Color(0xFFFF5722),
        Color(0xFFFF8A65),
        Color(0xFFFFAB91),
      ],
      [
        Color(0xFF6A1B9A),
        Color(0xFFAB47BC),
        Color(0xFFE1BEE7),
      ],
      [
        Color(0xFFFFC107),
        Color(0xFFFFE082),
        Color(0xFFFFECB3),
      ],
    ];

    final List<DateTime> cardDates = [
      DateTime(2025, 5, 24),
      DateTime(2025, 5, 25),
      DateTime(2025, 5, 26),
      DateTime(2025, 5, 27),
      DateTime(2025, 5, 28),
      DateTime(2025, 5, 29),
    ];

    final screenWidth = MediaQuery.of(context).size.width;
    const horizontalPadding = 16.0 * 2;
    const spacingBetweenCards = 2.0 * 2;
    final cardWidth = (screenWidth - horizontalPadding - spacingBetweenCards) / 3;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF6A1B9A),
                          Color(0xFFE91E63),
                          Color(0xFFFFC107),
                          Color(0xFFFF5722),
                          Color(0xFFF06292),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white.withOpacity(0.15),
                      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  'Pentru azi',
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...todos.map((item) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    children: [
                                      Icon(
                                        item.type == 'materia'
                                            ? Icons.book_rounded
                                            : item.type == 'tema'
                                                ? Icons.assignment_rounded
                                                : Icons.quiz_rounded,
                                        color: Colors.black87,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          item.title,
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      if (item.isCompleted)
                                        const Icon(Icons.check_circle, color: Colors.black87, size: 22),
                                    ],
                                  ),
                                );
                              }).toList(),
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: () {
                                  final nextItem = todos.firstWhere((i) => !i.isCompleted, orElse: () => todos.last);
                                  provider.completeItem(nextItem.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Începi: ${nextItem.title}')),
                                  );
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Începe',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/carti/1.png',
                            width: 100,
                            height: 140,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: IconButton(
                  icon: const Icon(Icons.settings, color: Colors.black87),
                  onPressed: () => _openSettingsModal(context, provider),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: plan.progress,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(const Color(0xFF6A1B9A)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Progres: ${(plan.progress * 100).toStringAsFixed(0)}%',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          if (plan.grade != null) ...[
            const SizedBox(height: 16),
            Text(
              'Nota finală: ${plan.grade!.toStringAsFixed(1)}',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6A1B9A),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _openPlanModal(context, todos, cardDates[0], miniCardGradients[0], 'assets/carti/2.png'),
                    child: _buildMiniCard(0, todos, miniCardGradients, cardDates, cardWidth),
                  ),
                  const SizedBox(width: 2),
                  GestureDetector(
                    onTap: () => _openPlanModal(context, todos, cardDates[1], miniCardGradients[1], 'assets/carti/3.png'),
                    child: _buildMiniCard(1, todos, miniCardGradients, cardDates, cardWidth),
                  ),
                  const SizedBox(width: 2),
                  GestureDetector(
                    onTap: () => _openPlanModal(context, todos, cardDates[2], miniCardGradients[2], 'assets/carti/4.png'),
                    child: _buildMiniCard(2, todos, miniCardGradients, cardDates, cardWidth),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _openPlanModal(context, todos, cardDates[3], miniCardGradients[3], 'assets/carti/5.png'),
                    child: _buildMiniCard(3, todos, miniCardGradients, cardDates, cardWidth),
                  ),
                  const SizedBox(width: 2),
                  GestureDetector(
                    onTap: () => _openPlanModal(context, todos, cardDates[4], miniCardGradients[4], 'assets/carti/6.png'),
                    child: _buildMiniCard(4, todos, miniCardGradients, cardDates, cardWidth),
                  ),
                  const SizedBox(width: 2),
                  GestureDetector(
                    onTap: () => _openPlanModal(context, todos, cardDates[5], miniCardGradients[5], 'assets/carti/7.png'),
                    child: _buildMiniCard(5, todos, miniCardGradients, cardDates, cardWidth),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCard(int index, List<StudyItem> todos, List<List<Color>> gradients, List<DateTime> cardDates, double cardWidth) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: cardWidth,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradients[index],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white.withOpacity(0.15),
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...todos.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Icon(
                                  item.type == 'materia'
                                      ? Icons.book_rounded
                                      : item.type == 'tema'
                                          ? Icons.assignment_rounded
                                          : Icons.quiz_rounded,
                                  color: Colors.black87,
                                  size: 10,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: GoogleFonts.poppins(
                                      fontSize: 7,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (item.isCompleted)
                                  const Icon(Icons.check_circle, color: Colors.black87, size: 10),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(
                      'assets/carti/${index + 2}.png',
                      width: 30,
                      height: 42,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${cardDates[index].day}.${cardDates[index].month}.${cardDates[index].year}',
          style: GoogleFonts.poppins(
            fontSize: 8,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  void _openPlanModal(BuildContext context, List<StudyItem> todos, DateTime date, List<Color> gradient, String imagePath) {
    final dateFormatter = DateFormat('d MMMM yyyy', 'ro');
    final weekdayFormatter = DateFormat('EEEE', 'ro');
    final formattedDate = dateFormatter.format(date);
    final weekday = weekdayFormatter.format(date);
    final formattedWeekday = weekday[0].toUpperCase() + weekday.substring(1);

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withOpacity(0.15),
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Planul pentru:',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$formattedDate - $formattedWeekday',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...todos.map((item) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    children: [
                                      Icon(
                                        item.type == 'materia'
                                            ? Icons.book_rounded
                                            : item.type == 'tema'
                                                ? Icons.assignment_rounded
                                                : Icons.quiz_rounded,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          item.title,
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      if (item.isCompleted)
                                        const Icon(Icons.check_circle, color: Colors.white, size: 22),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            imagePath,
                            width: 100,
                            height: 140,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Închide',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _openSettingsModal(BuildContext context, StudyPlanProvider provider) {
    final hoursController = TextEditingController(text: provider.plan.hoursPerDay.toString());
    DateTime? selectedDate = provider.plan.examDate;
    final prefs = <String>{...provider.plan.preferences};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (ctx, setState) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Text('Setări plan', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Text('Orele de studiu pe zi:', style: GoogleFonts.poppins()),
                      TextField(
                        controller: hoursController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'Ore pe zi'),
                      ),
                      const SizedBox(height: 12),
                      Text('Data examenului:', style: GoogleFonts.poppins()),
                      GestureDetector(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: ctx,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) setState(() => selectedDate = date);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            selectedDate != null
                                ? '${selectedDate!.day}.${selectedDate!.month}.${selectedDate!.year}'
                                : 'Selectează data',
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('Preferințe:', style: GoogleFonts.poppins()),
                      Wrap(
                        spacing: 8,
                        children: [
                          'Începe de la zero', 'Recap intensiv', 'Doar teste',
                          'Doar materie', 'Teste combinate', 'Teste suplimentare',
                          'Simulări', 'Spețe', 'Flashcarduri',
                          'Grile anii anteriori', 'Grile dificile'
                        ].map((opt) {
                          final selected = prefs.contains(opt);
                          return FilterChip(
                            label: Text(opt, style: GoogleFonts.poppins(fontSize: 12)),
                            selected: selected,
                            onSelected: (sel) {
                              setState(() {
                                sel ? prefs.add(opt) : prefs.remove(opt);
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            final hours = int.tryParse(hoursController.text) ?? provider.plan.hoursPerDay;
                            provider.updateSettings(
                              hours: hours,
                              examDate: selectedDate,
                              prefs: prefs.toList(),
                            );
                            Navigator.of(ctx).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6A1B9A),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          ),
                          child: Text('Salvează', style: GoogleFonts.poppins()),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}