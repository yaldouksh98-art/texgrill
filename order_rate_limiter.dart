import 'package:cloud_firestore/cloud_firestore.dart';

class OrderCheckResult {
  final bool canOrder;
  final int remainingSeconds;
  final String message;

  OrderCheckResult(this.canOrder, this.remainingSeconds, this.message);
}

class OrderRateLimiter {
  static Future<OrderCheckResult> checkCanOrder(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('ordini_totali')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return OrderCheckResult(true, 0, 'OK');
      }

      final lastOrderTime = (snapshot.docs.first.data()['timestamp'] as Timestamp).toDate();
      final difference = DateTime.now().difference(lastOrderTime).inSeconds;
      const int waitTime = 60; // Attesa di 60 secondi tra ordini

      if (difference < waitTime) {
        return OrderCheckResult(false, waitTime - difference, 'Attendi prima di ordinare di nuovo');
      }
      
      return OrderCheckResult(true, 0, 'OK');
    } catch (e) {
      return OrderCheckResult(false, 0, 'Errore controllo: $e');
    }
  }
}