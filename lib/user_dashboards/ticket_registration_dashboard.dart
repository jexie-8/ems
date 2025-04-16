import 'package:flutter/material.dart';

class TicketRegistrationDashboard extends StatelessWidget {
  const TicketRegistrationDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TicketRegistration Dashboard')),
      body: const Center(child: Text('Welcome TicketRegistration!')),
    );
  }
}
