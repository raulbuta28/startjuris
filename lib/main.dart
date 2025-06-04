import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main_container.dart';
import 'pages/backend/auth/login_page.dart';
import 'pages/modern_code_reader.dart';
import 'pages/backend/providers/auth_provider.dart';
import 'pages/backend/providers/chat_provider.dart';
import 'pages/backend/providers/level_provider.dart';
import 'providers/obiective_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ObiectiveProvider()),
        ChangeNotifierProvider(
          create: (context) => ChatProvider(context.read<AuthProvider>().token),
        ),
        ChangeNotifierProvider(
          create: (context) => LevelProvider(context.read<AuthProvider>().token),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) => MaterialApp(
          title: 'StartJuris',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            textTheme: GoogleFonts.interTextTheme(),
          ),
          home: auth.isAuthenticated ? const MainContainer() : const LoginPage(),
          routes: {
            '/code_reader': (context) => const ModernCodeReader(
                  codeId: 'default_code_id',
                  codeTitle: 'Cod Juridic',
                ),
            '/login': (context) => const LoginPage(),
          },
        ),
      ),
    );
  }
}