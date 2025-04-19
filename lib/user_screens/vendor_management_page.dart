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

  @override
  void initState() {
    super.initState();
    fetchAllVendors();
  }

  Future<void> fetchAllVendors() async {
    final vendorManagersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc('employees')
        .collection('vendor_manager')
        .get();

    Map<String, List<Map<String, dynamic>>> eventVendorMap = {};

    for (var managerDoc in vendorManagersSnapshot.docs) {
      final vendorsSnapshot =
          await managerDoc.reference.collection('vendors').get();

      for (var vendorDoc in vendorsSnapshot.docs) {
        final vendorData = vendorDoc.data();
        final eventTitle = vendorData['event_title'] ?? 'Unknown Event';

        final fullData = {
          ...vendorData,
          'ref': vendorDoc.reference,
          'manager_id': managerDoc.id,
        };

        eventVendorMap.putIfAbsent(eventTitle, () => []).add(fullData);
      }
    }

    setState(() {
      groupedVendors = eventVendorMap;
    });
  }

  void _openForm({
    String? managerId,
    DocumentReference? ref,
    Map<String, dynamic>? data,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VendorFormPage(
          vendorManagerId: managerId ?? '',
          vendorRef: ref,
          vendorData: data,
        ),
      ),
    );
    fetchAllVendors(); // Refresh list after form
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vendor Management"),
        backgroundColor: Colors.deepPurple,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
        onPressed: () {
          if (groupedVendors.isNotEmpty) {
            final firstGroup = groupedVendors.entries.first.value;
            _openForm(managerId: firstGroup.first['manager_id']);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No vendor managers available.")),
            );
          }
        },
      ),
      body: groupedVendors.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: groupedVendors.entries.map((entry) {
                final eventTitle = entry.key;
                final vendors = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text(
                        eventTitle,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                    ...vendors.map((vendor) => Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${vendor['first_name']} ${vendor['last_name']}',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.deepPurple),
                                        onPressed: () {
                                          _openForm(
                                            managerId: vendor['manager_id'],
                                            ref: vendor['ref'],
                                            data: vendor,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  Text('Type: ${vendor['type']}'),
                                  Text('Phone: ${vendor['phone_num']}'),
                                  Text('Cost: ${vendor['cost']} EGP'),
                                  Text(
                                      'Contract: ${vendor['contract_details']}'),
                                  Text('Availability: ${vendor['availability']}'),
                                  Text(
                                      'Payment Status: ${vendor['payment_status']}'),
                                ],
                              ),
                            ),
                          ),
                        )),
                  ],
                );
              }).toList(),
            ),
    );
  }
}
