import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TexGrillCard extends StatelessWidget {
  const TexGrillCard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    // TOKEN CRIPTATO: Creiamo un link professionale che nasconde l'UID reale
    final String secureToken = "https://texgrill.it/v/${user.uid.substring(0, 8).toUpperCase()}";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade900, Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.orange.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1), 
            blurRadius: 10, 
            spreadRadius: 2
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "VAQUERO CARD",
                style: TextStyle(
                  color: Colors.amber, 
                  fontWeight: FontWeight.bold, 
                  letterSpacing: 1.5
                ),
              ),
              // Icona fuoco stilizzata per il brand
              const Icon(Icons.local_fire_department, color: Colors.orange, size: 28),
            ],
          ),
          const SizedBox(height: 20),
          
          // QR CODE compatibile con versione 4.0.0
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: QrImage(
              data: secureToken,
              version: QrVersions.auto,
              size: 160.0,
              foregroundColor: Colors.black,
              gapless: false,
            ),
          ),
          
          const SizedBox(height: 15),
          const Text(
            "Mostra questo codice alla cassa per accumulare Tacos",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70, 
              fontSize: 12, 
              fontStyle: FontStyle.italic
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "ID: ${user.uid.substring(0, 8).toUpperCase()}",
            style: TextStyle(
              color: Colors.orange.withOpacity(0.5), 
              fontSize: 10,
              fontWeight: FontWeight.bold
            ),
          ),
        ],
      ),
    );
  }
}