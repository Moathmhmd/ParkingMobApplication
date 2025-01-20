import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parking_proj/main_page.dart';
import 'package:parking_proj/onboarding_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            // User is logged in: Navigate to MainPage and clear back stack
            Future.microtask(() {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) =>  MainPage()),
                (route) => false, // Remove all previous routes
              );
            });
            return const SizedBox(); // Placeholder while navigation occurs
          } else {
            // User is not logged in: Navigate to OnboardingScreen
            Future.microtask(() {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                (route) => false, // Remove all previous routes
              );
            });
            return const SizedBox(); // Placeholder while navigation occurs
          }
        },
      ),
    );
  }
}
