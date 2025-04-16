import 'package:flutter/material.dart';

// Main event page widget creation
class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}
// class that manages the form data
/* This class holds data that can change and rebuilds the widget
     when that happens  */

class _CreateEventPageState extends State<CreateEventPage> {
  //
  final _formKey = GlobalKey<FormState>();

  //Global key for the form widget/key for validating and interact with this form
  // Controller for managing the text input and allows us to read and write
  //the field values.
  final _eventNameController = TextEditingController();
  final _eventDateController = TextEditingController();
  final _eventLocalionController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      //validating the form through key.
      print('Event Name:${_eventNameController.text}');
      print('Event Date:${_eventDateController.text}');
      print('Event location:${_eventLocalionController.text}');
      //Notification for event creation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event created successfully')),
      );
      _formKey.currentState!.reset(); //Resets the form after submission
    }
  }

  @override
  void dispose() {
    //prevents memory leaks
    _eventNameController.dispose();
    _eventDateController.dispose();
    _eventLocalionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar:AppBar(title:const Text ('Create New Event'),backgroundColor: Colors.purpleAccent,
    ),
    body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Event Name Field
              TextFormField(
                controller: _eventNameController,
                decoration: const InputDecoration(
                  labelText: 'Event Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an event name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Event Date Field
              TextFormField(
                controller: _eventDateController,
                decoration: const InputDecoration(
                  labelText: 'Event Date (MM/DD/YYYY)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Event Location Field
              TextFormField(
                controller: _eventLocalionController,
                decoration: const InputDecoration(
                  labelText: 'Event Location',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Create Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}