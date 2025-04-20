import 'package:flutter/material.dart';
import '../event_creation_webpage.dart'; 
import 'user_management.dart';
import 'vendor_management_page.dart';
import 'vendor_form_page.dart';
import '../login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventManagerDashboard extends StatelessWidget {
  const EventManagerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logo Name'),
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
            // The Create Event button
            dashboardButton(context, 'Create Event'),
            dashboardButton(context, 'View Events'),
            dashboardButton(context, 'View Users'),
            dashboardButton(context, 'View Vendors'),
            dashboardButton(context, 'Send notifications'),
          ],
        ),
      ),
    );
  }

  // Updated dashboardButton function that accepts context and navigates on press
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
        } else if (text == 'View Users') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserManagementScreen()),
          );
        } else if (text == 'View Vendors') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const VendorManagementPage()),
          );
        }
        // Add more navigation conditions here for other buttons
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
