import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Import FirebaseAuth
import '../event_functionality/event_creation_webpage.dart'; 
import '../event_functionality/view_event_screen.dart';
import '../login_page.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('A.J.'),
        backgroundColor: Colors.purpleAccent,
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
            dashboardButton(context, 'Create Event'),
            dashboardButton(context, 'View Events'),
            dashboardButton(context, 'View Attendee'),
            dashboardButton(context, 'Manage Tickets'),
            dashboardButton(context, 'Send notifications'),
          ],
        ),
      ),
    );
  }

  Widget dashboardButton(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        onPressed: () {
          if (text == 'Create Event') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateEventScreen()),
            );
          }
          if (text == 'View Events') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ViewEventsScreen()),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.deepPurple,
          backgroundColor: Colors.white,
          shadowColor: Colors.grey,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        ),
        child: Text(text),
      ),
    );
  }
}
