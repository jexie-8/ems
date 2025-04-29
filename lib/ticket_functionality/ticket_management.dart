import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'view_tickets_page.dart';
import 'create_tickets_page.dart';

class TicketManagementPage extends StatefulWidget {
  const TicketManagementPage({super.key});

  @override
  State<TicketManagementPage> createState() => _TicketManagementPageState();
}

class _TicketManagementPageState extends State<TicketManagementPage> {
  late Future<List<QueryDocumentSnapshot>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = _fetchAllEvents();
  }
  Future<List<QueryDocumentSnapshot>> _fetchAllEvents() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('events').get();
    return snapshot.docs;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ticket Management",style: TextStyle(color: Colors.white),), ),
      body: Container(
        color: Color(0xFFF3E8FF), // Light pale lavender
        child: Stack(
          children: [
            Positioned(
              top: -60,
              left: -60,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.purple.shade100.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              right: -60,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.purple.shade100.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            FutureBuilder<List<QueryDocumentSnapshot>>(
              future: _eventsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No events found."));
                }
                final events = snapshot.data!;
                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index].data() as Map<String, dynamic>;
                    final docID = events[index].id;
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      elevation: 4, // Add shadow for better separation
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          15,
                        ), // Rounded corners for cards
                      ),
                      child: ListTile(
                        title: Text(event['Title'] ?? 'Untitled Event'),
                        subtitle: Text(
                          'Status: ${event['Status'] ?? 'Unknown'}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => ViewTicketsPage(eventId: docID),
                                  ),
                                );
                              },
                              child: const Text("View Tickets"),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder:(_) => CreateTicketsPage(eventId: docID),),
                                );
                              },
                              child: const Text("Create Tickets"),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}