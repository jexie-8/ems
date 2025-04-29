import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'qr_scanner_page.dart'; 
import 'package:flutter/foundation.dart';

class RedeemTicketPage extends StatefulWidget {
  const RedeemTicketPage({super.key});

  @override
  State<RedeemTicketPage> createState() => _RedeemTicketPageState();
}

class _RedeemTicketPageState extends State<RedeemTicketPage> {
  String? _selectedEventId;
  List<Map<String, String>> _events = [];

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
  final snapshot = await FirebaseFirestore.instance.collection('events').get();
  setState(() {
    _events = snapshot.docs.map((doc) => {
      'id': doc.id,
      'title': (doc.data()['Title'] ?? 'No Title').toString(),
    }).toList();
  });
}

  void _startScanning() {
  if (_selectedEventId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please select an event first")),
    );
    return;
  }

  if (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QRScannerPage(eventId: _selectedEventId!),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("QR Scanning is only supported on Android/iOS devices.")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Redeem Ticket"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Select Event:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: _selectedEventId,
              isExpanded: true,
              hint: const Text("Choose Event"),
              items: _events.map((event) {
                return DropdownMenuItem<String>(
                  value: event['id'],
                  child: Text(event['title']!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedEventId = value;
                });
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _startScanning,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text("Start QR Scanner"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
