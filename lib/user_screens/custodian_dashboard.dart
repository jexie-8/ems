import 'package:flutter/material.dart';

class CustodianDashboard extends StatelessWidget {
  const CustodianDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custodian Dashboard')),
      body: const Center(child: Text('Welcome Custodian!')),
    );
  }
}
