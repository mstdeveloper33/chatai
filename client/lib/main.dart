import 'package:client/core/di/di_container.dart';
import 'package:client/design/app_theme.dart';
import 'package:client/features/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Uygulama giriş noktası
/// Burada veritabanı başlatılır, dependency injection ayarlanır ve
/// uygulama UI yapısı hazırlanır.
void main() async {
  // Widget'ların kullanılabilir olduğundan emin olmak için
  WidgetsFlutterBinding.ensureInitialized();
  
  // SQLite başlatma - Platforma göre SQLite başlatma işlemi
  if (!kIsWeb) {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Desktop platformları için FFI başlatma
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }
  
  // Dependency Injection container'ını başlat
  final di = DependencyInjection();
  await di.init();
  
  // Uygulamayı başlat
  runApp(
    MultiProvider(
      providers: di.providers,
      child: const MyApp(),
    ),
  );
}

/// Uygulamanın ana widget sınıfı
/// Tema, rota yapılandırması ve genel UI özellikleri burada ayarlanır
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Chat Uygulaması',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: OnboardingScreen(),
    );
  }
}