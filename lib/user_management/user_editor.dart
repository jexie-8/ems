import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
const Map<String, List<String>> roleCollections = {
    'Admin': ['admins', 'admin_users'],
    'Attendee': ['Attendee', 'attendees'],
    'Event_Manager': ['employees', 'event_manager'],
    'Tickets_Registration': ['employees', 'ticketeers'],
    'Vendor_Manager': ['employees', 'vendor_manager'],
  };
class UserViewScreen extends StatefulWidget {
  const UserViewScreen({super.key});
  
  @override
  State<UserViewScreen> createState() => _UserViewScreenState();
}


class _UserViewScreenState extends State<UserViewScreen> {
  String _selectedRole = "All";
  String? _currentUserRole;

  final List<String> _allRoles = [
    'All',
    'Admin',
    'Attendee',
    'Event_Manager',
    'Tickets_Registration',
    'Vendor_Manager',
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentUserRole();
  }
void _showEditDialog(BuildContext context, Map<String, dynamic> user) {
  final firstNameController = TextEditingController(text: user["firstName"]);
  final lastNameController = TextEditingController(text: user["lastName"]);
  final numberController = TextEditingController(text: user["number"] ?? "");
  String selectedRole = user["role"];

  

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Edit User"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(labelText: "First Name"),
            ),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(labelText: "Last Name"),
            ),
            TextField(
              controller: numberController,
              decoration: const InputDecoration(labelText: "Phone Number"),
            ),
            DropdownButtonFormField<String>(
              value: selectedRole,
              items: roleCollections.keys.map((role) {
                return DropdownMenuItem(value: role, child: Text(role));
              }).toList(),
              onChanged: (value) {
                if (value != null) selectedRole = value;
              },
              decoration: const InputDecoration(labelText: "Role"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () async {
            final newDocId =
                "${firstNameController.text.trim()},${lastNameController.text.trim()}_${DateTime.now().millisecondsSinceEpoch}";

            final userData = {
              "firstName": firstNameController.text.trim(),
              "lastName": lastNameController.text.trim(),
              "email": user["email"],
              "number": numberController.text.trim(),
            };

            if (selectedRole != "Admin" &&
                selectedRole != "Event_Manager" &&
                selectedRole != "Attendee") {
              userData["supervisor_ID"] = user["supervisor_ID"] ?? "";
            }

            // Delete old doc
            await user["ref"].delete();

            // Add to new path
            final newPath = roleCollections[selectedRole]!;
            await FirebaseFirestore.instance
                .collection("users")
                .doc(newPath[0])
                .collection(newPath[1])
                .doc(newDocId)
                .set(userData);

            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("User updated and moved")),
            );

            setState(() {}); // Refresh screen
          },
          child: const Text("Save"),
        ),
      ],
    ),
  );
}


  Future<void> _getCurrentUserRole() async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;

    final rolePaths = [
      ['admins', 'admin_users'],
      ['Attendee', 'attendees'],
      ['employees', 'event_manager'],
      ['employees', 'ticketeeers'],
      ['employees', 'vendor_manager'],
    ];

    for (var path in rolePaths) {
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(path[0])
          .collection(path[1])
          .where("email", isEqualTo: email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() => _currentUserRole = path[1]);
        return;
      }
    }
  }
  void _showCreateDialog(BuildContext context) {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _numberController = TextEditingController();
  final _supervisorIDController = TextEditingController();
  String _selectedRole = "Attendee";

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final isEmployee =
              roleCollections[_selectedRole]![0] == "Employee" && _selectedRole != "Event_Manager";

          return AlertDialog(
            title: const Text("Create New User"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(labelText: "First Name"),
                  ),
                  TextField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: "Last Name"),
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                  ),
                  TextField(
                    controller: _numberController,
                    decoration: const InputDecoration(labelText: "Phone Number"),
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: const InputDecoration(labelText: "Role"),
                    isExpanded: true,
                    items: _allRoles
                        .where((r) => !(_currentUserRole == 'Event_Manager' && r == 'Admin'))
                        .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedRole = val);
                    },
                  ),
                  if (isEmployee)
                    TextField(
                      controller: _supervisorIDController,
                      decoration: const InputDecoration(labelText: "Supervisor ID"),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final firstName = _firstNameController.text.trim();
                  final lastName = _lastNameController.text.trim();
                  final email = _emailController.text.trim();
                  final number = _numberController.text.trim();
                  final supervisorID = _supervisorIDController.text.trim();

                  if (firstName.isEmpty || lastName.isEmpty || email.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please fill required fields")),
                    );
                    return;
                  }
