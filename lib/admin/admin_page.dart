import 'package:flutter/material.dart';
import 'admin_add_parking_page.dart'; // Ensure correct import path

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
            style: TextStyle(color: Colors.blueAccent)),
        backgroundColor: const Color.fromARGB(0, 33, 149, 243),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to AdminAddParkingPage
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminAddParking(),
              ),
            );
          },
          child: const Text("Add Parking Lot"),
        ),
      ),
    );
  }
}
