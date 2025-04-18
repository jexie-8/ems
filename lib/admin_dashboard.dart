import 'package:flutter/material.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.purpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                print("");
              },
              child: const Text('Create Event'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                print("View Events button pressed");
              },
              child: const Text('View Events'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                print("View Attendee button pressed");
              },
              child: const Text('View/Edit Events'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                print("Manage Tickets button pressed");
              },
              child: const Text("Vendor Managment"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                print("User Role Management");
              },
              child: const Text("User-Role-Managment"),
            ),
          ],
        ),
      ),
    );
  }
}
