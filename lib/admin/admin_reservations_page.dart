import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class AdminReservationsPage extends StatefulWidget {
  const AdminReservationsPage({Key? key}) : super(key: key);

  @override
  State<AdminReservationsPage> createState() => _AdminReservationsPageState();
}

class _AdminReservationsPageState extends State<AdminReservationsPage> {
  String? selectedParkingId; // Selected parking lot ID
  final String adminId = FirebaseAuth.instance.currentUser!.uid; // Current admin ID

  String formatDateTime(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    return DateFormat('yyyy-MM-dd – kk:mm').format(dateTime);
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
          "View Reservations",
          style: TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown to Select Parking Lot
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('parkingSpots')
                  .where('ownerId', isEqualTo: adminId) // Filter by admin ID
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No parking lots available."));
                }

                final parkingSpots = snapshot.data!.docs;

                return DropdownButtonFormField<String>(
                  value: selectedParkingId,
                  hint: const Text("Choose a parking lot"),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  items: parkingSpots.map((parkingDoc) {
                    return DropdownMenuItem<String>(
                      value: parkingDoc.id,
                      child: Text(parkingDoc['name'] ?? 'Unnamed Spot'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedParkingId = value;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            // Reservations List Section
            selectedParkingId == null
                ? const Expanded(
                    child: Center(
                      child: Text(
                        "Please select a parking lot to view reservations.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : Expanded(
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('parkingSpots')
                          .doc(selectedParkingId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                          return const Center(
                            child: Text("No reservations found for the selected parking lot."),
                          );
                        }

                        final data = snapshot.data!.data() as Map<String, dynamic>;
                        final reservationRefs = List<String>.from(data['reservationsRefs'] ?? []);

                        if (reservationRefs.isEmpty) {
                          return const Center(
                            child: Text(
                              "No reservations found for the selected parking lot.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: reservationRefs.length,
                          itemBuilder: (context, index) {
                            final ref = reservationRefs[index];
                            return StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance.doc(ref).snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const ListTile(
                                    title: Text("Loading reservation..."),
                                  );
                                }

                                if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                                  return const ListTile(
                                    title: Text("Failed to load reservation."),
                                  );
                                }

                                final reservationData = snapshot.data!.data() as Map<String, dynamic>;
                                final isActive = reservationData['status'] == 'active';

                                return FutureBuilder<DocumentSnapshot>(
                                  future: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(reservationData['userId'])
                                      .get(),
                                  builder: (context, userSnapshot) {
                                    String userName = "Unknown User";
                                    if (userSnapshot.connectionState == ConnectionState.done &&
                                        userSnapshot.hasData &&
                                        userSnapshot.data!.exists) {
                                      userName = userSnapshot.data!['name'] ?? "Unknown User";
                                    }

                                    return Card(
                                      color: isActive ? Colors.green[100] : Colors.red[100],
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      margin: const EdgeInsets.symmetric(vertical: 8),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Spot: ${reservationData['spotName']}",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text("Floor: ${reservationData['floorNumber']}",
                                              style: const TextStyle(
                                              fontSize: 16,)), 
                                            Text("Reserved by: $userName",
                                              style: const TextStyle(
                                              fontSize: 16,)), 
                                            Text("Start Time: ${formatDateTime(reservationData['startTime'])}",
                                              style: const TextStyle(
                                              fontSize: 16,)), 
                                            Text("End Time: ${formatDateTime(reservationData['endTime'])}",
                                              style: const TextStyle(
                                              fontSize: 16,)), 
                                            Text("Price: \$${reservationData['price']}",
                                              style: const TextStyle(
                                              fontSize: 16,)), 
                                            const Text('Status: ',
                                              style: TextStyle(fontWeight: FontWeight.bold)),
                                            Badge(status: reservationData['status']),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
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
    );
  }
}
class Badge extends StatelessWidget {
  final String status;

  const Badge({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    if (status == 'active') {
      badgeColor = Colors.green;
    } else if (status == 'completed') {
      badgeColor = Colors.red;
    } else {
      badgeColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}