import 'package:flutter/material.dart';

class AccountantDashboard extends StatelessWidget {
  const AccountantDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accountant Dashboard')),
      body: const Center(child: Text('Welcome Accoutant!')),
    );
  }
}
