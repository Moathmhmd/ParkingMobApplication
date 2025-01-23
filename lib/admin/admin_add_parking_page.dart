import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminAddParking extends StatefulWidget {
  const AdminAddParking({super.key});

  @override
  State<AdminAddParking> createState() => _AdminAddParkingState();
}

class _AdminAddParkingState extends State<AdminAddParking> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _parkingCollection =
      FirebaseFirestore.instance.collection('parkingSpots');

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  final TextEditingController _floorNumberController = TextEditingController();
  final TextEditingController _floorSlotsController = TextEditingController();
  final TextEditingController _floorPriceController =
      TextEditingController(); // Price per floor

  final List<Map<String, dynamic>> _floors = [];

  // Method to add a parking lot to Firestore
  void _addParkingLot() async {
    final String name = _nameController.text.trim();
    final String area = _areaController.text.trim();
    final double latitude = double.tryParse(_latitudeController.text) ?? 0.0;
    final double longitude = double.tryParse(_longitudeController.text) ?? 0.0;

    // Validate inputs
    if (name.isEmpty || area.isEmpty || _floors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields and add floors")),
      );
      return;
    }

    final int capacity = _floors.fold<int>(
        0, (sum, floor) => sum + (floor['slots'] as List).length);
    final int availableSpots = capacity;

    // Get the current user's ID
    final String ownerId = FirebaseAuth.instance.currentUser?.uid ?? "";

    final Map<String, dynamic> parkingLot = {
      'name': name,
      'area': area,
      'latitude': latitude,
      'longitude': longitude,
      'capacity': capacity,
      'availableSpots': availableSpots,
      'floors': _floors,
      'ownerId': ownerId, // Assign ownership
      'timestamp': '', 
    };

    try {
      // Add the new parking lot to Firestore with an automatically generated ID
      DocumentReference docRef = await _parkingCollection.add(parkingLot);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Parking lot added successfully!")),
      );
      _resetForm();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error")),
      );
    }
  }

  // Method to reset the form fields
  void _resetForm() {
    _nameController.clear();
    _areaController.clear();
    _latitudeController.clear();
    _longitudeController.clear();
    _floorNumberController.clear();
    _floorSlotsController.clear();
    _floorPriceController.clear(); // Reset price controller
    _floors.clear();
    setState(() {});
  }

  // Method to add a floor to the list
  void _addFloor() {
    final int floorNumber =
        int.tryParse(_floorNumberController.text.trim()) ?? 0;
    final int slotsCount = int.tryParse(_floorSlotsController.text.trim()) ?? 0;
    final double price =
        double.tryParse(_floorPriceController.text.trim()) ?? 0.0;

    if (floorNumber > 0 && slotsCount > 0) {
      final List<Map<String, dynamic>> slots = List.generate(
        slotsCount,
        (index) => {
          'name': '${String.fromCharCode(65 + floorNumber - 1)}${index + 1}',
          'isReserved': false,
          'reservationStartTime': '',
          'reservationEndTime': '',
          'reservedBy': '',
          'status': 'available',
        },
      );

      setState(() {
        _floors.add({
          'floorNumber': floorNumber,
          'price': price, // Use "price" instead of "hourlyRate"
          'slots': slots,
        });
      });

      // Clear the floor-specific inputs
      _floorNumberController.clear();
      _floorSlotsController.clear();
      _floorPriceController.clear(); // Reset price field
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid floor details.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Admin - Add Parking Lot",
          style:
              TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(0, 33, 149, 243),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration:
                    const InputDecoration(labelText: "Parking Lot Name"),
              ),
              TextField(
                controller: _areaController,
                decoration: const InputDecoration(labelText: "Area"),
              ),
              TextField(
                controller: _latitudeController,
                decoration: const InputDecoration(labelText: "Latitude"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _longitudeController,
                decoration: const InputDecoration(labelText: "Longitude"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text("Add Floor Details",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent)),
              ),
              TextField(
                controller: _floorNumberController,
                decoration: const InputDecoration(labelText: "Floor Number"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _floorSlotsController,
                decoration: const InputDecoration(labelText: "Number of Slots"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _floorPriceController,
                decoration:
                    const InputDecoration(labelText: "Price per Floor"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              Center(
                child: ElevatedButton(
                  onPressed: _addFloor,
                  child: const Text("Add Floor"),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  "Floors Added: ${_floors.length}",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _addParkingLot,
                  child: const Text("Add Parking Lot"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
