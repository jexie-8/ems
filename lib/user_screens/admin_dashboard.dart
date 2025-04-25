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
      backgroundColor: const Color(0xFFE6E0F8),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 32, 19, 77),
        elevation: 0,
        title: ShaderMask(
          shaderCallback:
              (bounds) => const LinearGradient(
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
          // 💫 Animated or decorative background blob shapes
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

          // 🧑‍💻 Main content with greeting
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 30.0,
            ),
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
                  child: const Text(
                    '👋 Welcome Back, Admin!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 32, 19, 77),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Center the boxes in the middle of the screen without interfering with the greeting text
                Expanded(
                  child: Center(
                    child: Wrap(
                      spacing: 25,
                      runSpacing: 25,
                      alignment: WrapAlignment.center,
                      children: [
                        buildDashboardBox(context, 'Events', Icons.event),
                        buildDashboardBox(context, 'Users', Icons.people),
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
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 260, // Slightly enlarged if desired
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
                MaterialPageRoute(
                  builder: (context) => const ViewEventsScreen(),
                ),
              );
            } else if (label == 'Users') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserViewScreen()),
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