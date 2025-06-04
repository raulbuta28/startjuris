import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/code_structure.dart';

class CodeParser {
  static const String _baseUrl = String.fromEnvironment('API_URL', 
      defaultValue: 'http://localhost:8080');
  
  static final Map<String, String> _codeTitles = {
    'civil': 'Codul Civil',
    'penal': 'Codul Penal',
    'proc_civil': 'Codul de Procedură Civilă',
    'proc_penal': 'Codul de Procedură Penală',
  };

  /// Parse code structure from backend API (NO ASSETS!)
  static Future<CodeStructure> parseCodeFromAssets(String codeId) async {
    debugPrint('🌐 Loading code structure from backend for: $codeId');
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/codes/$codeId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        debugPrint('✅ Backend response successful for $codeId');
        final data = jsonDecode(response.body);
        
        // Parse the response into our Flutter models
        final structure = _parseBackendResponse(data);
        debugPrint('📊 Successfully parsed structure with ${structure.books.length} books');
        return structure;
      } else {
        debugPrint('❌ Backend error: ${response.statusCode}');
        throw Exception('Backend returned status ${response.statusCode}: ${response.reasonPhrase}');
      }
    } on http.ClientException catch (e) {
      debugPrint('❌ Network error: $e');
      throw Exception('Network connection failed: Please check your internet connection');
    } on FormatException catch (e) {
      debugPrint('❌ JSON parsing error: $e');
      throw Exception('Invalid response format from server');
    } catch (e) {
      debugPrint('❌ Failed to load from backend: $e');
      throw Exception('Failed to connect to backend: ${e.toString()}');
    }
  }

  /// Parse backend JSON response into Flutter models
  static CodeStructure _parseBackendResponse(Map<String, dynamic> data) {
    debugPrint('🔄 Parsing backend response...');
    
    try {
      final books = <Book>[];
      
      if (data['books'] != null) {
        for (final bookData in data['books']) {
          books.add(_parseBook(bookData));
        }
      }
      
      Map<String, dynamic> metadata = {};
      if (data['metadata'] is List) {
        for (String item in data['metadata']) {
          if (item.contains('=')) {
            final parts = item.split('=');
            if (parts.length >= 2) {
              metadata[parts[0]] = parts.sublist(1).join('=');
            }
          }
        }
      } else if (data['metadata'] is Map) {
        metadata = Map<String, dynamic>.from(data['metadata']);
      }
      
      final structure = CodeStructure(
        id: data['id'] ?? '',
        title: data['title'] ?? '',
        type: data['type'] ?? '',
        books: books,
        metadata: metadata,
        lastUpdated: data['lastUpdated'] != null 
            ? DateTime.tryParse(data['lastUpdated']) ?? DateTime.now()
            : DateTime.now(),
      );
      
      debugPrint('✅ Parsed structure: ${structure.id} with ${books.length} books');
      return structure;
    } catch (e) {
      debugPrint('❌ Error parsing backend response: $e');
      throw Exception('Failed to parse server response: ${e.toString()}');
    }
  }

  static Book _parseBook(Map<String, dynamic> bookData) {
    try {
      final titles = <Title>[];
      
      if (bookData['titles'] != null) {
        for (final titleData in bookData['titles']) {
          titles.add(_parseTitle(titleData));
        }
      }
      
      return Book(
        id: bookData['id'] ?? '',
        title: bookData['title'] ?? '',
        subtitle: bookData['subtitle'],
        titles: titles,
        order: bookData['order'] ?? 0,
      );
    } catch (e) {
      debugPrint('❌ Error parsing book: $e');
      return Book(
        id: bookData['id'] ?? '',
        title: bookData['title'] ?? 'Unknown Book',
        subtitle: null,
        titles: [],
        order: 0,
      );
    }
  }

  static Title _parseTitle(Map<String, dynamic> titleData) {
    try {
      final chapters = <Chapter>[];
      
      if (titleData['chapters'] != null) {
        for (final chapterData in titleData['chapters']) {
          chapters.add(_parseChapter(chapterData));
        }
      }
      
      return Title(
        id: titleData['id'] ?? '',
        title: titleData['title'] ?? '',
        subtitle: titleData['subtitle'],
        chapters: chapters,
        order: titleData['order'] ?? 0,
      );
    } catch (e) {
      debugPrint('❌ Error parsing title: $e');
      return Title(
        id: titleData['id'] ?? '',
        title: titleData['title'] ?? 'Unknown Title',
        subtitle: null,
        chapters: [],
        order: 0,
      );
    }
  }

  static Chapter _parseChapter(Map<String, dynamic> chapterData) {
    try {
      final sections = <Section>[];
      
      if (chapterData['sections'] != null) {
        for (final sectionData in chapterData['sections']) {
          sections.add(_parseSection(sectionData));
        }
      }
      
      return Chapter(
        id: chapterData['id'] ?? '',
        title: chapterData['title'] ?? '',
        subtitle: chapterData['subtitle'],
        sections: sections,
        order: chapterData['order'] ?? 0,
      );
    } catch (e) {
      debugPrint('❌ Error parsing chapter: $e');
      return Chapter(
        id: chapterData['id'] ?? '',
        title: chapterData['title'] ?? 'Unknown Chapter',
        subtitle: null,
        sections: [],
        order: 0,
      );
    }
  }

  static Section _parseSection(Map<String, dynamic> sectionData) {
    try {
      final subsections = <Subsection>[];
      final articles = <Article>[];
      
      if (sectionData['subsections'] != null) {
        for (final subsectionData in sectionData['subsections']) {
          subsections.add(_parseSubsection(subsectionData));
        }
      }
      
      if (sectionData['articles'] != null) {
        for (final articleData in sectionData['articles']) {
          articles.add(_parseArticle(articleData));
        }
      }
      
      return Section(
        id: sectionData['id'] ?? '',
        title: sectionData['title'] ?? '',
        subtitle: sectionData['subtitle'],
        subsections: subsections,
        articles: articles,
        order: sectionData['order'] ?? 0,
      );
    } catch (e) {
      debugPrint('❌ Error parsing section: $e');
      return Section(
        id: sectionData['id'] ?? '',
        title: sectionData['title'] ?? 'Unknown Section',
        subtitle: null,
        subsections: [],
        articles: [],
        order: 0,
      );
    }
  }

  static Subsection _parseSubsection(Map<String, dynamic> subsectionData) {
    try {
      final articles = <Article>[];
      
      if (subsectionData['articles'] != null) {
        for (final articleData in subsectionData['articles']) {
          articles.add(_parseArticle(articleData));
        }
      }
      
      return Subsection(
        id: subsectionData['id'] ?? '',
        title: subsectionData['title'] ?? '',
        subtitle: subsectionData['subtitle'],
        articles: articles,
        order: subsectionData['order'] ?? 0,
      );
    } catch (e) {
      debugPrint('❌ Error parsing subsection: $e');
      return Subsection(
        id: subsectionData['id'] ?? '',
        title: subsectionData['title'] ?? 'Unknown Subsection',
        subtitle: null,
        articles: [],
        order: 0,
      );
    }
  }

  static Article _parseArticle(Map<String, dynamic> articleData) {
    try {
      return Article(
        id: articleData['id'] ?? '',
        number: articleData['number'] ?? '',
        title: articleData['title'] ?? '',
        content: articleData['content'] ?? '',
        paragraphs: [],
        notes: List<String>.from(articleData['notes'] ?? []),
        references: List<String>.from(articleData['references'] ?? []),
        isImportant: articleData['isImportant'] ?? false,
        keywords: List<String>.from(articleData['keywords'] ?? []),
      );
    } catch (e) {
      debugPrint('❌ Error parsing article: $e');
      return Article(
        id: articleData['id'] ?? '',
        number: articleData['number'] ?? '',
        title: articleData['title'] ?? 'Unknown Article',
        content: articleData['content'] ?? '',
        paragraphs: [],
        notes: [],
        references: [],
        isImportant: false,
        keywords: [],
      );
    }
  }

  /// Test backend connectivity
  static Future<bool> testBackendConnection() async {
    try {
      debugPrint('🔧 Testing backend connection...');
      final response = await http.get(
        Uri.parse('$_baseUrl/api/codes'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 3));
      
      final isConnected = response.statusCode == 200;
      debugPrint(isConnected ? '✅ Backend is available' : '❌ Backend unavailable');
      return isConnected;
    } catch (e) {
      debugPrint('❌ Backend test failed: $e');
      return false;
    }
  }

  /// Get list of available codes from backend
  static Future<List<Map<String, dynamic>>> getAvailableCodes() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/codes'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['codes'] ?? []);
      } else {
        throw Exception('Failed to fetch available codes: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      debugPrint('❌ Network error getting available codes: $e');
      throw Exception('Network connection failed');
    } on FormatException catch (e) {
      debugPrint('❌ JSON error getting available codes: $e');
      throw Exception('Invalid response format');
    } catch (e) {
      debugPrint('❌ Failed to get available codes: $e');
      throw Exception('Failed to get available codes: ${e.toString()}');
    }
  }
} 