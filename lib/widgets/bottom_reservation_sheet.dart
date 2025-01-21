import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parking_proj/Reservation_Page.dart';

class BottomReservationSheet {
  static void show(
    BuildContext context,
    Map<String, dynamic> slot,
    int floorNumber,
    String parkingLotId,
    int slotIndex,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Ensures it takes up the required space
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('parkingSpots')
              .doc(parkingLotId)
              .snapshots(),
          builder: (context,  snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('No data available.'));
            }

            // Extract updated slot and floor data
            final parkingData = snapshot.data!.data() as Map<String, dynamic>;
            final floorData =
                (parkingData['floors'] as List<dynamic>)[floorNumber - 1];
            final updatedSlot =
                (floorData['slots'] as List<dynamic>)[slotIndex];
            final double floorPrice = (floorData['price'] is int)
              ? (floorData['price'] as int).toDouble()
                : floorData['price'] as double;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Slot: ${updatedSlot['name']}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Floor: $floorNumber",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Status: ${updatedSlot['status']}",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Price: \$${floorPrice.toStringAsFixed(2)} per hour",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to the Reservation Page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReservationPage(
                                spotName: updatedSlot['name'], // Slot name (e.g., A1)
                                floorNumber: floorNumber, // Floor number
                                price: floorPrice, // Floor price
                                parkingLotId: parkingLotId, // Parking lot ID
                                spotId: '${parkingLotId}-${updatedSlot['name']}', // Unique spot identifier
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Reserve"),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
