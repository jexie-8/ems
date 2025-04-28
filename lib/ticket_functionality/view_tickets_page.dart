import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewTicketsPage extends StatefulWidget {
  final String eventId;

  const ViewTicketsPage({super.key, required this.eventId});

  @override
  State<ViewTicketsPage> createState() => _ViewTicketsPageState();
}

class _ViewTicketsPageState extends State<ViewTicketsPage> {
  Map<String, bool> _selectedTickets = {};
  List<QueryDocumentSnapshot> _allTickets = [];

  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  String? _sortColumn;
  bool _isAscending = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .collection('tickets')
        .get();

    setState(() {
      _allTickets = snapshot.docs.where((doc) => doc.id != "_init").toList();
      _loading = false;
    });
  }

  void _deleteSelectedTickets() async {
    final selectedIds = _selectedTickets.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    for (final ticketId in selectedIds) {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('tickets')
          .doc(ticketId)
          .delete();
    }

    setState(() {
      _allTickets.removeWhere((doc) => selectedIds.contains(doc.id));
      _selectedTickets.clear();
    });
  }

  void _sortTickets(String column) {
    setState(() {
      if (_sortColumn == column) {
        _isAscending = !_isAscending;
      } else {
        _sortColumn = column;
        _isAscending = true;
      }

      _allTickets.sort((a, b) {
        final aData = a.data() as Map<String, dynamic>;
        final bData = b.data() as Map<String, dynamic>;

        final aValue = aData[column];
        final bValue = bData[column];

        if (aValue == null) return _isAscending ? -1 : 1;
        if (bValue == null) return _isAscending ? 1 : -1;

        if (aValue is num && bValue is num) {
          return _isAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
        } else {
          return _isAscending
              ? aValue.toString().compareTo(bValue.toString())
              : bValue.toString().compareTo(aValue.toString());
        }
      });
    });
  }

  int? _getColumnIndex(String? columnName) {
    switch (columnName) {
      case 'ticket_type':
        return 2;
      case 'ticket_status':
        return 3;
      case 'price':
        return 4;
      default:
        return null;
    }
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6E0F8),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 32, 19, 77),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _selectedTickets.containsValue(true)
                ? _deleteSelectedTickets
                : null,
          ),
        ],
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
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _allTickets.isEmpty
                  ? const Center(child: Text("No tickets found."))
                  : Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Scrollbar(
                          controller: _verticalScrollController,
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            controller: _verticalScrollController,
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              controller: _horizontalScrollController,
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columnSpacing: 24,
                                headingRowColor: MaterialStateColor.resolveWith(
                                  (states) => const Color(0xFFD6CCF0),
                                ),
                                headingTextStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                sortColumnIndex: _getColumnIndex(_sortColumn),
                                sortAscending: _isAscending,
                                columns: [
                                  const DataColumn(label: Text('Select')),
                                  const DataColumn(label: Text('Ticket ID')),
                                  DataColumn(
                                    label: const Text('Ticket Type'),
                                    onSort: (_, __) => _sortTickets('ticket_type'),
                                  ),
                                  DataColumn(
                                    label: const Text('Status'),
                                    onSort: (_, __) => _sortTickets('ticket_status'),
                                  ),
                                  DataColumn(
                                    label: const Text('Price'),
                                    numeric: true,
                                    onSort: (_, __) => _sortTickets('price'),
                                  ),
                                  const DataColumn(label: Text('Buyer')),
                                ],
                                rows: _allTickets.map((doc) {
                                  final data = doc.data() as Map<String, dynamic>;
                                  final ticketId = doc.id;

                                  return DataRow(
                                    selected: _selectedTickets[ticketId] ?? false,
                                    onSelectChanged: (bool? selected) {
                                      setState(() {
                                        _selectedTickets[ticketId] = selected ?? false;
                                      });
                                    },
                                    cells: [
                                      DataCell(Checkbox(
                                        value: _selectedTickets[ticketId] ?? false,
                                        onChanged: (bool? selected) {
                                          setState(() {
                                            _selectedTickets[ticketId] = selected ?? false;
                                          });
                                        },
                                      )),
                                      DataCell(Text(ticketId)),
                                      DataCell(Text(data['ticket_type'] ?? 'N/A')),
                                      DataCell(Text(data['ticket_status'] ?? 'N/A')),
                                      DataCell(Text(data['price']?.toString() ?? 'N/A')),
                                      DataCell(Text(data['buyerID'] ?? 'N/A')),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
        ],
      ),
    );
  }
}
