import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:math';
import '../utils/auth_guard.dart';

class LuckyWheelDialog extends StatefulWidget {
  const LuckyWheelDialog({super.key});

  @override
  State<LuckyWheelDialog> createState() => _LuckyWheelDialogState();
}

class _LuckyWheelDialogState extends State<LuckyWheelDialog> {
  final StreamController<int> _controller = StreamController<int>();
  bool _isSpinning = false;
  bool _canSpin = true;

  // Premi aggiornati con terminologia Tacos
  final List<String> _premi = [
    '5 Tacos',
    '10 Tacos',
    'Sconto 5%',
    '20 Tacos',
    'Sconto 10%',
    '50 Tacos',
    'Niente',
    '100 Tacos',
  ];

  @override
  void initState() {
    super.initState();
    // ✅ Controlla autenticazione - se non loggato, chiudi il dialog
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    if (FirebaseAuth.instance.currentUser == null) {
      // ❌ Non autenticato
      if (!mounted) return;
      Navigator.pop(context); // Chiudi il dialog
      // Il parent farà il controllo auth_guard
    } else {
      // ✅ Autenticato - controlla se può girare
      _checkCanSpin();
    }
  }

  Future<void> _checkCanSpin() async {
    final user = FirebaseAuth.instance.currentUser!;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final lastSpin = doc.data()?['ultimo_giro'] as Timestamp?; // Nome campo allineato alla HomePage

    if (lastSpin != null) {
      final now = DateTime.now();
      final lastSpinDate = lastSpin.toDate();
      final difference = now.difference(lastSpinDate);

      // ✅ CONTROLLO SETTIMANALE: 7 giorni = 168 ore
      if (difference.inDays < 7) {
        setState(() {
          _canSpin = false;
        });
      }
    }
  }

  Future<void> _spin() async {
    if (!_canSpin || _isSpinning) return;

    setState(() {
      _isSpinning = true;
    });

    final random = Random().nextInt(_premi.length);
    _controller.add(random);

    await Future.delayed(const Duration(seconds: 4));

    final premio = _premi[random];
    await _assegnaPremio(premio);

    if (!mounted) return;

    setState(() {
      _isSpinning = false;
      _canSpin = false;
    });

    _mostraPremio(premio);
  }

  Future<void> _assegnaPremio(String premio) async {
    final user = FirebaseAuth.instance.currentUser!;
    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    await userRef.update({
      'ultimo_giro': FieldValue.serverTimestamp(),
    });

    if (premio.contains('Tacos')) {
      final punti = int.parse(premio.split(' ')[0]);
      await userRef.update({
        'punti': FieldValue.increment(punti),
      });
    } else if (premio.contains('Sconto')) {
      final sconto = premio.split(' ')[1];
      await FirebaseFirestore.instance.collection('premi_vinti').add({
        'userId': user.uid,
        'premio': "Sconto $sconto",
        'usato': false,
        'data_vincita': FieldValue.serverTimestamp(),
      });
    }
  }

  void _mostraPremio(String premio) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Complimenti!', style: TextStyle(color: Colors.amber)),
        content: Text(
          premio == 'Niente'
              ? 'Peccato! Riprova la prossima settimana!'
              : 'Hai vinto: $premio\nIl premio è stato aggiunto al tuo account!',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Chiude l'alert
              Navigator.pop(context); // Chiude la ruota
            },
            child: const Text('OTTIMO!', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'RUOTA DEI TACOS',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),
            
            // Ruota semplificata
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.orange.shade800, Colors.orange.shade600],
                ),
                border: Border.all(color: Colors.amber, width: 4),
              ),
              child: Center(
                child: Text(
                  _isSpinning ? '🎡' : '🌮',
                  style: const TextStyle(fontSize: 80),
                ),
              ),
            ),
            
            const SizedBox(height: 25),
            
            // Pulsante dinamico
            ElevatedButton(
              onPressed: (_isSpinning || !_canSpin) ? null : _spin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                disabledBackgroundColor: Colors.grey.shade900,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _isSpinning 
                  ? 'GIRANDO...' 
                  : (_canSpin ? 'GIRA E VINCI! 🌮' : 'DISPONIBILE TRA 7 GIORNI'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            
            if (!_canSpin && !_isSpinning)
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  'Puoi girare la ruota una volta a settimana!',
                  style: TextStyle(color: Colors.orangeAccent, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
              
            const SizedBox(height: 10),
            TextButton(
              onPressed: _isSpinning ? null : () => Navigator.pop(context),
              child: const Text('Torna alla Home', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}