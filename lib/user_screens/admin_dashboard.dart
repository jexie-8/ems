import 'package:flutter/material.dart';
import '../event_creation_webpage.dart'; 
import '../view_event_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logo Name'),
        backgroundColor: Colors.purpleAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // The Create Event button
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