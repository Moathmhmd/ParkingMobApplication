import 'package:flutter/material.dart';
import 'admin_add_parking_page.dart'; // Ensure correct import path
import 'admin_edit_parking_page.dart'; // Ensure correct import path for the edit page

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Page",
            style: TextStyle(color: Color.fromARGB(255, 55, 128, 255))),
        backgroundColor: const Color.fromARGB(0, 33, 149, 243),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 20,
                ),
                textStyle: const TextStyle(fontSize: 20),
              ),
              child: const Text("Add Parking Lot"),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 20,
                ),
                textStyle: const TextStyle(fontSize: 20),
              ),
              child: const Text("Edit Parking Lot"),
            ),
          ],
        ),
      ),
    );
  }
}
