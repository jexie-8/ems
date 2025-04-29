import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PurchasedTicketsPage extends StatelessWidget {
  final String userId;

  const PurchasedTicketsPage({Key? key, required this.userId}) : super(key: key);

 Future<List<Map<String, dynamic>>> _fetchTickets() async {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null || currentUser.email == null) return [];

  final String currentEmail = currentUser.email!;
  final ticketSnapshot = await FirebaseFirestore.instance.collectionGroup('tickets').get();

  List<Map<String, dynamic>> ticketDetails = [];

  for (var ticketDoc in ticketSnapshot.docs) {
    final ticketData = ticketDoc.data();

    if (ticketData['buyerID'] != currentEmail) continue;

    final eventId = ticketDoc.reference.parent.parent?.id;
    if (eventId == null) continue;

    final eventSnapshot = await FirebaseFirestore.instance.collection('events').doc(eventId).get();
    final eventData = eventSnapshot.data();
    if (eventData == null) continue;

    ticketDetails.add({
      'eventTitle': eventData['Title'],
      'eventDate': eventData['Start_DT'],
      'ticketType': ticketData['ticket_type'],
      'price': ticketData['price'],
      'ticketStatus': ticketData['ticket_status'],
      'paymentStatus': ticketData['payment_status'],
      'redeemed': ticketData['redeemed'] ?? false, // <-- new field collected
      'QRcode': ticketData['QR_code'],
    });
  }

  return ticketDetails;
}



  void _showEnlargedQR(BuildContext context, String qrData) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black.withOpacity(0.8),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: QrImageView(
            data: qrData,
            version: QrVersions.auto,
            size: 300.0,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        title: const Text('My Tickets', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 10,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          ...List.generate(10, (index) {
            final shapes = [
              {'top': 20.0, 'left': 10.0, 'angle': 0.4},
              {'bottom': 90.0, 'right': 30.0, 'angle': -0.4},
              {'top': 160.0, 'right': -30.0, 'angle': 0.6},
              {'bottom': 220.0, 'left': -20.0, 'angle': -0.3},
              {'top': 320.0, 'left': 200.0, 'angle': 0.7},
            ];
            final pos = shapes[index % shapes.length];
            return Positioned(
              child: Transform.rotate(
                angle: pos['angle'] as double,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.03 * (index % 4 + 1)),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
            );
          }),
          FutureBuilder<List<Map<String, dynamic>>>(
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  final ticket = tickets[index];
                  final qrCodeData = ticket['QRcode'] ?? '';
                  final eventDate = (ticket['eventDate'] as Timestamp).toDate();
                  final bool isRedeemed = ticket['redeemed'] ?? false;

                  final formattedDate = '${eventDate.day}/${eventDate.month}/${eventDate.year} at ${eventDate.hour}:${eventDate.minute.toString().padLeft(2, '0')}';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE1BEE7), Color(0xFFF3E5F5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ticket['eventTitle'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          Text(
                            '📅 Date: $formattedDate',
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '🎟️ Type: ${ticket['ticketType']}',
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                          if (isRedeemed)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                             '✅ Redeemed',
                              style: TextStyle(
                               color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                           ),
                          ),
                          const SizedBox(height: 12),
                          if (qrCodeData.isNotEmpty)
                            Center(
                              child: GestureDetector(
                                onTap: () => _showEnlargedQR(context, qrCodeData),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: QrImageView(
                                    data: qrCodeData,
                                    version: QrVersions.auto,
                                    size: 150.0,
                                    foregroundColor: Colors.deepPurple,
                                  ),
                                ),
                              ),
                            ),
                          if (qrCodeData.isEmpty)
                            const Center(
                              child: Text(
                                'No QR code available.',
                                style: TextStyle(fontSize: 14, color: Colors.red),
                              ),
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
    );
  }
}
