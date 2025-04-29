import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'event_details_screen.dart';
import 'event_creation_webpage.dart';

class ViewEventsScreen extends StatefulWidget {
  const ViewEventsScreen({super.key});

  @override
  State<ViewEventsScreen> createState() => _ViewEventsScreenState();
}

class _ViewEventsScreenState extends State<ViewEventsScreen> {
  bool _showOnlyMine = false;

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      backgroundColor: const Color(0xFFE6E0F8),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 32, 19, 77),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.purpleAccent, Colors.white],
          ).createShader(bounds),
          child: const Text(
            'N.O.H.A',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ),
        actions: [
          Row(
            children: [
              const Text("Only mine", style: TextStyle(color: Colors.white),),
              Checkbox(
                value: _showOnlyMine,
                onChanged: (val) {
                  setState(() {
                    _showOnlyMine = val ?? false;
                  });
                },
              ),
            ],
          )
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
            padding: const EdgeInsets.all(20.0),
            child: StreamBuilder(
              stream: _showOnlyMine
                  ? FirebaseFirestore.instance
                      .collection('events')
                      .where("createdBy", isEqualTo: userEmail)
                      .snapshots()
                  : FirebaseFirestore.instance.collection('events').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No events found."));
                }

                var events = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    var eventDoc = events[index];
                    var event = eventDoc.data();
                    return Card(
                      margin: const EdgeInsets.all(10),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15),
                        title: Text(
                          event["Title"] ?? "No Title",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(event["Description"] ?? "No Description", style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 5),
                            Text(
                              "Created by: ${event["createdBy"] ?? "Unknown"}",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              "Created on: ${_formatTimestamp(event["createdAt"])}",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        trailing: Text(
                          "Capacity: ${event["Max_capacity"] ?? 0}",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventDetailsScreen(
                                event: event,
                                docID: eventDoc.id,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateEventScreen()),
          );
        },
        label: const Text("Create Event"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.purple,
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      return "${_getMonthName(dateTime.month)} ${dateTime.day}, ${dateTime.year} at ${_formatTime(dateTime)}";
    }
    return "Unknown date";
  }

  String _formatTime(DateTime dateTime) {
    int hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    String minute = dateTime.minute.toString().padLeft(2, '0');
    String period = dateTime.hour >= 12 ? "PM" : "AM";
    return "$hour:$minute $period";
  }

  String _getMonthName(int month) {
    const List<String> months = [
      "", "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return months[month];
  }
}