import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parking_proj/main_page.dart';
import 'package:parking_proj/admin/admin_page.dart';
import 'package:parking_proj/onboarding_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  Future<String?> _getUserRole(String userId) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      return 'user';
    }

    final adminDoc = await FirebaseFirestore.instance.collection('admins').doc(userId).get();
    if (adminDoc.exists) {
      return 'admin';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            final user = snapshot.data!;
            return FutureBuilder<String?>(
              future: _getUserRole(user.uid),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (roleSnapshot.data == 'user') {
                  // Navigate to MainPage and clear back stack
                  Future.microtask(() {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const MainPage()),
                      (route) => false,
                    );
                  });
                  return const SizedBox();
                } else if (roleSnapshot.data == 'admin') {
                  // Navigate to AdminPage and clear back stack
                  Future.microtask(() {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminPage()),
                      (route) => false,
                    );
                  });
                  return const SizedBox();
                } else {
                  // No valid role found, log out
                  FirebaseAuth.instance.signOut();
                  return const OnboardingScreen();
                }
              },
            );
          } else {
            // If no user is logged in, show onboarding
            return const OnboardingScreen();
          }
        },
      ),
    );
  }
}
