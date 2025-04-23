import 'package:flutter/material.dart';
import 'exports.dart';
import '../login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
class VendorManagerDashboard extends StatelessWidget {
  const VendorManagerDashboard({super.key});

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logo Name'),
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
           
            dashboardButton(context, 'View Vendors'),
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
          if (text == 'View Vendors') {
         
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const VendorManagementPage()),
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