import 'package:flutter/material.dart';

class AttendeeDashboard extends StatelessWidget {
  const AttendeeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendee Dashboard')),
      body: const Center(child: Text('Welcome Attendee!')),
    );
  }
}
