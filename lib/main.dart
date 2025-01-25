import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:parking_proj/admin/admin_add_parking_page.dart';
import 'package:parking_proj/admin/admin_edit_parking_page.dart';
import 'package:parking_proj/admin/admin_page.dart';
import 'package:parking_proj/auth/admin_signup.dart';
import 'package:parking_proj/auth/auth_page.dart';
import 'package:parking_proj/auth/login_page.dart';
import 'package:parking_proj/user_info_page.dart';
import 'package:parking_proj/users_reservation_details';
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
        '/booking': (context) => const UserReservationsPage(),
        '/adminDashboard': (context) => const AdminPage(),
        '/adminSignup': (context) => const AdminSignupPage(),
        '/AdminAddParking': (context) => const AdminAddParking(),
        '/AdminEditParking': (context) => const AdminEditParking(),
      },
    );
  }
}
