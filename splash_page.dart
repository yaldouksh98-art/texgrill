import 'package:flutter/material.dart'; // Fondamentale per i widget grafici
import 'package:firebase_auth/firebase_auth.dart'; // Fondamentale per controllare l'utente
import 'dart:async'; // Per gestire il timer della splash
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () async {
      if (!mounted) return;
      
      // Controlla se è la prima volta
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A1A), Color(0xFF000000)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network('https://i.ibb.co/RJGPBPs/Chat-GPT-Image-2-gen-2026-23-48-48.png', width: 280),
              const SizedBox(height: 30),
              const CircularProgressIndicator(color: Colors.amber),
            ],
          ),
        ),
      ),
    );
  }
}