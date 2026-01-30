import 'package:cloud_firestore/cloud_firestore.dart';

/// Servizio custom per il tracking degli eventi senza firebase_analytics
class AppAnalytics {
  static const String _eventsCollection = 'app_events';

  /// Registra un evento di login
  static Future<void> logLogin(String userId, String provider) async {
    await _logEvent(
      eventType: 'login',
      userId: userId,
      data: {'provider': provider},
    );
  }

  /// Registra un evento di ordine
  static Future<void> logOrder(
    String userId,
    double amount,
    int itemCount, {
    String? orderType, // 'asporto' o 'prenotazione'
  }) async {
    await _logEvent(
      eventType: 'order_placed',
      userId: userId,
      data: {
        'amount': amount,
        'item_count': itemCount,
        'order_type': orderType,
      },
    );
  }

  /// Registra un evento di menu view
  static Future<void> logMenuView(String userId, String category) async {
    await _logEvent(
      eventType: 'menu_viewed',
      userId: userId,
      data: {'category': category},
    );
  }

  /// Registra una prenotazione
  static Future<void> logReservation(String userId, int guests) async {
    await _logEvent(
      eventType: 'reservation_made',
      userId: userId,
      data: {'guests': guests},
    );
  }

  /// Registra un evento generico
  static Future<void> _logEvent({
    required String eventType,
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await FirebaseFirestore.instance.collection(_eventsCollection).add({
        'event_type': eventType,
        'user_id': userId,
        'timestamp': FieldValue.serverTimestamp(),
        ...data,
      });
    } catch (e) {
      print('❌ Errore nel logging evento: $e');
    }
  }
}
