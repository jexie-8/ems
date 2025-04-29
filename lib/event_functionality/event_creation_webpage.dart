import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _maxCapacityController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _ageRatingController = TextEditingController();
  final TextEditingController _clientEmailController = TextEditingController();

  DateTime? _startDateTime;
  DateTime? _endDateTime;

  bool _isCreatingEvent = false; // <-- New flag here

  Future<void> _createEvent() async {
  setState(() {
    _isCreatingEvent = true;
  });

  final title = _titleController.text.trim();
  final description = _descriptionController.text.trim();
  final maxCapacity = int.tryParse(_maxCapacityController.text) ?? 0;
  final status = _statusController.text.trim();
  final budgetStr = _budgetController.text.trim();
  final budget = double.tryParse(budgetStr) ?? -1; // Try parsing budget as double
  final ageRatingStr = _ageRatingController.text.trim();
  final ageRating = int.tryParse(ageRatingStr);
  final clientEmail = _clientEmailController.text.trim();

  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  if (title.isEmpty ||
      description.isEmpty ||
      status.isEmpty ||
      budgetStr.isEmpty ||
      ageRatingStr.isEmpty ||
      clientEmail.isEmpty ||
      _startDateTime == null ||
      _endDateTime == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please fill in all fields and select start/end time.")),
    );
    setState(() {
      _isCreatingEvent = false;
    });
    return;
  }

  if (maxCapacity <= 0 || maxCapacity > 500) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Max Capacity must be between 1 and 500.")),
    );
    setState(() {
      _isCreatingEvent = false;
    });
    return;
  }

  if (budget <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Budget must be a positive number.")),
    );
    setState(() {
      _isCreatingEvent = false;
    });
    return;
  }

  if (ageRating == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Age Rating must be an integer number.")),
    );
    setState(() {
      _isCreatingEvent = false;
    });
    return;
  }

  if (!emailRegex.hasMatch(clientEmail)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please enter a valid Client Email address.")),
    );
    setState(() {
      _isCreatingEvent = false;
    });
    return;
  }

  try {
    final firestore = FirebaseFirestore.instance;
    final eventRef = firestore.collection("events").doc();
    final user = FirebaseAuth.instance.currentUser;

    final start = Timestamp.fromDate(_startDateTime!);
    final end = Timestamp.fromDate(_endDateTime!);

    await eventRef.set({
      "Event_ID": eventRef.id,
      "Client_Email": clientEmail,
      "Title": title,
      "Description": description,
      "Start_DT": start,
      "End_DT": end,
      "Max_capacity": maxCapacity,
      "Status": status,
      "Budget": budget.toStringAsFixed(2), // Save budget as string nicely
      "Age_Rating": ageRating.toString(),
      "createdBy": user?.email ?? "Unknown",
      "createdAt": Timestamp.now(),
    });

    final reportDocRef = firestore.collection("report").doc("${eventRef.id}, $title");

    await reportDocRef.set({
      "eventId": eventRef.id,
      "eventName": title,
      "generatedAt": Timestamp.now(),
      "generatedBy": user?.email ?? "Unknown",
      "status": "awaiting_feedback",
    });

    await reportDocRef.collection("payments").doc("_init").set({
      "initialized": true,
      "createdAt": Timestamp.now(),
    });

    await reportDocRef.collection("feedback").doc("_init").set({
      "initialized": true,
      "createdAt": Timestamp.now(),
    });

    await eventRef.collection("tickets").doc("_init").set({
      "note": "Placeholder to initialize the tickets subcollection.",
    });

    await eventRef.collection("feedback").doc("_init").set({
      "note": "Placeholder to initialize the feedback subcollection.",
    });

    await eventRef.collection("vendors").doc("_init").set({
      "note": "Placeholder to initialize the vendors subcollection.",
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Event Created Successfully")),
    );

    setState(() {
      _isCreatingEvent = false;
    });

    Navigator.pop(context);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error creating event: $e")),
    );
    setState(() {
      _isCreatingEvent = false;
    });
  }
}


  Future<void> _pickDateTime(bool isStart) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 9, minute: 0),
      );

      if (pickedTime != null) {
        final dateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          if (isStart) {
            _startDateTime = dateTime;
          } else {
            _endDateTime = dateTime;
          }
        });
      }
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          labelStyle: const TextStyle(fontWeight: FontWeight.w500),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Color(0xFF6A4C9C), width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text("Create Event"),
        backgroundColor: const Color(0xFF57419D),
      ),
      body: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTextField("Title", _titleController),
                  _buildTextField("Description", _descriptionController),
                  _buildTextField("Max Capacity", _maxCapacityController, type: TextInputType.number),
                  _buildTextField("Status", _statusController),
                  _buildTextField("Budget", _budgetController),
                  _buildTextField("Age Rating", _ageRatingController),
                  _buildTextField("Client's Email", _clientEmailController),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _startDateTime == null
                              ? "Pick Start Date & Time"
                              : "Start: ${_startDateTime.toString()}",
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.access_time),
                        onPressed: () => _pickDateTime(true),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _endDateTime == null
                              ? "Pick End Date & Time"
                              : "End: ${_endDateTime.toString()}",
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.access_time),
                        onPressed: () => _pickDateTime(false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isCreatingEvent ? null : _createEvent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A4C9C),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      child: _isCreatingEvent
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              "Create Event",
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
