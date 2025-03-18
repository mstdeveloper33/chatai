import 'package:client/design/app_theme.dart';
import 'package:client/features/chat/providers/chat_provider.dart';
import 'package:client/features/chat/providers/conversation_provider.dart';
import 'package:client/features/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  // SQLite başlatma
  WidgetsFlutterBinding.ensureInitialized();
  
  // Platforma göre SQLite başlatma işlemi
  if (!kIsWeb) {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Desktop platformları için FFI başlatma
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ConversationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: OnboardingScreen(),
    );
  }
}