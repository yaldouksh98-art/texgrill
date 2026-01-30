import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ⚠️ verifica il path corretto
import 'scelta_ordine_page.dart';

class PrenotazionePage extends StatefulWidget {
  const PrenotazionePage({super.key});

  @override
  State<PrenotazionePage> createState() => _PrenotazionePageState();
}

class _PrenotazionePageState extends State<PrenotazionePage> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _telefonoController = TextEditingController();

  DateTime? _dataSelezionata;
  TimeOfDay? _oraSelezionata;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _caricaDatiUtente();
  }

  Future<void> _caricaDatiUtente() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists && mounted) {
      final data = doc.data()!;
      _nomeController.text = data['nome'] ?? '';
      _telefonoController.text = data['telefono'] ?? '';
    }
  }

  Future<void> _selezionaData() async {
    final oggi = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: oggi,
      firstDate: oggi,
      lastDate: oggi.add(const Duration(days: 30)),
    );

    if (picked != null && mounted) {
      setState(() => _dataSelezionata = picked);
    }
  }

  Future<void> _selezionaOra() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null && mounted) {
      setState(() => _oraSelezionata = picked);
    }
  }

  String _slotPrenotazione() {
    final data =
        '${_dataSelezionata!.year}-${_dataSelezionata!.month.toString().padLeft(2, '0')}-${_dataSelezionata!.day.toString().padLeft(2, '0')}';
    final ora =
        '${_oraSelezionata!.hour.toString().padLeft(2, '0')}:${_oraSelezionata!.minute.toString().padLeft(2, '0')}';
    return '${data}_$ora';
  }

  Future<void> _inviaPrenotazione() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dataSelezionata == null || _oraSelezionata == null) {
      _errore('Seleziona data e ora');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final slot = _slotPrenotazione();
      final user = FirebaseAuth.instance.currentUser;

      // 🔒 blocco doppia prenotazione stesso utente / slot
      if (user != null) {
        final doppia = await FirebaseFirestore.instance
            .collection('prenotazioni')
            .where('slot', isEqualTo: slot)
            .where('userId', isEqualTo: user.uid)
            .get();

        if (doppia.docs.isNotEmpty) {
          _errore('Hai già una prenotazione per questo orario');
          return;
        }
      }

      // ⏱ limite massimo per slot
      final existing = await FirebaseFirestore.instance
          .collection('prenotazioni')
          .where('slot', isEqualTo: slot)
          .get();

      if (existing.docs.length >= 10) {
        _errore('Orario non disponibile');
        return;
      }

      // 💾 salva prenotazione
      final docRef =
          await FirebaseFirestore.instance.collection('prenotazioni').add({
        'nome': _nomeController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'data': _dataSelezionata,
        'ora': _oraSelezionata!.format(context),
        'slot': slot,
        'userId': user?.uid,
        'stato': 'Confermata',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // 👉 vai alla scelta ordine
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SceltaOrdinePage(
            prenotazioneId: docRef.id,
          ),
        ),
      );
    } catch (e) {
      _errore('Errore durante la prenotazione');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _errore(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prenota un tavolo'),
        backgroundColor: const Color(0xFFD94C1B),
      ),
      backgroundColor: const Color(0xFF121212),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: const Color(0xFF1E1E1E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _nomeController,
                    decoration: const InputDecoration(labelText: 'Nome'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Inserisci il nome' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _telefonoController,
                    decoration: const InputDecoration(labelText: 'Telefono'),
                    keyboardType: TextInputType.phone,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Inserisci il telefono' : null,
                  ),
                  const SizedBox(height: 24),
                  ListTile(
                    leading: const Icon(Icons.calendar_today,
                        color: Colors.amber),
                    title: Text(
                      _dataSelezionata == null
                          ? 'Seleziona data'
                          : '${_dataSelezionata!.day}/${_dataSelezionata!.month}/${_dataSelezionata!.year}',
                    ),
                    onTap: _selezionaData,
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.access_time, color: Colors.amber),
                    title: Text(
                      _oraSelezionata == null
                          ? 'Seleziona ora'
                          : _oraSelezionata!.format(context),
                    ),
                    onTap: _selezionaOra,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed:
                          _isLoading ? null : _inviaPrenotazione,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD94C1B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              'CONFERMA PRENOTAZIONE',
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
          ),
        ),
      ),
    );
  }
}
