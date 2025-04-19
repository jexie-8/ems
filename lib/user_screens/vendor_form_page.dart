import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VendorFormPage extends StatefulWidget {
  final String vendorManagerId;
  final DocumentReference? vendorRef;
  final Map<String, dynamic>? vendorData;

  const VendorFormPage({
    super.key,
    required this.vendorManagerId,
    this.vendorRef,
    this.vendorData,
  });

  @override
  State<VendorFormPage> createState() => _VendorFormPageState();
}

class _VendorFormPageState extends State<VendorFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController firstName;
  late TextEditingController lastName;
  late TextEditingController type;
  late TextEditingController phone;
  late TextEditingController cost;
  late TextEditingController contractDetails;
  late TextEditingController availability;
  late TextEditingController paymentStatus;

  String? selectedEventTitle;
  List<String> eventTitles = [];

  @override
  void initState() {
    super.initState();
    final d = widget.vendorData ?? {};
    firstName = TextEditingController(text: d['first_name']);
    lastName = TextEditingController(text: d['last_name']);
    type = TextEditingController(text: d['type']);
    phone = TextEditingController(text: d['phone_num']);
    cost = TextEditingController(text: d['cost']);
    contractDetails = TextEditingController(text: d['contract_details']);
    availability = TextEditingController(text: d['availability']);
    paymentStatus = TextEditingController(text: d['payment_status']);
    selectedEventTitle = d['Title'];

    fetchEventTitles();
  }

  Future<void> fetchEventTitles() async {
    final snapshot = await FirebaseFirestore.instance.collection('events').get();
    setState(() {
      eventTitles = snapshot.docs.map((doc) => doc['Title'] as String).toList();
    });
  }

  @override
  void dispose() {
    firstName.dispose();
    lastName.dispose();
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
      'first_name': firstName.text,
      'last_name': lastName.text,
      'type': type.text,
      'phone_num': phone.text,
      'cost': cost.text,
      'contract_details': contractDetails.text,
      'availability': availability.text,
      'payment_status': paymentStatus.text,
      'Title': selectedEventTitle,
    };

    final vendorsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc('employees')
        .collection('vendor_manager')
        .doc(widget.vendorManagerId)
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
              _buildField("First Name", firstName),
              _buildField("Last Name", lastName),
              _buildField("Type", type),
              _buildField("Phone", phone),
              _buildField("Cost", cost),
              _buildField("Contract Details", contractDetails),
              _buildField("Availability", availability),
              _buildField("Payment Status", paymentStatus),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedEventTitle,
                decoration: const InputDecoration(
                  labelText: 'Event',
                  border: OutlineInputBorder(),
                ),
                items: eventTitles.map((title) {
                  return DropdownMenuItem<String>(
                    value: title,
                    child: Text(title),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedEventTitle = value;
                  });
                },
                validator: (val) =>
                    val == null || val.isEmpty ? 'Please select an event' : null,
              ),
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
