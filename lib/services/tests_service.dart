import 'dart:convert';
import 'package:http/http.dart' as http;
import '../pages/backend/services/api_service.dart';
import '../pages/grile/admitereinm/models.dart';

class FetchedTest {
  final String id;
  final String name;
  final String subject;
  final List<Question> questions;

  FetchedTest({
    required this.id,
    required this.name,
    required this.subject,
    required this.questions,
  });

  factory FetchedTest.fromJson(Map<String, dynamic> json) {
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
      return Question(
        id: entry.key + 1,
        text: q['text'] ?? '',
        answers: answers,
        correctAnswers: correctLetters,
        explanation: q['explanation'] ?? '',
        note: q['note']?.toString() ?? '',
      );
    }).toList();

    return FetchedTest(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      subject: json['subject'] ?? '',
      questions: questions,
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
