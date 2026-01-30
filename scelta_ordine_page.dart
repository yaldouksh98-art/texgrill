import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ordine_page.dart';
import 'menu_page.dart';
import 'home_page.dart';
import 'login_page.dart';

class SceltaOrdinePage extends StatefulWidget {
  final String prenotazioneId;

  const SceltaOrdinePage({super.key, required this.prenotazioneId});

  @override
  State<SceltaOrdinePage> createState() => _SceltaOrdinePageState();
}

class _SceltaOrdinePageState extends State<SceltaOrdinePage> {
  bool _isLoading = false;

  Future<void> _ordinaSubito() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginPage(),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 📝 Aggiorna la prenotazione per indicare che il cliente ordina subito
      await FirebaseFirestore.instance
          .collection('prenotazioni')
          .doc(widget.prenotazioneId)
          .update({
        'ordinazioneGia': true,
      });

      if (!mounted) return;

      // 🍽️ Vai al menu per ordinare
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MenuPage(
            prenotazioneId: widget.prenotazioneId,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _ordinaAlTavolo() async {
    setState(() => _isLoading = true);

    try {
      // 📝 Aggiorna la prenotazione per indicare che il cliente ordina al tavolo
      await FirebaseFirestore.instance
          .collection('prenotazioni')
          .doc(widget.prenotazioneId)
          .update({
        'ordinazioneGia': false,
      });

      if (!mounted) return;

      // 🏠 Mostra dialogo di ringraziamento e torna a home
      _showThankYouDialog(
        title: 'Grazie per la prenotazione!',
        message:
            'Non vediamo l\'ora di vederti al ristorante.\n\nPotrai ordinare comodamente al tavolo.',
        onDismiss: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
            (route) => false,
          );
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showThankYouDialog({
    required String title,
    required String message,
    required VoidCallback onDismiss,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDismiss();
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
        title: const Text('Prenotazione Confermata'),
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFD94C1B),
      ),
      backgroundColor: const Color(0xFF121212),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              'Prenotazione Confermata!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ti vediamo presto al nostro ristorante',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),

            // 🟧 ORDINA SUBITO
            Card(
              color: const Color(0xFF1E1E1E),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: const Icon(Icons.restaurant_menu,
                    color: Colors.amber, size: 32),
                title: const Text(
                  'Vuoi ordinare subito?',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: const Text(
                  'Prepariamo solo quando arrivi al ristorante',
                  style: TextStyle(color: Colors.white70),
                ),
                onTap: _isLoading ? null : _ordinaSubito,
                enabled: !_isLoading,
              ),
            ),

            const SizedBox(height: 20),

            // 🟦 ORDINA AL TAVOLO
            Card(
              color: const Color(0xFF1E1E1E),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: const Icon(Icons.event_seat,
                    color: Colors.lightBlue, size: 32),
                title: const Text(
                  'No, ordino al tavolo',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: const Text(
                  'Ordinerai comodamente una volta seduto',
                  style: TextStyle(color: Colors.white70),
                ),
                onTap: _isLoading ? null : _ordinaAlTavolo,
                enabled: !_isLoading,
              ),
            ),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 30),
                child: CircularProgressIndicator(
                  color: Color(0xFFD94C1B),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
