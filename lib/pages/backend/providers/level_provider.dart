import 'package:flutter/foundation.dart';
import '../models/level_model.dart';
import '../models/performance_model.dart';
import '../services/api_service_login.dart';

class LevelProvider with ChangeNotifier {
  Level? _level;
  Performance? _performance;
  late ApiServiceLogin _apiService;

  Level? get level => _level;
  Performance? get performance => _performance;

  LevelProvider(String? token) {
    _apiService = ApiServiceLogin(token: token);
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadLevel(),
      _loadPerformance(),
    ]);
  }

  Future<void> _loadLevel() async {
    try {
      _level = await _apiService.getLevel();
      notifyListeners();
    } catch (e) {
      print('Error loading level: $e');
    }
  }

  Future<void> _loadPerformance() async {
    try {
      _performance = await _apiService.getPerformance();
      notifyListeners();
    } catch (e) {
      print('Error loading performance: $e');
    }
  }

  Future<void> refresh() async {
    await _loadData();
  }

  void updateToken(String? token) {
    _apiService = ApiServiceLogin(token: token);
    if (token != null) {
      _loadData();
    } else {
      _level = null;
      _performance = null;
      notifyListeners();
    }
  }
}