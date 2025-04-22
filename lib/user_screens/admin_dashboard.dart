import 'package:ems/user_management/user_editor.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';  
import '../event_functionality/view_event_screen.dart';
import '../login_page.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('A.J.'),
        backgroundColor: Colors.purpleAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            dashboardButton(context, 'Events'),
            dashboardButton(context, 'Users'),           
          ],
        ),
      ),
    );
  }

  Widget dashboardButton(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        onPressed: () {
          
          if (text == 'Events') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ViewEventsScreen()),
            );
          }
          if (text == 'Users') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserViewScreen()),
            );
          }
        },
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
        child: Text(text),
      ),
    );
  }
}
