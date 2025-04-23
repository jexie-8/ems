import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateTicketsPage extends StatefulWidget {
  final String eventId;

  const CreateTicketsPage({super.key, required this.eventId});

  @override
  State<CreateTicketsPage> createState() => _CreateTicketsPageState();
}

class _CreateTicketsPageState extends State<CreateTicketsPage> {
  final TextEditingController _typeCountController = TextEditingController();
  List<Map<String, TextEditingController>> _ticketInputs = [];

  void _generateTicketInputs() {
    final int? typeCount = int.tryParse(_typeCountController.text.trim());

    if (typeCount == null || typeCount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid number of ticket types.")),
      );
      return;
    }

    _ticketInputs = List.generate(typeCount, (_) {
      return {
        'type': TextEditingController(),
        'amount': TextEditingController(),
        'price': TextEditingController(),
      };
    });

    setState(() {});
  }

  Future<void> _createTicketsAndSaveTypes() async {
    List<Map<String, dynamic>> ticketTypeData = [];
    final WriteBatch batch = FirebaseFirestore.instance.batch();
    final ticketsRef = FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .collection('tickets');

    for (var input in _ticketInputs) {
      final String type = input['type']!.text.trim();
      final int? amount = int.tryParse(input['amount']!.text.trim());
      final double? price = double.tryParse(input['price']!.text.trim());

      if (type.isEmpty || amount == null || price == null || amount <= 0 || price < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill in all fields correctly.")),
        );
        return;
      }


      ticketTypeData.add({
        "type": type,
        "amount": amount,
        "price": price,
      });


      for (int i = 0; i < amount; i++) {
        final newDoc = ticketsRef.doc();
        batch.set(newDoc, {
          'QR_code': '',
          'buyerID': '',
          'payment_status': '',
          'ticket_status': 'available',
          'ticket_type': type,
          'price': price,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }

    await batch.commit();

    await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .update({"ticketTypes": ticketTypeData});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Tickets created and types saved successfully")),
    );

 
    _typeCountController.clear();
    setState(() {
      _ticketInputs = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Tickets")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _typeCountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "How many ticket types?"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _generateTicketInputs,
              child: const Text("Set Ticket Types"),
            ),
            const SizedBox(height: 20),
            ..._ticketInputs.asMap().entries.map((entry) {
              int index = entry.key;
              var input = entry.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Ticket Type ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextField(
                    controller: input['type'],
                    decoration: const InputDecoration(labelText: "Type (e.g. VIP, Regular)"),
                  ),
                  TextField(
                    controller: input['amount'],
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Amount"),
                  ),
                  TextField(
                    controller: input['price'],
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: "Price"),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
            if (_ticketInputs.isNotEmpty)
              ElevatedButton(
                onPressed: _createTicketsAndSaveTypes,
                child: const Text("Generate All Tickets"),
              ),
          ],
        ),
      ),
    );
  }
}
