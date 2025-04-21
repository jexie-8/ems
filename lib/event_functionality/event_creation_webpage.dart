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

  DateTime? _startDateTime;
  DateTime? _endDateTime;
Future<void> _createEvent() async {
  final title = _titleController.text.trim();
  final description = _descriptionController.text.trim();
  final maxCapacity = int.tryParse(_maxCapacityController.text) ?? 0;
  final status = _statusController.text.trim();
  final budget = _budgetController.text.trim();
  final ageRating = _ageRatingController.text.trim();

  // ✅ Validation
  if (title.isEmpty ||
      description.isEmpty ||
      status.isEmpty ||
      budget.isEmpty ||
      ageRating.isEmpty ||
      _startDateTime == null ||
      _endDateTime == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please fill in all fields and select start/end time.")),
    );
    return;
  }

  if (maxCapacity <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Max Capacity must be a positive number.")),
    );
    return;
  }

  if (maxCapacity > 500) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Max Capacity cannot exceed 500.")),
    );
    return;
  }

  final firestore = FirebaseFirestore.instance;
  final eventRef = firestore.collection("events").doc();
  final user = FirebaseAuth.instance.currentUser;

  final start = Timestamp.fromDate(_startDateTime!);
  final end = Timestamp.fromDate(_endDateTime!);

  // ✅ 1. Create the event
  await eventRef.set({
    "Event_ID": eventRef.id,
    "Title": title,
    "Description": description,
    "Start_DT": start,
    "End_DT": end,
    "Max_capacity": maxCapacity,
    "Status": status,
    "Budget": budget,
    "Age_Rating": ageRating,
    "createdBy": user?.email ?? "Unknown",
    "createdAt": Timestamp.now(),
  });

  final reportDocRef = firestore.collection("report").doc("${eventRef.id}, ${title}");

// Step 1: Create the report document
await reportDocRef.set({
  "eventId": eventRef.id,
  "eventName": title,
  "generatedAt": Timestamp.now(),
  "generatedBy": user?.email ?? "Unknown",
  "status": "awaiting_feedback",
});

// Step 2: Initialize payments subcollection
await reportDocRef.collection("payments").doc("_init").set({
  "initialized": true,
  "createdAt": Timestamp.now(),
});

// Step 3: Initialize feedback subcollection
await reportDocRef.collection("feedback").doc("_init").set({
  "initialized": true,
  "createdAt": Timestamp.now(),
});

  // ✅ 3. Create and KEEP dummy _init doc in tickets subcollection
  await firestore
      .collection("events")
      .doc(eventRef.id)
      .collection("tickets")
      .doc("_init")
      .set({
        "note": "This is a placeholder to initialize the tickets subcollection. Safe to ignore.",
      });
  await firestore
    .collection("events")
    .doc(eventRef.id)
    .collection("feedback")
    .doc("_init")
    .set({
      "note": "This is a placeholder to initialize the feedback subcollection. Safe to ignore.",
    });
  // ✅ 4. Notify and go back
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Event Created Successfully")),
  );
  Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Event")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Title")),
              TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: "Description")),
              TextField(controller: _maxCapacityController, decoration: const InputDecoration(labelText: "Max Capacity"), keyboardType: TextInputType.number),
              TextField(controller: _statusController, decoration: const InputDecoration(labelText: "Status")),
              TextField(controller: _budgetController, decoration: const InputDecoration(labelText: "Budget")),
              TextField(controller: _ageRatingController, decoration: const InputDecoration(labelText: "Age Rating")),

              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _startDateTime == null
                          ? "Pick Start Date & Time"
                          : "Start: ${_startDateTime.toString()}",
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
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: () => _pickDateTime(false),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createEvent,
                child: const Text("Create Event"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
