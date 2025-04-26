import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'vendor_form_page.dart';

class VendorManagementPage extends StatefulWidget {
  const VendorManagementPage({super.key});

  @override
  State<VendorManagementPage> createState() => _VendorManagementPageState();
}

class _VendorManagementPageState extends State<VendorManagementPage> {
  Map<String, List<Map<String, dynamic>>> groupedVendors = {};
  Map<String, String> eventIds = {};
  Set<String> expandedEvents = {};

  @override
  void initState() {
    super.initState();
    fetchAllEventsAndVendors();
  }

  Future<void> fetchAllEventsAndVendors() async {
    final eventsSnapshot = await FirebaseFirestore.instance.collection('events').get();
    Map<String, List<Map<String, dynamic>>> vendorMap = {};
    Map<String, String> idMap = {};

    for (var eventDoc in eventsSnapshot.docs) {
      final eventId = eventDoc.id;
      final eventTitle = eventDoc['Title'] ?? 'Untitled Event';

      idMap[eventTitle] = eventId;

      final vendorsSnapshot = await eventDoc.reference.collection('vendors').get();
      final vendorDocs = vendorsSnapshot.docs.where((doc) => doc.id != '_init');

      final vendors = vendorDocs.map((v) => {
        ...v.data(),
        'ref': v.reference,
        'event_id': eventId,
        'event_title': eventTitle,
      }).toList();

      vendorMap[eventTitle] = vendors;
    }

    setState(() {
      groupedVendors = vendorMap;
      eventIds = idMap;
    });
  }

  void _openForm({
    DocumentReference? ref,
    Map<String, dynamic>? data,
    required String eventTitle,
    required String eventId,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VendorFormPage(
          vendorRef: ref,
          vendorData: data,
          eventTitle: eventTitle,
          eventId: eventId,
        ),
      ),
    );
    fetchAllEventsAndVendors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6E0F8),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 32, 19, 77),
        elevation: 0,
        centerTitle: true,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.purpleAccent, Colors.white],
          ).createShader(bounds),
          child: const Text(
            'Vendor Management',
            style: TextStyle(
              fontSize: 26,
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
          // Background decorative circles
          Positioned(
            top: -80,
            left: -60,
            child: Container(
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
          // Main content
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: eventIds.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    children: eventIds.entries.map((entry) {
                      final eventTitle = entry.key;
                      final eventId = entry.value;
                      final vendors = groupedVendors[eventTitle] ?? [];
                      final isExpanded = expandedEvents.contains(eventTitle);

                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 6,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                eventTitle,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 32, 19, 77),
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                                    onPressed: () {
                                      _openForm(eventTitle: eventTitle, eventId: eventId);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                      color: Colors.deepPurple,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (isExpanded) {
                                          expandedEvents.remove(eventTitle);
                                        } else {
                                          expandedEvents.add(eventTitle);
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            if (isExpanded)
                              vendors.isEmpty
                                  ? const Padding(
                                      padding: EdgeInsets.only(bottom: 16),
                                      child: Text("No vendors yet."),
                                    )
                                  : Column(
                                      children: vendors.map((vendor) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          child: Card(
                                            color: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                            elevation: 2,
                                            child: ListTile(
                                              title: Text(
                                                vendor['vendor_name'] ?? 'Unnamed',
                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              subtitle: Padding(
                                                padding: const EdgeInsets.only(top: 8),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('Type: ${vendor['type']}'),
                                                    Text('Phone: ${vendor['phone_num']}'),
                                                    Text('Cost: ${vendor['cost']} EGP'),
                                                    Text('Contract: ${vendor['contract_details']}'),
                                                    Text('Availability: ${vendor['availability']}'),
                                                    Text('Payment Status: ${vendor['payment_status']}'),
                                                  ],
                                                ),
                                              ),
                                              onTap: () {
                                                _openForm(
                                                  ref: vendor['ref'],
                                                  data: vendor,
                                                  eventTitle: eventTitle,
                                                  eventId: eventId,
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
