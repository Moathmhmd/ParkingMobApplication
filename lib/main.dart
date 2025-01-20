import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:parking_proj/auth/auth_page.dart';
import 'package:parking_proj/auth/login_page.dart';
import 'package:parking_proj/user_info_page.dart';
import 'auth/signup_page.dart';
import 'main_page.dart';
import 'onboarding_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parking App',
      theme: ThemeData(
        primaryColor: Colors.lightBlueAccent,
        scaffoldBackgroundColor: Colors.lightBlue[50],
        fontFamily: 'Roboto',
      ),
      initialRoute: '/auth',
      routes: {
        '/': (context) => const OnboardingScreen(),
        '/signup': (context) => const SignupPage(),
        '/main': (context) => const MainPage(),
        '/login': (context) => const LoginPage(),
        '/auth': (context) => const AuthPage(),
        '/user_info': (context) => const UserInfoPage(),
      },
      //yanal
    );
  }
}
