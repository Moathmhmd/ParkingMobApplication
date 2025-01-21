import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationUtils {
  static Future<void> checkAndUpdateExpiredReservations() async {
    try {
      final now = DateTime.now().toIso8601String();
      final query = await FirebaseFirestore.instance
          .collection('reservations')
          .where('status', isEqualTo: 'active')
          .where('endTime', isLessThanOrEqualTo: now)
          .get();

      for (var doc in query.docs) {
        final reservation = doc.data();
        final spotDoc = FirebaseFirestore.instance
            .collection('parkingSpots')
            .doc(reservation['parkingLotId']);

        final spotData = await spotDoc.get();
        if (!spotData.exists) continue;

        final spot = spotData.data() as Map<String, dynamic>;
        final floorData = (spot['floors'] as List<dynamic>)[reservation['floorNumber'] - 1];
        final slot = (floorData['slots'] as List<dynamic>).firstWhere(
          (s) => s['name'] == reservation['spotName'],
          orElse: () => null,
        );

        if (slot == null || slot['status'] != "reserved") continue;

        slot['status'] = "available";
        slot['reservedBy'] = "";
        slot['reservationStartTime'] = "";
        slot['reservationEndTime'] = "";

        await spotDoc.update({'floors': spot['floors']});
        await doc.reference.update({'status': 'completed'});
      }
    } catch (e) {
      print("Error checking expired reservations: $e");
    }
  }
}
