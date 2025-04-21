import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../checkout_functionality/checkoutpage.dart';

class TicketSelectionPage extends StatefulWidget {
  final String eventId;

  const TicketSelectionPage({Key? key, required this.eventId}) : super(key: key);

  @override
  _TicketSelectionPageState createState() => _TicketSelectionPageState();
}

class _TicketSelectionPageState extends State<TicketSelectionPage> {
  Map<String, int> availableTickets = {};
  Map<String, int> selectedTickets = {};
  Map<String, int> prices = {};
  List<String> ticketTypes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchTicketData();
  }

  Future<void> fetchTicketData() async {
    try {
      final eventDoc = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .get();

      final List<dynamic> types = eventDoc.data()?['ticketTypes'] ?? [];
      ticketTypes = types.map((e) => e['type'].toString()).toList();

      for (var type in types) {
        prices[type['type']] = (type['price'] as num).toInt();
        selectedTickets[type['type']] = 0;
        availableTickets[type['type']] = 0;
      }

      final availableSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('tickets')
          .where('ticket_status', isEqualTo: 'available')
          .get();

      for (var doc in availableSnapshot.docs) {
        final data = doc.data();
        final type = data['ticket_type'];
        if (availableTickets.containsKey(type)) {
          availableTickets[type] = availableTickets[type]! + 1;
        }
      }

      setState(() => _loading = false);
    } catch (e) {
      print("Error: $e");
    }
  }

  int calculateTotal() {
    int total = 0;
    selectedTickets.forEach((type, count) {
      total += (prices[type] ?? 0) * count;
    });
    return total;
  }

  Widget buildTicketBox(String type) {
    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(type, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text(prices.containsKey(type) ? '${prices[type]} EGP' : '-- EGP'),
              ],
            ),
            const SizedBox(height: 10),
            Text('Available tickets: ${availableTickets[type] ?? 0}'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: selectedTickets[type]! > 0
                      ? () => setState(() => selectedTickets[type] = selectedTickets[type]! - 1)
                      : null,
                ),
                Text('${selectedTickets[type]}'),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: (availableTickets[type] ?? 0) > selectedTickets[type]!
                      ? () => setState(() => selectedTickets[type] = selectedTickets[type]! + 1)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? "Anonymous";
    final userName = FirebaseAuth.instance.currentUser?.displayName ?? "Anonymous";

    return Scaffold(
      appBar: AppBar(title: const Text('Select Tickets')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    children: ticketTypes.map(buildTicketBox).toList(),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total: ${calculateTotal()} EGP',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          bool hasTickets = selectedTickets.values.any((v) => v > 0);
                          if (!hasTickets) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please select at least one ticket.")),
                            );
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CheckoutPage(
                                eventId: widget.eventId,
                                selectedTickets: selectedTickets,
                                userName: userName,
                                userEmail: userEmail,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Checkout'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
