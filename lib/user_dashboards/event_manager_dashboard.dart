import 'package:flutter/material.dart';

class EventManagerDashboard extends StatelessWidget {
  const EventManagerDashboard({super.key});

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
            dashboardButton('Create Event'),
            dashboardButton('View Events'),
            dashboardButton('View Attendee'),
            dashboardButton('Manage Tickets'),
            dashboardButton('Send notifications'),
          ],
        ),
      ),
    );
  }

  Widget dashboardButton(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        onPressed: () {}, // Add navigation here later
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
