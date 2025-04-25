import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  String? _selectedEventId;
  String? _selectedEventName;
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  List<String> _eventIds = [];
  List<String> _eventNames = [];

  @override
  void initState() {
    super.initState();
    _loadUserEvents();
  }

  Future<void> _loadUserEvents() async {
    final user = auth.currentUser;
    if (user == null) return;

    final attendeeSnap = await firestore
        .collection("users")
        .doc("Attendee")
        .collection("attendees")
        .where("email", isEqualTo: user.email)
        .limit(1)
        .get();

    if (attendeeSnap.docs.isEmpty) return;

    final events = <String, String>{};

    final eventsSnapshot = await firestore.collection("events").get();
    for (final eventDoc in eventsSnapshot.docs) {
      final ticketsSnap = await eventDoc.reference.collection("tickets").get();
      for (final ticketDoc in ticketsSnap.docs) {
        final ticketData = ticketDoc.data();
        if (ticketData["buyerID"] == user.email) {
          final eventTitle = eventDoc.data()["Title"]?.toString() ?? "Untitled Event";
          events[eventDoc.id] = eventTitle;
          break;
        }
      }
    }

    setState(() {
      _eventIds = events.keys.toList();
      _eventNames = events.values.toList();
    });
  }

  Future<void> _submitFeedback() async {
    final user = auth.currentUser;
    if (user == null || _selectedEventId == null || _selectedEventName == null) return;

    final attendeeSnap = await firestore
        .collection("users")
        .doc("Attendee")
        .collection("attendees")
        .where("email", isEqualTo: user.email)
        .limit(1)
        .get();

    if (attendeeSnap.docs.isEmpty) return;

    final userData = attendeeSnap.docs.first.data();
    final reportId = "$_selectedEventId, $_selectedEventName";

    final feedbackSnap = await firestore
        .collection("report")
        .doc(reportId)
        .collection("feedback")
        .where("email", isEqualTo: user.email)
        .limit(1)
        .get();

    if (feedbackSnap.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You have already submitted feedback for this event.")),
      );
      return;
    }

    await firestore.collection("report").doc(reportId).collection("feedback").add({
      "email": user.email,
      "firstName": userData["firstName"],
      "lastName": userData["lastName"],
      "number": userData["number"],
      "rating": _rating,
      "feedback": _commentController.text.trim(),
      "submittedAt": Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Thank you for your feedback, it means a lot!")),
    );

    setState(() {
      _selectedEventId = null;
      _selectedEventName = null;
      _rating = 0;
      _commentController.clear();
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '🎤 Event Feedback',
          style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.deepPurple),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade50, Colors.purple.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              const SizedBox(height: 80),
              const Text(
                "Select Event:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
              const SizedBox(height: 8),
              DropdownButton<String>(
                isExpanded: true,
                value: _selectedEventId,
                hint: const Text("Choose an event"),
                items: List.generate(_eventIds.length, (index) {
                  return DropdownMenuItem(
                    value: _eventIds[index],
                    child: Text(_eventNames[index]),
                  );
                }),
                onChanged: (value) {
                  final index = _eventIds.indexOf(value!);
                  setState(() {
                    _selectedEventId = value;
                    _selectedEventName = _eventNames[index];
                  });
                },
              ),
              const SizedBox(height: 20),
              const Text(
                "Rate the Event (1-10):",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: List.generate(10, (index) {
                  final ratingValue = index + 1;
                  return GestureDetector(
                    onTap: () => setState(() => _rating = ratingValue),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: _rating >= ratingValue ? Colors.deepPurple : Colors.grey.shade300,
                      child: Text(
                        '$ratingValue',
                        style: TextStyle(
                          color: _rating >= ratingValue ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              const Text(
                "Leave a Comment:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _commentController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Share your experience...",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _submitFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text(
                    "Submit Feedback",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
