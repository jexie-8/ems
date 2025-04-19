import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'signup_page.dart';
import 'user_screens/exports.dart';


class LoginScreen extends StatefulWidget {


  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _obscurePassword = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Map<String, List<String>> rolePaths = {
    'Admin': ['admins', 'admin_users'],
    'Attendee': ['Attendee', 'attendees'],
    'Client': ['Client', 'clients'],
    'Event_Manager': ['employees', 'event_manager'],
    'Accountant': ['employees', 'Accountant'],
    'Custodian': ['employees', 'Custodian'],
    'Security_Safety': ['employees', 'Security_Safety'],
    'Technical_Logistics': ['employees', 'Technical_Logistics'],
    'Tickets_Registration': ['employees', 'ticketeers'],
    'Vendor_Manager': ['employees', 'Vendor_Manager'],
  };
  Future<void> _signIn() async {
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);

      String? userRole;
for (final entry in rolePaths.entries) {
  final path = entry.value;
  print("Checking role: ${entry.key} at path: users/${path[0]}/${path[1]}");

  final snapshot = await _firestore
      .collection("users")
      .doc(path[0])
      .collection(path[1])
      .where("email", isEqualTo: email)
      .limit(1)
      .get();

  for (var doc in snapshot.docs) {
    print("Found user: ${doc.data()}"); // prints all fields in the user document
    print("User email: ${doc['email']}"); // optionally print just the email
  }

  if (snapshot.docs.isNotEmpty) {
    userRole = entry.key;
    break;
  }
}

      if (userRole != null) {
        switch (userRole) {
          case "Admin":
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdminDashboard()));
            break;
          case "Event_Manager":
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => EventManagerDashboard()));
            break;
          case "Client":
           Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ClientDashboard()));
            break;
          case "Tickets_Registration":
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TicketRegistrationDashboard()));
            break;
          case "Attendee":
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AttendeeDashboardPage()));
            break;
          case "Custodian":
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CustodianDashboard()));
            break;
          case "Vendor_Manager":
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => VendorManagerDashboard()));
            break;
          default:
            setState(() => _errorMessage = "No dashboard defined for role: $userRole");
        }
      } else {
        setState(() => _errorMessage = "User role not found.");
      }
    } catch (e) {
      setState(() => _errorMessage = "Error: ${e.toString()}");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                  onSubmitted: (_) => _signIn(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  onSubmitted: (_) => _signIn(),
                  decoration: InputDecoration(
                    labelText: "Password",
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _signIn,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                  child: const Text("Login"),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => SignupScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                  child: const Text("Sign Up"),
                ),
                const SizedBox(height: 16),
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}