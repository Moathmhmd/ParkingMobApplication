import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminEditParking extends StatefulWidget {
  const AdminEditParking({Key? key}) : super(key: key);

  @override
  State<AdminEditParking> createState() => _AdminEditParkingState();
}

class _AdminEditParkingState extends State<AdminEditParking> {
  final String adminId = FirebaseAuth.instance.currentUser!.uid;

  String? selectedParkingId;
  String? selectedFloorId;
  final TextEditingController _floorPriceController = TextEditingController();
  final TextEditingController _numSlotsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.lightBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Edit Parking Lots",
          style: TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown for Parking Lots
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('parkingSpots')
                  .where('ownerId', isEqualTo: adminId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No parking lots available."));
                }

                final parkingLots = snapshot.data!.docs;

                return DropdownButtonFormField<String>(
                  value: selectedParkingId,
                  hint: const Text("Choose a parking lot"),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  items: parkingLots.map((parkingDoc) {
                    return DropdownMenuItem<String>(
                      value: parkingDoc.id,
                      child: Text(parkingDoc['name'] ?? 'Unnamed Spot'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedParkingId = value;
                      selectedFloorId = null; // Reset selected floor
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 20),

            // Dropdown for Floors
            selectedParkingId == null
                ? const Center(
                    child: Text(
                      "Please select a parking lot to view floors.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('parkingSpots')
                        .doc(selectedParkingId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return const Center(child: Text("No floors found."));
                      }

                      final data = snapshot.data!.data() as Map<String, dynamic>;
                      final floors = List<Map<String, dynamic>>.from(data['floors'] ?? []);

                      return DropdownButtonFormField<String>(
                        value: selectedFloorId,
                        hint: const Text("Choose a floor"),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        items: floors.map((floor) {
                          return DropdownMenuItem<String>(
                            value: floor['floorNumber'].toString(),
                            child: Text("Floor ${floor['floorNumber']}"),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedFloorId = value;
                            final selectedFloor = floors.firstWhere(
                                (floor) => floor['floorNumber'].toString() == value);
                            _floorPriceController.text = selectedFloor['price'].toString();
                            _numSlotsController.text =
                                (selectedFloor['slots'] as List).length.toString();
                          });
                        },
                      );
                    },
                  ),
            const SizedBox(height: 20),

            // Floor Details and Update Section
            if (selectedFloorId != null) ...[
              TextField(
                controller: _floorPriceController,
                decoration: const InputDecoration(
                  labelText: "Floor Price",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _numSlotsController,
                decoration: const InputDecoration(
                  labelText: "Number of Slots",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updateFloorDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Update Floor Details"),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _updateFloorDetails() async {
    if (_floorPriceController.text.isEmpty || _numSlotsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    try {
      final updatedPrice = double.tryParse(_floorPriceController.text.trim()) ?? 0.0;
      final updatedNumSlots = int.tryParse(_numSlotsController.text.trim()) ?? 0;

      final parkingLotDoc =
          await FirebaseFirestore.instance.collection('parkingSpots').doc(selectedParkingId).get();

      if (parkingLotDoc.exists) {
        final parkingLotData = parkingLotDoc.data()!;
        final List floors = List.from(parkingLotData['floors']);
        final floorIndex = floors
            .indexWhere((floor) => floor['floorNumber'].toString() == selectedFloorId);

        if (floorIndex != -1) {
          final List slots = List.generate(updatedNumSlots, (index) {
            return index < (floors[floorIndex]['slots'] as List).length
                ? floors[floorIndex]['slots'][index]
                : {
                    'name': '${String.fromCharCode(65 + floorIndex)}${index + 1}',
                    'status': 'available',
                    'isReserved': false,
                    'reservationStartTime': '',
                    'reservationEndTime': '',
                    'reservedBy': ''
                  };
          });

          floors[floorIndex]['price'] = updatedPrice;
          floors[floorIndex]['slots'] = slots;

          await FirebaseFirestore.instance
              .collection('parkingSpots')
              .doc(selectedParkingId)
              .update({'floors': floors});

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Floor details updated successfully!")),
          );

          setState(() {}); // Refresh UI
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating floor details: $e")),
      );
    }
  }
}
