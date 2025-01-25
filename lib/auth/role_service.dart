// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class RoleService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // Fetches the user's role from Firestore
//   Future<String?> getUserRole() async {
//     final user = _auth.currentUser;
//     if (user == null) return null;

//     try {
//       // Check in 'users' collection
//       final userDoc = await _firestore.collection('users').doc(user.uid).get();
//       if (userDoc.exists) {
//         return 'user';
//       }

//       // Check in 'admins' collection
//       final adminDoc = await _firestore.collection('admins').doc(user.uid).get();
//       if (adminDoc.exists) {
//         return 'admin';
//       }

//       return null; // No role found
//     } catch (e) {
//       print("Error fetching role: $e");
//       return null;
//     }
//   }

//   // Checks if the user is an admin
//   Future<bool> isAdmin() async {
//     final role = await getUserRole();
//     return role == 'admin';
//   }

//   // Checks if the user is a regular user
//   Future<bool> isUser() async {
//     final role = await getUserRole();
//     return role == 'user';
//   }
// }
