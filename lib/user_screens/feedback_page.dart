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
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final snapshot = await firestore.collection('events').get();
    setState(() {
      _eventIds = snapshot.docs.map((doc) => doc.id as String).toList();
_eventNames = snapshot.docs
    .map((doc) => doc.data()['Title']?.toString() ?? 'Untitled Event')
    .toList();

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

  await firestore
      .collection("report")
      .doc(reportId)
      .collection("feedback")
      .add({
        "email": user.email,
        "firstName": userData["firstName"],
        "lastName": userData["lastName"],
        "number": userData["number"],
        "rating": _rating,
        "feedback": _commentController.text.trim(),
        "submittedAt": Timestamp.now(),
      });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Thank you for your FeedBack, it means a lot!")),
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
      appBar: AppBar(title: const Text("Submit Feedback")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Event:", style: TextStyle(fontWeight: FontWeight.bold)),
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
            const Text("Rate this event (1-10):", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 4,
              children: List.generate(10, (index) {
                final starIndex = index + 1;
                return GestureDetector(
                  onTap: () => setState(() => _rating = starIndex),
                  child: Icon(
                    Icons.star,
                    color: _rating >= starIndex ? Colors.amber : Colors.grey,
                    size: 30,
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            const Text("Leave a comment (optional):", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "What did you think about the event?",
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _submitFeedback,
                child: const Text("Submit Feedback"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
