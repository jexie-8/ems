import 'package:flutter/material.dart';
import 'user_dashboards/exports.dart';
import 'login_screen.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
     debugPrint('Caught Flutter framework error.\n${details.exception}');
  };
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard Launcher',
      debugShowCheckedModeBanner: false,
      home: const HomeSelector(),
    );
  }
}

class HomeSelector extends StatelessWidget {
  const HomeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Dashboard'),
        backgroundColor: Colors.purpleAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            routeButton(context, 'Accoutant Dashboard', const AccountantDashboard()),
            routeButton(context, 'Admin Dashboard', const AdminDashboard()),
            routeButton(context, 'Attendee Dashboard', const AttendeeDashboard()),
            routeButton(context, 'Client Dashboard', const ClientDashboard()),
            routeButton(context, 'Custodian Dashboard', const CustodianDashboard()),
            routeButton(context, 'Event Manager Dashboard', const EventManagerDashboard()),
            routeButton(context, 'Security & Safety Dashboard', const SecuritySafetyDashboard()),
            routeButton(context, 'Technician Dashboard', const TechnicianDashboard()),
            routeButton(context, 'Ticket Registration Dashboard', const TicketRegistrationDashboard()),
            routeButton(context, 'Vendor Manager Dashboard', const VendorManagerDashboard()),
            routeButton(context, 'Login Page', const LoginScreen()),
            
          ],
        ),
      ),
    );
  }

  Widget routeButton(BuildContext context, String label, Widget screen) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        ),
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
        child: Text(label),
      ),
    );
  }
}
