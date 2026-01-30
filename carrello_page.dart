import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/cart_service.dart';
import '../models/cart_item.dart';
import 'menu_page.dart';
import '../utils/auth_guard.dart';
import '../utils/order_rate_limiter.dart';

class CarrelloPage extends StatefulWidget {
  const CarrelloPage({super.key});

  @override
  State<CarrelloPage> createState() => _CarrelloPageState();
}

class _CarrelloPageState extends State<CarrelloPage> with SingleTickerProviderStateMixin {
  final CartService _cartService = CartService();
  final _noteController = TextEditingController();
  String _orarioRitiro = 'Il prima possibile';
  String _metodoPagamento = 'Contanti alla consegna';
  bool _isLoading = false;
  bool _orderCompleted = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _orderCompleted = false;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_orderCompleted) {
      return _buildOrderCompletedScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Il tuo Carrello',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFFD94C1B),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          StreamBuilder<List<CartItem>>(
            stream: _cartService.items,
            initialData: _cartService.currentItems,
            builder: (context, snapshot) {
              final items = snapshot.data ?? [];
              if (items.isEmpty) return const SizedBox();
              
              return TextButton.icon(
                onPressed: () => _confermaRimuoviTutto(),
                icon: const Icon(Icons.delete_sweep, color: Colors.white),
                label: const Text(
                  'Svuota',
                  style: TextStyle(color: Colors.white),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<CartItem>>(
        stream: _cartService.items,
        initialData: _cartService.currentItems,
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];
          
          if (items.isEmpty) {
            return _buildEmptyCart();
          }

          final totale = _cartService.totale;
          final punti = _calcolaPunti(totale);

          return FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildHeaderSummary(items.length, totale),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildCartItemCard(item);
                    },
                  ),
                ),
                _buildCheckoutBox(items, totale, punti),
              ],
            ),
          );
        },
      ),
    );
  }

  // ✅ FIX #1: Sostituito WillPopScope con PopScope
  Widget _buildOrderCompletedScreen() {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 100,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                const Text(
                  'Ordine Inviato!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Il tuo ordine è in preparazione',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                        },
                        icon: const Icon(Icons.restaurant_menu),
                        label: const Text(
                          'TORNA AL MENU',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD94C1B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                          // TODO: Navigate to storico ordini tab
                        },
                        icon: const Icon(Icons.history, color: Color(0xFFF3A62D)),
                        label: const Text(
                          'VEDI I MIEI ORDINI',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF3A62D),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFF3A62D)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Container(
      color: const Color(0xFF121212),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 120,
              color: Colors.grey.shade700,
            ),
            const SizedBox(height: 24),
            Text(
              'Il carrello è vuoto',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aggiungi piatti per iniziare',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.restaurant_menu),
              label: const Text('Sfoglia il Menu'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD94C1B),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSummary(int itemCount, double totale) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD94C1B).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.shopping_bag,
                  color: Color(0xFFD94C1B),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$itemCount ${itemCount == 1 ? "articolo" : "articoli"}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Totale: €${totale.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF3A62D).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '+${_calcolaPunti(totale)} 🌮',
              style: const TextStyle(
                color: Color(0xFFF3A62D),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(CartItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade900,
              Colors.grey.shade800,
            ],
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
                  color: const Color(0xFFD94C1B).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.restaurant,
                  color: Color(0xFFD94C1B),
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nome,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '€${item.prezzo.toStringAsFixed(2)} cad.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    if (item.note != null && item.note!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.note, size: 12, color: Colors.blue),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                item.note!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.blue,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          item.quantita > 1 ? Icons.remove_circle : Icons.delete,
                          color: item.quantita > 1 
                              ? const Color(0xFFD94C1B)
                              : Colors.red,
                          size: 28,
                        ),
                        onPressed: () {
                          if (item.quantita > 1) {
                            _cartService.updateQuantity(item.id, item.quantita - 1);
                          } else {
                            _confermaRimozioneItem(item);
                          }
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD94C1B).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${item.quantita}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD94C1B),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle,
                          color: Color(0xFFD94C1B),
                          size: 28,
                        ),
                        onPressed: () => _cartService.updateQuantity(item.id, item.quantita + 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tot: €${(item.prezzo * item.quantita).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF3A62D),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckoutBox(List<CartItem> items, double totale, int punti) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOptionSelector(
              icon: Icons.access_time,
              label: 'Orario di ritiro',
              value: _orarioRitiro,
              options: [
                'Il prima possibile',
                '12:00 - 12:30',
                '12:30 - 13:00',
                '13:00 - 13:30',
                '19:00 - 19:30',
                '19:30 - 20:00',
                '20:00 - 20:30',
                '20:30 - 21:00',
              ],
              onChanged: (v) => setState(() => _orarioRitiro = v!),
            ),
            const SizedBox(height: 16),
            
            _buildOptionSelector(
              icon: Icons.payment,
              label: 'Metodo di pagamento',
              value: _metodoPagamento,
              options: [
                'Contanti alla consegna',
                'Carta alla consegna',
                'Satispay',
              ],
              onChanged: (v) => setState(() => _metodoPagamento = v!),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _noteController,
              maxLines: 2,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Note per l\'ordine (opzionale)',
                labelStyle: const TextStyle(color: Color(0xFFF3A62D)),
                hintText: 'Es: Senza cipolla, piccante...',
                hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                prefixIcon: const Icon(Icons.note_alt, color: Color(0xFFF3A62D)),
                filled: true,
                fillColor: Colors.grey.shade900,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Subtotale:',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Text(
                        '€${totale.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                  const Divider(height: 20, color: Colors.grey),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTALE:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '€${totale.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFFD94C1B),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Punti guadagnati:',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3A62D).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '+$punti 🌮',
                          style: const TextStyle(
                            color: Color(0xFFF3A62D),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _confermaOrdine(items, totale, punti),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD94C1B),
                  disabledBackgroundColor: Colors.grey.shade700,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Invio in corso...',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.check_circle, color: Colors.white, size: 28),
                          SizedBox(width: 12),
                          Text(
                            'CONFERMA ORDINE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionSelector({
    required IconData icon,
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        dropdownColor: Colors.grey.shade900,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFFF3A62D)),
          prefixIcon: Icon(icon, color: const Color(0xFFF3A62D)),
          border: InputBorder.none,
        ),
        items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  int _calcolaPunti(double totale) {
    return totale.toInt();
  }

  Future<void> _confermaRimozioneItem(CartItem item) async {
    final conferma = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.delete_outline, color: Colors.red),
            SizedBox(width: 10),
            Text('Rimuovi articolo'),
          ],
        ),
        content: Text('Vuoi rimuovere "${item.nome}" dal carrello?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ANNULLA'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('RIMUOVI'),
          ),
        ],
      ),
    );

    if (conferma == true) {
      _cartService.updateQuantity(item.id, 0);
    }
  }

  Future<void> _confermaRimuoviTutto() async {
    final conferma = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 10),
            Text('Svuota carrello'),
          ],
        ),
        content: const Text('Sei sicuro di voler rimuovere tutti gli articoli dal carrello?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ANNULLA'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('SVUOTA'),
          ),
        ],
      ),
    );

    if (conferma == true) {
      _cartService.clear();
    }
  }

  Future<void> _confermaOrdine(List<CartItem> items, double totale, int punti) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _mostraErrore('Devi effettuare il login per ordinare');
      return;
    }

    if (_orarioRitiro.isEmpty) {
      _mostraErrore('Seleziona un orario di ritiro');
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('🚀 Inizio invio ordine...');
      
      // ✅ FIX #2: RIMOSSA VALIDAZIONE DUPLICATA (linee 833-839 eliminate)
      // Rate limiting check
      final result = await OrderRateLimiter.checkCanOrder(user.uid);
      if (!result.canOrder) {
        setState(() => _isLoading = false);
        _mostraErrore('${result.message} (${result.remainingSeconds}s)');
        return;
      }
      
      // Ottieni dati utente
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .timeout(const Duration(seconds: 10));

      print('✅ Dati utente recuperati');

      final userData = userDoc.data() ?? {};
      final userName = userData['nome'] ?? user.displayName ?? 'Cliente';
      final userEmail = userData['email'] ?? user.email ?? '';

      // Crea gli ordini UNO ALLA VOLTA
      print('📦 Creazione ${items.length} ordini...');
      
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        print('  Ordine ${i + 1}/${items.length}: ${item.nome}');
        
        await FirebaseFirestore.instance
            .collection('ordini_totali')
            .add({
              'userId': user.uid,
              'cliente_nome': userName,
              'cliente_email': userEmail,
              'nome': item.nome,
              'quantita': item.quantita,
              'prezzo': item.prezzo,
              'note': item.note ?? '',
              'orarioRitiro': _orarioRitiro,
              'metodoPagamento': _metodoPagamento,
              'noteOrdine': _noteController.text.trim(),
              'stato': 'In attesa',
              'puntiAssegnati': (item.prezzo * item.quantita).toInt(),
              'timestamp': FieldValue.serverTimestamp(),
            })
            .timeout(const Duration(seconds: 10));
        
        print('  ✅ Ordine ${i + 1} creato');
      }

      print('✅ Tutti gli ordini creati');

      // Aggiorna i punti
      print('⭐ Aggiornamento punti...');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'punti': FieldValue.increment(punti)})
          .timeout(const Duration(seconds: 10));

      print('✅ Punti aggiornati');

      // Pulisci carrello
      print('🧹 Pulizia carrello...');
      _cartService.clear();
      _noteController.clear();

      if (!mounted) {
        print('⚠️ Widget non più montato');
        return;
      }

      print('✅ Ordine completato con successo!');

      // Aggiorna UI
      setState(() {
        _orderCompleted = true;
        _isLoading = false;
      });

      // Mostra conferma
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Ordine inviato! Hai guadagnato $punti punti 🌮'),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );

    } on TimeoutException catch (e) {
      print('❌ TIMEOUT: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        _mostraErrore('Timeout: la connessione è troppo lenta. Riprova.');
      }
    } on FirebaseException catch (e) {
      print('❌ FIREBASE ERROR: ${e.code} - ${e.message}');
      if (mounted) {
        setState(() => _isLoading = false);
        _mostraErrore('Errore Firebase: ${e.message}');
      }
    } catch (e, stackTrace) {
      print('❌ ERRORE GENERICO: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        setState(() => _isLoading = false);
        _mostraErrore('Errore imprevisto: ${e.toString()}');
      }
    } finally {
      // ✅ GARANTISCI che _isLoading si fermi sempre
      if (mounted && _isLoading) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _mostraErrore(String messaggio) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(messaggio)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
