import 'package:flutter/material.dart';

class TechnicianDashboard extends StatelessWidget {
  const TechnicianDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Technician Dashboard')),
      body: const Center(child: Text('Welcome Technician!')),
    );
  }
}
