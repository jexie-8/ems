import 'package:flutter/material.dart';
import '../ticket_management.dart';

class TicketRegistrationDashboard extends StatelessWidget {
  const TicketRegistrationDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tickets & Registration"),
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
