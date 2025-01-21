import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({Key? key}) : super(key: key);

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  String userName = "User";
  String userEmail = "No Email";
  String userPhone = "No Phone Number";

  bool isEditingName = false;
  bool isEditingPhone = false;
  bool isEditingEmail = false;
  bool isEditingPassword = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final doc =
            await _firestore.collection('users').doc(currentUser.uid).get();
        if (doc.exists) {
          setState(() {
            userName = doc['name'] ?? "User";
            userEmail = doc['email'] ?? "No Email";
            userPhone = doc['phoneNumber'] ?? "No Phone Number";
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  Future<void> _updateName(String newName) async {
    if (newName.isEmpty) {
      _showError("Username cannot be empty.");
      return;
    }

    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .update({'name': newName});
        setState(() {
          userName = newName;
          isEditingName = false;
        });
      }
    } catch (e) {
      debugPrint('Error updating name: $e');
    }
  }

  Future<void> _updatePhone(String newPhone) async {
    if (newPhone.length != 10 || int.tryParse(newPhone) == null) {
      _showError("Phone number must be 10 digits.");
      return;
    }

    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final formattedPhone = '+1$newPhone'; // Add country code
        await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .update({'phoneNumber': formattedPhone});
        setState(() {
          userPhone = formattedPhone;
          isEditingPhone = false;
        });
      }
    } catch (e) {
      debugPrint('Error updating phone: $e');
    }
  }

  Future<void> _updateEmail(String newEmail) async {
    if (!RegExp(r"^[a-zA-Z0-9._]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(newEmail)) {
      _showError("Invalid email format.");
      return;
    }

    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await currentUser.updateEmail(newEmail);
        await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .update({'email': newEmail});
        setState(() {
          userEmail = newEmail;
          isEditingEmail = false;
        });
      }
    } catch (e) {
      debugPrint('Error updating email: $e');
    }
  }

  Future<void> _resetPassword(String oldPassword, String newPassword) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final credential = EmailAuthProvider.credential(
          email: currentUser.email!,
          password: oldPassword,
        );

        await currentUser.reauthenticateWithCredential(credential);
        await currentUser.updatePassword(newPassword);

        setState(() {
          isEditingPassword = false;
          oldPasswordController.clear();
          newPasswordController.clear();
        });
      }
    } catch (e) {
      _showError("Old password is incorrect.");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _signOut() {
    _auth.signOut();
    Navigator.pushReplacementNamed(context, '/auth');
  }

  Widget _buildEditSection({
    required String title,
    required bool isEditing,
    required TextEditingController controller,
    required VoidCallback onEdit,
    required Function(String) onSave,
    required VoidCallback onCancel,
    String labelText = '',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (isEditing)
          Column(
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: labelText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => onSave(controller.text.trim()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.lightBlue,
                    ),
                    child: const Text('Save'),
                  ),
                  ElevatedButton(
                    onPressed: onCancel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(controller.text.isEmpty ? "No data" : controller.text),
              IconButton( icon: Icon(Icons.settings),
                onPressed: onEdit,
              ),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.lightBlue),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  
                  IconButton(
                      onPressed: () => _signOut(),
                      icon: const Icon(Icons.logout, color: Colors.redAccent),
                      tooltip: 'Sign Out',
                    ),
                  ],
                ), 
                const Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage('assets/profile.png'),
                  ),
                ),
                const SizedBox(height: 20),
                _buildEditSection(
                  title: "Username",
                  isEditing: isEditingName,
                  controller: nameController..text = userName,
                  onEdit: () => setState(() => isEditingName = true),
                  onSave: _updateName,
                  onCancel: () => setState(() => isEditingName = false),
                  labelText: "New Username",
                ),
                const SizedBox(height: 20),
                _buildEditSection(
                  title: "Email",
                  isEditing: isEditingEmail,
                  controller: emailController..text = userEmail,
                  onEdit: () => setState(() => isEditingEmail = true),
                  onSave: _updateEmail,
                  onCancel: () => setState(() => isEditingEmail = false),
                  labelText: "New Email",
                ),
                const SizedBox(height: 20),
                _buildEditSection(
                  title: "Phone Number",
                  isEditing: isEditingPhone,
                  controller: phoneController..text = userPhone,
                  onEdit: () => setState(() => isEditingPhone = true),
                  onSave: _updatePhone,
                  onCancel: () => setState(() => isEditingPhone = false),
                  labelText: "New Phone Number",
                ),
                const SizedBox(height: 20),
                if (isEditingPassword)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Change Password",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: oldPasswordController,
                        decoration: InputDecoration(
                          labelText: "Old Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: newPasswordController,
                        decoration: InputDecoration(
                          labelText: "New Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () => _resetPassword(
                              oldPasswordController.text.trim(),
                              newPasswordController.text.trim(),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blue,
                            ),
                            child: const Text("Save"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isEditingPassword = false;
                                oldPasswordController.clear();
                                newPasswordController.clear();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Cancel'),
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Change Password",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(icon: Icon(Icons.settings),
                        onPressed: () =>
                            setState(() => isEditingPassword = true),
                        
                      ),
                    ],
                  ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}
