import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'payment_success.dart';

// Custom input formatter for card number
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
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

// Custom input formatter for expiry date
class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
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
        await FirebaseFirestore.instance.collection('events').doc(eventId).get();
    return eventSnapshot.data()!;
  }

  int calculateTotal(Map<String, int> selectedTickets, Map<String, int> prices) {
    int total = 0;
    selectedTickets.forEach((type, count) {
      total += (prices[type] ?? 0) * count;
    });
    return total;
  }

  String generateQRCodeData() {
    return "User: ${widget.userName}, Event: ${widget.eventId}, Tickets: ${widget.selectedTickets.toString()}";
  }

  Future<void> updateTicketStatusAndGenerateQRCode() async {
    final ticketCollection = FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .collection('tickets');

    for (var entry in widget.selectedTickets.entries) {
      if (entry.value > 0) {
        final querySnapshot = await ticketCollection
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
            'QR_code': generateQRCodeData(),
          });
          updatedCount++;
        }

        if (updatedCount < entry.value) {
          Fluttertoast.showToast(
            msg: "Only $updatedCount ${entry.key} ticket(s) were available and purchased.",
            toastLength: Toast.LENGTH_LONG,
          );
        }
      }
    }
  }

  Future<void> createPaymentRecord(int totalAmount) async {
    final paymentCollection = FirebaseFirestore.instance.collection('payments');

    await paymentCollection.add({
      'amount': totalAmount,
      'ticket_bought': widget.selectedTickets.entries
          .where((e) => e.value > 0)
          .map((e) => {'type': e.key, 'quantity': e.value})
          .toList(),
      'user_email': widget.userEmail,
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
    Map<String, int> prices = {
      'VIP': 1500,
      'Fanpit': 850,
      'Regular': 500,
    };

    return Scaffold(
      appBar: AppBar(title: Text('Checkout')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchEventDetails(widget.eventId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final event = snapshot.data!;
          final total = calculateTotal(widget.selectedTickets, prices);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Text(
                  'Event Summary',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text('Title: ${event['Title']}'),
                Text('Date: ${DateFormat.yMMMd().add_jm().format(event['Start_DT'].toDate())}'),
                Text('Description: ${event['Description']}'),
                Divider(height: 30),

                Text(
                  'Ticket Summary',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                ...widget.selectedTickets.entries.map((entry) {
                  return entry.value > 0
                      ? Text('${entry.key} x ${entry.value} - ${prices[entry.key]! * entry.value} EGP')
                      : SizedBox.shrink();
                }).toList(),
                Divider(height: 30),

                Text(
                  'Payment Information',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _cardController,
                        decoration: InputDecoration(labelText: 'Card Number', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        inputFormatters: [CardNumberInputFormatter()],
                        validator: (value) {
                          if (value == null || !isCardNumberValid(value)) {
                            return 'Enter a valid 16-digit card number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _expiryController,
                              decoration: InputDecoration(labelText: 'Expiry Date', hintText: 'MM/YY', border: OutlineInputBorder()),
                              keyboardType: TextInputType.datetime,
                              inputFormatters: [ExpiryDateInputFormatter()],
                              validator: (value) {
                                if (value == null || !isExpiryValid(value)) {
                                  return 'Invalid expiry date';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _cvvController,
                              decoration: InputDecoration(labelText: 'CVV', border: OutlineInputBorder()),
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              maxLength: 3,
                              validator: (value) {
                                if (value == null || value.length != 3) {
                                  return 'CVV must be 3 digits';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final total = calculateTotal(widget.selectedTickets, prices);

                            await updateTicketStatusAndGenerateQRCode();
                            await createPaymentRecord(total);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentSuccessPage(qrCodeData: generateQRCodeData()),
                              ),
                            );
                            Fluttertoast.showToast(msg: "Payment Successful!");
                          } else {
                            Fluttertoast.showToast(msg: "Invalid payment info");
                          }
                        },
                        child: Text('Pay Now'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          textStyle: TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
