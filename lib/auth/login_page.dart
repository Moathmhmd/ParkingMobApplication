import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = false;

  Future<void> login({required bool isAdmin}) async {
    setState(() {
      isLoading = true;
    });

    try {
      // Firebase Authentication Login
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Navigate to respective pages
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                isAdmin ? 'Admin Login Successful!' : 'Login Successful!')),
      );
      Navigator.pushReplacementNamed(
          context, isAdmin ? '/adminDashboard' : '/auth');
    } catch (e) {
      // Handle login errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email or Password is Incorrect')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 100),
                  Text(
                    'Login',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => login(isAdmin: false),
                    child: const Text('Login as User'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => login(isAdmin: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.blueAccent, // Highlight admin button
                    ),
                    child: const Text('Login as Admin'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: const Text('Sign Up as User'),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/adminSignup');
                        },
                        child: const Text('Sign Up as Admin'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
