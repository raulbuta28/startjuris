class CodeStructure {
  final String id;
  final String title;
  final String type; // 'civil', 'penal', 'proc_civil', 'proc_penal'
  final List<Book> books;
  final Map<String, dynamic> metadata;
  final DateTime lastUpdated;

  CodeStructure({
    required this.id,
    required this.title,
    required this.type,
    required this.books,
    required this.metadata,
    required this.lastUpdated,
  });

  factory CodeStructure.fromJson(Map<String, dynamic> json) {
    return CodeStructure(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      books: (json['books'] as List).map((b) => Book.fromJson(b)).toList(),
      metadata: json['metadata'] ?? {},
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'type': type,
    'books': books.map((b) => b.toJson()).toList(),
    'metadata': metadata,
    'lastUpdated': lastUpdated.toIso8601String(),
  };
}

class Book {
  final String id;
  final String title;
  final String? subtitle;
  final List<Title> titles;
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
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      titles: (json['titles'] as List).map((t) => Title.fromJson(t)).toList(),
      order: json['order'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'titles': titles.map((t) => t.toJson()).toList(),
    'order': order,
  };
}

class Title {
  final String id;
  final String title;
  final String? subtitle;
  final List<Chapter> chapters;
  final int order;

  Title({
    required this.id,
    required this.title,
    this.subtitle,
    required this.chapters,
    required this.order,
  });

  factory Title.fromJson(Map<String, dynamic> json) {
    return Title(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      chapters: (json['chapters'] as List).map((c) => Chapter.fromJson(c)).toList(),
      order: json['order'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'chapters': chapters.map((c) => c.toJson()).toList(),
    'order': order,
  };
}

class Chapter {
  final String id;
  final String title;
  final String? subtitle;
  final List<Section> sections;
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
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      sections: (json['sections'] as List).map((s) => Section.fromJson(s)).toList(),
      order: json['order'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'sections': sections.map((s) => s.toJson()).toList(),
    'order': order,
  };
}

class Section {
  final String id;
  final String title;
  final String? subtitle;
  final List<Subsection> subsections;
  final List<Article> articles;
  final int order;

  Section({
    required this.id,
    required this.title,
    this.subtitle,
    required this.subsections,
    required this.articles,
    required this.order,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      subsections: (json['subsections'] as List? ?? []).map((s) => Subsection.fromJson(s)).toList(),
      articles: (json['articles'] as List? ?? []).map((a) => Article.fromJson(a)).toList(),
      order: json['order'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'subsections': subsections.map((s) => s.toJson()).toList(),
    'articles': articles.map((a) => a.toJson()).toList(),
    'order': order,
  };
}

class Subsection {
  final String id;
  final String title;
  final String? subtitle;
  final List<Article> articles;
  final int order;

  Subsection({
    required this.id,
    required this.title,
    this.subtitle,
    required this.articles,
    required this.order,
  });

  factory Subsection.fromJson(Map<String, dynamic> json) {
    return Subsection(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      articles: (json['articles'] as List).map((a) => Article.fromJson(a)).toList(),
      order: json['order'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'articles': articles.map((a) => a.toJson()).toList(),
    'order': order,
  };
}

class Article {
  final String id;
  final String number;
  final String title;
  final String content;
  final List<String> paragraphs;
  final List<String> notes;
  final List<String> references;
  final DateTime? lastModified;
  final bool isImportant;
  final List<String> keywords;

  Article({
    required this.id,
    required this.number,
    required this.title,
    required this.content,
    required this.paragraphs,
    required this.notes,
    required this.references,
    this.lastModified,
    this.isImportant = false,
    required this.keywords,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      number: json['number'],
      title: json['title'],
      content: json['content'],
      paragraphs: List<String>.from(json['paragraphs'] ?? []),
      notes: List<String>.from(json['notes'] ?? []),
      references: List<String>.from(json['references'] ?? []),
      lastModified: json['lastModified'] != null ? DateTime.parse(json['lastModified']) : null,
      isImportant: json['isImportant'] ?? false,
      keywords: List<String>.from(json['keywords'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'number': number,
    'title': title,
    'content': content,
    'paragraphs': paragraphs,
    'notes': notes,
    'references': references,
    'lastModified': lastModified?.toIso8601String(),
    'isImportant': isImportant,
    'keywords': keywords,
  };

  String get fullText => '$title\n\n$content${notes.isNotEmpty ? '\n\nNote:\n${notes.join('\n')}' : ''}';
}

class ReadingProgress {
  final String codeId;
  final Set<String> readArticles;
  final Map<String, DateTime> readingDates;
  final Map<String, int> timeSpent; // in seconds
  final double overallProgress;
  final DateTime lastRead;

  ReadingProgress({
    required this.codeId,
    required this.readArticles,
    required this.readingDates,
    required this.timeSpent,
    required this.overallProgress,
    required this.lastRead,
  });

  factory ReadingProgress.fromJson(Map<String, dynamic> json) {
    return ReadingProgress(
      codeId: json['codeId'],
      readArticles: Set<String>.from(json['readArticles'] ?? []),
      readingDates: (json['readingDates'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, DateTime.parse(v))),
      timeSpent: Map<String, int>.from(json['timeSpent'] ?? {}),
      overallProgress: (json['overallProgress'] ?? 0.0).toDouble(),
      lastRead: DateTime.parse(json['lastRead']),
    );
  }

  Map<String, dynamic> toJson() => {
    'codeId': codeId,
    'readArticles': readArticles.toList(),
    'readingDates': readingDates.map((k, v) => MapEntry(k, v.toIso8601String())),
    'timeSpent': timeSpent,
    'overallProgress': overallProgress,
    'lastRead': lastRead.toIso8601String(),
  };
}

class SearchMatch {
  final String articleId;
  final String articleNumber;
  final String articleTitle;
  final String matchedText;
  final String context;
  final double relevanceScore;
  final List<String> highlightedKeywords;

  SearchMatch({
    required this.articleId,
    required this.articleNumber,
    required this.articleTitle,
    required this.matchedText,
    required this.context,
    required this.relevanceScore,
    required this.highlightedKeywords,
  });

  factory SearchMatch.fromJson(Map<String, dynamic> json) {
    return SearchMatch(
      articleId: json['articleId'],
      articleNumber: json['articleNumber'],
      articleTitle: json['articleTitle'],
      matchedText: json['matchedText'],
      context: json['context'],
      relevanceScore: (json['relevanceScore'] ?? 0.0).toDouble(),
      highlightedKeywords: List<String>.from(json['highlightedKeywords'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'articleId': articleId,
    'articleNumber': articleNumber,
    'articleTitle': articleTitle,
    'matchedText': matchedText,
    'context': context,
    'relevanceScore': relevanceScore,
    'highlightedKeywords': highlightedKeywords,
  };
} 