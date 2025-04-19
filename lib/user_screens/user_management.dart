import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  String _selectedRole = 'All'; // Default to 'All'
  late Stream<QuerySnapshot> _userStream;

  @override
  void initState() {
    super.initState();
    _updateUserStream(); // Update the stream based on selected role
  }

  void _updateUserStream() {
    if (_selectedRole == 'All') {
      
      _userStream = FirebaseFirestore.instance.collection('employees').snapshots();
    } else if (_selectedRole == 'Employee') {
      _userStream = FirebaseFirestore.instance.collection('employees').snapshots();
    } else if (_selectedRole == 'Attendee') {
      _userStream = FirebaseFirestore.instance.collection('attendees').snapshots();
    } else if (_selectedRole == 'Admin') {
      _userStream = FirebaseFirestore.instance.collection('admins').snapshots();
    } else if (_selectedRole == 'Client') {
      _userStream = FirebaseFirestore.instance.collection('clients').snapshots();
    }
  }
  Widget _buildFilterDropdown() {
    return DropdownButton<String>(
      value: _selectedRole,
      onChanged: (value) {
        setState(() {
          _selectedRole = value!;
          _updateUserStream();
        });
      },
      items: ['All', 'Employee', 'Attendee', 'Admin', 'Client']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
  Widget _buildUserList(List<QueryDocumentSnapshot> users) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        var user = users[index].data() as Map<String, dynamic>;
        return Card(
          child: ListTile(
            title: Text(user['name']),
            subtitle: Text('Role: ${user['role']}'),
            trailing: _selectedRole == 'Employee'
                ? Column(
                    children: [
                      Text('Salary: ${user['salary']}'),
                      Text('Schedule: ${user['schedule'].join(', ')}'),
                    ],
                  )
                : _selectedRole == 'Client'
                    ? Column(
                        children: [
                          Text('Email: ${user['email']}'),
                        ],
                      )
                    : const SizedBox.shrink(), // Only show for Employees and Clients
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Role Management")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildFilterDropdown(),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _userStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong.'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No users found.'));
                  }

                  return _buildUserList(snapshot.data!.docs);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
