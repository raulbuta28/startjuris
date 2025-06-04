import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:intl/date_symbol_data_local.dart' as intl_data;
import 'dart:ui' show TextDirection, Matrix4, Rect, ImageFilter;

void main() {
  intl_data.initializeDateFormatting('ro_RO', null).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plan Studii',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.light,
          primary: const Color(0xFF6C63FF),
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: const Color(0xFF1A1A1A),
        ),
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: const SetariPlan(),
    );
  }
}

class SetariPlan extends StatefulWidget {
  const SetariPlan({super.key});

  @override
  State<SetariPlan> createState() => _SetariPlanState();
}

class _SetariPlanState extends State<SetariPlan> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  String? _scopPlan;
  DateTime? _dataInceput;
  DateTime? _dataExamen;
  String? _materieInceput;
  int? _oreStudiu;
  String? _intensitatePlan;
  String? _parcurgereMaterie;
  String? _personalizareGrileMaterie;

  final _scopOptions = ['Admitere INM', 'Barou', 'INR', 'Facultate'];
  final _materieOptions = ['Drept civil', 'Drept penal', 'Drept procesual civil', 'Drept procesual penal'];
  final _parcurgereOptions = ['Toată materia', 'Doar Drept civil', 'Doar Drept penal', 'Doar Drept procesual civil', 'Doar Drept procesual penal'];
  final _intensitateOptions = ['Ușor', 'Mediu', 'Intens'];
  final _personalizareOptions = ['Grile + Materie', 'Doar grile', 'Doar materie'];
  final _oreOptions = List.generate(12, (i) => i + 1);

  late final AnimationController _backgroundController;
  late final AnimationController _floatingController;
  late final AnimationController _shimmerController;
  late final Animation<double> _floatingAnimation;
  late final Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _floatingAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _floatingController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _selectDate({required bool isExamen}) async {
    HapticFeedback.lightImpact();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(2030),
      locale: const Locale('ro', 'RO'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF6C63FF),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: const Color(0xFF1A1A1A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isExamen) _dataExamen = picked;
        else _dataInceput = picked;
      });
    }
  }

  void _generarePlan() {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      final plan = '''
Scop: ${_scopPlan!}
Data început: ${intl.DateFormat('d MMMM yyyy', 'ro_RO').format(_dataInceput!)}
Data examen: ${intl.DateFormat('d MMMM yyyy', 'ro_RO').format(_dataExamen!)}
Materie început: ${_materieInceput!}
Ore studiu/zi: $_oreStudiu
Intensitate: $_intensitatePlan
Parcurgere: $_parcurgereMaterie
Personalizare: $_personalizareGrileMaterie
''';
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutExpo,
            tween: Tween(begin: 1.0, end: 0.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 50 * value),
                child: Opacity(
                  opacity: 1 - value,
                  child: child,
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF6C63FF).withOpacity(0.95),
                    const Color(0xFF3B3663).withOpacity(0.95),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) {
                                return const LinearGradient(
                                  colors: [Colors.white, Color(0xFFE0E0FF)],
                                ).createShader(bounds);
                              },
                              child: Text(
                                'Planul Tău',
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            children: plan.split('\n').map((line) {
                              if (line.isEmpty) return const SizedBox.shrink();
                              final parts = line.split(': ');
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.only(top: 6, right: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.5),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            parts[0],
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: Colors.white.withOpacity(0.7),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            parts[1],
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF6C63FF),
                            minimumSize: const Size.fromHeight(56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Text(
                                  'Începe Studiul',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 16,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6C63FF).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
      _formKey.currentState!.reset();
      setState(() {
        _scopPlan = null;
        _dataInceput = null;
        _dataExamen = null;
        _materieInceput = null;
        _oreStudiu = null;
        _intensitatePlan = null;
        _parcurgereMaterie = null;
        _personalizareGrileMaterie = null;
      });
    }
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required Widget child,
    bool isButton = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isButton)
            SizedBox(width: double.infinity, child: child)
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: child,
            ),
        ],
      ),
    );
  }

  Widget _buildIntensityButton(String value) {
    final isSelected = _intensitatePlan == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _intensitatePlan = isSelected ? null : value;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF6C63FF),
                      const Color(0xFF3B3663),
                    ],
                  )
                : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? const Color(0xFF6C63FF).withOpacity(0.3)
                    : Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isSelected)
                Positioned(
                  right: 8,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        color: Colors.grey[400],
        fontSize: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.grey[200]!,
          width: 2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFF6C63FF),
          width: 2,
        ),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      prefixIcon: Container(
        margin: const EdgeInsets.only(left: 16, right: 8),
        width: 1,
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: Colors.grey[200]!,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFF5F5F5),
              Colors.grey[100]!,
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 250,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                title: ShimmerText(
                  'Planul Tău de Studiu',
                  animation: _shimmerAnimation,
                ),
                background: Stack(
                  children: [
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _backgroundController,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: _WavesPainter(
                              color: const Color(0xFF6C63FF).withOpacity(0.1),
                              progress: _backgroundController.value,
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _floatingAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _floatingAnimation.value),
                            child: _buildFloatingElements(),
                          );
                        },
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.9),
                            ],
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
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildSection(
                        title: 'Scopul Planului',
                        subtitle: 'Ce examen pregătești?',
                        child: DropdownButtonFormField<String>(
                          value: _scopPlan,
                          items: _scopOptions.map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(
                              s,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                          )).toList(),
                          onChanged: (v) {
                            HapticFeedback.selectionClick();
                            setState(() => _scopPlan = v);
                          },
                          validator: (v) => v == null ? 'Selectează un scop' : null,
                          decoration: _buildInputDecoration('Alege scopul'),
                        ),
                      ),
                      _buildSection(
                        title: 'Perioada de Studiu',
                        subtitle: 'Când începi și când dai examenul?',
                        isButton: true,
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.calendar_today, size: 20),
                                label: Text(
                                  _dataInceput != null
                                      ? intl.DateFormat('d MMM', 'ro_RO').format(_dataInceput!)
                                      : 'Start',
                                  style: GoogleFonts.poppins(fontSize: 16),
                                ),
                                onPressed: () => _selectDate(isExamen: false),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF6C63FF),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 4,
                                  shadowColor: const Color(0xFF6C63FF).withOpacity(0.2),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.event, size: 20),
                                label: Text(
                                  _dataExamen != null
                                      ? intl.DateFormat('d MMM', 'ro_RO').format(_dataExamen!)
                                      : 'Final',
                                  style: GoogleFonts.poppins(fontSize: 16),
                                ),
                                onPressed: () => _selectDate(isExamen: true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF6C63FF),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 4,
                                  shadowColor: const Color(0xFF6C63FF).withOpacity(0.2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildSection(
                        title: 'Materia de Start',
                        subtitle: 'Cu ce materie vrei să începi?',
                        child: DropdownButtonFormField<String>(
                          value: _materieInceput,
                          items: _materieOptions.map((m) => DropdownMenuItem(
                            value: m,
                            child: Text(
                              m,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                          )).toList(),
                          onChanged: (v) {
                            HapticFeedback.selectionClick();
                            setState(() => _materieInceput = v);
                          },
                          validator: (v) => v == null ? 'Selectează materia' : null,
                          decoration: _buildInputDecoration('Alege materia'),
                        ),
                      ),
                      _buildSection(
                        title: 'Program Zilnic',
                        subtitle: 'Câte ore poți aloca studiului în fiecare zi?',
                        child: DropdownButtonFormField<int>(
                          value: _oreStudiu,
                          items: _oreOptions.map((o) => DropdownMenuItem(
                            value: o,
                            child: Text(
                              '$o ${o == 1 ? 'oră' : 'ore'}',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                          )).toList(),
                          onChanged: (v) {
                            HapticFeedback.selectionClick();
                            setState(() => _oreStudiu = v);
                          },
                          validator: (v) => v == null ? 'Selectează numărul de ore' : null,
                          decoration: _buildInputDecoration('Alege numărul de ore'),
                        ),
                      ),
                      _buildSection(
                        title: 'Intensitatea Studiului',
                        subtitle: 'Cât de intens vrei să fie programul?',
                        child: Row(
                          children: _intensitateOptions
                              .map((option) => _buildIntensityButton(option))
                              .toList(),
                        ),
                      ),
                      _buildSection(
                        title: 'Materii de Parcurs',
                        subtitle: 'Ce materii vrei să studiezi?',
                        child: DropdownButtonFormField<String>(
                          value: _parcurgereMaterie,
                          items: _parcurgereOptions.map((p) => DropdownMenuItem(
                            value: p,
                            child: Text(
                              p,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                          )).toList(),
                          onChanged: (v) {
                            HapticFeedback.selectionClick();
                            setState(() => _parcurgereMaterie = v);
                          },
                          validator: (v) => v == null ? 'Selectează materiile' : null,
                          decoration: _buildInputDecoration('Alege materiile'),
                        ),
                      ),
                      _buildSection(
                        title: 'Stil de Învățare',
                        subtitle: 'Cum preferi să înveți?',
                        child: DropdownButtonFormField<String>(
                          value: _personalizareGrileMaterie,
                          items: _personalizareOptions.map((p) => DropdownMenuItem(
                            value: p,
                            child: Text(
                              p,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                          )).toList(),
                          onChanged: (v) {
                            HapticFeedback.selectionClick();
                            setState(() => _personalizareGrileMaterie = v);
                          },
                          validator: (v) => v == null ? 'Selectează stilul' : null,
                          decoration: _buildInputDecoration('Alege stilul'),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        margin: const EdgeInsets.only(bottom: 48),
                        child: ElevatedButton(
                          onPressed: _generarePlan,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 8,
                            shadowColor: const Color(0xFF6C63FF).withOpacity(0.4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.auto_awesome, size: 24),
                              const SizedBox(width: 12),
                              Text(
                                'Generează Planul',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingElements() {
    return Stack(
      children: [
        Positioned(
          top: 50,
          left: 20,
          child: _buildFloatingIcon(Icons.book, Colors.blue),
        ),
        Positioned(
          top: 100,
          right: 30,
          child: _buildFloatingIcon(Icons.school, Colors.purple),
        ),
        Positioned(
          top: 150,
          left: 120,
          child: _buildFloatingIcon(Icons.timer, Colors.orange),
        ),
      ],
    );
  }

  Widget _buildFloatingIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        icon,
        color: color.withOpacity(0.6),
        size: 24,
      ),
    );
  }
}

class ShimmerText extends StatelessWidget {
  final String text;
  final Animation<double> animation;

  const ShimmerText(this.text, {super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Color(0xFF6C63FF),
                Colors.white,
                Color(0xFF6C63FF),
              ],
              stops: [
                animation.value - 1,
                animation.value,
                animation.value + 1,
              ],
            ).createShader(bounds);
          },
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        );
      },
    );
  }
}

class _WavesPainter extends CustomPainter {
  final Color color;
  final double progress;

  _WavesPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final width = size.width;
    final height = size.height;

    path.moveTo(0, height * 0.8);
    for (var i = 0; i < width; i++) {
      final x = i.toDouble();
      final y = height * 0.8 +
          sin((x / width * 2 * pi) + (progress * 2 * pi)) * 20 +
          cos((x / width * 4 * pi) + (progress * 2 * pi)) * 10;
      path.lineTo(x, y);
    }
    path.lineTo(width, height);
    path.lineTo(0, height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}