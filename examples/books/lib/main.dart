import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'screens/book_list_screen.dart';
import 'services/logger_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    AppLogger.instance.logException(
      details.exception,
      details.stack,
      'Flutter Framework Error (${details.library ?? "unknown"})',
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.instance.logException(error, stack, 'Uncaught Async Error');
    return true;
  };

  runApp(const BookApp());
}

class BookApp extends StatelessWidget {
  const BookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookNook',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
          surface: const Color(0xFF0F172A),
          surfaceContainerHigh: const Color(0xFF1E293B),
          surfaceContainerHighest: const Color(0xFF334155),
        ),
        scaffoldBackgroundColor: const Color(0xFF090D16),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF090D16),
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          brightness: Brightness.light,
        ),
      ),
      home: const BookListScreen(),
    );
  }
}
