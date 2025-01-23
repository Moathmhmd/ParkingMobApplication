import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReservationPage extends StatefulWidget {
  final String spotName;
  final int floorNumber;
  final double price;
  final String parkingLotId;
  final String spotId;

  const ReservationPage({
    Key? key,
    required this.spotName,
    required this.floorNumber,
    required this.price,
    required this.parkingLotId,
    required this.spotId,
  }) : super(key: key);

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  String? _selectedDuration;
  final List<String> _durations = ["1 Hour", "2 Hours", "3 Hours"];
  bool _isLoading = false;

  Future<void> _reserveSlot() async {
    if (_selectedDuration == null) {
      _showError("Please select a reservation duration.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentTime = DateTime.now();
      final durationInHours = int.parse(_selectedDuration!.split(' ')[0]);
      final endTime = currentTime.add(Duration(hours: durationInHours));

      final spotDoc = FirebaseFirestore.instance
          .collection('parkingSpots')
          .doc(widget.parkingLotId);
      final spotData = await spotDoc.get();

      if (!spotData.exists) {
        _showError("Parking spot not found.");
        return;
      }

      final spot = spotData.data() as Map<String, dynamic>;
      final floorData = (spot['floors'] as List<dynamic>)[widget.floorNumber - 1];
      final slot = (floorData['slots'] as List<dynamic>).firstWhere((s) => s['name'] == widget.spotName);

      // Null check and reservation validation
      if ((slot['isReserved'] ?? false)) {
        _showError("The selected slot is already reserved.");
        return;
      }

      // Calculate the total price for the reservation
      final totalPrice = widget.price * durationInHours;

      // Update slot's reservation details
      slot['isReserved'] = true;
      slot['status'] = "reserved"; // Explicitly mark as reserved
      slot['reservedBy'] = FirebaseAuth.instance.currentUser?.uid ?? "";
      slot['reservationStartTime'] = currentTime.toIso8601String();
      slot['reservationEndTime'] = endTime.toIso8601String();

      await spotDoc.update({'floors': spot['floors']});

      // Add reservation to the reservations collection
      final reservationDoc = FirebaseFirestore.instance.collection('reservations').doc();
      await reservationDoc.set({
        'reservationId': reservationDoc.id,
        'userId': FirebaseAuth.instance.currentUser?.uid ?? "",
        'spotId': widget.spotId,
        'parkingLotId': widget.parkingLotId,
        'floorNumber': widget.floorNumber,
        'spotName': widget.spotName,
        'startTime': currentTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'status': "active",
        'price': totalPrice, // Save calculated price
      });

      // Add reference to the user's reservations
      final userDoc = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid);
      await userDoc.update({
        'reservationRefs': FieldValue.arrayUnion([reservationDoc.path]),
      });

      _showSuccess("Reservation confirmed for ${widget.spotName}.\nTotal Price: \$${totalPrice.toStringAsFixed(2)}");
    } catch (e) {
      _showError("Failed to reserve the spot. Please try again later.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reserve ${widget.spotName}"),
        backgroundColor: Colors.lightBlue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Spot Details",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: ListTile(
                        title: Text("Spot Name: ${widget.spotName}"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Floor: ${widget.floorNumber}"),
                            Text("Price: \$${widget.price.toStringAsFixed(2)} per hour"),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Select Duration",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: _selectedDuration,
                      hint: const Text("Choose a duration"),
                      isExpanded: true,
                      items: _durations
                          .map((duration) => DropdownMenuItem(
                                value: duration,
                                child: Text(duration),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDuration = value;
                        });
                      },
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _reserveSlot,
                        child: const Text("Confirm Reservation"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.lightBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
