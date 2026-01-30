/// Modello Livello Loyalty Program Avanzato
/// Mantiene i nomi originali TexGrill
class Livello {
  final int livello;
  final String nome;
  final int puntiRichiesti;
  final double scontoPercentuale;
  final String descrizione;
  
  // 🆕 BENEFICI AVANZATI
  final int prioritaPrenotazione; // 0 = normale, 1 = media, 2 = alta, 3 = VIP
  final bool skipCoda; // Può saltare la coda
  final int giriRuotaBonus; // Giri gratis alla ruota per livello
  final double moltiplicatorePunti; // Es: 1.5 = 50% punti in più
  final List<String> premiEsclusivi; // Premi disponibili solo per questo livello
  final String badgeEmoji; // Emoji distintivo
  final String colore; // Colore del livello (hex)

  Livello({
    required this.livello,
    required this.nome,
    required this.puntiRichiesti,
    required this.scontoPercentuale,
    required this.descrizione,
    this.prioritaPrenotazione = 0,
    this.skipCoda = false,
    this.giriRuotaBonus = 0,
    this.moltiplicatorePunti = 1.0,
    this.premiEsclusivi = const [],
    this.badgeEmoji = '🌵',
    this.colore = '#FF4500',
  });

  /// Calcola i punti guadagnati applicando il moltiplicatore
  int calcolaPuntiConBonus(int puntiBase) {
    return (puntiBase * moltiplicatorePunti).round();
  }

  /// Calcola il prezzo scontato
  double applicaSconto(double prezzoOriginale) {
    return prezzoOriginale * (1 - scontoPercentuale / 100);
  }

  /// Restituisce il badge completo con emoji
  String get badgeCompleto => '$badgeEmoji $nome';

  /// Verifica se l'utente può accedere a un premio
  bool puoAccedereAPremio(String nomePremio) {
    return premiEsclusivi.isEmpty || premiEsclusivi.contains(nomePremio);
  }

  Map<String, dynamic> toMap() {
    return {
      'livello': livello,
      'nome': nome,
      'puntiRichiesti': puntiRichiesti,
      'scontoPercentuale': scontoPercentuale,
      'descrizione': descrizione,
      'prioritaPrenotazione': prioritaPrenotazione,
      'skipCoda': skipCoda,
      'giriRuotaBonus': giriRuotaBonus,
      'moltiplicatorePunti': moltiplicatorePunti,
      'premiEsclusivi': premiEsclusivi,
      'badgeEmoji': badgeEmoji,
      'colore': colore,
    };
  }

  factory Livello.fromMap(Map<String, dynamic> map) {
    return Livello(
      livello: (map['livello'] ?? 0).toInt(),
      nome: map['nome'] ?? '',
      puntiRichiesti: (map['puntiRichiesti'] ?? 0).toInt(),
      scontoPercentuale: (map['scontoPercentuale'] ?? 0).toDouble(),
      descrizione: map['descrizione'] ?? '',
      prioritaPrenotazione: (map['prioritaPrenotazione'] ?? 0).toInt(),
      skipCoda: map['skipCoda'] ?? false,
      giriRuotaBonus: (map['giriRuotaBonus'] ?? 0).toInt(),
      moltiplicatorePunti: (map['moltiplicatorePunti'] ?? 1.0).toDouble(),
      premiEsclusivi: List<String>.from(map['premiEsclusivi'] ?? []),
      badgeEmoji: map['badgeEmoji'] ?? '🌵',
      colore: map['colore'] ?? '#FF4500',
    );
  }

  @override
  String toString() {
    return 'Livello $livello: $nome ($puntiRichiesti pts, $scontoPercentuale% sconto)';
  }
}

