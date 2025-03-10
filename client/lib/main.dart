import 'package:client/design/app_theme.dart';
import 'package:client/features/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      theme: AppTheme.darkTheme,
      home: OnboardingScreen()
    );
  }
}