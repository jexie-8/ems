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
      final eventDoc = await FirebaseFirestore.instance.collection('events').doc(widget.eventId).get();
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
      print("Error fetching tickets: $e");
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFB39DDB), Color(0xFF9575CD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: Colors.deepPurple.withOpacity(0.3), blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(type, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('${prices[type]} EGP', style: const TextStyle(fontSize: 20, color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 12),
            Text('Available: ${availableTickets[type] ?? 0}', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.white),
                  onPressed: selectedTickets[type]! > 0
                      ? () => setState(() => selectedTickets[type] = selectedTickets[type]! - 1)
                      : null,
                ),
                Text('${selectedTickets[type]}', style: const TextStyle(fontSize: 20, color: Colors.white)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white),
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
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7E57C2),
        elevation: 0,
        title: const Text('Select Your Tickets', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF7E57C2)))
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    children: ticketTypes.map(buildTicketBox).toList(),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total: ${calculateTotal()} EGP', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                          backgroundColor: const Color(0xFF7E57C2),
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('Checkout', style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
} 