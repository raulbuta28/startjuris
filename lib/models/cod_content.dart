import 'package:flutter/material.dart';

class CodContent {
  final String id;
  final String title;
  final List<CodChapter> chapters;
  final String lastUpdate;
  final Map<String, dynamic> metadata;

  CodContent({
    required this.id,
    required this.title,
    required this.chapters,
    required this.lastUpdate,
    required this.metadata,
  });
}

class CodChapter {
  final String id;
  final String title;
  final List<CodArticle> articles;
  final int chapterNumber;
  final String description;

  CodChapter({
    required this.id,
    required this.title,
    required this.articles,
    required this.chapterNumber,
    required this.description,
  });
}

class CodArticle {
  final String id;
  final int number;
  final String content;
  final List<String> references;
  final List<String> jurisprudence;
  final List<String> doctrine;

  CodArticle({
    required this.id,
    required this.number,
    required this.content,
    this.references = const [],
    this.jurisprudence = const [],
    this.doctrine = const [],
  });
}

class UserHighlight {
  final String id;
  final String articleId;
  final String text;
  final Color color;
  final DateTime createdAt;
  final String? note;

  UserHighlight({
    required this.id,
    required this.articleId,
    required this.text,
    required this.color,
    required this.createdAt,
    this.note,
  });
}

class UserNote {
  final String id;
  final String articleId;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> tags;

  UserNote({
    required this.id,
    required this.articleId,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.tags = const [],
  });
}

class UserBookmark {
  final String id;
  final String articleId;
  final String title;
  final DateTime createdAt;
  final Color color;

  UserBookmark({
    required this.id,
    required this.articleId,
    required this.title,
    required this.createdAt,
    required this.color,
  });
}

class SearchResult {
  final String articleId;
  final String chapterId;
  final String matchText;
  final int articleNumber;
  final String chapterTitle;
  final double relevance;

  SearchResult({
    required this.articleId,
    required this.chapterId,
    required this.matchText,
    required this.articleNumber,
    required this.chapterTitle,
    required this.relevance,
  });
} 