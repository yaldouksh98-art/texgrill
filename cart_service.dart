import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart_item.dart';

class CartService {
  // ==========================
  // SINGLETON
  // ==========================
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;

  CartService._internal() {
    // 🔥 EMISSIONE INIZIALE (FONDAMENTALE)
    _itemsController.add([]);
    print('🧠 CartService inizializzato');
  }

  // ==========================
  // STATE
  // ==========================
  final StreamController<List<CartItem>> _itemsController =
      StreamController<List<CartItem>>.broadcast();

  final List<CartItem> _items = [];

  // ==========================
  // GETTERS
  // ==========================
  Stream<List<CartItem>> get items => _itemsController.stream;

  List<CartItem> get currentItems => List.unmodifiable(_items);

  double get totale {
    return _items.fold(
      0.0,
      (sum, item) => sum + (item.prezzo * item.quantita),
    );
  }

  int get totalItems {
    return _items.fold(0, (sum, item) => sum + item.quantita);
  }

  // ==========================
  // METODI CARRELLO
  // ==========================
  void addItem(CartItem newItem) {
    print('🛒 Aggiunta prodotto: ${newItem.nome}');

    final index = _items.indexWhere((item) => item.id == newItem.id);

    if (index >= 0) {
      final existing = _items[index];
      _items[index] = CartItem(
        id: existing.id,
        nome: existing.nome,
        prezzo: existing.prezzo,
        quantita: existing.quantita + newItem.quantita,
        note: existing.note,
      );
    } else {
      _items.add(newItem);
    }

    _emit();
  }

  void updateQuantity(String id, int newQuantity) {
    final index = _items.indexWhere((item) => item.id == id);

    if (index == -1) return;

    if (newQuantity <= 0) {
      _items.removeAt(index);
    } else {
      final item = _items[index];
      _items[index] = CartItem(
        id: item.id,
        nome: item.nome,
        prezzo: item.prezzo,
        quantita: newQuantity,
        note: item.note,
      );
    }

    _emit();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    _emit();
  }

  void clear() {
    _items.clear();
    _emit();
  }

  // ==========================
  // SAVE ORDER TO FIRESTORE
  // ==========================
  Future<String> saveOrder(String prenotazioneId) async {
    if (_items.isEmpty) {
      throw Exception('Carrello vuoto');
    }

    final ordineRef = await FirebaseFirestore.instance
        .collection('ordini')
        .add({
      'userId': FirebaseAuth.instance.currentUser?.uid,
      'prenotazioneId': prenotazioneId,
      'items': _items.map((item) => item.toMap()).toList(),
      'totale': totale,
      'stato': 'In preparazione',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // ✅ Aggiorna la prenotazione con l'ID dell'ordine
    await FirebaseFirestore.instance
        .collection('prenotazioni')
        .doc(prenotazioneId)
        .update({
      'ordini': FieldValue.arrayUnion([ordineRef.id]),
    });

    print('✅ Ordine salvato: ${ordineRef.id}');
    return ordineRef.id;
  }

  // ==========================
  // STREAM EMIT
  // ==========================
  void _emit() {
    if (!_itemsController.isClosed) {
      _itemsController.add(List.unmodifiable(_items));
      print(
        '📢 Stream aggiornato → ${_items.length} prodotti | Totale €${totale.toStringAsFixed(2)}',
      );
    }
  }

  // ==========================
  // DISPOSE (opzionale)
  // ==========================
  void dispose() {
    _itemsController.close();
    print('🔒 CartService chiuso');
  }
}
