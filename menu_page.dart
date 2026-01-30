import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item.dart';
import '../models/cart_item.dart';
import '../services/cart_service.dart';
import 'ordine_page.dart';

class MenuPage extends StatefulWidget {
  final String? prenotazioneId;

  const MenuPage({super.key, this.prenotazioneId});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String _selectedCategory = 'Tutti';
  final List<String> _categories = ['Tutti', 'Burger', 'Pizza', 'Contorni', 'Dolci', 'Bevande'];

  final Color brandColor = const Color(0xFFFF4500);
  double _prezzoTotale = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MENU',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: brandColor,
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_checkout_rounded),
            onPressed: () {
              // Se è una prenotazione, vai a OrdinePage
              if (widget.prenotazioneId != null && widget.prenotazioneId!.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrdinePage(prenotazioneId: widget.prenotazioneId!),
                  ),
                );
              } else {
                // Altrimenti vai al carrello normale
                Navigator.pushNamed(context, '/carrello');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Selettore Categorie
          Container(
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedCategory = category);
                    },
                    selectedColor: brandColor,
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                );
              },
            ),
          ),
          // Lista Prodotti
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('menu').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Errore nel caricamento del menu'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var items = snapshot.data!.docs
                    .map((doc) => MenuItem.fromMap(doc.data() as Map<String, dynamic>, doc.id))
                    .toList();

                if (_selectedCategory != 'Tutti') {
                  items = items.where((item) =>
                    item.categoria.toLowerCase() == _selectedCategory.toLowerCase()
                  ).toList();
                }

                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 10),
                        const Text('Nessun prodotto in questa categoria'),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(15),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _buildMenuItemRow(items[index]),
                );
              },
            ),
          ),
          
          // 🛒 Bottone Procedi al Checkout (solo se ha articoli)
          StreamBuilder<List<CartItem>>(
            stream: CartService().items,
            builder: (context, snapshot) {
              final items = snapshot.data ?? [];
              if (items.isEmpty) return const SizedBox();
              
              final totale = CartService().totale;
              
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  border: Border(top: BorderSide(color: Colors.grey.shade700)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${items.length} articol${items.length == 1 ? "o" : "i"}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Totale: €${totale.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Se è una prenotazione, vai a OrdinePage
                          if (widget.prenotazioneId != null && widget.prenotazioneId!.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OrdinePage(prenotazioneId: widget.prenotazioneId!),
                              ),
                            );
                          } else {
                            // Altrimenti vai al carrello normale
                            Navigator.pushNamed(context, '/carrello');
                          }
                        },
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: const Text(
                          'PROCEDI AL CHECKOUT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemRow(MenuItem item) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showItemDialog(item),
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // Immagine a sinistra
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: item.imageUrl.isNotEmpty
                      ? Image.network(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, _, __) =>
                              Container(color: Colors.grey[200], child: Icon(item.icon, size: 40, color: Colors.grey)),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: Icon(item.icon, size: 40, color: Colors.grey[400]),
                        ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(item.nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(
                      item.descrizione.isNotEmpty ? item.descrizione : "Nessuna descrizione disponibile",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '€${item.prezzo.toStringAsFixed(2)}',
                      style: TextStyle(color: brandColor, fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  final cartItem = CartItem(
                    id: item.id,
                    nome: item.nome,
                    prezzo: item.prezzo,
                    quantita: 1,
                    prenotazioneId: widget.prenotazioneId,
                  );
                  CartService().addItem(cartItem);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${item.nome} aggiunto al carrello!'), backgroundColor: brandColor, behavior: SnackBarBehavior.floating),
                  );
                },
                icon: Icon(Icons.add_circle_outline, color: brandColor, size: 30),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showItemDialog(MenuItem item) {
    List<Ingrediente> ingredientiModificabili = item.ingredienti
        .map((i) => Ingrediente(
              nome: i.nome,
              fotoUrl: i.fotoUrl,
              rimovibile: i.rimovibile,
              aggiungibile: i.aggiungibile,
              costoExtra: i.costoExtra,
              quantita: i.quantita,
            ))
        .toList();

    showDialog(
      context: context,
      builder: (context) => _ModificaPiattoDialog(
        item: item,
        ingredienti: ingredientiModificabili,
        prenotazioneId: widget.prenotazioneId,
        onConferma: (ingredientiFinali, prezzoTotale) {
          String noteModifiche = _generaNoteModifiche(item.ingredienti, ingredientiFinali);
          CartService().addItem(CartItem(
            id: item.id,
            nome: item.nome,
            prezzo: prezzoTotale,
            quantita: 1,
            note: noteModifiche.isNotEmpty ? noteModifiche : null,
            prenotazioneId: widget.prenotazioneId,
          ));

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${item.nome} aggiunto al carrello!'),
              backgroundColor: brandColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  String _generaNoteModifiche(List<Ingrediente> originali, List<Ingrediente> modificati) {
    List<String> note = [];

    for (int i = 0; i < modificati.length; i++) {
      final mod = modificati[i];
      final orig = originali.length > i ? originali[i] : null;

      if (orig != null) {
        if (mod.quantita == 0) note.add('Senza ${mod.nome.toLowerCase()}');
        else if (mod.quantita > orig.quantita) note.add('Extra ${mod.nome.toLowerCase()} (${mod.quantita - orig.quantita}x)');
      }
    }

    return note.join(', ');
  }
}

// Modifica Piatto Dialog
class _ModificaPiattoDialog extends StatefulWidget {
  final MenuItem item;
  final List<Ingrediente> ingredienti;
  final Function(List<Ingrediente>, double) onConferma;
  final String? prenotazioneId;

  const _ModificaPiattoDialog({required this.item, required this.ingredienti, required this.onConferma, this.prenotazioneId});

  @override
  State<_ModificaPiattoDialog> createState() => _ModificaPiattoDialogState();
}

class _ModificaPiattoDialogState extends State<_ModificaPiattoDialog> {
  late List<Ingrediente> _ingredienti;
  late double _prezzoTotale;

  @override
  void initState() {
    super.initState();
    _ingredienti = widget.ingredienti;
    _calcolaPrezzoTotale();
  }

  void _calcolaPrezzoTotale() {
    double extra = 0;
    for (var ing in _ingredienti) {
      if (ing.quantita > 1) extra += ing.costoExtra * (ing.quantita - 1);
    }
    setState(() => _prezzoTotale = widget.item.prezzo + extra);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 700, maxWidth: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [const Color(0xFF2A2A2A), Colors.grey.shade900]),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            if (widget.item.descrizione.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text(widget.item.descrizione, style: TextStyle(fontSize: 14, color: Colors.grey.shade300), textAlign: TextAlign.center),
              ),
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shrinkWrap: true,
                itemCount: _ingredienti.length,
                itemBuilder: (context, index) => _buildIngredienteCard(_ingredienti[index], index),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

   Widget _buildHeader() {
    return Stack(
      children: [
        Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            image: widget.item.imageUrl.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(widget.item.imageUrl),
                    fit: BoxFit.cover,
                  )
                : null,
            color: widget.item.imageUrl.isEmpty ? Colors.grey.shade800 : null,
          ),
          child: widget.item.imageUrl.isEmpty
              ? Center(
                  child: Icon(
                    widget.item.icon,
                    size: 80,
                    color: Colors.grey.shade600,
                  ),
                )
              : null,
        ),
        Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white),
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.item.nome,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.tune, color: Colors.white70, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    _ingredienti.isNotEmpty ? 'Personalizza il tuo piatto' : 'Aggiungi al carrello',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIngredienteCard(Ingrediente ing, int index) {
    final bool isRimosso = ing.quantita == 0;
    final bool hasExtra = ing.quantita > 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRimosso ? Colors.red.withOpacity(0.1) : Colors.grey.shade800,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRimosso 
              ? Colors.red.withOpacity(0.3)
              : hasExtra
                  ? const Color(0xFFF3A62D).withOpacity(0.5)
                  : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade700,
                image: ing.fotoUrl != null && ing.fotoUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(ing.fotoUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: ing.fotoUrl == null || ing.fotoUrl!.isEmpty
                  ? Icon(
                      Icons.fastfood,
                      color: Colors.grey.shade500,
                      size: 30,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ing.nome,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isRimosso ? Colors.red.shade300 : Colors.white,
                      decoration: isRimosso ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (hasExtra && ing.costoExtra > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3A62D).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '+€${(ing.costoExtra * (ing.quantita - 1)).toStringAsFixed(2)} extra',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFF3A62D),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (isRimosso)
                    Text(
                      'Rimosso',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade300,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
            Row(
              children: [
                if (ing.rimovibile && ing.quantita > 0)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _ingredienti[index].quantita--;
                        _calcolaPrezzoTotale();
                      });
                    },
                    icon: Icon(
                      ing.quantita == 1 ? Icons.remove_circle : Icons.remove_circle_outline,
                      color: ing.quantita == 1 ? Colors.red : const Color(0xFFFF4500),
                      size: 32,
                    ),
                  ),
                if (ing.quantita > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4500).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${ing.quantita}x',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF4500),
                      ),
                    ),
                  ),
                if (ing.aggiungibile || (isRimosso && ing.rimovibile))
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _ingredienti[index].quantita++;
                        _calcolaPrezzoTotale();
                      });
                    },
                    icon: Icon(
                      isRimosso ? Icons.add_circle : Icons.add_circle_outline,
                      color: isRimosso ? Colors.green : const Color(0xFFFF4500),
                      size: 32,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Prezzo totale:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '€${_prezzoTotale.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF3A62D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () {
                // ✅ Aggiungi il piatto con prenotazioneId
                CartService().addItem(
                  CartItem(
                    id: widget.item.id,
                    nome: widget.item.nome,
                    prezzo: _prezzoTotale,
                    quantita: 1,
                    prenotazioneId: widget.prenotazioneId,
                  ),
                );
                Navigator.pop(context);
              },
              icon: const Icon(Icons.shopping_cart, size: 24),
              label: const Text(
                'AGGIUNGI AL CARRELLO',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4500),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
