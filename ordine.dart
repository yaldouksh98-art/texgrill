import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item.dart';

class Ordine {
  final String id;
  final String prenotazioneId;
  final List<CartItem> items;
  final double totale;
  final String stato; // 'In preparazione', 'Pronto', 'Completato'
  final DateTime timestamp;

  Ordine({
    required this.id,
    required this.prenotazioneId,
    required this.items,
    required this.totale,
    required this.stato,
    required this.timestamp,
  });

  factory Ordine.fromMap(Map<String, dynamic> map, String id) {
    return Ordine(
      id: id,
      prenotazioneId: map['prenotazioneId'] ?? '',
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => CartItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      totale: (map['totale'] as num?)?.toDouble() ?? 0.0,
      stato: map['stato'] ?? 'In preparazione',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'prenotazioneId': prenotazioneId,
      'items': items.map((item) => item.toMap()).toList(),
      'totale': totale,
      'stato': stato,
      'timestamp': timestamp,
    };
  }
}
