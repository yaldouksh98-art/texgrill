import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (int page) => setState(() => _currentPage = page),
            children: [
              _buildPage(
                icon: Icons.restaurant_menu,
                title: "Benvenuto in TexGrill!",
                description: "Il tuo ristorante preferito, ora sempre a portata di mano",
                color: Colors.deepOrange,
              ),
              _buildPage(
                icon: Icons.stars,
                title: "Accumula Punti",
                description: "Ogni ordine ti fa guadagnare punti. Più ordini, più premi!",
                color: Colors.amber,
              ),
              _buildPage(
                icon: Icons.card_giftcard,
                title: "Gira la Ruota",
                description: "Ogni settimana puoi girare la ruota e vincere premi esclusivi",
                color: Colors.purple,
              ),
              _buildPage(
                icon: Icons.phone_android,
                title: "Ordina e Ritira",
                description: "Ordina dal menu, paga e ritira quando vuoi tu. Semplice e veloce!",
                color: Colors.green,
              ),
            ],
          ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) => _buildDot(index)),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _currentPage == 3
                ? ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text("INIZIA ORA", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  )
                : TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                    child: const Text("SALTA", style: TextStyle(color: Colors.white54)),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage({required IconData icon, required String title, required String description, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 120, color: color),
          const SizedBox(height: 40),
          Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Text(description, style: const TextStyle(fontSize: 16, color: Colors.white70), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      width: _currentPage == index ? 12 : 8,
      height: _currentPage == index ? 12 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.amber : Colors.white38,
        shape: BoxShape.circle,
      ),
    );
  }
}
