import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_screens/checkoutpage.dart';

class TicketSelectionPage extends StatefulWidget {
  final String eventId;

  const TicketSelectionPage({Key? key, required this.eventId}) : super(key: key);

  @override
  _TicketSelectionPageState createState() => _TicketSelectionPageState();
}

class _TicketSelectionPageState extends State<TicketSelectionPage> {
  Map<String, int> availableTickets = {
    'VIP': 0,
    'Fanpit': 0,
    'Regular': 0,
  };
  Map<String, int> selectedTickets = {
    'VIP': 0,
    'Fanpit': 0,
    'Regular': 0,
  };
  Map<String, int> prices = {}; // Removed default values

  @override
  void initState() {
    super.initState();
    fetchAvailableTicketsAndPrices();
  }

  Future<void> fetchAvailableTicketsAndPrices() async {
    try {
      final eventId = widget.eventId;
      final snapshot = await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .collection('tickets')
          .where('ticket_status', isEqualTo: 'available')
          .get();

      Map<String, int> typeCounters = {
        'VIP': 0,
        'Fanpit': 0,
        'Regular': 0,
      };

      Map<String, int> typePrices = {};

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String type = data['ticket_type'] ?? '';
        int price = data['price'] ?? 0;

        if (typeCounters.containsKey(type)) {
          typeCounters[type] = typeCounters[type]! + 1;

          // If this ticket type's price is not yet recorded, set it
          if (!typePrices.containsKey(type)) {
            typePrices[type] = price;
          }
        }
      }

      setState(() {
        availableTickets = typeCounters;
        prices = typePrices;
      });
    } catch (e) {
      print("Error fetching available tickets and prices: $e");
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
      margin: EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  type,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  prices.containsKey(type) ? '${prices[type]} EGP' : '-- EGP',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'Available tickets: ${availableTickets[type] ?? 'N/A'}',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: selectedTickets[type]! > 0
                      ? () {
                          setState(() {
                            selectedTickets[type] = selectedTickets[type]! - 1;
                          });
                        }
                      : null,
                ),
                Text('${selectedTickets[type]}'),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: (availableTickets[type] ?? 0) > selectedTickets[type]!
                      ? () {
                          setState(() {
                            selectedTickets[type] = selectedTickets[type]! + 1;
                          });
                        }
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
      appBar: AppBar(title: Text('Select Tickets')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                buildTicketBox('VIP'),
                buildTicketBox('Fanpit'),
                buildTicketBox('Regular'),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 4),
            ]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ${calculateTotal()} EGP',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {
                    bool hasTickets = selectedTickets.values.any((v) => v > 0);
                    if (!hasTickets) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please select at least one ticket.")),
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
                  child: Text('Checkout'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
