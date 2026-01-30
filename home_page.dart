import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

// Pagine e widget
import 'prenotazione_page.dart';
import '../widgets/home_carousel.dart';
import '../widgets/lucky_wheel_dialog.dart';
import '../models/livello.dart';
import '../widgets/texgrill_card.dart';

// Pagine per la navigazione
import 'menu_page.dart';
import 'carrello_page.dart';
import 'storico_ordini_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? user;
  int punti = 0;
  int _selectedIndex = 0;
  List couponVinti = [];
  DateTime? ultimoGiro;
  String countdownText = "";
  Timer? _timer;
  String? nomeUtente;

  String? prenotazioneId;
  bool prenotazioneAttiva = false;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((u) {
      if (mounted) setState(() => user = u);

      if (u != null) {
        FirebaseFirestore.instance.collection('users').doc(u.uid).snapshots().listen((s) {
          if (mounted && s.exists) {
            final data = s.data()!;
            setState(() {
              punti = data['punti'] ?? 0;
              nomeUtente = data['nome'];
              couponVinti = data['premi_vinti'] ?? [];
              if (data['ultimo_giro'] != null) {
                ultimoGiro = (data['ultimo_giro'] as Timestamp).toDate();
              }

              prenotazioneId = data['prenotazione_attiva']?['id'];
              prenotazioneAttiva = prenotazioneId != null;
            });
            _startCountdown();
          }
        });
      }
    });
  }

  void _startCountdown() {
    _timer?.cancel();
    if (ultimoGiro == null) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final diff = ultimoGiro!.add(const Duration(days: 7)).difference(DateTime.now());
      if (diff.isNegative) {
        if (mounted) setState(() => countdownText = "");
        t.cancel();
      } else {
        if (mounted) setState(() => countdownText = "${diff.inDays}g ${diff.inHours % 24}h ${diff.inMinutes % 60}m");
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formattaNome(String? nome) {
    if (nome == null || nome.isEmpty) return "Vaquero";
    return nome[0].toUpperCase() + nome.substring(1).toLowerCase();
  }

  Widget _buildBody(Livello liv) {
    switch (_selectedIndex) {
      case 1: 
        return MenuPage(prenotazioneId: prenotazioneId); // ✅ passa prenotazioneId
      case 2: 
        return const CarrelloPage();
      case 3: 
        return const StoricoOrdiniPage();
      default: 
        return _buildHomeContent(liv);
    }
  }

  Widget _buildLuckyWheelSection() {
    bool canSpin = countdownText.isEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const LuckyWheelDialog(),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: canSpin
                  ? [Colors.orange.shade800, Colors.red.shade900]
                  : [Colors.grey.shade800, Colors.black],
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: canSpin ? Colors.amber : Colors.orange.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.stars,
                color: canSpin ? Colors.amber : Colors.orange.withOpacity(0.5),
                size: 40,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "GIRA LA RUOTA!",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      canSpin ? "Vinci dei premi speciali 🌮" : "Prossimo giro tra: $countdownText",
                      style: TextStyle(color: canSpin ? Colors.white70 : Colors.orange.shade200, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.remove_red_eye_outlined, color: Colors.white70, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent(Livello liv) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: const Color(0xFF2A2A2A),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF2A2A2A), Color(0xFF0F0F0F)],
                ),
              ),
              child: Center(
                child: Image.network(
                  'https://i.ibb.co/RJGPBPs/Chat-GPT-Image-2-gen-2026-23-48-48.png',
                  width: 200,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.restaurant, color: Colors.amber, size: 50),
                ),
              ),
            ),
          ),
          actions: [
            if (user != null)
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (mounted) Navigator.pushReplacementNamed(context, '/login');
                },
              ),
          ],
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            const HomeCarousel(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Text(
                "Ciao, ${_formattaNome(nomeUtente)}! 🌵",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            // --- PRENOTAZIONE & ORDINE ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton.icon(
                onPressed: () {
                  if (prenotazioneAttiva) {
                    // Se ha una prenotazione attiva, vai al menu per ordinare
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MenuPage(prenotazioneId: prenotazioneId),
                      ),
                    );
                  } else {
                    // Se non ha prenotazione, apri la pagina di prenotazione
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PrenotazionePage(),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.restaurant_menu),
                label: Text(prenotazioneAttiva ? 'Ordina per evitare lunghe attese' : 'Prenota un tavolo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD94C1B),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),

            if (user != null) ...[
              _buildLuckyWheelSection(),
              _buildStatusCard(liv),
              const TexGrillCard(),

              // Storico premi e note
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/coupon'),
                      icon: const Icon(Icons.wallet_giftcard, size: 20),
                      label: const Text("STORICO PREMI E SHOP TACOS"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E1E1E),
                        foregroundColor: Colors.amber,
                        minimumSize: const Size(double.infinity, 48),
                        side: BorderSide(color: Colors.amber.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        "Nota: una volta attivato un coupon, hai a disposizione 48 ore per usarlo.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ]),
        ),
      ],
    );
  }

  Widget _buildStatusCard(Livello liv) {
    return Card(
      margin: const EdgeInsets.all(16),
      color: const Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(liv.nome, style: const TextStyle(color: Colors.amber, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("$punti TACOS ACCUMULATI 🌮", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (punti % 1000) / 1000,
              backgroundColor: Colors.black,
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final liv = livelliTexGrill.lastWhere(
      (g) => punti >= g.puntiRichiesti,
      orElse: () => livelliTexGrill[0],
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: _buildBody(liv),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1A1A1A),
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profilo'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Menu'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Carrello'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Ordini'),
        ],
      ),
    );
  }
}
