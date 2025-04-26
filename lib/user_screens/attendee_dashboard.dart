
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../ticket_functionality/purchased_tickets.dart';
import '../event_functionality/upcoming_events.dart';
import '../login_page.dart';
import 'feedback_page.dart'; 

class AttendeeDashboardPage extends StatelessWidget {
  const AttendeeDashboardPage({super.key});

  void navigate(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        title: const Text('🎶 N.O.H.A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Colors.deepPurple,
        elevation: 10,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // MAX decorative background spiral shapes
          ...List.generate(15, (index) {
            final shapes = [
              {'top': 20.0, 'left': 10.0, 'angle': 0.4},
              {'bottom': 90.0, 'right': 30.0, 'angle': -0.4},
              {'top': 160.0, 'right': -30.0, 'angle': 0.6},
              {'bottom': 220.0, 'left': -20.0, 'angle': -0.3},
              {'top': 320.0, 'left': 200.0, 'angle': 0.7},
              {'bottom': 130.0, 'right': 100.0, 'angle': -0.2},
              {'top': 30.0, 'right': 100.0, 'angle': 0.5},
              {'top': 420.0, 'left': 50.0, 'angle': -0.6},
              {'bottom': 290.0, 'right': 10.0, 'angle': 0.2},
              {'top': 480.0, 'left': 120.0, 'angle': -0.5},
              {'top': 500.0, 'right': 140.0, 'angle': 0.8},
              {'top': 240.0, 'right': 220.0, 'angle': 0.1},
              {'top': 110.0, 'left': 160.0, 'angle': -0.7},
              {'bottom': 40.0, 'left': 80.0, 'angle': 0.6},
              {'top': 350.0, 'right': 70.0, 'angle': -0.4},
            ];
            final pos = shapes[index % shapes.length];
            return Positioned(
              top: pos['top'] as double?,
              left: pos['left'] as double?,
              right: pos['right'] as double?,
              bottom: pos['bottom'] as double?,
              child: Transform.rotate(
                angle: pos['angle'] as double,
                child: Container(
                  width: 90 + (index % 3) * 25.0,
                  height: 90 + (index % 3) * 25.0,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.03 * (index % 4 + 1)),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                child: Text(
                  "🎉 Welcome, ${user?.email?.split('@')[0] ?? 'Attendee'}!",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
                const SizedBox(height: 40),
                Center(
                  child: Wrap(
                    spacing: 25,
                    runSpacing: 25,
                    alignment: WrapAlignment.center,
                    children: [
                      DashboardButton(
                        icon: Icons.music_note,
                        label: 'Events',
                        onPressed: () => navigate(context, UpcomingEventsPage()),
                      ),
                      DashboardButton(
                        icon: Icons.star_rate_outlined,
                        label: 'Feedback',
                        onPressed: () => navigate(context, const FeedbackPage()),
                      ),
                      DashboardButton(
                        icon: Icons.confirmation_number_outlined,
                        label: 'My Tickets',
                        onPressed: () => navigate(context, PurchasedTicketsPage(userId: user?.uid ?? '')),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class DashboardButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const DashboardButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: const LinearGradient(
            colors: [Color(0xFF8E24AA), Color(0xFFBA68C8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.25),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 30, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
 