import 'package:flutter/material.dart';

class Ingrediente {
  final String nome;
  final String? fotoUrl;
  final bool rimovibile;
  final bool aggiungibile;
  final double costoExtra;
  int quantita;

  Ingrediente({
    required this.nome,
    this.fotoUrl,
    this.rimovibile = true,
    this.aggiungibile = true,
    this.costoExtra = 0.0,
    this.quantita = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'fotoUrl': fotoUrl,
      'rimovibile': rimovibile,
      'aggiungibile': aggiungibile,
      'costoExtra': costoExtra,
      'quantita': quantita,
    };
  }

  factory Ingrediente.fromMap(Map<String, dynamic> map) {
    return Ingrediente(
      nome: map['nome'] ?? '',
      fotoUrl: map['fotoUrl'],
      rimovibile: map['rimovibile'] ?? true,
      aggiungibile: map['aggiungibile'] ?? true,
      costoExtra: (map['costoExtra'] as num? ?? 0).toDouble(),
      quantita: map['quantita'] ?? 1,
    );
  }

  Ingrediente copyWith({
    String? nome,
    String? fotoUrl,
    bool? rimovibile,
    bool? aggiungibile,
    double? costoExtra,
    int? quantita,
  }) {
    return Ingrediente(
      nome: nome ?? this.nome,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      rimovibile: rimovibile ?? this.rimovibile,
      aggiungibile: aggiungibile ?? this.aggiungibile,
      costoExtra: costoExtra ?? this.costoExtra,
      quantita: quantita ?? this.quantita,
    );
  }
}

class MenuItem {
  final String id;
  final String nome;
  final String descrizione;
  final double prezzo;
  final String categoria;
  final String imageUrl;
  final bool disponibile;
  final List<Ingrediente> ingredienti;

  MenuItem({
    required this.id,
    required this.nome,
    required this.descrizione,
    required this.prezzo,
    required this.categoria,
    required this.imageUrl,
    this.disponibile = true,
    this.ingredienti = const [],
  });

  IconData get icon {
    switch (categoria.toLowerCase()) {
      case 'pizza': return Icons.local_pizza;
      case 'burger': return Icons.lunch_dining;
      case 'contorni': return Icons.fastfood;
      case 'dolci': return Icons.icecream;
      case 'bevande': return Icons.local_drink;
      default: return Icons.restaurant;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descrizione': descrizione,
      'prezzo': prezzo,
      'categoria': categoria,
      'imageUrl': imageUrl,
      'disponibile': disponibile,
      'ingredienti': ingredienti.map((i) => i.toMap()).toList(),
    };
  }

  factory MenuItem.fromMap(Map<String, dynamic> map, String id) {
    List<Ingrediente> ingredientiList = [];
    if (map['ingredienti'] != null) {
      ingredientiList = (map['ingredienti'] as List)
          .map((i) => Ingrediente.fromMap(i as Map<String, dynamic>))
          .toList();
    }

    return MenuItem(
      id: id,
      nome: map['nome'] ?? '',
      descrizione: map['descrizione'] ?? '',
      prezzo: (map['prezzo'] as num? ?? 0).toDouble(),
      categoria: map['categoria'] ?? 'Generale',
      imageUrl: map['imageUrl'] ?? '',
      disponibile: map['disponibile'] ?? true,
      ingredienti: ingredientiList,
    );
  }
}
