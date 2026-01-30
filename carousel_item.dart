class CarouselItem {
  final String id;
  final String imageUrl;
  final String? title;
  final String? description;
  final String? linkUrl;
  final int order;
  final bool active;

  CarouselItem({
    required this.id,
    required this.imageUrl,
    this.title,
    this.description,
    this.linkUrl,
    required this.order,
    required this.active,
  });

  // Questo risolve l'ERRORE DI BUILD (riga 25)
  factory CarouselItem.fromMap(Map<String, dynamic> map, {String id = ''}) {
    return CarouselItem(
      id: id,
      imageUrl: map['imageUrl'] ?? '',
      title: map['title'],
      description: map['description'],
      linkUrl: map['linkUrl'],
      order: map['order'] ?? 0,
      active: map['active'] ?? true,
    );
  }

  // Questo mantiene la compatibilità con il tuo codice ORIGINALE
  factory CarouselItem.fromFirestore(Map<String, dynamic> data, String id) {
    return CarouselItem.fromMap(data, id: id);
  }

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'title': title,
      'description': description,
      'linkUrl': linkUrl,
      'order': order,
      'active': active,
    };
  }
}