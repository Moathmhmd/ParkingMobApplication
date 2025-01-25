import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> login() async {
  setState(() {
    isLoading = true;
  });

  try {
    // Authenticate the user
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    final userId = userCredential.user!.uid;

    // Check if the user exists in the `admins` collection
    final adminDoc = await FirebaseFirestore.instance.collection('admins').doc(userId).get();
    if (adminDoc.exists) {
      // Navigate to admin dashboard
      Navigator.pushNamedAndRemoveUntil(context, '/adminDashboard', (route) => false);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login Successful! Redirecting to Admin Dashboard.'),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }

    // Check if the user exists in the `users` collection
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      // Navigate to user main dashboard
      Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login Successful! '),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }

    // If user is not found in either collection
    _showError("Account not found. Please contact support.");
  } on FirebaseAuthException catch (e) {
    // Handle specific FirebaseAuth exceptions
    String errorMessage = 'An error occurred. Please try again.';
    if (e.code == 'user-not-found') {
      errorMessage = 'No account found for this email.';
    } else if (e.code == 'wrong-password') {
      errorMessage = 'Incorrect password.';
    }
    _showError(errorMessage);
  } catch (e) {
    // Handle general errors
    _showError('Failed to login. Please try again later.');
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
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
                          color: Colors.lightBlue,
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        backgroundColor: Colors.lightBlue,
                      ),
                      child: const Text('Login',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),),
                    
                    ),
                    
                    
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