try {
    // ✅ Step 1: Create Firebase Auth account
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: "12344321", // 🔐 Replace with your logic (default or generated)
    );
  }on FirebaseAuthException catch (e) {
    Navigator.pop(context); // Close dialog if error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Auth Error: ${e.message}")),
    );
    return;
  }
                  final docId = "$firstName,$lastName${DateTime.now().millisecondsSinceEpoch}";
                  final path = roleCollections[_selectedRole]!;

                  final userData = {
                    "firstName": firstName,
                    "lastName": lastName,
                    "email": email,
                    "number": number,
                    "role": _selectedRole,
                  };

                  if (isEmployee) {
                    userData["supervisor_ID"] = supervisorID;
                  }

                  await FirebaseFirestore.instance
                      .collection("users")
                      .doc(path[0])
                      .collection(path[1])
                      .doc(docId)
                      .set(userData);
if (_selectedRole == "Vendor_Manager") {
  await FirebaseFirestore.instance
      .collection("users")
      .doc("employees")
      .collection("vendor_manager")
      .doc(docId)
      .collection("vendors")
      .doc("_init")
      .set({
        "initialized": true,
        "createdAt": FieldValue.serverTimestamp(),
      });
}
                  Navigator.pop(context); // close dialog
                  setState(() {}); // refresh screen
                  setState(() {});
                },
                child: const Text("Create"),
              ),
            ],
          );
        },
      );
    },
  );
}


  Future<List<Map<String, dynamic>>> _fetchAllUsers() async {
    final List<Map<String, dynamic>> users = [];

    final roleCollections = {
    'Admin': ['admins', 'admin_users'],
    'Attendee': ['Attendee', 'attendees'],
    'Event_Manager': ['employees', 'event_manager'],
    'Tickets_Registration': ['employees', 'ticketeers'],
    'Vendor_Manager': ['employees', 'Vendor_Manager'],
    };

    for (var role in roleCollections.entries) {
      if (_currentUserRole == 'Event_Manager' && role.key == 'Admin') continue;
      if (_selectedRole != 'All' && _selectedRole != role.key) continue;
      if (_selectedRole == 'All' && role.key == 'Attendee') continue; // 👈 hide Attendees unless selected

      final path = role.value;
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(path[0])
          .collection(path[1])
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        data['role'] = role.key;
        data['ref'] = doc.reference;
        users.add(data);
      }
    }

    return users;
  }

  void _confirmDelete(BuildContext context, DocumentReference ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete User"),
        content: const Text("Are you sure you want to delete this user?"),
        actions: [
         TextButton(
          onPressed: () {
             Navigator.of(context, rootNavigator: true).pop(); // Only close the dialog
            },
              child: const Text("Cancel"),
           ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await ref.delete();
              Navigator.pop(context);
              setState(() {}); // Refresh
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Users"),
        actions: [
          DropdownButton<String>(
            value: _selectedRole,
            dropdownColor: const Color.fromARGB(255, 211, 210, 210),
            items: _allRoles
                .where((r) => !(_currentUserRole == 'Event_Manager' && r == 'Admin'))
                .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                .toList(),
            onChanged: (value) => setState(() => _selectedRole = value ?? "All"),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchAllUsers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final users = snapshot.data!;
          if (users.isEmpty) return const Center(child: Text("No users found."));

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text("Name")),
                DataColumn(label: Text("Email")),
                DataColumn(label: Text("Role")),
                DataColumn(label: Text("Phone Number")),
                DataColumn(label: Text("Actions")),
              ],
              rows: users.map((user) {
                return DataRow(cells: [
                  DataCell(SelectableText("${user["firstName"]} ${user["lastName"]}")),
                  DataCell(SelectableText(user["email"] ?? "")),
                  DataCell(SelectableText(user["role"])),
                  DataCell(SelectableText(user["number"] ?? "")),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                         _showEditDialog(context, user); // Optional: implement this
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, user['ref']),
                      ),
                    ],
                  )),
                ]);
              }).toList(),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
  onPressed: () => _showCreateDialog(context),
  icon: const Icon(Icons.add),
  label: const Text("Create User"),
  backgroundColor: Colors.purple,
),
    );
  }
}
