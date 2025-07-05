import 'dart:convert';
import 'package:http/http.dart' as http;
import '../pages/backend/services/api_service.dart';
import '../pages/grile/admitereinm/models.dart';

String _cleanQuestionText(String text) {
  final reg = RegExp(r'^\s*\d{1,3}\s*[\.\)\-:]\s*');
  return text.replaceFirst(reg, '');
}

class FetchedTest {
  final String id;
  final String name;
  final String subject;
  final List<Question> questions;
  final List<String> categories;
  final int order;
  final List<String> sections;

  FetchedTest({
    required this.id,
    required this.name,
    required this.subject,
    required this.questions,
    required this.categories,
    required this.order,
    required this.sections,
  });

  factory FetchedTest.fromJson(Map<String, dynamic> json) {
    final sections = (json['sections'] as List? ?? [])
        .map((e) => e.toString())
        .toList();
    String currentSection = '';
    final questions = (json['questions'] as List? ?? [])
        .asMap()
        .entries
        .map<Question>((entry) {
      final q = entry.value as Map<String, dynamic>;
      final answers = (q['answers'] as List? ?? [])
          .asMap()
          .entries
          .map<Answer>((a) => Answer(
                letter: String.fromCharCode(65 + a.key),
                text: a.value.toString(),
              ))
          .toList();
      final correctIndexes = (q['correct'] as List? ?? [])
          .map((e) => e as int)
          .toList();
      final correctLetters =
          correctIndexes.map((i) => String.fromCharCode(65 + i)).toList();
      String section = q['section']?.toString() ?? '';
      if (section.isNotEmpty) {
        currentSection = section;
      } else if (currentSection.isEmpty && sections.isNotEmpty) {
        // If no section specified yet, fall back to first provided section
        currentSection = sections.first;
      }
      return Question(
        id: entry.key + 1,
        text: _cleanQuestionText(q['text']?.toString() ?? ''),
        answers: answers,
        correctAnswers: correctLetters,
        explanation: q['explanation'] ?? '',
        note: q['note']?.toString() ?? '',
        categories: (q['categories'] as List? ?? ['INM', 'Barou', 'INR'])
            .map((e) => e.toString())
            .toList(),
        section: section.isNotEmpty ? section : currentSection,
      );
    }).toList();

    return FetchedTest(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      subject: json['subject'] ?? '',
      questions: questions,
      categories: (json['categories'] as List? ?? ['INM', 'Barou', 'INR'])
          .map((e) => e.toString())
          .toList(),
      order: json['order'] is int ? json['order'] as int : 0,
      sections: (json['sections'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

class TestsService {
  static Future<List<FetchedTest>> fetchTests() async {
    final uri = Uri.parse('${ApiService.baseUrl}/tests');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((e) => FetchedTest.fromJson(e)).toList();
    }
    throw Exception('failed to load tests');
  }
}
