import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User _user;
  String? _userName;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _getUserDetails();
  }

  Future<void> _getUserDetails() async {
    _user = _auth.currentUser!;
    DocumentSnapshot userSnapshot =
        await _firestore.collection('User').doc(_user.uid).get();
    setState(() {
      _userName = userSnapshot['name'];
      _userEmail = userSnapshot['email'];
    });
  }

  Future<void> _updateUserProfile(String newName, String newEmail) async {
    await _firestore.collection('User').doc(_user.uid).update({
      'name': newName,
      'email': newEmail,
    });
    setState(() {
      _userName = newName;
      _userEmail = newEmail;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Color.fromARGB(255, 165, 182, 143),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              _showUpdateDialog();
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person),
                SizedBox(width: 10),
                Text(
                  _userName ?? 'Name',
                  style: TextStyle(fontSize: 18.0),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Row(
              children: [
                Icon(Icons.email),
                SizedBox(width: 10),
                Text(
                  _userEmail ?? 'Email',
                  style: TextStyle(fontSize: 18.0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateDialog() {
    String newName = '';
    String newEmail = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  newName = value;
                },
                decoration: InputDecoration(labelText: 'New Name'),
              ),
              SizedBox(height: 10.0),
              TextField(
                onChanged: (value) {
                  newEmail = value;
                },
                decoration: InputDecoration(labelText: 'New Email'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Update profile
                _updateUserProfile(newName, newEmail);
                Navigator.pop(context);
              },
              child: Text('Update'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
