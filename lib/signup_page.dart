import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';

class SignupScreen extends StatefulWidget {
  
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _numberController = TextEditingController(); 

  String _errorMessage = '';
  double _passwordStrength = 0;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _checkPasswordStrength(String password) {
    double strength = 0;
    if (password.length >= 6) strength += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.25;

    setState(() {
      _passwordStrength = strength;
    });
  }

  String _generateRandomId(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random();
    return List.generate(length, (index) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final fName = _firstNameController.text.trim();
    final lName = _lastNameController.text.trim();
    final number = _numberController.text.trim();

    if (password != confirmPassword) {
      setState(() => _errorMessage = "Passwords do not match.");
      return;
    }
    if (fName.isEmpty || lName.isEmpty || number.isEmpty) {
      setState(() => _errorMessage = "Please fill in all fields.");
      return;
    }

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final user = userCredential.user;

      if (user != null) {
        final docId = "$lName, $fName ${_generateRandomId(5)}";

        await _firestore
            .collection("users")
            .doc("Attendee")
            .collection("attendees")
            .doc(docId)
            .set({
          "email": user.email,
          "firstName": fName,
          "lastName": lName,
          "number": number, 
          "role": "Attendee",
          "createdAt": FieldValue.serverTimestamp(),
        });

        setState(() => _errorMessage = "Account created!");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LoginScreen(),
          ),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = "Error: ${e.toString()}");
    }
  }

  Color _getStrengthColor() {
    if (_passwordStrength < 0.25) return Colors.red;
    if (_passwordStrength < 0.5) return Colors.orange;
    if (_passwordStrength < 0.75) return Colors.yellow;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
        backgroundColor: isDark ? Colors.black : null,
        
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            children: [
              TextField(controller: _firstNameController, decoration: const InputDecoration(labelText: "First Name")),
              const SizedBox(height: 12),
              TextField(controller: _lastNameController, decoration: const InputDecoration(labelText: "Last Name")),
              const SizedBox(height: 12),
              TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email")),
              const SizedBox(height: 12),
              TextField(controller: _numberController, decoration: const InputDecoration(labelText: "Phone Number")),  
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                onChanged: _checkPasswordStrength,
                decoration: const InputDecoration(labelText: "Password"),
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: _passwordStrength,
                color: _getStrengthColor(),
                backgroundColor: Colors.grey[300],
                minHeight: 5,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Confirm Password"),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _signUp,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                child: const Text("Sign Up"),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LoginScreen(),
                    ),
                  );
                },
                child: const Text("Already have an account? Log In"),
              ),
              const SizedBox(height: 12),
              if (_errorMessage.isNotEmpty)
                Text(_errorMessage, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}