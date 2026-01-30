class CartItem {
  final String id;
  final String nome;
  final double prezzo;
  final int quantita;
  final String? note;
  final String? prenotazioneId; // ✅ aggiunto per collegare all'ordine prenotazione

  const CartItem({
    required this.id,
    required this.nome,
    required this.prezzo,
    required this.quantita,
    this.note,
    this.prenotazioneId, // ✅ parametro opzionale
  });

  // Metodo copyWith per creare copie modificate
  CartItem copyWith({
    String? id,
    String? nome,
    double? prezzo,
    int? quantita,
    String? note,
    String? prenotazioneId, // ✅ aggiunto
  }) {
    return CartItem(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      prezzo: prezzo ?? this.prezzo,
      quantita: quantita ?? this.quantita,
      note: note ?? this.note,
      prenotazioneId: prenotazioneId ?? this.prenotazioneId, // ✅ aggiunto
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'prezzo': prezzo,
      'quantita': quantita,
      'note': note,
      'prenotazioneId': prenotazioneId, // ✅ aggiunto
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] as String,
      nome: map['nome'] as String,
      prezzo: (map['prezzo'] as num).toDouble(),
      quantita: map['quantita'] as int,
      note: map['note'] as String?,
      prenotazioneId: map['prenotazioneId'] as String?, // ✅ aggiunto
    );
  }

  @override
  String toString() {
    return 'CartItem(id: $id, nome: $nome, prezzo: €${prezzo.toStringAsFixed(2)}, quantita: $quantita, note: $note, prenotazioneId: $prenotazioneId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