// 🤠 LIVELLI TEXGRILL CON BENEFICI AVANZATI
final List<Livello> livelliTexGrill = [
  // 🌵 LIVELLO 0: PEÓN (Principiante)
  Livello(
    livello: 0,
    nome: "PEÓN",
    puntiRichiesti: 0,
    scontoPercentuale: 0,
    descrizione: "Benvenuto nel selvaggio West!",
    prioritaPrenotazione: 0,
    skipCoda: false,
    giriRuotaBonus: 0,
    moltiplicatorePunti: 1.0,
    premiEsclusivi: [],
    badgeEmoji: '🌵',
    colore: '#8B4513', // Marrone
  ),

  // 🐎 LIVELLO 1: VAQUERO (Esperto)
  Livello(
    livello: 1,
    nome: "VAQUERO",
    puntiRichiesti: 1000,
    scontoPercentuale: 5,
    descrizione: "Inizi a cavalcare bene, ecco uno sconto!",
    prioritaPrenotazione: 1,
    skipCoda: false,
    giriRuotaBonus: 1, // 1 giro bonus al mese
    moltiplicatorePunti: 1.1, // +10% punti
    premiEsclusivi: ['Bibita Gratis'],
    badgeEmoji: '🐎',
    colore: '#FF8C00', // Arancione scuro
  ),

  // 🎖️ LIVELLO 2: CABALLERO (Veterano)
  Livello(
    livello: 2,
    nome: "CABALLERO",
    puntiRichiesti: 2500,
    scontoPercentuale: 10,
    descrizione: "Un vero veterano della griglia.",
    prioritaPrenotazione: 2,
    skipCoda: true, // Salta la coda!
    giriRuotaBonus: 2, // 2 giri bonus al mese
    moltiplicatorePunti: 1.25, // +25% punti
    premiEsclusivi: ['Bibita Gratis', 'Dessert Gratis', 'Aperitivo Speciale'],
    badgeEmoji: '🎖️',
    colore: '#FFD700', // Oro
  ),

  // 👑 LIVELLO 3: EL PATRÓN (Leggenda)
  Livello(
    livello: 3,
    nome: "EL PATRÓN",
    puntiRichiesti: 5000,
    scontoPercentuale: 15,
    descrizione: "Il re del TexGrill!",
    prioritaPrenotazione: 3, // VIP totale
    skipCoda: true,
    giriRuotaBonus: 4, // 4 giri bonus al mese
    moltiplicatorePunti: 1.5, // +50% punti (DOPPI!)
    premiEsclusivi: [
      'Bibita Gratis',
      'Dessert Gratis',
      'Aperitivo Speciale',
      'Menu Degustazione',
      'Tavolo Riservato VIP',
      'Piatto dello Chef',
    ],
    badgeEmoji: '👑',
    colore: '#9400D3', // Viola regale
  ),
];

/// Utility per ottenere il livello in base ai punti
Livello getLivelloByPunti(int punti) {
  for (int i = livelliTexGrill.length - 1; i >= 0; i--) {
    if (punti >= livelliTexGrill[i].puntiRichiesti) {
      return livelliTexGrill[i];
    }
  }
  return livelliTexGrill[0]; // Default: PEÓN
}

/// Calcola punti mancanti al prossimo livello
int puntiMancanti(int puntiAttuali) {
  final livelloCorrente = getLivelloByPunti(puntiAttuali);
  
  // Se è già al livello massimo
  if (livelloCorrente.livello == livelliTexGrill.last.livello) {
    return 0;
  }
  
  final prossimoLivello = livelliTexGrill[livelloCorrente.livello + 1];
  return prossimoLivello.puntiRichiesti - puntiAttuali;
}

/// Calcola percentuale progresso verso prossimo livello
double progressoProssimoLivello(int puntiAttuali) {
  final livelloCorrente = getLivelloByPunti(puntiAttuali);
  
  // Se è già al livello massimo
  if (livelloCorrente.livello == livelliTexGrill.last.livello) {
    return 100.0;
  }
  
  final prossimoLivello = livelliTexGrill[livelloCorrente.livello + 1];
  final puntiInizioLivello = livelloCorrente.puntiRichiesti;
  final puntiFineProximoLivello = prossimoLivello.puntiRichiesti;
  
  final progressoTotale = puntiFineProximoLivello - puntiInizioLivello;
  final progressoAttuale = puntiAttuali - puntiInizioLivello;
  
  return (progressoAttuale / progressoTotale * 100).clamp(0.0, 100.0);
}
