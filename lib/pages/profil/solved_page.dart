import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';

class SolvedPage extends StatefulWidget {
  const SolvedPage({super.key});

  @override
  _SolvedPageState createState() => _SolvedPageState();
}

class _SolvedPageState extends State<SolvedPage> {
  final ScrollController _scrollController = ScrollController();
  
  final List<Map<String, dynamic>> testData = [
    {
      'category': 'Teme',
      'icon': Icons.assignment,
      'color': Color(0xFF6C63FF),
      'tests': [
        {
          'title': 'Tema 1',
          'subject': 'Matematică',
          'mistakes': 3,
          'date': DateTime(2025, 5, 20),
          'completed': true,
        },
        {
          'title': 'Tema 2',
          'subject': 'Matematică',
          'mistakes': 0,
          'date': DateTime(2025, 5, 18),
          'completed': true,
        },
        {
          'title': 'Tema 3',
          'subject': 'Matematică',
          'mistakes': null,
          'date': null,
          'completed': false,
        },
        {
          'title': 'Tema 4',
          'subject': 'Matematică',
          'mistakes': null,
          'date': null,
          'completed': false,
        },
      ],
    },
    {
      'category': 'Teste suplimentare',
      'icon': Icons.science,
      'color': Color(0xFFFF6B6B),
      'tests': [
        {
          'title': 'Test suplimentar 1',
          'subject': 'Fizică',
          'mistakes': 5,
          'date': DateTime(2025, 5, 15),
          'completed': true,
        },
        {
          'title': 'Test suplimentar 2',
          'subject': 'Fizică',
          'mistakes': null,
          'date': null,
          'completed': false,
        },
      ],
    },
    {
      'category': 'Teste combinate',
      'icon': Icons.merge_type,
      'color': Color(0xFF4ECDC4),
      'tests': [
        {
          'title': 'Test combinat 1',
          'subject': 'Chimie',
          'mistakes': 2,
          'date': DateTime(2025, 5, 10),
          'completed': true,
        },
        {
          'title': 'Test combinat 2',
          'subject': 'Chimie',
          'mistakes': null,
          'date': null,
          'completed': false,
        },
      ],
    },
    {
      'category': 'Simulări',
      'icon': Icons.timer,
      'color': Color(0xFFFFBE0B),
      'tests': [
        {
          'title': 'Simulare 1',
          'subject': 'Matematică',
          'mistakes': 7,
          'date': DateTime(2025, 5, 5),
          'completed': true,
        },
        {
          'title': 'Simulare 2',
          'subject': 'Matematică',
          'mistakes': null,
          'date': null,
          'completed': false,
        },
      ],
    },
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView.builder(
        controller: _scrollController,
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
        itemCount: testData.length,
        itemBuilder: (context, index) {
          final category = testData[index];
          return FadeInUp(
            duration: Duration(milliseconds: 400 + (index * 100)),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: category['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            category['icon'],
                            color: category['color'],
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          category['category'],
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: (category['tests'] as List).length,
                      itemBuilder: (context, testIndex) {
                        final test = category['tests'][testIndex];
                        return Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: TestCard(
                            title: test['title'],
                            subject: test['subject'],
                            mistakes: test['mistakes'],
                            date: test['date'],
                            completed: test['completed'],
                            color: category['color'],
                            onTap: () {
                              // Navigate to test details
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class TestCard extends StatefulWidget {
  final String title;
  final String subject;
  final int? mistakes;
  final DateTime? date;
  final bool completed;
  final Color color;
  final VoidCallback onTap;

  const TestCard({
    super.key,
    required this.title,
    required this.subject,
    required this.mistakes,
    required this.date,
    required this.completed,
    required this.color,
    required this.onTap,
  });

  @override
  _TestCardState createState() => _TestCardState();
}

class _TestCardState extends State<TestCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: 180,
          constraints: BoxConstraints(minHeight: 220),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.description_outlined,
                        size: 40,
                        color: widget.color,
                      ),
                    ),
                    if (widget.completed)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green.shade400,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Rezolvat',
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.school_outlined,
                              size: 16,
                              color: widget.color,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                widget.subject,
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (widget.completed && widget.mistakes != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: widget.mistakes == 0 
                                  ? Colors.green.shade50 
                                  : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  widget.mistakes == 0 
                                      ? Icons.emoji_events 
                                      : Icons.error_outline,
                                  size: 16,
                                  color: widget.mistakes == 0 
                                      ? Colors.green.shade700 
                                      : Colors.red.shade400,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.mistakes == 0 
                                      ? 'Perfect!' 
                                      : '${widget.mistakes} greșeli',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: widget.mistakes == 0 
                                        ? Colors.green.shade700 
                                        : Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (widget.completed && widget.date != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 14,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('dd MMM yyyy', 'ro').format(widget.date!),
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (!widget.completed)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.pending_outlined,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Nerezolvat',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade700,
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
            ],
          ),
        ),
      ),
    );
  }
}