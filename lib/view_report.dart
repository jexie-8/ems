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
      backgroundColor: const Color(0xFFE6E0F8),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 32, 19, 77),
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.purpleAccent, Colors.white],
          ).createShader(bounds),
          child: const Text(
            'N.O.H.A',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -80,
            left: -60,
            child: AnimatedContainer(
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.purpleAccent.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          reportId == null
              ? const Center(child: CircularProgressIndicator())
              : Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "📝 Feedback",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 32, 19, 77),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Expanded(child: FeedbackListWidget(reportId: reportId!)),
                          ],
                        ),
                      ),
                    ),
                    const VerticalDivider(width: 1, color: Colors.grey),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "💳 Payments",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 32, 19, 77),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Expanded(child: PaymentsListWidget(reportId: reportId!)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}

class FeedbackListWidget extends StatelessWidget {
  final String reportId;
  const FeedbackListWidget({super.key, required this.reportId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("report")
          .doc(reportId)
          .collection("feedback")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final feedbackDocs = snapshot.data!.docs.where((doc) => doc.id != '_init').toList();

        if (feedbackDocs.isEmpty) {
          return const Center(child: Text("No feedback found."));
        }

        return ListView.builder(
          itemCount: feedbackDocs.length,
          itemBuilder: (context, index) {
            final data = feedbackDocs[index].data() as Map<String, dynamic>;
            return Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.symmetric(vertical: 8),
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
  const PaymentsListWidget({super.key, required this.reportId});

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

        final payments = snapshot.data?.docs.where((doc) => doc.id != '_init').toList();

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
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.symmetric(vertical: 8),
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
