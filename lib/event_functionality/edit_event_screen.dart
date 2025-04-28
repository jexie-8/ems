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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update event: $e")),
      );
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
        title: const Text("Edit Event"),
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

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _startDate == null
                              ? "Pick Start Date"
                              : "Start: ${_startDate.toString()}",
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _pickDate(true),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _endDate == null
                              ? "Pick End Date"
                              : "End: ${_endDate.toString()}",
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _pickDate(false),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _updateEvent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A4C9C),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      child: const Text(
                        "Save Changes",
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
