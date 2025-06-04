import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ReflectionsPage extends StatefulWidget {
  const ReflectionsPage({super.key});

  @override
  State<ReflectionsPage> createState() => _ReflectionsPageState();
}

class _ReflectionsPageState extends State<ReflectionsPage> with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> _reflections = [];
  late AnimationController _controller;
  late TextEditingController _textController;
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _textController = TextEditingController();
    _loadReflections();
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadReflections() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoading = true;
    });

    try {
      final String? reflectionsJson = prefs.getString('reflections');
      if (reflectionsJson != null) {
        final List<dynamic> decoded = json.decode(reflectionsJson);
        _reflections.clear();
        _reflections.addAll(decoded.cast<Map<String, dynamic>>());
      }
    } catch (e) {
      debugPrint('Error loading reflections: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveReflection(String text) async {
    if (text.trim().isEmpty) return;

    final reflection = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'text': text,
      'date': DateTime.now().toIso8601String(),
      'color': _getRandomPastelColor().value,
    };

    setState(() {
      _reflections.insert(0, reflection);
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reflections', json.encode(_reflections));
    _textController.clear();
  }

  Color _getRandomPastelColor() {
    final List<Color> colors = [
      const Color(0xFFFFD6D6), // Pastel Red
      const Color(0xFFD6FFD6), // Pastel Green
      const Color(0xFFD6D6FF), // Pastel Blue
      const Color(0xFFFFE8D6), // Pastel Orange
      const Color(0xFFFFF0D6), // Pastel Yellow
      const Color(0xFFFFD6FF), // Pastel Purple
    ];
    return colors[DateTime.now().millisecond % colors.length];
  }

  Future<void> _deleteReflection(String id) async {
    setState(() {
      _reflections.removeWhere((reflection) => reflection['id'] == id);
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reflections', json.encode(_reflections));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Reflecții',
          style: GoogleFonts.playfairDisplay(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _reflections.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.auto_stories,
                                size: 80,
                                color: Colors.grey[300],
                              ).animate()
                                .fade(duration: const Duration(milliseconds: 500))
                                .scale(delay: const Duration(milliseconds: 200)),
                              const SizedBox(height: 16),
                              Text(
                                'Începe să îți notezi gândurile...',
                                style: GoogleFonts.playfairDisplay(
                                  color: Colors.grey[400],
                                  fontSize: 18,
                                ),
                              ).animate()
                                .fade(delay: const Duration(milliseconds: 300))
                                .slideY(begin: 0.3, end: 0),
                            ],
                          ),
                        )
                      : MasonryGridView.count(
                          padding: const EdgeInsets.all(16),
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          itemCount: _reflections.length,
                          itemBuilder: (context, index) {
                            final reflection = _reflections[index];
                            final date = DateTime.parse(reflection['date']);
                            final formattedDate = DateFormat('d MMM, y').format(date);
                            
                            return Card(
                              color: Color(reflection['color']),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      reflection['text'],
                                      style: GoogleFonts.lora(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          formattedDate,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 20),
                                          onPressed: () => _deleteReflection(reflection['id']),
                                          color: Colors.black54,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ).animate()
                              .fade(duration: const Duration(milliseconds: 500))
                              .scale(delay: Duration(milliseconds: index * 100));
                          },
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, -4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _textController,
                            decoration: InputDecoration(
                              hintText: 'Scrie un gând...',
                              hintStyle: GoogleFonts.lora(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Te rog scrie ceva';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.send, color: Colors.white),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _saveReflection(_textController.text);
                              }
                            },
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