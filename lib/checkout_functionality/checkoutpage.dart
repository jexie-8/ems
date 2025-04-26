import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'payment_success.dart';

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    final newString = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      newString.write(digitsOnly[i]);
      if ((i + 1) % 4 == 0 && i + 1 != digitsOnly.length) {
        newString.write(' ');
      }
    }
    final selectionIndex = newString.length;
    return TextEditingValue(
      text: newString.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.length > 4) text = text.substring(0, 4);
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(text[i]);
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class CheckoutPage extends StatefulWidget {
  final String eventId;
  final Map<String, int> selectedTickets;
  final String userName;
  final String userEmail;

  const CheckoutPage({
    Key? key,
    required this.eventId,
    required this.selectedTickets,
    required this.userName,
    required this.userEmail,
  }) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  Future<Map<String, dynamic>> fetchEventDetails(String eventId) async {
    final eventSnapshot =
        await FirebaseFirestore.instance
            .collection('events')
            .doc(eventId)
            .get();
    return eventSnapshot.data()!;
  }

  int calculateTotal(
    Map<String, int> selectedTickets,
    Map<String, int> prices,
  ) {
    int total = 0;
    selectedTickets.forEach((type, count) {
      total += (prices[type] ?? 0) * count;
    });
    return total;
  }

  Future<String> generateQRCodeData(
    String eventTitle,
    String ticketType,
  ) async {
    final querySnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc('Attendee')
            .collection('attendees')
            .where('email', isEqualTo: widget.userEmail)
            .limit(1)
            .get();

    final doc = querySnapshot.docs.isNotEmpty ? querySnapshot.docs.first : null;
    final firstName = doc?.data()['firstName'] ?? 'Unknown';
    final lastName = doc?.data()['lastName'] ?? 'User';

    return "User: $firstName $lastName, Event: $eventTitle, Ticket Type: $ticketType";
  }

  Future<void> updateTicketStatusAndGenerateQRCode(String eventTitle) async {
    final ticketCollection = FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .collection('tickets');

    for (var entry in widget.selectedTickets.entries) {
      if (entry.value > 0) {
        final querySnapshot =
            await ticketCollection
                .where('ticket_type', isEqualTo: entry.key)
                .where('ticket_status', isEqualTo: 'available')
                .limit(entry.value)
                .get();

        int updatedCount = 0;

        for (var doc in querySnapshot.docs) {
          await doc.reference.update({
            'ticket_status': 'sold',
            'payment_status': 'completed',
            'buyerID': widget.userEmail,
            'event_id': widget.eventId,
            'QR_code': await generateQRCodeData(eventTitle, entry.key),
          });
          updatedCount++;
        }

        if (updatedCount < entry.value) {
          Fluttertoast.showToast(
            msg:
                "Only $updatedCount ${entry.key} ticket(s) were available and purchased.",
            toastLength: Toast.LENGTH_LONG,
          );
        }
      }
    }
  }

  Future<void> createPaymentRecord(int totalAmount, String eventTitle) async {
    final reportId = "${widget.eventId}, $eventTitle";
    final reportRef = FirebaseFirestore.instance
        .collection('report')
        .doc(reportId);

    final reportSnap = await reportRef.get();
    if (!reportSnap.exists) {
      Fluttertoast.showToast(msg: "No matching report found for this event.");
      return;
    }

    await reportRef.collection('payments').add({
      'amount': totalAmount,
      'ticket_bought':
          widget.selectedTickets.entries
              .where((e) => e.value > 0)
              .map((e) => {'type': e.key, 'quantity': e.value})
              .toList(),
      'user_email': widget.userEmail,
      'event_id': widget.eventId,
      'event_title': eventTitle,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  bool isExpiryValid(String input) {
    try {
      final parts = input.split('/');
      if (parts.length != 2) return false;
      final month = int.parse(parts[0]);
      final year = int.parse(parts[1]) + 2000;
      if (month < 1 || month > 12) return false;

      final now = DateTime.now();
      final expiryDate = DateTime(year, month + 1);
      return expiryDate.isAfter(now);
    } catch (_) {
      return false;
    }
  }

  bool isCardNumberValid(String cardNumber) {
    final clean = cardNumber.replaceAll(' ', '');
    return RegExp(r'^[0-9]{16}$').hasMatch(clean);
  }

  @override
  void dispose() {
    _cardController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F0FF),
      appBar: AppBar(
        title: Text('Checkout'),
        backgroundColor: Colors.deepPurple[100],
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Decorative background circles
          Positioned(
            top: -60,
            left: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.deepPurple.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            right: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.deepPurple.withOpacity(0.1),
              ),
            ),
          ),
          FutureBuilder<Map<String, dynamic>>(
            future: fetchEventDetails(widget.eventId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final event = snapshot.data!;
              final eventTitle = event['Title'];

              final List ticketTypes = event['ticketTypes'] ?? [];
              final Map<String, int> prices = {
                for (var ticket in ticketTypes)
                  ticket['type']: (ticket['price'] as num).toInt(),
              };

              final total = calculateTotal(widget.selectedTickets, prices);

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    _buildCard(
                      title: 'Event Summary',
                      children: [
                        Text('Title: $eventTitle'),
                        Text(
                          'Date: ${DateFormat.yMMMd().add_jm().format(event['Start_DT'].toDate())}',
                        ),
                        Text('Description: ${event['Description']}'),
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildCard(
                      title: 'Ticket Summary',
                      children:
                          widget.selectedTickets.entries
                              .where((entry) => entry.value > 0)
                              .map(
                                (entry) => Text(
                                  '${entry.key} x ${entry.value} - ${prices[entry.key]! * entry.value} EGP',
                                ),
                              )
                              .toList(),
                    ),
                    SizedBox(height: 16),
                    _buildCard(
                      title: 'Payment Information',
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _cardController,
                                decoration: InputDecoration(
                                  labelText: 'Card Number',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [CardNumberInputFormatter()],
                                validator: (value) {
                                  if (value == null ||
                                      !isCardNumberValid(value)) {
                                    return 'Enter a valid 16-digit card number';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _expiryController,
                                      decoration: InputDecoration(
                                        labelText: 'Expiry Date',
                                        hintText: 'MM/YY',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.datetime,
                                      inputFormatters: [
                                        ExpiryDateInputFormatter(),
                                      ],
                                      validator: (value) {
                                        if (value == null ||
                                            !isExpiryValid(value)) {
                                          return 'Invalid expiry date';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _cvvController,
                                      decoration: InputDecoration(
                                        labelText: 'CVV',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                      obscureText: true,
                                      // maxLength removed
                                      validator: (value) {
                                        if (value == null ||
                                            value.length != 3) {
                                          return 'CVV must be 3 digits';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height:
                                    60, // 👈 This makes the button area taller
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      try {
                                        await updateTicketStatusAndGenerateQRCode(
                                          eventTitle,
                                        );
                                        await createPaymentRecord(
                                          total,
                                          eventTitle,
                                        );

                                        final selectedType =
                                            widget.selectedTickets.entries
                                                .firstWhere((e) => e.value > 0)
                                                .key;
                                        final qrString =
                                            await generateQRCodeData(
                                              eventTitle,
                                              selectedType,
                                            );

                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => PaymentSuccessPage(
                                                  qrCodeData: qrString,
                                                ),
                                          ),
                                        );
                                        Fluttertoast.showToast(
                                          msg: "Payment Successful!",
                                        );
                                      } catch (e) {
                                        Fluttertoast.showToast(
                                          msg: "Error: $e",
                                        );
                                      }
                                    } else {
                                      Fluttertoast.showToast(
                                        msg: "Invalid payment info",
                                      );
                                    }
                                  },
                                  child: Text(
                                    'Pay Now',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.symmetric(vertical: 8),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }
}