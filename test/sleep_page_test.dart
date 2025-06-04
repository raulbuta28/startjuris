import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/pages/acasa/utile/sleep_page.dart';
import '../lib/pages/acasa/utile/models/sleep_settings.dart';
import '../lib/pages/acasa/utile/models/sleep_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SleepPage Tests', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    testWidgets('SleepPage shows loading indicator initially', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SleepPage(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('SleepPage shows sleep score card when data is available', (tester) async {
      final now = DateTime.now();
      final settings = SleepSettings(
        bedtime: const TimeOfDay(hour: 22, minute: 0),
        wakeTime: const TimeOfDay(hour: 6, minute: 30),
      );
      final sleepData = SleepData(
        bedtime: now.subtract(const Duration(hours: 8)),
        wakeTime: now,
        sleepQuality: 4,
      );

      await prefs.setString('sleep_settings', settings.toJson().toString());
      await prefs.setString('sleep_history', {
        now.toIso8601String().split('T')[0]: sleepData.toJson(),
      }.toString());

      await tester.pumpWidget(
        const MaterialApp(
          home: SleepPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Scor Somn'), findsOneWidget);
      expect(find.text('8h 0m'), findsOneWidget);
      expect(find.text('4/5'), findsOneWidget);
    });

    testWidgets('SleepPage shows sleep sounds card', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SleepPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sunete Relaxante'), findsOneWidget);
      expect(find.text('Ploaie liniștită'), findsOneWidget);
      expect(find.text('Valuri oceanice'), findsOneWidget);
    });

    testWidgets('SleepPage shows settings dialog', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SleepPage(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.text('Setări Somn'), findsOneWidget);
      expect(find.text('Ora de Culcare'), findsOneWidget);
      expect(find.text('Ora de Trezire'), findsOneWidget);
    });

    testWidgets('SleepPage shows add sleep dialog', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SleepPage(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Înregistrează Somn'));
      await tester.pumpAndSettle();

      expect(find.text('Înregistrează Somn'), findsOneWidget);
      expect(find.text('Calitatea Somnului'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsNWidgets(5));
    });
  });
} 