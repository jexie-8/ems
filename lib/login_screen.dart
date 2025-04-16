import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_dashboards/exports.dart';

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
    'Attendee': ['attendee', 'attendee_users'],
    'Client': ['client', 'client_users'],
    'Event_Manager': ['employees', 'event_manager'],
    'Accountant': ['employees', 'accountants'],
    'Custodian': ['employees', 'custodian'],
    'Security_Safety': ['employees', 'inspectors'],
    'Technical_Logistics': ['employees', 'technicians'],
    'Tickets_Registration': ['employees', 'ticketeers'],
    'Vendor_Manager': ['employees', 'vendor_manager'],
  };

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = "Auth Error: ${e.message ?? 'Unknown error'}");
      return;
    } catch (e) {
      setState(() => _errorMessage = "Unexpected authentication error.");
      return;
    }

    String? userRole;

    try {
      for (final entry in rolePaths.entries) {
        final path = entry.value;

        try {
          final snapshot = await _firestore
              .collection("users")
              .doc(path[0])
              .collection(path[1])
              .where("email", isEqualTo: email)
              .limit(1)
              .get();

          if (snapshot.docs.isNotEmpty) {
            userRole = entry.key;
            break;
          }
        } on FirebaseException catch (e) {
          debugPrint("Firestore query failed for ${entry.key}: ${e.message}");
          continue;
        } catch (e) {
          debugPrint("Non-Firebase error during query: $e");
          continue;
        }
      }
    } catch (e) {
      setState(() => _errorMessage = "User role check failed.");
      return;
    }

    if (userRole != null) {
      switch (userRole) {
        case "Admin":
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
          break;
        case "Event_Manager":
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const EventManagerDashboard()));
          break;
        case "Client":
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ClientDashboard()));
          break;
        case "Tickets_Registration":
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TicketRegistrationDashboard()));
          break;
        default:
          setState(() => _errorMessage = "No dashboard defined for role: $userRole");
      }
    } else {
      setState(() => _errorMessage = "User role not found.");
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
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
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
                    // TODO: Add sign-up logic here
                  },
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                  child: const Text("Sign Up"),
                ),
                const SizedBox(height: 16),
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage.toString(), // safe display
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
