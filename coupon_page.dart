import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CouponPage extends StatelessWidget {
  const CouponPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text(
          "I MIEI COUPON",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        backgroundColor: Colors.orange.shade900,
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Errore nel caricamento", style: TextStyle(color: Colors.white)));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.orange));

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final List premiVinti = data?['premi_vinti'] ?? [];

          // ✅ LOGICA FILTRI (Senza eliminare dati)
          // Coupon attivi o ancora da attivare
          final couponAttivi = premiVinti.where((p) => p['stato'] != 'usato').toList();
          // Coupon marchiati come 'usato' dall'App Admin
          final storicoCoupon = premiVinti.where((p) => p['stato'] == 'usato').toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // --- SEZIONE ATTIVI ---
              if (couponAttivi.isNotEmpty) ...[
                const Text(
                  "PREMI DISPONIBILI",
                  style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.1),
                ),
                const SizedBox(height: 12),
                ...couponAttivi.map((p) => _buildCouponItem(p, isUsed: false)).toList(),
              ] else if (storicoCoupon.isEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      "Non hai ancora premi disponibili.\nTorna a girare la ruota! 🎡",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white38, fontSize: 16),
                    ),
                  ),
                ),
              ],

              // --- SEZIONE STORICO (Solo se ci sono coupon usati) ---
              if (storicoCoupon.isNotEmpty) ...[
                const SizedBox(height: 30),
                Row(
                  children: const [
                    Icon(Icons.history, color: Colors.white38, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "STORICO PREMI RISCATTATI",
                      style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                const Divider(color: Colors.white12, thickness: 1),
                const SizedBox(height: 10),
                ...storicoCoupon.map((p) => _buildCouponItem(p, isUsed: true)).toList(),
              ],
            ],
          );
        },
      ),
    );
  }

  // ✅ WIDGET CARD ORIGINALE CON STILE AGGIORNATO PER LO STORICO
  Widget _buildCouponItem(Map<String, dynamic> coupon, {required bool isUsed}) {
    return Opacity(
      opacity: isUsed ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isUsed ? Colors.transparent : Colors.orange.withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: isUsed ? [] : [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 5, offset: const Offset(0, 3)),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isUsed ? Colors.grey.shade800 : Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isUsed ? Icons.check : Icons.local_activity,
              color: isUsed ? Colors.white24 : Colors.orange,
            ),
          ),
          title: Text(
            coupon['nome']?.toUpperCase() ?? "PREMIO",
            style: TextStyle(
              color: isUsed ? Colors.white38 : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              decoration: isUsed ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              isUsed 
                ? "Utilizzato il ${_formatDate(coupon['data_riscatto'])}" 
                : _getSubtitleStatus(coupon),
              style: TextStyle(
                color: isUsed ? Colors.white24 : Colors.white70, 
                fontSize: 13,
                fontStyle: isUsed ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
          trailing: isUsed 
            ? const Text("USATO", style: TextStyle(color: Colors.white12, fontWeight: FontWeight.bold))
            : const Icon(Icons.arrow_forward_ios, color: Colors.orange, size: 14),
        ),
      ),
    );
  }

  String _getSubtitleStatus(Map<String, dynamic> coupon) {
    if (coupon['stato'] == 'attivo') {
      return "Mostra in cassa - Scade tra ${_calcolaScadenza(coupon['data_attivazione'])}";
    }
    return "Non ancora attivato";
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "n/d";
    try {
      DateTime date = (timestamp as Timestamp).toDate();
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return "n/d";
    }
  }

  String _calcolaScadenza(dynamic dataAttivazione) {
    if (dataAttivazione == null) return "48h";
    try {
      DateTime inizio = (dataAttivazione as Timestamp).toDate();
      DateTime scadenza = inizio.add(const Duration(hours: 48));
      Duration rimante = scadenza.difference(DateTime.now());
      
      if (rimante.isNegative) return "Scaduto";
      if (rimante.inHours > 0) return "${rimante.inHours}h";
      return "${rimante.inMinutes}m";
    } catch (e) {
      return "48h";
    }
  }
}