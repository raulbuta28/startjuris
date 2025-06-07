class CodeTextSection {
  final String type;
  final String name;
  final List<dynamic> content; // Can be CodeTextSection, CodeTextArticle or CodeTextNote

  CodeTextSection({required this.type, required this.name, required this.content});

  factory CodeTextSection.fromJson(Map<String, dynamic> json) {
    return CodeTextSection(
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      content: (json['content'] as List? ?? []).map((e) {
        if (e is Map<String, dynamic>) {
          if (e['type'] == 'Note' || e['type'] == 'Decision') {
            return CodeTextNote.fromJson(e);
          }
          if (e.containsKey('type')) {
            return CodeTextSection.fromJson(e);
          }
          if (e.containsKey('number')) {
            return CodeTextArticle.fromJson(e);
          }
        }
        return e;
      }).toList(),
    );
  }
}

class CodeTextArticle {
  String number;
  String title;
  List<String> content;
  List<String> amendments;

  CodeTextArticle({required this.number, required this.title, required this.content, required this.amendments});

  factory CodeTextArticle.fromJson(Map<String, dynamic> json) {
    return CodeTextArticle(
      number: json['number'] ?? '',
      title: json['title'] ?? '',
      content: List<String>.from(json['content'] ?? []),
      amendments: List<String>.from(json['amendments'] ?? []),
    );
  }
}

class CodeTextNote {
  final String type;
  final List<String> content;

  CodeTextNote({required this.type, required this.content});

  factory CodeTextNote.fromJson(Map<String, dynamic> json) {
    return CodeTextNote(
      type: json['type'] ?? '',
      content: List<String>.from(json['content'] ?? []),
    );
  }
}
