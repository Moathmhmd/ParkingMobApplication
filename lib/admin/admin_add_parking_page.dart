import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class AdminAddParking extends StatefulWidget {
  const AdminAddParking({super.key});

  @override
  State<AdminAddParking> createState() => _AdminAddParkingState();
}

class _AdminAddParkingState extends State<AdminAddParking> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _floorNumberController = TextEditingController();
  final TextEditingController _floorSlotsController = TextEditingController();
  final TextEditingController _floorPriceController = TextEditingController();

  final List<Map<String, dynamic>> _floors = [];
  LatLng? _selectedLocation;
  File? _selectedImage;
  String? _imageUrl;

  final ImagePicker _picker = ImagePicker();

  // Select an image
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Upload image to Firebase Storage
  Future<String?> _uploadImage(String parkingId) async {
    if (_selectedImage == null) return null;

    try {
      final storageRef = _storage.ref().child('parking_images/$parkingId.jpg');
      final uploadTask = storageRef.putFile(_selectedImage!);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading image: $e")),
      );
      return null;
    }
  }

  void _addParkingLot() async {
    final String name = _nameController.text.trim();
    final String area = _areaController.text.trim();

    if (name.isEmpty ||
        area.isEmpty ||
        _floors.isEmpty ||
        _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please fill all fields, add floors, and select an image.")),
      );
      return;
    }

    final int capacity = _floors.fold<int>(
        0, (sum, floor) => sum + (floor['slots'] as List).length);
    final int availableSpots = capacity;

    final String ownerId = FirebaseAuth.instance.currentUser?.uid ?? "";

    final Map<String, dynamic> parkingLot = {
      'name': name,
      'area': area,
      'latitude': _selectedLocation!.latitude,
      'longitude': _selectedLocation!.longitude,
      'capacity': capacity,
      'availableSpots': availableSpots,
      'floors': _floors,
      'ownerId': ownerId,
      'timestamp': '',
    };

    try {
      final docRef = await _firestore.collection('parkingSpots').add(parkingLot);

      // Upload image and update the document
      final imageUrl = await _uploadImage(docRef.id);
      if (imageUrl != null) {
        await docRef.update({'imageUrl': imageUrl});
      }

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

  void _resetForm() {
    _nameController.clear();
    _areaController.clear();
    _floorNumberController.clear();
    _floorSlotsController.clear();
    _floorPriceController.clear();
    _floors.clear();
    _selectedLocation = null;
    _selectedImage = null;
    setState(() {});
  }

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
          'price': price,
          'slots': slots,
        });
      });

      _floorNumberController.clear();
      _floorSlotsController.clear();
      _floorPriceController.clear();
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.lightBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Admin - Add Parking Lot",
          style: TextStyle(
              color: Colors.lightBlueAccent, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
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
              const SizedBox(height: 16),
              Text(
                _selectedLocation == null
                    ? "Location not selected"
                    : "Selected Location: (${_selectedLocation!.latitude}, ${_selectedLocation!.longitude})",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              LocationPicker(
                initialLocation: _selectedLocation,
                onLocationSelected: (LatLng location) {
                  setState(() {
                    _selectedLocation = location;
                  });
                },
              ),
              const SizedBox(height: 16),
              if (_selectedImage != null)
                Image.file(
                  _selectedImage!,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              Center(
                child: ElevatedButton(
                  onPressed: _pickImage,
                
                style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
                  child: const Text("Select Image"
                  ,style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "Add Floor Details",
                  style: TextStyle(
                      color: Colors.lightBlueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 22),
                ),
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
                decoration: const InputDecoration(labelText: "Price per Floor"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              Center(
                child: ElevatedButton(
                  onPressed: _addFloor,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
                  child: const Text("Add Floor",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),),
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
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
                  child: const Text("Add Parking Lot",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LocationPicker extends StatefulWidget {
  final LatLng? initialLocation;
  final Function(LatLng) onLocationSelected;

  const LocationPicker({
    Key? key,
    this.initialLocation,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _currentLocation = widget.initialLocation ?? const LatLng(31.9544, 35.9106);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _currentLocation!,
            zoom: 16,
          ),
          markers: _currentLocation != null
              ? {
                  Marker(
                    markerId: const MarkerId('selection_pin'),
                    position: _currentLocation!,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed),
                    draggable: true,
                    onDragEnd: (newPosition) {
                      setState(() {
                        _currentLocation = newPosition;
                      });
                      widget.onLocationSelected(newPosition);
                    },
                  ),
                }
              : {},
          onTap: (LatLng tappedLocation) {
            setState(() {
              _currentLocation = tappedLocation;
            });
            widget.onLocationSelected(tappedLocation);
          },
        ),
      ),
    );
  }
}
