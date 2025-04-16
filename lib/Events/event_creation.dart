import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventCreation {} extends StatefulWidget{
  const EventCreation({super.key});
  @override
  State<EventCreation> createState() => _EventCreationScreenState();
}
class _EventCreationScreenState extends State<EventCreation> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _maxCapacityController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _ageRatingController = TextEditingController();
  DateTime? _startDateTime;
  DateTime? _endDateTIme;
  
}