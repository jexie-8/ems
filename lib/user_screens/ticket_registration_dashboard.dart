import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../ticket_functionality/ticket_management.dart';
import '../login_page.dart';

class TicketRegistrationDashboard extends StatelessWidget {
  const TicketRegistrationDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tickets & Registration"),
         actions: [ // ✅ Added sign out button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut(); // ✅ Sign out logic
              Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Welcome, Ticket & Registration Staff!",
                style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                 context,
                 MaterialPageRoute(builder: (_) => const TicketManagementPage()),
               );
            },
              child: const Text("Manage Tickets"),
            ),
          ],
        ),
      ),
    );
  }
}
