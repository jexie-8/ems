import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateTicketsPage extends StatefulWidget {
  final String eventId;

  const CreateTicketsPage({super.key, required this.eventId});

  @override
  State<CreateTicketsPage> createState() => _CreateTicketsPageState();
}

class _CreateTicketsPageState extends State<CreateTicketsPage> {
  final TextEditingController _ticketCountController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();

  Future<void> _createTickets() async {
    final int? count = int.tryParse(_ticketCountController.text.trim());
    final double? price = double.tryParse(_priceController.text.trim());
    final String ticketType = _typeController.text.trim();

    if (count == null || price == null || ticketType.isEmpty || count <= 0 || price < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter valid ticket count, price, and type.")),
      );
      return;
    }

    final WriteBatch batch = FirebaseFirestore.instance.batch();
    final ticketsRef = FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .collection('tickets');

    for (int i = 0; i < count; i++) {
      final newDoc = ticketsRef.doc();
      batch.set(newDoc, {
        'QR_code': '',
        'buyerID': '',
        'payment_status': '',
        'ticket_status': 'available',
        'ticket_type': ticketType,
        'price': price,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$count tickets created successfully")),
    );

    _ticketCountController.clear();
    _priceController.clear();
    _typeController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Tickets")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _ticketCountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Number of Tickets",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: "Price per Ticket",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _typeController,
              decoration: const InputDecoration(
                labelText: "Ticket Type (e.g. VIP, Standard)",
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _createTickets,
              child: const Text("Generate Tickets"),
            ),
          ],
        ),
      ),
    );
  }
}
