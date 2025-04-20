import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';  // Import for Firebase Auth
import 'purchased_tickets.dart';  // Import Purchased Tickets page
import 'upcoming_events.dart';  // Import Upcoming Events page
import '../login_page.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendee Dashboard'),
        backgroundColor: Colors.deepPurple,
        actions: [ // ✅ Added sign out button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut(); // ✅ Sign out logic
              Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) =>  LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DashboardButton(
              icon: Icons.event,
              label: 'Upcoming Events',
              onPressed: () {
                navigate(context, UpcomingEventsPage());
              },
            ),
            const SizedBox(height: 20),
            DashboardButton(
              icon: Icons.feedback,
              label: 'Feedback',
              onPressed: () {
                navigate(context, const PlaceholderPage(title: 'Feedback'));
              },
            ),
            const SizedBox(height: 20),
            DashboardButton(
              icon: Icons.confirmation_number,
              label: 'Purchased Tickets',
              onPressed: () {
                // Get the user ID from Firebase Auth
                String userId = FirebaseAuth.instance.currentUser?.uid ?? ''; 
                
                // Navigate to the PurchasedTicketsPage with the userId
                navigate(context, PurchasedTicketsPage(userId: userId));
              },
            ),
          ],
        ),
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
    return ElevatedButton.icon(
      icon: Icon(icon, size: 28),
      label: Text(label, style: const TextStyle(fontSize: 18)),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(60),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      onPressed: onPressed,
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final String title;

  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Text('$title page coming soon!', style: const TextStyle(fontSize: 20)),
      ),
    );
  }
}
