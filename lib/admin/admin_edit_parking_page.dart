import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminEditParking extends StatefulWidget {
  const AdminEditParking({super.key});

  @override
  State<AdminEditParking> createState() => _AdminEditParkingState();
}

class _AdminEditParkingState extends State<AdminEditParking> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late User _currentUser;
  List<dynamic> _parkingLots = [];
  List<Map<String, dynamic>> _floors = [];
  Map<String, dynamic>? _selectedSpot;

  final TextEditingController _spotStatusController = TextEditingController();
  final TextEditingController _spotPriceController = TextEditingController();
  final TextEditingController _floorPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  void _fetchCurrentUser() {
    final User? user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not authenticated")),
      );
      return;
    }
    _currentUser = user;
    _fetchParkingLots();
  }

  void _fetchParkingLots() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('parkingSpots')
          .where('owner.id', isEqualTo: _currentUser.uid)
          .get();

      setState(() {
        _parkingLots = querySnapshot.docs.map((doc) => doc.data()).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching parking lots: $e")),
      );
    }
  }

  void _fetchFloors(String parkingLotId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('parkingSpots').doc(parkingLotId).get();
      if (doc.exists) {
        setState(() {
          _selectedSpot = null;
          _floors = List<Map<String, dynamic>>.from(doc['floors']);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching floors: $e")),
      );
    }
  }

  void _updateFloorPrice(String parkingLotId, int floorNumber) async {
    if (_floorPriceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill the floor price")),
      );
      return;
    }

    try {
      final updatedFloorPrice =
          double.tryParse(_floorPriceController.text.trim()) ?? 0.0;
      final parkingLotDoc =
          await _firestore.collection('parkingSpots').doc(parkingLotId).get();

      if (parkingLotDoc.exists) {
        final parkingLotData = parkingLotDoc.data()!;
        final List floors = List.from(parkingLotData['floors']);
        final floorIndex =
            floors.indexWhere((floor) => floor['floorNumber'] == floorNumber);

        if (floorIndex != -1) {
          floors[floorIndex]['price'] = updatedFloorPrice;
          await _firestore.collection('parkingSpots').doc(parkingLotId).update({
            'floors': floors,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Floor price updated successfully!")),
          );
          setState(() {});
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating floor price: $e")),
      );
    }
  }

  void _updateSpotDetails() async {
    if (_spotStatusController.text.isEmpty ||
        _spotPriceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    try {
      final updatedSpot = {
        'status': _spotStatusController.text.trim(),
        'price': double.tryParse(_spotPriceController.text.trim()) ?? 0.0,
        'owner': _selectedSpot!['owner'],
      };

      final parkingLotDoc = await _firestore
          .collection('parkingSpots')
          .doc(_selectedSpot!['parkingLotId'])
          .get();
      if (parkingLotDoc.exists) {
        final parkingLotData = parkingLotDoc.data()!;
        final List floors = List.from(parkingLotData['floors']);
        final floorIndex = floors.indexWhere(
            (floor) => floor['floorNumber'] == _selectedSpot!['floorNumber']);
        final spotIndex = floors[floorIndex]['slots']
            .indexWhere((spot) => spot['name'] == _selectedSpot!['name']);

        if (floorIndex != -1 && spotIndex != -1) {
          floors[floorIndex]['slots'][spotIndex] = updatedSpot;
          await _firestore
              .collection('parkingSpots')
              .doc(_selectedSpot!['parkingLotId'])
              .update({
            'floors': floors,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Parking spot updated successfully!")),
          );
          setState(() {});
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating spot: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin - Edit Parking Lot"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _parkingLots.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Select a Parking Lot",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _parkingLots.length,
                      itemBuilder: (context, index) {
                        final parkingLot = _parkingLots[index];
                        return ListTile(
                          title: Text(parkingLot['name']),
                          subtitle: Text(parkingLot['area']),
                          onTap: () => _fetchFloors(parkingLot['id']),
                        );
                      },
                    ),
                  ),
                  if (_floors.isNotEmpty) ...[
                    const Text("Select a Floor and Edit Price",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _floors.length,
                        itemBuilder: (context, index) {
                          final floor = _floors[index];
                          return ListTile(
                            title: Text("Floor ${floor['floorNumber']}"),
                            subtitle:
                                Text("Current Price: \$${floor['price']}"),
                            onTap: () {
                              _floorPriceController.text =
                                  floor['price'].toString();
                              _updateFloorPrice(_parkingLots[index]['id'],
                                  floor['floorNumber']);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                  if (_selectedSpot != null) ...[
                    const SizedBox(height: 16),
                    const Text("Edit Spot Details",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    TextField(
                      controller: _spotStatusController,
                      decoration:
                          const InputDecoration(labelText: "Spot Status"),
                    ),
                    TextField(
                      controller: _spotPriceController,
                      decoration:
                          const InputDecoration(labelText: "Spot Price"),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: ElevatedButton(
                        onPressed: _updateSpotDetails,
                        child: const Text("Update Spot"),
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
