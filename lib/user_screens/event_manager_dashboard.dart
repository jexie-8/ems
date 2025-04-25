import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../login_page.dart';
import 'vendor_management_page.dart';
import 'package:ems/event_functionality/view_event_screen.dart';
import 'package:ems/user_management/user_editor.dart';

class EventManagerDashboard extends StatefulWidget {
  const EventManagerDashboard({super.key});

  @override
  State<EventManagerDashboard> createState() => _EventManagerDashboardState();
}

class _EventManagerDashboardState extends State<EventManagerDashboard> {
  String greetingName = 'Event Manager';

  @override
  void initState() {
    super.initState();
    _loadEventManagerName();
  }

  Future<void> _loadEventManagerName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc('employees')
          .collection('event_manager')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        final first = data['firstName']?.trim() ?? '';

setState(() {
  greetingName = first.isNotEmpty ? first : 'Event Manager';
});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6E0F8),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 32, 19, 77),
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.purpleAccent, Colors.white],
          ).createShader(bounds),
          child: const Text(
            'N.O.H.A',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: -80,
            left: -60,
            child: AnimatedContainer(
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.purpleAccent.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    '🎉 Welcome Back, $greetingName!',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 32, 19, 77),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: Center(
                    child: Wrap(
                      spacing: 25,
                      runSpacing: 25,
                      alignment: WrapAlignment.center,
                      children: [
                        buildDashboardBox(context, 'Events', Icons.event),
                        buildDashboardBox(context, 'Users', Icons.people),
                        buildDashboardBox(context, 'Vendors', Icons.store),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDashboardBox(BuildContext context, String label, IconData icon) {
    return GestureDetector(
      onTap: () {
        if (label == 'Events') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ViewEventsScreen()),
          );
        } else if (label == 'Users') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserViewScreen()),
          );
        } else if (label == 'Vendors') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const VendorManagementPage()),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 260,
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color.fromARGB(255, 32, 19, 77), Color(0xFF5C4D9B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurpleAccent.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: InkWell(
          splashColor: Colors.white24,
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            if (label == 'Events') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ViewEventsScreen()),
              );
            } else if (label == 'Users') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserViewScreen()),
              );
            } else if (label == 'Vendors') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VendorManagementPage()),
              );
            }
          },
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 30),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
