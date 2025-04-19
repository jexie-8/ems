import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// You need to create these pages
import 'view_tickets_page.dart';
import 'ticket_functionality/create_tickets_page.dart';

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
    final snapshot = await FirebaseFirestore.instance.collection('events').get();
    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ticket Management")),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
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
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(event['Title'] ?? 'Untitled Event'),
                  subtitle: Text('Status: ${event['Status'] ?? 'Unknown'}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ViewTicketsPage(eventId: docID),
                            ),
                          );
                        },
                        child: const Text("View Tickets"),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CreateTicketsPage(eventId: docID),
                            ),
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
    );
  }
}
