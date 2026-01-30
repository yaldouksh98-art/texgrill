import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class StoricoOrdiniPage extends StatefulWidget {
  const StoricoOrdiniPage({super.key});

  @override
  State<StoricoOrdiniPage> createState() => _StoricoOrdiniPageState();
}

class _StoricoOrdiniPageState extends State<StoricoOrdiniPage> {
  String filtroStato = "Tutti";
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('I Miei Ordini'),
          backgroundColor: const Color(0xFFD94C1B),
        ),
        body: const Center(
          child: Text('Devi effettuare il login per visualizzare i tuoi ordini.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'I Miei Ordini',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFD94C1B),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Aggiorna',
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtri
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip("Tutti"),
                  const SizedBox(width: 8),
                  _buildFilterChip("In attesa"),
                  const SizedBox(width: 8),
                  _buildFilterChip("In preparazione"),
                  const SizedBox(width: 8),
                  _buildFilterChip("Completato"),
                  const SizedBox(width: 8),
                  _buildFilterChip("Annullato"),
                ],
              ),
            ),
          ),

          // Lista Ordini
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('ordini_totali')
                  .where('userId', isEqualTo: user.uid)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 80, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Errore nel caricamento degli ordini',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text('Riprova'),
                          onPressed: () => setState(() {}),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                var ordini = snapshot.data!.docs;

                // Applica filtro
                if (filtroStato != "Tutti") {
                  ordini = ordini.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return (data['stato'] ?? 'In attesa') == filtroStato;
                  }).toList();
                }

                if (ordini.isEmpty) {
                  return _buildEmptyState(
                    message: 'Nessun ordine con stato: $filtroStato',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: ordini.length,
                  itemBuilder: (context, index) {
                    final doc = ordini[index];
                    final ordine = doc.data() as Map<String, dynamic>;
                    return _buildOrdineCard(context, doc.id, ordine, user.uid);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = filtroStato == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => filtroStato = label);
      },
      selectedColor: const Color(0xFFD94C1B),
      backgroundColor: Colors.grey.shade800,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey.shade400,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildOrdineCard(
    BuildContext context,
    String ordineId,
    Map<String, dynamic> ordine,
    String userId,
  ) {
    final stato = ordine['stato'] ?? 'In attesa';
    final timestamp = (ordine['timestamp'] as Timestamp?)?.toDate();
    final punti = ordine['puntiAssegnati'] ?? 0;
    final totale = ordine['prezzo'] ?? 0.0;
    final quantita = ordine['quantita'] ?? 1;
    final nome = ordine['nome'] ?? 'Ordine';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade900,
              Colors.grey.shade800,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nome,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (timestamp != null)
                          Text(
                            DateFormat('dd/MM/yyyy • HH:mm').format(timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  _buildStatoBadge(stato),
                ],
              ),

              const Divider(height: 24),

              // Dettagli
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailItem(
                    icon: Icons.restaurant,
                    label: 'Quantità',
                    value: 'x$quantita',
                  ),
                  _buildDetailItem(
                    icon: Icons.euro,
                    label: 'Totale',
                    value: '€${(totale * quantita).toStringAsFixed(2)}',
                  ),
                  _buildDetailItem(
                    icon: Icons.stars,
                    label: 'Punti',
                    value: '+$punti 🌮',
                    valueColor: const Color(0xFFF3A62D),
                  ),
                ],
              ),

              // Azioni
              if (stato == 'In attesa') ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () => _confermaAnnullamento(
                              context,
                              ordineId,
                              userId,
                              punti,
                              nome,
                            ),
                    icon: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.cancel),
                    label: const Text(
                      'ANNULLA ORDINE',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatoBadge(String stato) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (stato) {
      case 'Completato':
        backgroundColor = Colors.green.withOpacity(0.2);
        textColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'In preparazione':
        backgroundColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange;
        icon = Icons.restaurant;
        break;
      case 'Annullato':
        backgroundColor = Colors.red.withOpacity(0.2);
        textColor = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        backgroundColor = Colors.blue.withOpacity(0.2);
        textColor = Colors.blue;
        icon = Icons.access_time;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(
            stato,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade500),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({String? message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 100,
              color: Colors.grey.shade700,
            ),
            const SizedBox(height: 24),
            Text(
              message ?? 'Non hai ancora effettuato ordini',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'I tuoi ordini appariranno qui',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confermaAnnullamento(
    BuildContext context,
    String ordineId,
    String userId,
    int puntiDaTogliere,
    String nomeOrdine,
  ) async {
    final conferma = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 10),
            Text('Conferma Annullamento'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sei sicuro di voler annullare l\'ordine:'),
            const SizedBox(height: 8),
            Text(
              '"$nomeOrdine"',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFD94C1B),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Verranno stornati $puntiDaTogliere punti',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ANNULLA'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('CONFERMA'),
          ),
        ],
      ),
    );

    if (conferma == true && context.mounted) {
      await _annullaOrdine(context, ordineId, userId, puntiDaTogliere);
    }
  }

  Future<void> _annullaOrdine(
    BuildContext context,
    String ordineId,
    String userId,
    int puntiDaTogliere,
  ) async {
    setState(() => isLoading = true);

    try {
      // Usa una transazione per garantire atomicità
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // 1. Leggi il documento utente
        final userDoc = await transaction.get(
          FirebaseFirestore.instance.collection('users').doc(userId),
        );

        if (!userDoc.exists) {
          throw Exception('Utente non trovato');
        }

        final currentPoints = userDoc.data()?['punti'] ?? 0;

        // Verifica che l'utente abbia abbastanza punti
        if (currentPoints < puntiDaTogliere) {
          throw Exception('Punti insufficienti per l\'annullamento');
        }

        // 2. Aggiorna i punti
        transaction.update(
          FirebaseFirestore.instance.collection('users').doc(userId),
          {'punti': FieldValue.increment(-puntiDaTogliere)},
        );

        // 3. Aggiorna lo stato dell'ordine
        transaction.update(
          FirebaseFirestore.instance.collection('ordini_totali').doc(ordineId),
          {
            'stato': 'Annullato',
            'annullatoIl': FieldValue.serverTimestamp(),
          },
        );
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text('Ordine annullato con successo. Punti stornati.'),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Errore: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }
}