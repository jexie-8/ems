import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'event_details_screen.dart';
import 'event_creation_webpage.dart'; // ✅ Make sure this import is correct

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
      appBar: AppBar(
        title: const Text("View Events"),
        actions: [
          Row(
            children: [
              const Text("Only mine"),
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
      body: StreamBuilder(
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
                child: ListTile(
                  title: Text(event["Title"] ?? "No Title"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event["Description"] ?? "No Description"),
                      Text("Created by: ${event["createdBy"] ?? "Unknown"}"),
                      Text("Created on: ${_formatTimestamp(event["createdAt"])}"),
                    ],
                  ),
                  trailing: Text("Capacity: ${event["Max_capacity"] ?? 0}"),
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
