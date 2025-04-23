import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_event_screen.dart';
import '../ticket_functionality/view_tickets_page.dart';
import '../view_report.dart';
class EventDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> event;
  final String docID;

  const EventDetailsScreen({super.key, required this.event, required this.docID});

  Future<String?> _getUserRole() async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return null;

    final Map<String, List<String>> rolePaths = {
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

    for (var entry in rolePaths.entries) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(entry.value[0])
          .collection(entry.value[1])
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return entry.key;
      }
    }

    return null;
  }

  Future<void> _deleteEvent(BuildContext context) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection("events")
          .where("Title", isEqualTo: event["Title"])
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Event not found")),
        );
        return;
      }

      final eventDoc = query.docs.first;
      final eventId = eventDoc.id;
      final eventTitle = event["Title"];
      final reportId = "$eventId, $eventTitle";


      Future<void> deleteEventSubcollection(String subcollection) async {
        final subDocs = await FirebaseFirestore.instance
            .collection("events")
            .doc(eventId)
            .collection(subcollection)
            .get();

        for (var doc in subDocs.docs) {
          await doc.reference.delete();
        }
      }


      Future<void> deleteReportSubcollection(String subcollection) async {
        final subDocs = await FirebaseFirestore.instance
            .collection("report")
            .doc(reportId)
            .collection(subcollection)
            .get();

        for (var doc in subDocs.docs) {
          await doc.reference.delete();
        }
      }
      await deleteEventSubcollection("tickets");  
      await deleteReportSubcollection("feedback");
      await deleteReportSubcollection("payments");  
      await eventDoc.reference.delete();    
      await FirebaseFirestore.instance.collection("report").doc(reportId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event and all related data deleted")),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting event: $e")),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext screenContext) {
    showDialog(
      context: screenContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete Event"),
        content: const Text("Are you sure you want to delete this event?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _deleteEvent(screenContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
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
    const months = [
      "", "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return months[month];
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle = Theme.of(context).textTheme.bodyLarge!;

    return Scaffold(
      appBar: AppBar(title: Text(event["Title"] ?? "Event Details")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            Text("Description: ${event["Description"] ?? "No Description"}", style: labelStyle),
            const SizedBox(height: 10),
            Text("Created by: ${event["createdBy"] ?? "Unknown"}", style: labelStyle),
            Text("Created on: ${_formatTimestamp(event["createdAt"])}", style: labelStyle),
            const Divider(height: 30),
            Text("Start Time: ${_formatTimestamp(event["Start_DT"])}", style: labelStyle),
            Text("End Time: ${_formatTimestamp(event["End_DT"])}", style: labelStyle),
            Text("Max Capacity: ${event["Max_capacity"] ?? 0}", style: labelStyle),
            Text("Status: ${event["Status"] ?? "N/A"}", style: labelStyle),
            Text("Budget: ${event["Budget"]} EGP", style: labelStyle),
            Text("Age Rating: ${event["Age_Rating"] ?? "N/A"}", style: labelStyle),
            const SizedBox(height: 30),

            FutureBuilder<String?>(
              future: _getUserRole(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final role = snapshot.data;
                if (role == "Admin" || role == "Event_Manager") {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text("Edit"),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditEventScreen(event: event, docId: docID),
                            ),
                          );
                        },
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.receipt),
                        label: const Text("Tickets"),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ViewTicketsPage(eventId:docID),
                            ),
                          );
                        },
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.request_page_outlined),
                        label: const Text("Report"),
                        onPressed: () {
                          Navigator.push(
                            context,
                              MaterialPageRoute(
                                builder: (_) => ReportPage(eventId:docID),
                            ),
                          );
                        },
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.delete),
                        label: const Text("Delete"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () => _showDeleteConfirmation(context),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
