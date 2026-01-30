import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/cart_service.dart';
import 'home_page.dart';
import '../utils/auth_guard.dart';

class OrdinePage extends StatefulWidget {
  final String prenotazioneId;

  const OrdinePage({super.key, required this.prenotazioneId});

  @override
  State<OrdinePage> createState() => _OrdinePageState();
}

class _OrdinePageState extends State<OrdinePage> {
  final CartService _cartService = CartService();
  bool _isConfirming = false;

  Future<void> _confermOrdine() async {
    // ✅ CONTROLLO AUTENTICAZIONE - Prima verifica se è loggato
    if (!await checkAuthAndRedirect(context)) {
      return; // Non autenticato, è già stato reindirizzato
    }

    final totale = _cartService.totale;

    if (totale <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aggiungi articoli al carrello')),
      );
      return;
    }

    setState(() => _isConfirming = true);

    try {
      // 💾 Salva l'ordine in Firestore collegato alla prenotazione
      await _cartService.saveOrder(widget.prenotazioneId);

      if (!mounted) return;

      // 🎉 Mostra dialogo di ringraziamento
      _showThankYouDialog(totale);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isConfirming = false);
    }
  }

  void _showThankYouDialog(double totale) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Ordine confermato!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Grazie per il tuo ordine!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Prepareremo tutto per la tua prenotazione.\n\nCi vediamo presto al ristorante! 🍽️',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFD94C1B).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Totale: €${totale.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFFD94C1B),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Svuota carrello e torna a home
              _cartService.clear();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
                (route) => false,
              );
            },
            child: const Text(
              'OK',
              style: TextStyle(
                color: Color(0xFFD94C1B),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riepilogo Ordine'),
        backgroundColor: const Color(0xFFD94C1B),
      ),
      backgroundColor: const Color(0xFF121212),
      body: StreamBuilder(
        stream: _cartService.items,
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];
          final totale = _cartService.totale;

          return Column(
            children: [
              Expanded(
                child: items.isEmpty
                    ? const Center(
                        child: Text(
                          'Carrello vuoto',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return Card(
                            color: const Color(0xFF1E1E1E),
                            child: ListTile(
                              title: Text(
                                item.nome,
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                '€${item.prezzo.toStringAsFixed(2)} x ${item.quantita}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                ),
                              ),
                              trailing: Text(
                                '€${(item.prezzo * item.quantita).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Color(0xFFD94C1B),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade700),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Totale:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '€${totale.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFFD94C1B),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isConfirming ? null : _confermOrdine,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD94C1B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isConfirming
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Conferma Ordine',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
