import 'package:cloud_firestore/cloud_firestore.dart';

class Prenotazione {
  final String id;
  final String nome;
  final String telefono;
  final DateTime data;
  final String ora;
  final String slot;
  final String userId;
  final String stato; // 'Confermata', 'Completata', 'Cancellata'
  final List<String>? ordini; // IDs degli ordini associati
  final DateTime timestamp;
  final bool ordinazioneGia; // true = ha ordinato prima, false = ordina al tavolo

  Prenotazione({
    required this.id,
    required this.nome,
    required this.telefono,
    required this.data,
    required this.ora,
    required this.slot,
    required this.userId,
    required this.stato,
    this.ordini,
    required this.timestamp,
    required this.ordinazioneGia,
  });

  factory Prenotazione.fromMap(Map<String, dynamic> map, String id) {
    return Prenotazione(
      id: id,
      nome: map['nome'] ?? '',
      telefono: map['telefono'] ?? '',
      data: (map['data'] as Timestamp).toDate(),
      ora: map['ora'] ?? '',
      slot: map['slot'] ?? '',
      userId: map['userId'] ?? '',
      stato: map['stato'] ?? 'Confermata',
      ordini: List<String>.from(map['ordini'] ?? []),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      ordinazioneGia: map['ordinazioneGia'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'telefono': telefono,
      'data': data,
      'ora': ora,
      'slot': slot,
      'userId': userId,
      'stato': stato,
      'ordini': ordini ?? [],
      'timestamp': timestamp,
      'ordinazioneGia': ordinazioneGia,
    };
  }
}
