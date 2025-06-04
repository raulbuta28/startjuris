import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/cod_content.dart';

class StorageService {
  static const String _dbName = 'startjuris.db';
  static Database? _database;
  
  // Database initialization
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }
  
  static Future<Database> _initDB() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _dbName);
      
      return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await _createTables(db);
        },
      );
    } catch (e) {
      debugPrint('Error initializing database: $e');
      rethrow;
    }
  }

  static Future<void> _createTables(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS highlights (
          id TEXT PRIMARY KEY,
          articleId TEXT NOT NULL,
          text TEXT NOT NULL,
          color INTEGER NOT NULL,
          createdAt INTEGER NOT NULL,
          note TEXT
        )
      ''');
      
      await db.execute('''
        CREATE TABLE IF NOT EXISTS notes (
          id TEXT PRIMARY KEY,
          articleId TEXT NOT NULL,
          content TEXT NOT NULL,
          createdAt INTEGER NOT NULL,
          updatedAt INTEGER,
          tags TEXT
        )
      ''');
      
      await db.execute('''
        CREATE TABLE IF NOT EXISTS bookmarks (
          id TEXT PRIMARY KEY,
          articleId TEXT NOT NULL,
          title TEXT NOT NULL,
          createdAt INTEGER NOT NULL,
          color INTEGER NOT NULL
        )
      ''');
      
      await db.execute('''
        CREATE TABLE IF NOT EXISTS reading_progress (
          articleId TEXT PRIMARY KEY,
          lastRead INTEGER NOT NULL,
          progress REAL NOT NULL
        )
      ''');
    } catch (e) {
      debugPrint('Error creating tables: $e');
      rethrow;
    }
  }
  
  // Highlights
  static Future<List<UserHighlight>> getHighlights() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('highlights');
    
    return List.generate(maps.length, (i) {
      return UserHighlight(
        id: maps[i]['id'],
        articleId: maps[i]['articleId'],
        text: maps[i]['text'],
        color: Color(maps[i]['color']),
        createdAt: DateTime.fromMillisecondsSinceEpoch(maps[i]['createdAt']),
        note: maps[i]['note'],
      );
    });
  }
  
  static Future<void> saveHighlight(UserHighlight highlight) async {
    final db = await database;
    await db.insert(
      'highlights',
      {
        'id': highlight.id,
        'articleId': highlight.articleId,
        'text': highlight.text,
        'color': highlight.color.value,
        'createdAt': highlight.createdAt.millisecondsSinceEpoch,
        'note': highlight.note,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  static Future<void> deleteHighlight(String id) async {
    final db = await database;
    await db.delete(
      'highlights',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Notes
  static Future<List<UserNote>> getNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('notes');
    
    return List.generate(maps.length, (i) {
      return UserNote(
        id: maps[i]['id'],
        articleId: maps[i]['articleId'],
        content: maps[i]['content'],
        createdAt: DateTime.fromMillisecondsSinceEpoch(maps[i]['createdAt']),
        updatedAt: maps[i]['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(maps[i]['updatedAt'])
          : null,
        tags: (jsonDecode(maps[i]['tags']) as List).cast<String>(),
      );
    });
  }
  
  static Future<void> saveNote(UserNote note) async {
    final db = await database;
    await db.insert(
      'notes',
      {
        'id': note.id,
        'articleId': note.articleId,
        'content': note.content,
        'createdAt': note.createdAt.millisecondsSinceEpoch,
        'updatedAt': note.updatedAt?.millisecondsSinceEpoch,
        'tags': jsonEncode(note.tags),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  static Future<void> deleteNote(String id) async {
    final db = await database;
    await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Bookmarks
  static Future<List<UserBookmark>> getBookmarks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('bookmarks');
    
    return List.generate(maps.length, (i) {
      return UserBookmark(
        id: maps[i]['id'],
        articleId: maps[i]['articleId'],
        title: maps[i]['title'],
        createdAt: DateTime.fromMillisecondsSinceEpoch(maps[i]['createdAt']),
        color: Color(maps[i]['color']),
      );
    });
  }
  
  static Future<void> saveBookmark(UserBookmark bookmark) async {
    final db = await database;
    await db.insert(
      'bookmarks',
      {
        'id': bookmark.id,
        'articleId': bookmark.articleId,
        'title': bookmark.title,
        'createdAt': bookmark.createdAt.millisecondsSinceEpoch,
        'color': bookmark.color.value,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  static Future<void> deleteBookmark(String id) async {
    final db = await database;
    await db.delete(
      'bookmarks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Reading Progress
  static Future<Map<String, double>> getReadingProgress() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('reading_progress');
    
    final progress = <String, double>{};
    for (final map in maps) {
      progress[map['articleId']] = map['progress'];
    }
    return progress;
  }
  
  static Future<void> saveReadingProgress(String articleId, double progress) async {
    final db = await database;
    await db.insert(
      'reading_progress',
      {
        'articleId': articleId,
        'lastRead': DateTime.now().millisecondsSinceEpoch,
        'progress': progress,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  // Preferences
  static Future<void> savePreferences({
    required double fontSize,
    required String fontFamily,
    required bool isDarkMode,
    required double lineHeight,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', fontSize);
    await prefs.setString('fontFamily', fontFamily);
    await prefs.setBool('isDarkMode', isDarkMode);
    await prefs.setDouble('lineHeight', lineHeight);
  }
  
  static Future<Map<String, dynamic>> getPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'fontSize': prefs.getDouble('fontSize') ?? 16.0,
      'fontFamily': prefs.getString('fontFamily') ?? 'Poppins',
      'isDarkMode': prefs.getBool('isDarkMode') ?? true,
      'lineHeight': prefs.getDouble('lineHeight') ?? 1.6,
    };
  }
} 