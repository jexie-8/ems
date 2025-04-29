import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
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
  return Scaffold(
    body: Stack(
      children: [
        // Background image
        SizedBox.expand(
          child: Image.asset(
            'assets/backgrounds/login_bg.jpg',
            fit: MediaQuery.of(context).size.aspectRatio > 1
                ? BoxFit.fitHeight
                : BoxFit.cover,
          ),
        ),

        // Blur overlay
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              color: Colors.black.withOpacity(0.0),
            ),
          ),
        ),

        // Dark layer for contrast
        Container(
          color: Colors.black.withOpacity(0.6),
        ),

        // Frosted signup form
        Center(
          child: SingleChildScrollView(
            child: Align(
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 25,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Create Account",
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Sign up to get started",
                              style: GoogleFonts.poppins(fontSize: 16, color: Colors.white60),
                            ),
                            const SizedBox(height: 24),

                            // Input fields
                            _buildTextField(_firstNameController, "First Name"),
                            const SizedBox(height: 12),
                            _buildTextField(_lastNameController, "Last Name"),
                            const SizedBox(height: 12),
                            _buildTextField(_emailController, "Email"),
                            const SizedBox(height: 12),
                            _buildTextField(_numberController, "Phone Number"),
                            const SizedBox(height: 12),
                            _buildTextField(_passwordController, "Password", obscure: true, onChanged: _checkPasswordStrength),
                            const SizedBox(height: 6),
                            LinearProgressIndicator(
                              value: _passwordStrength,
                              color: _getStrengthColor(),
                              backgroundColor: Colors.grey[300],
                              minHeight: 5,
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(_confirmPasswordController, "Confirm Password", obscure: true),

                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _signUp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 32, 19, 77),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text("Sign Up", style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                );
                              },
                              child: const Text("Already have an account? Log In", style: TextStyle(color: Colors.white70)),
                            ),
                            const SizedBox(height: 12),
                            if (_errorMessage.isNotEmpty)
                              Text(_errorMessage, style: const TextStyle(color: Colors.redAccent), textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

// Helper for consistent input field styling
Widget _buildTextField(TextEditingController controller, String label, {bool obscure = false, void Function(String)? onChanged}) {
  return TextField(
    controller: controller,
    obscureText: obscure,
    onChanged: onChanged,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(Icons.input, color: Colors.white),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.deepPurpleAccent),
      ),
    ),
  );
}

}