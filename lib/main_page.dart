import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parking_proj/parking_details_page.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/parking_card.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final user = FirebaseAuth.instance.currentUser;

  String searchQuery = "";

  void signUserOut(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/auth'); // Redirect to on boarding after sign-out
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Info and Sign-Out Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/user_info'); // Navigate to User Info page
                      },
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: const AssetImage('assets/profile.png'), // Placeholder image
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        "Hello, ${user?.displayName ?? 'User'}",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => signUserOut(context),
                      icon: const Icon(Icons.logout, color: Colors.redAccent),
                      tooltip: 'Sign Out',
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search for parking spots...',
                    prefixIcon: const Icon(Icons.search, color: Colors.lightBlue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.lightBlue, width: 1),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: 24),
                
                // Welcome Section
                const Text(
                  'Parking Nearby',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlueAccent,
                  ),
                ),
                const SizedBox(height: 16),

                // Parking Spots List
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('parkingSpots').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return const Center(child: Text('Error fetching data.'));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No parking spots available.'));
                      }

                      final allParkingSpots = snapshot.data!.docs;
                      final filteredParkingSpots = allParkingSpots.where((doc) {
                        final name = (doc['name'] ?? '').toString().toLowerCase();
                        return name.contains(searchQuery);
                      }).toList();

                      if (filteredParkingSpots.isEmpty) {
                        return const Center(child: Text('No matching parking spots found.'));
                      }

                      return ListView.builder(
                        itemCount: filteredParkingSpots.length,
                        itemBuilder: (context, index) {
                          final spot = filteredParkingSpots[index];
                          return ParkingCard(
                            imageUrl: 'assets/onboarding1.png', // Placeholder image
                            name: spot['name'] ?? 'Unnamed Spot',
                            location: spot['area'] ?? 'Unknown Area', // Display area from Firestore
                            price: '${spot['hourlyRate'] ?? 'N/A'}/hour',
                            onTap: () async {
                              // Fetch full parking spot details dynamically
                              final parkingDetails = await FirebaseFirestore.instance
                                  .collection('parkingSpots')
                                  .doc(spot.id) // Use the document ID
                                  .get();

                              if (parkingDetails.exists) {
                                final data = parkingDetails.data()!;

                                // Safely cast 'floors' to List<Map<String, dynamic>>
                                final List<Map<String, dynamic>> floors = (data['floors'] as List)
                                    .map((floor) => floor as Map<String, dynamic>)
                                    .toList();

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ParkingDetailsPage(
                                      parkingName: data['name'] ?? 'Unnamed Spot',
                                      floors: floors,
                                      latitude: data['latitude'] ?? 0.0,
                                      longitude: data['longitude'] ?? 0.0,
                                      capacity: data['capacity'] ?? 0,
                                      availableSpots: data['availableSpots'] ?? 0,
                                      id:spot.id ?? 'Unknown ID',
                                      timestamp: data['timestamp'] ?? 0 ,
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Parking spot not found.')),
                                );
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const BottomNavBar(),
      ),
    );
  }
}
