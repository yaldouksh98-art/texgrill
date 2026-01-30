import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/login_page.dart';

/// Controlla se l'utente è autenticato, altrimenti lo reindirizza al login
Future<bool> checkAuthAndRedirect(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;
  
  if (user == null) {
    // ❌ Non autenticato → Mostra dialogo e reindirizza
    if (!context.mounted) return false;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.lock_outline, color: Colors.orange),
            SizedBox(width: 10),
            Text('Accesso Richiesto', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          'Devi effettuare il login per accedere a questa funzione.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annulla', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx); // Chiudi dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4500),
            ),
            child: const Text('Vai al Login'),
          ),
        ],
      ),
    );
    
    return false; // Non autenticato
  }
  
  return true; // ✅ Autenticato
}
