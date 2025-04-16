import 'package:flutter/material.dart';

class VendorManagerDashboard extends StatelessWidget {
  const VendorManagerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VendorManager Dashboard')),
      body: const Center(child: Text('Welcome VendorManager!')),
    );
  }
}
