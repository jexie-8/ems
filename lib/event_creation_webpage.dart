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
    final maxCapacity = int.tryParse(_maxCapacityController.text) ?? 0;

    if (maxCapacity > 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Max Capacity cannot exceed 500.")),
      );
      return;
    }

    final firestore = FirebaseFirestore.instance;
    final eventRef = firestore.collection("events").doc();
    final user = FirebaseAuth.instance.currentUser;

    await eventRef.set({
      "Event_ID": eventRef.id,
      "Title": _titleController.text,
      "Description": _descriptionController.text,
      "Start_D/T": _startDateTime != null ? Timestamp.fromDate(_startDateTime!) : null,
      "End_D/T": _endDateTime != null ? Timestamp.fromDate(_endDateTime!) : null,
      "Max_capacity": maxCapacity,
      "Status": _statusController.text,
      "Budget": _budgetController.text,
      "Age_Rating": _ageRatingController.text,
      "createdBy": user?.email ?? "Unknown",
      "createdAt": Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Event Created Successfully")),
    );
    Navigator.pop(context); // Go back after creating event
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
