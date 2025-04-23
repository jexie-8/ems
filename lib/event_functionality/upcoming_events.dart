import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../ticket_functionality/view_tickets.dart'; 

class UpcomingEventsPage extends StatefulWidget {
  const UpcomingEventsPage({super.key});

  @override
  State<UpcomingEventsPage> createState() => _UpcomingEventsPageState();
}

class _UpcomingEventsPageState extends State<UpcomingEventsPage> {
  List<Map<String, dynamic>> upcomingEvents = [];

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

   Future<void> fetchEvents() async {
  try {
    final now = Timestamp.now();

   
    final snapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('Start_DT', isGreaterThan: now) 
        .get();

    final events = snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data(),
      };

    }).toList();

    setState(() {
      upcomingEvents = events;
    });
  } catch (e) {
    print("Error fetching events: $e");
  }
}


  void openEventDetail(Map<String, dynamic> eventData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketSelectionPage(eventId: eventData['id']),
      ),
    );
  }

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    return DateFormat('yyyy-MM-dd – HH:mm').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upcoming Events"),
        backgroundColor: Colors.deepPurple,
      ),
      body: upcomingEvents.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: upcomingEvents.length,
              itemBuilder: (context, index) {
                final event = upcomingEvents[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.deepPurple.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () => openEventDetail(event),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Title: ${event['Title']}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text("Description: ${event['Description']}"),
                        Text("Start: ${formatTimestamp(event['Start_DT'])}"),
                        Text("End: ${formatTimestamp(event['End_DT'])}"),
                        Text("Age Rating: ${event['Age_Rating']}"),
                        Text("Capacity: ${event['Max_capacity']}"),
                        Text("Status: ${event['Status']}"),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
