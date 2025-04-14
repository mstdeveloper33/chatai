import 'package:client/design/app_colors.dart';
import 'package:client/features/chat/chat_page.dart';
import 'package:flutter/material.dart';

// ignore: camel_case_types
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greenBgColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.chat,
              size: 100,),
            const Text(
              'Welcome to ChatGPT',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            //const CircularProgressIndicator(),
            ElevatedButton(onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(),),);
            }, child: const Text("Get Started"),)
          ],
        ),
      ),
    );
  }
}