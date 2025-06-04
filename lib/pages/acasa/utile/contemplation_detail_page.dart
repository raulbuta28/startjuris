import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';

class ContemplationDetailPage extends StatefulWidget {
  final String title;
  final String description;
  final String image;

  const ContemplationDetailPage({
    super.key,
    required this.title,
    required this.description,
    required this.image,
  });

  @override
  State<ContemplationDetailPage> createState() => _ContemplationDetailPageState();
}

class _ContemplationDetailPageState extends State<ContemplationDetailPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final TextEditingController _noteController = TextEditingController();
  final List<bool> _completedSteps = List.generate(5, (index) => false);
  String _personalNote = '';
  bool _isEditingNote = false;

  Map<String, List<Map<String, dynamic>>> get _detailedContent {
    return {
      'Scop': [
        {
          'title': 'Identifică-ți valorile personale',
          'description': 'Reflectează asupra valorilor tale fundamentale și cum acestea se aliniază cu cariera juridică. Ce principii te ghidează în viață?',
          'action': 'Scrie 3 valori esențiale pentru tine și cum te vor ghida în carieră.',
          'quote': '"Succesul nu este final, eșecul nu este fatal: curajul de a continua contează." - Winston Churchill'
        },
        {
          'title': 'Definește-ți motivația profundă',
          'description': 'Ce te inspiră cu adevărat în domeniul juridic? Care sunt momentele care ți-au confirmat această alegere?',
          'action': 'Descrie momentul care te-a făcut să alegi dreptul.',
          'quote': '"Justiția este constanța și perpetua voință de a da fiecăruia ce i se cuvine." - Ulpian'
        },
        {
          'title': 'Stabilește obiective clare',
          'description': 'Vizualizează-ți cariera în etape distincte. Unde vrei să fii peste 1 an? Dar peste 5 ani?',
          'action': 'Creează un timeline al obiectivelor tale profesionale.',
          'quote': '"Cel mai bun mod de a prezice viitorul este să-l creezi." - Peter Drucker'
        },
        {
          'title': 'Aliniază profesia cu valorile',
          'description': 'Cum poți folosi dreptul pentru a-ți exprima valorile? În ce domeniu juridic te regăsești cel mai bine?',
          'action': 'Identifică 3 domenii juridice care te atrag și de ce.',
          'quote': '"Legea este ordinea lucrurilor, iar ordinea este calea spre excelență." - Aristotel'
        },
        {
          'title': 'Planifică impactul social',
          'description': 'Ce schimbare vrei să aduci în societate prin profesia ta? Cum poți folosi dreptul pentru binele comun?',
          'action': 'Descrie viziunea ta despre justiție și impactul dorit.',
          'quote': '"Să fii avocat înseamnă să fii un agent al schimbării sociale." - Thurgood Marshall'
        }
      ],
      'Anxietate': [
        {
          'title': 'Acceptă și înțelege anxietatea',
          'description': 'Anxietatea este o reacție naturală la provocări. Cum o poți transforma într-un catalizator pentru creștere?',
          'action': 'Identifică 3 situații care îți provoacă anxietate și cum le poți aborda.',
          'quote': '"Curajul nu este absența fricii, ci triumful asupra ei." - Nelson Mandela'
        },
        {
          'title': 'Tehnici de respirație și mindfulness',
          'description': 'Respirația conștientă este ancora ta în prezent. Învață să o folosești pentru a-ți calma mintea.',
          'action': 'Practică exercițiul 4-7-8: inspiră 4s, ține 7s, expiră 8s.',
          'quote': '"Respiră. Lasă să treacă. Observă cum fiecare respirație este o nouă șansă." - Thich Nhat Hanh'
        },
        {
          'title': 'Organizare și planificare',
          'description': 'Structura aduce claritate și reduce anxietatea. Cum îți poți organiza mai bine studiul?',
          'action': 'Creează un plan săptămânal realist și flexibil.',
          'quote': '"Ordinea este jumătate din viață." - John Dryden'
        },
        {
          'title': 'Rutine de relaxare',
          'description': 'Dezvoltă ritualuri care te ajută să te reconectezi cu tine însuți și să-ți recapeți energia.',
          'action': 'Stabilește 3 activități zilnice de relaxare.',
          'quote': '"Liniștea nu este absența activității, ci prezența armoniei." - Anon'
        },
        {
          'title': 'Construiește un sistem de suport',
          'description': 'Nu trebuie să mergi singur pe acest drum. Cine sunt oamenii care te pot sprijini?',
          'action': 'Identifică 3 persoane cu care poți vorbi când ai nevoie.',
          'quote': '"Împreună suntem mai puternici." - Helen Keller'
        }
      ],
      // ... Adaugă conținut similar pentru celelalte categorii
    };
  }

  List<Map<String, dynamic>> _getDetailedSteps() {
    return _detailedContent[widget.title] ?? [];
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _controller.forward();
    _loadProgress();
    _loadNote();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (int i = 0; i < _completedSteps.length; i++) {
        _completedSteps[i] = prefs.getBool('${widget.title}_step_$i') ?? false;
      }
    });
  }

  Future<void> _saveProgress(int index, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${widget.title}_step_$index', value);
  }

  Future<void> _loadNote() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _personalNote = prefs.getString('${widget.title}_note') ?? '';
      _noteController.text = _personalNote;
    });
  }

  Future<void> _saveNote(String note) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${widget.title}_note', note);
  }

  @override
  void dispose() {
    _controller.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final steps = _getDetailedSteps();
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            stretch: true,
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.share_outlined, color: Colors.white),
                    onPressed: () {
                      final completedCount = _completedSteps.where((step) => step).length;
                      final totalSteps = _completedSteps.length;
                      final percentage = (completedCount / totalSteps * 100).toInt();
                      
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) => Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    Text(
                                      'Progres în ${widget.title}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    CircularProgressIndicator(
                                      value: completedCount / totalSteps,
                                      backgroundColor: Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                                      strokeWidth: 8,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      '$percentage% completat',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '$completedCount din $totalSteps pași finalizați',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Progresul tău a fost salvat și exportat!'),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue[700],
                                        minimumSize: const Size(double.infinity, 50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text(
                                        'Exportă progresul',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3.0,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: widget.image,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(widget.image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 80,
                    left: 16,
                    right: 16,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.description,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: _completedSteps.where((step) => step).length / _completedSteps.length,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                                minHeight: 6,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${(_completedSteps.where((step) => step).length / _completedSteps.length * 100).toInt()}% din parcurs completat',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue[700]!, Colors.blue[400]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Progresul tău',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: _completedSteps.where((step) => step).length / _completedSteps.length,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(_completedSteps.where((step) => step).length / _completedSteps.length * 100).toInt()}% completat',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: steps.length,
                    itemBuilder: (context, index) {
                      return FadeTransition(
                        opacity: CurvedAnimation(
                          parent: _controller,
                          curve: Interval(
                            index * 0.1,
                            index * 0.1 + 0.6,
                            curve: Curves.easeOut,
                          ),
                        ),
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.3, 0.0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _controller,
                            curve: Interval(
                              index * 0.1,
                              index * 0.1 + 0.6,
                              curve: Curves.easeOut,
                            ),
                          )),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 2,
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ExpansionTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: _completedSteps[index] ? Colors.green : Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: _completedSteps[index]
                                        ? const Icon(Icons.check, color: Colors.white)
                                        : Text(
                                            '${index + 1}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                  ),
                                ),
                                title: Text(
                                  steps[index]['title'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          steps[index]['description'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: Colors.orange.withOpacity(0.3),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.lightbulb_outline,
                                                color: Colors.orange,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  steps[index]['action'] ?? '',
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.purple.withOpacity(0.1),
                                                Colors.blue.withOpacity(0.1),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            children: [
                                              const Icon(
                                                Icons.format_quote,
                                                color: Colors.purple,
                                                size: 24,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                steps[index]['quote'] ?? '',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.purple[700],
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _completedSteps[index] ? 'Completat!' : 'Marchează ca terminat',
                                              style: TextStyle(
                                                color: _completedSteps[index] ? Colors.green : Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Switch(
                                              value: _completedSteps[index],
                                              onChanged: (bool value) {
                                                setState(() {
                                                  _completedSteps[index] = value;
                                                  _saveProgress(index, value);
                                                });
                                              },
                                              activeColor: Colors.green,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Notițele tale',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _isEditingNote ? Icons.check : Icons.edit,
                                color: Colors.blue,
                              ),
                              onPressed: () {
                                if (_isEditingNote) {
                                  _saveNote(_noteController.text);
                                  setState(() {
                                    _personalNote = _noteController.text;
                                    _isEditingNote = false;
                                  });
                                } else {
                                  setState(() {
                                    _isEditingNote = true;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_isEditingNote)
                          TextField(
                            controller: _noteController,
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText: 'Scrie gândurile tale aici...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          )
                        else
                          Text(
                            _personalNote.isEmpty
                                ? 'Apasă pe creion pentru a adăuga notițe...'
                                : _personalNote,
                            style: TextStyle(
                              fontSize: 16,
                              color: _personalNote.isEmpty ? Colors.grey : Colors.black87,
                              fontStyle: _personalNote.isEmpty ? FontStyle.italic : FontStyle.normal,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 