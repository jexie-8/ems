import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PurchasedTicketsPage extends StatelessWidget {
  final String userId;

  const PurchasedTicketsPage({Key? key, required this.userId}) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchTickets() async {
    final ticketSnapshot = await FirebaseFirestore.instance
        .collectionGroup('tickets')
        .where('buyerID', isEqualTo: userId)
        .get();

    List<Map<String, dynamic>> ticketDetails = [];

    for (var ticketDoc in ticketSnapshot.docs) {
      final ticketData = ticketDoc.data() as Map<String, dynamic>;
      final eventId = ticketDoc.reference.parent.parent?.id;

      if (eventId != null) {
        final eventSnapshot = await FirebaseFirestore.instance
            .collection('events')
            .doc(eventId)
            .get();
        final eventData = eventSnapshot.data() as Map<String, dynamic>;

        final userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        final userData = userSnapshot.data() as Map<String, dynamic>;

        ticketDetails.add({
          'eventTitle': eventData['title'],
          'eventDate': eventData['startD/T'], // 🆕 Add the date
          'ticketType': ticketData['ticket_type'],
          'price': ticketData['price'],
          'ticketStatus': ticketData['ticket_status'],
          'paymentStatus': ticketData['payment_status'],
          'QRcode': ticketData['QR_code'],
          'userName': '${userData['firstName']} ${userData['lastName']}',
        });
      }
    }

    return ticketDetails;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Purchased Tickets'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchTickets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tickets purchased yet.'));
          }

          final tickets = snapshot.data!;

          return ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              final qrCodeData = ticket['QRcode'] ?? '';
              final eventDate = (ticket['eventDate'] as Timestamp).toDate();
              final formattedDate =
                  '${eventDate.day}/${eventDate.month}/${eventDate.year} at ${eventDate.hour}:${eventDate.minute.toString().padLeft(2, '0')}';

              return Card(
                margin: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Event: ${ticket['eventTitle']}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Date: $formattedDate',
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Ticket Type: ${ticket['ticketType']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Price: ${ticket['price']} EGP',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Status: ${ticket['ticketStatus']}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Payment Status: ${ticket['paymentStatus']}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Buyer: ${ticket['userName']}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      if (qrCodeData.isNotEmpty)
                        Center(
                          child: QrImageView(
                            data: qrCodeData,
                            version: QrVersions.auto,
                            size: 150.0,
                            foregroundColor: Colors.blue,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      if (qrCodeData.isEmpty)
                        const Text(
                          'No QR code available.',
                          style: TextStyle(fontSize: 14, color: Colors.red),
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
