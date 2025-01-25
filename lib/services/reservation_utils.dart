import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationUtils {
  static Future<void> checkAndUpdateExpiredReservations() async {
    try {
      final now = DateTime.now().toIso8601String(); // Current time in ISO8601
      final reservationsQuery = await FirebaseFirestore.instance
          .collection('reservations')
          .where('status', isEqualTo: 'active') // Only active reservations
          .where('endTime', isLessThanOrEqualTo: now) // Check if expired
          .get();

      for (var reservationDoc in reservationsQuery.docs) {
        final reservation = reservationDoc.data();

        // Fetch the associated parking spot
        final parkingSpotDoc = await FirebaseFirestore.instance
            .collection('parkingSpots')
            .doc(reservation['parkingLotId'])
            .get();

        if (!parkingSpotDoc.exists) continue;

        final parkingSpotData = parkingSpotDoc.data()!;
        final List floors = List.from(parkingSpotData['floors']);

        // Find the reserved spot
        final floorIndex = floors.indexWhere(
            (floor) => floor['floorNumber'] == reservation['floorNumber']);
        if (floorIndex == -1) continue;

        final slots = List.from(floors[floorIndex]['slots']);
        final slotIndex = slots.indexWhere(
            (slot) => slot['name'] == reservation['spotName']);
        if (slotIndex == -1) continue;

        // Update the slot's status to "available"
        slots[slotIndex]['status'] = 'available';
        slots[slotIndex]['isReserved'] = false;
        slots[slotIndex]['reservedBy'] = '';
        slots[slotIndex]['reservationStartTime'] = '';
        slots[slotIndex]['reservationEndTime'] = '';

        floors[floorIndex]['slots'] = slots;

        // Update the parking spot document
        await parkingSpotDoc.reference.update({'floors': floors});

        // Update the reservation's status to "completed"
        await reservationDoc.reference.update({'status': 'completed'});
      }
    } catch (e) {
      print("Error checking expired reservations: $e");
    }
  }
}
