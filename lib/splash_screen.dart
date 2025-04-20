import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_page.dart';
import '/user_screens/exports.dart'; // Make sure all dashboards are exported here

class SessionHandler extends StatelessWidget {
  
  const SessionHandler({super.key});

  static const Map<String, List<String>> rolePaths = {
    'Admin': ['admins', 'admin_users'],
    'Attendee': ['Attendee', 'attendees'],
    'Client': ['Client', 'clients'],
    'Event_Manager': ['employees', 'event_manager'],
    'Accountant': ['employees', 'Accountant'],
    'Custodian': ['employees', 'Custodian'],
    'Security_Safety': ['employees', 'Security_Safety'],
    'Technical_Logistics': ['employees', 'Technical_Logistics'],
    'Tickets_Registration': ['employees', 'ticketeers'],
    'Vendor_Manager': ['employees', 'Vendor_Manager'],
  };

  Future<Widget> _handleSession() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return LoginScreen();
    }

    final email = user.email;

    for (final entry in rolePaths.entries) {
      final path = entry.value;
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(path[0])
          .collection(path[1])
          .where("email", isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        switch (entry.key) {
          case "Admin":
            return const AdminDashboard();
          case "Attendee":
            return const AttendeeDashboardPage(); // ✅ Replace with your real screen
          case "Client":
            return const ClientDashboard();
          case "Event_Manager":
            return const EventManagerDashboard();
          case "Accountant":
            return const AccountantDashboard(); // ✅ Make sure these exist
          case "Custodian":
            return const CustodianDashboard();
          case "Security_Safety":
            return const SecuritySafetyDashboard();
          case "Technical_Logistics":
            return const TechnicianDashboard();
          case "Tickets_Registration":
            return const TicketRegistrationDashboard();
          case "Vendor_Manager":
            return const VendorManagerDashboard();
        }
      }
    }

    return LoginScreen(); // fallback if no role is found
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _handleSession(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return snapshot.data!;
        } else {
          return LoginScreen();
        }
      },
    );
  }
}
