import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parking_proj/widgets/bottom_nav_bar.dart';
import 'package:parking_proj/widgets/bottom_reservation_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

class ParkingDetailsPage extends StatefulWidget {
  final String parkingName;
  final List<Map<String, dynamic>> floors;
  final double latitude;
  final double longitude;
  final int capacity;
  final int availableSpots;
  final String id;
  final String timestamp;

  const ParkingDetailsPage({
    Key? key,
    required this.parkingName,
    required this.floors,
    required this.latitude,
    required this.longitude,
    required this.capacity,
    required this.availableSpots,
    required this.id,
    required this.timestamp,

  }) : super(key: key);

  @override
  State<ParkingDetailsPage> createState() => _ParkingDetailsPageState();
  
}

class _ParkingDetailsPageState extends State<ParkingDetailsPage> {
  int selectedFloor = 0;
  void _openGoogleMaps() async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${widget.latitude},${widget.longitude}&travelmode=driving';
    if (url.isNotEmpty && await canLaunch(url)) {
      await launch(url);
    } else {
      debugPrint('Could not launch $url');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column( crossAxisAlignment: CrossAxisAlignment.center,
          children: [
                   Row( 
                     children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.lightBlue),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                     ],
                   ),
            // Parking Summary Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.parkingName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Capacity: ${widget.capacity} spots',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  Text(
                    'Available Spots: ${widget.availableSpots}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
        
            // Google Maps View
                        Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.lightBlue[50],
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(widget.latitude, widget.longitude),
                          zoom: 16,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('parking_location'),
                            position: LatLng(widget.latitude, widget.longitude),
                            infoWindow: InfoWindow(title: widget.parkingName),
                          ),
                        },
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton.icon(
                            onPressed: _openGoogleMaps,
                            icon: const Icon(Icons.directions, color: Colors.white),
                            label: const Text(
                              "Directions",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),

            Container(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('parkingSpots')
                    .doc(widget.id) // Ensure this is the document ID
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(child: Text('No data available.'));
                  }

                  final timestamp=snapshot.data!['timestamp'] as String;

                  return  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                            'Last Updated: $timestamp',
                            style:  TextStyle(fontSize: 16, color: Colors.grey[700]),
                          ),
                  );
                     
                }
              )
            ),
              
          
            // Floor Selector Bar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: Colors.lightBlue[50],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.floors.length, (index) {
                  // Get the floor data for this specific index
                  final floor = widget.floors[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedFloor =
                              index; // Update the selected floor when a button is pressed
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedFloor == index
                            ? Colors.lightBlue
                            : Colors.lightBlue[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('Floor ${floor['floorNumber']}',
                        style: TextStyle(
                          color: selectedFloor == index
                            ? Colors.white
                            : Colors.black,
                          fontWeight: selectedFloor == index
                            ? FontWeight.bold
                            : FontWeight.normal,
                        ),
                      ), // Use the correct floor number
                    ),
                  );
                }),
              ),
            ),
        
            // Parking Slots Grid
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('parkingSpots')
                    .doc(widget.id) // Ensure this is the document ID
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(child: Text('No data available.'));
                  }

                  final parkingData = snapshot.data!.data() as Map<String, dynamic>;
                  final floors = parkingData['floors'] as List<dynamic>;

                  // Ensure the selected floor index exists
                  if (selectedFloor >= floors.length) {
                    return const Center(child: Text('Invalid floor selected.'));
                  }

                  final currentFloor = floors[selectedFloor];
                  final slots = currentFloor['slots'] as List<dynamic>;

                  return GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, // Number of columns in the grid
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemCount: slots.length,
                    itemBuilder: (context, index) {
                      final slot = slots[index];
                      return ElevatedButton(
                        onPressed: () {
                           BottomReservationSheet.show(context, slot, currentFloor['floorNumber'], widget.id, index);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: slot['status'] == 'available'
                              ? Colors.green[200]
                              : slot['status'] == 'occupied'? Colors.red[200]: slot['status'] == 'reserved' ? const Color.fromARGB(255, 238, 227, 134): Colors.grey[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              slot['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              slot['status'],
                              style: TextStyle(
                                color: slot['status'] == 'available'
                                    ? Colors.green[900]
                                    : Colors.red[900],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
            bottomNavigationBar: const BottomNavBar(),

    );
  }
}