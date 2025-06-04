import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class Article {
  final String id;
  final String number;
  final String title;
  final String content;
  final List<String> notes;
  final List<String> references;
  final bool isImportant;
  final List<String> keywords;
  final int order;

  Article({
    required this.id,
    required this.number,
    required this.title,
    required this.content,
    required this.notes,
    required this.references,
    required this.isImportant,
    required this.keywords,
    required this.order,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] ?? '',
      number: json['number'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      notes: List<String>.from(json['notes'] ?? []),
      references: List<String>.from(json['references'] ?? []),
      isImportant: json['isImportant'] ?? false,
      keywords: List<String>.from(json['keywords'] ?? []),
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'title': title,
      'content': content,
      'notes': notes,
      'references': references,
      'isImportant': isImportant,
      'keywords': keywords,
      'order': order,
    };
  }
}

class CodeSection {
  final String id;
  final String title;
  final String? subtitle;
  final List<CodeSection> subsections;
  final List<Article> articles;
  final int order;

  CodeSection({
    required this.id,
    required this.title,
    this.subtitle,
    this.subsections = const [],
    this.articles = const [],
    required this.order,
  });

  factory CodeSection.fromJson(Map<String, dynamic> json) {
    return CodeSection(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'],
      subsections: (json['subsections'] as List<dynamic>?)
              ?.map((section) => CodeSection.fromJson(section))
              .toList() ??
          [],
      articles: (json['articles'] as List<dynamic>?)
              ?.map((article) => Article.fromJson(article))
              .toList() ??
          [],
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'subsections': subsections.map((s) => s.toJson()).toList(),
      'articles': articles.map((a) => a.toJson()).toList(),
      'order': order,
    };
  }
}

class ParsedCode {
  final String id;
  final String title;
  final String type;
  final List<Book> books;
  final Map<String, dynamic> metadata;
  final DateTime lastUpdated;
  final int totalArticles;
  final List<Article> articles;

  ParsedCode({
    required this.id,
    required this.title,
    required this.type,
    required this.books,
    required this.metadata,
    required this.lastUpdated,
    required this.totalArticles,
    required this.articles,
  });

  factory ParsedCode.fromJson(Map<String, dynamic> json) {
    print('Parsing ParsedCode with keys: ${json.keys}');
    try {
      return ParsedCode(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        type: json['type'] ?? '',
        books: (json['books'] as List<dynamic>?)
                ?.map((book) => Book.fromJson(book))
                .toList() ??
            [],
        metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
        lastUpdated: json['lastUpdated'] != null
            ? DateTime.tryParse(json['lastUpdated']) ?? DateTime.now()
            : DateTime.now(),
        totalArticles: json['totalArticles'] ?? 0,
        articles: (json['articles'] as List<dynamic>?)
                ?.map((article) => Article.fromJson(article))
                .toList() ??
            [],
      );
    } catch (e) {
      print('Error in ParsedCode.fromJson: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'books': books.map((b) => b.toJson()).toList(),
      'metadata': metadata,
      'lastUpdated': lastUpdated.toIso8601String(),
      'totalArticles': totalArticles,
      'articles': articles.map((a) => a.toJson()).toList(),
    };
  }
}

class Book {
  final String id;
  final String title;
  final String? subtitle;
  final List<CodeTitle> titles;
  final int order;

  Book({
    required this.id,
    required this.title,
    this.subtitle,
    required this.titles,
    required this.order,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'],
      titles: (json['titles'] as List<dynamic>?)
              ?.map((title) => CodeTitle.fromJson(title))
              .toList() ??
          [],
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'titles': titles.map((t) => t.toJson()).toList(),
      'order': order,
    };
  }
}

class CodeTitle {
  final String id;
  final String title;
  final String? subtitle;
  final List<Chapter> chapters;
  final int order;

  CodeTitle({
    required this.id,
    required this.title,
    this.subtitle,
    required this.chapters,
    required this.order,
  });

  factory CodeTitle.fromJson(Map<String, dynamic> json) {
    return CodeTitle(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'],
      chapters: (json['chapters'] as List<dynamic>?)
              ?.map((chapter) => Chapter.fromJson(chapter))
              .toList() ??
          [],
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'chapters': chapters.map((c) => c.toJson()).toList(),
      'order': order,
    };
  }
}

class Chapter {
  final String id;
  final String title;
  final String? subtitle;
  final List<CodeSection> sections;
  final int order;

  Chapter({
    required this.id,
    required this.title,
    this.subtitle,
    required this.sections,
    required this.order,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'],
      sections: (json['sections'] as List<dynamic>?)
              ?.map((section) => CodeSection.fromJson(section))
              .toList() ??
          [],
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'sections': sections.map((s) => s.toJson()).toList(),
      'order': order,
    };
  }
}

class ApiServiceCoduri extends ApiService {
  ApiServiceCoduri({super.token});

  Future<ParsedCode> getCodeContent(String codeId) async {
    try {
      final uri = Uri.parse('${ApiService.baseUrl}/codes/$codeId');
      final response = await http.get(uri, headers: headers);

      print('Code fetch URL: $uri');
      print('Code fetch response status: ${response.statusCode}');
      print('Code fetch response headers: ${response.headers}');
      print('Code fetch response body (first 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print('Parsed data type: ${data.runtimeType}');
        print('Parsed data (first 500 chars): ${data.toString().substring(0, data.toString().length > 500 ? 500 : data.toString().length)}');

        if (data is Map<String, dynamic>) {
          return ParsedCode.fromJson(data);
        } else {
          throw Exception('Unexpected response format: ${data.runtimeType}, body (first 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
        }
      } else {
        throw Exception('Failed to load code: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching code: $e');
      throw Exception('Error fetching code: $e');
    }
  }

  Future<List<Map<String, dynamic>>> searchContent({
    required String query,
    String? codeType,
  }) async {
    try {
      final uri = Uri.parse('${ApiService.baseUrl}/codes/$codeType/search').replace(queryParameters: {
        'q': query,
      });

      final response = await http.get(uri, headers: headers);

      print('Search URL: $uri');
      print('Search response status: ${response.statusCode}');
      print('Search response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['matches'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
      } else {
        throw Exception('Search failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Search error: $e');
      return [];
    }
  }
}