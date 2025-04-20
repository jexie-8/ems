import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditEventScreen extends StatefulWidget {
  
  final Map<String, dynamic> event;
  final String docId;
  const EditEventScreen({super.key, required this.event, required this.docId});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _maxCapacityController;
  late TextEditingController _statusController;
  late TextEditingController _budgetController;
  late TextEditingController _ageRatingController;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event["Title"]);
    _descriptionController = TextEditingController(text: widget.event["Description"]);
    _maxCapacityController =
        TextEditingController(text: widget.event["Max_capacity"].toString());
    _statusController = TextEditingController(text: widget.event["Status"]);
    _budgetController = TextEditingController(text: widget.event["Budget"].toString());
    _ageRatingController =
        TextEditingController(text: widget.event["Age_Rating"].toString());

    _startDate = _convertTimestamp(widget.event["Start_DT"]);
    _endDate = _convertTimestamp(widget.event["End_DT"]);
  }

  DateTime? _convertTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    return null;
  }

  Future<void> _pickDate(bool isStartDate) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  Future<void> _updateEvent() async {
    try {
      print("Using docId: ${widget.docId}");
      await FirebaseFirestore.instance
    .collection("events")
    .doc(widget.docId)
    .update({
  "Title": _titleController.text,
  "Description": _descriptionController.text,
  "Start_DT": _startDate,
  "End_DT": _endDate,
  "Max_capacity": int.tryParse(_maxCapacityController.text) ?? 0,
  "Status": _statusController.text,
  "Budget": _budgetController.text,
  "Age_Rating": _ageRatingController.text,
});


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event updated successfully!")),
      );

      Navigator.pop(context); 
      Navigator.pop(context);// Go back to event details screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update event: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Event")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Title")),
              TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: "Description")),
              TextField(controller: _maxCapacityController, decoration: const InputDecoration(labelText: "Max Capacity")),
              TextField(controller: _statusController, decoration: const InputDecoration(labelText: "Status")),
              TextField(controller: _budgetController, decoration: const InputDecoration(labelText: "Budget")),
              TextField(controller: _ageRatingController, decoration: const InputDecoration(labelText: "Age Rating")),
              
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: Text(_startDate == null ? "Pick Start Date" : "Start: ${_startDate.toString()}")),
                  IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => _pickDate(true)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: Text(_endDate == null ? "Pick End Date" : "End: ${_endDate.toString()}")),
                  IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => _pickDate(false)),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateEvent,
                child: const Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
