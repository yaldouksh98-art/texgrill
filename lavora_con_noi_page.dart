import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LavoraConNoiPage extends StatefulWidget {
  const LavoraConNoiPage({super.key});

  @override
  State<LavoraConNoiPage> createState() => _LavoraConNoiPageState();
}

class _LavoraConNoiPageState extends State<LavoraConNoiPage> {
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _messaggioCtrl = TextEditingController();
  String? selectedRole;
  bool sending = false;

  final List<Map<String, dynamic>> ruoli = [
    {'titolo': 'Cuoco/a', 'descrizione': 'Responsabile cucina e preparazione piatti', 'icon': Icons.restaurant},
    {'titolo': 'Cameriere/a', 'descrizione': 'Servizio clienti in sala', 'icon': Icons.room_service},
    {'titolo': 'Cassiere/a', 'descrizione': 'Gestione cassa e ordini', 'icon': Icons.point_of_sale},
    {'titolo': 'Addetto/a Delivery', 'descrizione': 'Consegne a domicilio', 'icon': Icons.delivery_dining},
  ];

  Future<void> _inviaCandidatura() async {
    if (_nomeCtrl.text.isEmpty || _emailCtrl.text.isEmpty || _telefonoCtrl.text.isEmpty || selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Compila tutti i campi obbligatori")),
      );
      return;
    }

    setState(() => sending = true);

    try {
      await FirebaseFirestore.instance.collection('candidature').add({
        'nome': _nomeCtrl.text,
        'email': _emailCtrl.text,
        'telefono': _telefonoCtrl.text,
        'ruolo': selectedRole,
        'messaggio': _messaggioCtrl.text,
        'data': DateTime.now().toIso8601String(),
        'stato': 'Nuova',
      });

      setState(() => sending = false);
      _nomeCtrl.clear();
      _emailCtrl.clear();
      _telefonoCtrl.clear();
      _messaggioCtrl.clear();
      setState(() => selectedRole = null);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 30),
              const SizedBox(width: 10),
              const Text("CANDIDATURA INVIATA"),
            ],
          ),
          content: const Text("Grazie per il tuo interesse! Ti contatteremo presto."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
          ],
        ),
      );
    } catch (e) {
      setState(() => sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Errore durante l'invio")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("LAVORA CON NOI")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.work_outline, size: 60, color: Colors.amber),
            const SizedBox(height: 15),
            const Text("Unisciti al Team TexGrill!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text(
              "Siamo sempre alla ricerca di persone motivate e appassionate. Inviaci la tua candidatura!",
              style: TextStyle(color: Colors.white70, height: 1.5),
            ),
            const SizedBox(height: 30),
            const Text("POSIZIONI APERTE:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
            const SizedBox(height: 15),
            ...ruoli.map((ruolo) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: RadioListTile<String>(
                value: ruolo['titolo'],
                groupValue: selectedRole,
                onChanged: (val) => setState(() => selectedRole = val),
                title: Row(
                  children: [
                    Icon(ruolo['icon'], color: Colors.amber, size: 25),
                    const SizedBox(width: 10),
                    Text(ruolo['titolo'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                subtitle: Text(ruolo['descrizione'], style: const TextStyle(fontSize: 12, color: Colors.white60)),
                activeColor: Colors.amber,
              ),
            )),
            const SizedBox(height: 30),
            const Text("I TUOI DATI:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
            const SizedBox(height: 15),
            TextField(
              controller: _nomeCtrl,
              decoration: InputDecoration(
                labelText: "Nome e Cognome *",
                prefixIcon: const Icon(Icons.person, color: Colors.amber),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white10,
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email *",
                prefixIcon: const Icon(Icons.email, color: Colors.amber),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white10,
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _telefonoCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Telefono *",
                prefixIcon: const Icon(Icons.phone, color: Colors.amber),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white10,
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _messaggioCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Messaggio (opzionale)",
                hintText: "Raccontaci perché vuoi lavorare con noi...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white10,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: sending ? null : _inviaCandidatura,
                icon: sending ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.send),
                label: Text(sending ? "INVIO..." : "INVIA CANDIDATURA", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text("* Campi obbligatori", style: TextStyle(fontSize: 12, color: Colors.white38)),
            ),
          ],
        ),
      ),
    );
  }
}
