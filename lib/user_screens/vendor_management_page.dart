import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'vendor_form_page.dart';

class VendorManagementPage extends StatefulWidget {
  const VendorManagementPage({super.key});

  @override
  State<VendorManagementPage> createState() => _VendorManagementPageState();
}

class _VendorManagementPageState extends State<VendorManagementPage> {
  Map<String, List<Map<String, dynamic>>> groupedVendors = {}; // key: eventTitle
  Map<String, String> eventIds = {}; // key: eventTitle -> eventId
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
      appBar: AppBar(
        title: const Text("Vendor Management"),
        backgroundColor: Colors.deepPurple,
      ),
      body: eventIds.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: eventIds.entries.map((entry) {
                final eventTitle = entry.key;
                final eventId = entry.value;
                final vendors = groupedVendors[eventTitle] ?? [];
                final isExpanded = expandedEvents.contains(eventTitle);

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          eventTitle,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.green),
                              onPressed: () {
                                _openForm(
                                  eventTitle: eventTitle,
                                  eventId: eventId,
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
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
                        (vendors.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: Text("No vendors yet."),
                              )
                            : Column(
                                children: vendors.map((vendor) => Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      child: Card(
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: ListTile(
                                          title: Text(
                                            vendor['vendor_name'] ?? 'Unnamed',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Column(
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
                                    )).toList(),
                              ))
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}
