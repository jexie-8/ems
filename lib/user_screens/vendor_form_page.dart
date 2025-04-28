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
      backgroundColor: const Color(0xFFE6E0F8),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 32, 19, 77),
        elevation: 0,
        centerTitle: true,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.purpleAccent, Colors.white],
          ).createShader(bounds),
          child: Text(
            widget.vendorRef == null ? 'Create Vendor' : 'Edit Vendor',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Decorative background circles
          Positioned(
            top: -80,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.purpleAccent.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 100),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  _buildField("Vendor Name", vendorName),
                  _buildField("Type of Vendor", type),
                  _buildField("Phone", phone),
                  _buildField("Cost", cost),
                  _buildField("Contract Details", contractDetails),
                  _buildField("Availability", availability),
                  _buildField("Payment Status", paymentStatus),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: saveVendor,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text(
                        "Save Vendor",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          labelStyle: const TextStyle(color: Colors.deepPurple),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.deepPurple),
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
      ),
    );
  }
}
