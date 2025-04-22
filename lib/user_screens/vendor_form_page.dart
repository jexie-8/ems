import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VendorFormPage extends StatefulWidget {
  final DocumentReference? vendorRef;
  final Map<String, dynamic>? vendorData;
  final String? eventTitle;
  final String? eventId;

  const VendorFormPage({
    super.key,
    this.vendorRef,
    this.vendorData,
    this.eventTitle,
    this.eventId,
  });

  @override
  State<VendorFormPage> createState() => _VendorFormPageState();
}

class _VendorFormPageState extends State<VendorFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController vendorName;
  late TextEditingController type;
  late TextEditingController phone;
  late TextEditingController cost;
  late TextEditingController contractDetails;
  late TextEditingController availability;
  late TextEditingController paymentStatus;

  @override
  void initState() {
    super.initState();
    final d = widget.vendorData ?? {};
    vendorName = TextEditingController(text: d['vendor_name']);
    type = TextEditingController(text: d['type']);
    phone = TextEditingController(text: d['phone_num']);
    cost = TextEditingController(text: d['cost']);
    contractDetails = TextEditingController(text: d['contract_details']);
    availability = TextEditingController(text: d['availability']);
    paymentStatus = TextEditingController(text: d['payment_status']);
  }

  @override
  void dispose() {
    vendorName.dispose();
    type.dispose();
    phone.dispose();
    cost.dispose();
    contractDetails.dispose();
    availability.dispose();
    paymentStatus.dispose();
    super.dispose();
  }

  Future<void> saveVendor() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'vendor_name': vendorName.text,
      'type': type.text,
      'phone_num': phone.text,
      'cost': cost.text,
      'contract_details': contractDetails.text,
      'availability': availability.text,
      'payment_status': paymentStatus.text,
      'event_title': widget.eventTitle,
    };

    final vendorsCollection = FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .collection('vendors');

    if (widget.vendorRef == null) {
      await vendorsCollection.add(data);
    } else {
      await widget.vendorRef!.update(data);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vendorRef == null ? 'Create Vendor' : 'Edit Vendor'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildField("Vendor Name", vendorName),
              _buildField("Type", type),
              _buildField("Phone", phone),
              _buildField("Cost", cost),
              _buildField("Contract Details", contractDetails),
              _buildField("Availability", availability),
              _buildField("Payment Status", paymentStatus),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveVendor,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
                child: const Text("Save Vendor"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
      ),
    );
  }
}
