import 'package:flutter/material.dart';

class AttendeeDashboard extends StatelessWidget {
  const AttendeeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendee Dashboard'),
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
              child: const Text('Feedback'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                print("View Events button pressed");
              },
              child: const Text('Upcoming Events '),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                print("View Attendee button pressed");
              },
              child: const Text('Purchased Tickets'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
