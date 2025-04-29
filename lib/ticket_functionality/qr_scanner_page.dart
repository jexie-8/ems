import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class QRScannerPage extends StatelessWidget {
  final String eventId;

  const QRScannerPage({Key? key, required this.eventId}) : super(key: key);

  Future<void> _validateTicket(String qrCode, BuildContext context) async {
    final ticketDoc = await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('tickets')
        .doc(qrCode)
        .get();

    if (!ticketDoc.exists) {
      Fluttertoast.showToast(msg: "Invalid QR Code!");
      return;
    }

    final ticketData = ticketDoc.data();
    final redeemed = ticketData?['redeemed'] ?? false;

    if (redeemed) {
      Fluttertoast.showToast(msg: "Ticket already redeemed.");
    } else {
      await ticketDoc.reference.update({'redeemed': true});
      Fluttertoast.showToast(msg: "Ticket redeemed successfully!");
    }

    Navigator.of(context).popUntil((route) => route.isFirst);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: MobileScanner(
        onDetect: (capture) {
          final barcode = capture.barcodes.first;
          if (barcode.rawValue != null) {
            _validateTicket(barcode.rawValue!, context);
          }
        },
      ),
    );
  }
}
