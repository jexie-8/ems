import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportPage extends StatefulWidget {
  final String eventId;

  const ReportPage({super.key, required this.eventId});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String? reportId;

  @override
  void initState() {
    super.initState();
    fetchReportId();
  }

  Future<void> fetchReportId() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("report")
        .where("eventId", isEqualTo: widget.eventId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        reportId = snapshot.docs.first.id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Event Report")),
      body: reportId == null
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // Feedback Section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        const Text("Feedback", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Expanded(child: FeedbackListWidget(reportId: reportId!)),
                      ],
                    ),
                  ),
                ),
                const VerticalDivider(width: 1),
                // Payments Section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        const Text("Payments", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Expanded(child: PaymentsListWidget(reportId: reportId!)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class FeedbackListWidget extends StatelessWidget {
  final String reportId;
  const FeedbackListWidget({Key? key, required this.reportId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("report")
          .doc(reportId)
          .collection("feedback")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final feedbackDocs = snapshot.data!.docs
            .where((doc) => doc.id != '_init')
            .toList();

        if (feedbackDocs.isEmpty) {
          return const Center(child: Text("No feedback found."));
        }

        return ListView.builder(
          itemCount: feedbackDocs.length,
          itemBuilder: (context, index) {
            final data = feedbackDocs[index].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text("${data["firstName"]} ${data["lastName"]}"),
                subtitle: Text(data["feedback"] ?? "No comment"),
                trailing: Text("⭐ ${data["rating"] ?? 'N/A'}"),
              ),
            );
          },
        );
      },
    );
  }
}

class PaymentsListWidget extends StatelessWidget {
  final String reportId;
  const PaymentsListWidget({Key? key, required this.reportId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('report')
          .doc(reportId)
          .collection('payments')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final payments = snapshot.data?.docs
            .where((doc) => doc.id != '_init')
            .toList();

        if (payments == null || payments.isEmpty) {
          return const Center(child: Text("No payments found."));
        }

        return ListView.builder(
          itemCount: payments.length,
          itemBuilder: (context, index) {
            final payment = payments[index].data() as Map<String, dynamic>;
            final email = payment['user_email'] ?? 'Unknown';
            final amount = payment['amount'] ?? 0;

            final ticketList = payment['ticket_bought'];
            final List<Map<String, dynamic>> tickets =
                (ticketList is List)
                    ? List<Map<String, dynamic>>.from(ticketList)
                    : [];

            final ticketSummary = tickets.isEmpty
                ? 'No tickets'
                : tickets.map((t) => "${t['type']} x ${t['quantity']}").join(', ');

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: ListTile(
                title: Text(email),
                subtitle: Text(ticketSummary),
                trailing: Text("$amount EGP"),
              ),
            );
          },
        );
      },
    );
  }
}