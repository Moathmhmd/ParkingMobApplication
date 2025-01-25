import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'admin_add_parking_page.dart'; // Ensure correct import path
import 'admin_edit_parking_page.dart'; // Ensure correct import path for the edit page
import 'admin_reservations_page.dart'; // Ensure correct import path for the reservations page

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

void signUserOut(BuildContext context) {
  FirebaseAuth.instance.signOut();
  Navigator.pushReplacementNamed(
      context, '/auth'); // Redirect to on boarding after sign-out
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Page",
            style: TextStyle(
                color: Colors.lightBlueAccent, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(0, 33, 149, 243),
        actions: [
          IconButton(
            onPressed: () => signUserOut(context),
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Button to Add Parking Lot
            ElevatedButton(
              onPressed: () {
                // Navigate to AdminAddParkingPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminAddParking(), // Remove const
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                        padding: 
                          const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                        backgroundColor: Colors.lightBlue,
                      ),
              child: const Text("  Add Parking Lot  ",
              style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),),
            ),
            const SizedBox(height: 30), // Space between buttons
            // Button to Edit Parking Lot
            ElevatedButton(
              onPressed: () {
                // Navigate to AdminEditParkingPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminEditParking(), // Remove const
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                        padding: 
                          const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                        backgroundColor: Colors.lightBlue,
                      ),
              child: const Text("  Edit Parking Lot  ",
              style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  
            ),
            const SizedBox(height: 30), // Space between buttons
            // Button to View Reservations
            ElevatedButton(
              onPressed: () {
                // Navigate to AdminReservationsPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminReservationsPage(), // Add navigation
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                        padding: 
                          const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                        backgroundColor: Colors.lightBlue,
                      ),
              child: const Text("View Reservations",
              style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
