class CodiceFiscaleValidator {
  // Valida formato Codice Fiscale italiano (16 caratteri alfanumerici)
  static bool isValidFormat(String cf) {
    final cfUpper = cf.toUpperCase().trim();
    if (cfUpper.length != 16) return false;
    
    // Pattern: 6 lettere (cognome) + 6 lettere (nome) + 2 numeri (anno) + 1 lettera (mese) + 2 numeri (giorno) + 4 caratteri (comune + controllo)
    final cfRegex = RegExp(r'^[A-Z]{6}[0-9LMNPQRSTUV]{2}[ABCDEHLMPRST][0-9LMNPQRSTUV]{2}[A-Z][0-9LMNPQRSTUV]{3}[A-Z]$');
    return cfRegex.hasMatch(cfUpper);
  }

  // Verifica carattere di controllo (ultimo carattere)
  static bool validateChecksum(String cf) {
    final cfUpper = cf.toUpperCase().trim();
    if (cfUpper.length != 16) return false;
    
    // Algoritmo di controllo Codice Fiscale italiano
    const oddMap = {
      '0': 1, '1': 0, '2': 5, '3': 7, '4': 9, '5': 13, '6': 15, '7': 17, '8': 19, '9': 21,
      'A': 1, 'B': 0, 'C': 5, 'D': 7, 'E': 9, 'F': 13, 'G': 15, 'H': 17, 'I': 19, 'J': 21,
      'K': 2, 'L': 4, 'M': 18, 'N': 20, 'O': 11, 'P': 3, 'Q': 6, 'R': 8, 'S': 12, 'T': 14,
      'U': 16, 'V': 10, 'W': 22, 'X': 25, 'Y': 24, 'Z': 23
    };
    
    const evenMap = {
      '0': 0, '1': 1, '2': 2, '3': 3, '4': 4, '5': 5, '6': 6, '7': 7, '8': 8, '9': 9,
      'A': 0, 'B': 1, 'C': 2, 'D': 3, 'E': 4, 'F': 5, 'G': 6, 'H': 7, 'I': 8, 'J': 9,
      'K': 10, 'L': 11, 'M': 12, 'N': 13, 'O': 14, 'P': 15, 'Q': 16, 'R': 17, 'S': 18,
      'T': 19, 'U': 20, 'V': 21, 'W': 22, 'X': 23, 'Y': 24, 'Z': 25
    };
    
    const checkChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    
    int sum = 0;
    for (int i = 0; i < 15; i++) {
      final char = cfUpper[i];
      if (i % 2 == 0) {
        sum += oddMap[char] ?? 0;
      } else {
        sum += evenMap[char] ?? 0;
      }
    }
    
    final checkChar = checkChars[sum % 26];
    return cfUpper[15] == checkChar;
  }

  // Estrae le consonanti da una stringa
  static String _getConsonants(String text) {
    return text.toUpperCase().replaceAll(RegExp('[AEIOU\\s]'), '');
  }

  // Estrae le vocali da una stringa
  static String _getVowels(String text) {
    return text.toUpperCase().replaceAll(RegExp('[^AEIOU]'), '');
  }

  // Calcola la parte del CF dal cognome (3 caratteri)
  static String _calculateCognome(String cognome) {
    final clean = cognome.toUpperCase().replaceAll(RegExp('[^A-Z]'), '');
    final consonants = _getConsonants(clean);
    final vowels = _getVowels(clean);
    
    if (consonants.length >= 3) {
      return consonants.substring(0, 3);
    } else if (consonants.length == 2) {
      return consonants + (vowels.isNotEmpty ? vowels[0] : 'X');
    } else if (consonants.length == 1) {
      return consonants + (vowels.length >= 2 ? vowels.substring(0, 2) : vowels + 'X');
    } else {
      return (vowels.length >= 3 ? vowels.substring(0, 3) : vowels.padRight(3, 'X'));
    }
  }

  // Calcola la parte del CF dal nome (3 caratteri)
  static String _calculateNome(String nome) {
    final clean = nome.toUpperCase().replaceAll(RegExp('[^A-Z]'), '');
    final consonants = _getConsonants(clean);
    final vowels = _getVowels(clean);
    
    if (consonants.length >= 4) {
      // Prendi 1a, 3a, 4a consonante
      return consonants[0] + consonants[2] + consonants[3];
    } else if (consonants.length == 3) {
      return consonants;
    } else if (consonants.length == 2) {
      return consonants + (vowels.isNotEmpty ? vowels[0] : 'X');
    } else if (consonants.length == 1) {
      return consonants + (vowels.length >= 2 ? vowels.substring(0, 2) : vowels + 'X');
    } else {
      return (vowels.length >= 3 ? vowels.substring(0, 3) : vowels.padRight(3, 'X'));
    }
  }

  // Calcola la parte del CF dalla data di nascita (5 caratteri: anno + mese + giorno)
  static String _calculateData(DateTime dataNascita, String sesso) {
    // Anno (ultime 2 cifre)
    final anno = dataNascita.year.toString().substring(2);
    
    // Mese (lettera)
    const mesi = ['A', 'B', 'C', 'D', 'E', 'H', 'L', 'M', 'P', 'R', 'S', 'T'];
    final mese = mesi[dataNascita.month - 1];
    
    // Giorno (con +40 per le donne)
    int giorno = dataNascita.day;
    if (sesso.toUpperCase() == 'F' || sesso.toUpperCase() == 'FEMMINA') {
      giorno += 40;
    }
    final giornoStr = giorno.toString().padLeft(2, '0');
    
    return anno + mese + giornoStr;
  }

  // Calcola il Codice Fiscale completo da dati anagrafici
  static String calculateCodiceFiscale(String cognome, String nome, DateTime dataNascita, String sesso, String comuneCodice) {
    final cfCognome = _calculateCognome(cognome);
    final cfNome = _calculateNome(nome);
    final cfData = _calculateData(dataNascita, sesso);
    final cfComune = comuneCodice.toUpperCase().padRight(4, 'X').substring(0, 4);
    
    // Calcola carattere di controllo
    final cf15 = cfCognome + cfNome + cfData + cfComune;
    const oddMap = {
      '0': 1, '1': 0, '2': 5, '3': 7, '4': 9, '5': 13, '6': 15, '7': 17, '8': 19, '9': 21,
      'A': 1, 'B': 0, 'C': 5, 'D': 7, 'E': 9, 'F': 13, 'G': 15, 'H': 17, 'I': 19, 'J': 21,
      'K': 2, 'L': 4, 'M': 18, 'N': 20, 'O': 11, 'P': 3, 'Q': 6, 'R': 8, 'S': 12, 'T': 14,
      'U': 16, 'V': 10, 'W': 22, 'X': 25, 'Y': 24, 'Z': 23
    };
    const evenMap = {
      '0': 0, '1': 1, '2': 2, '3': 3, '4': 4, '5': 5, '6': 6, '7': 7, '8': 8, '9': 9,
      'A': 0, 'B': 1, 'C': 2, 'D': 3, 'E': 4, 'F': 5, 'G': 6, 'H': 7, 'I': 8, 'J': 9,
      'K': 10, 'L': 11, 'M': 12, 'N': 13, 'O': 14, 'P': 15, 'Q': 16, 'R': 17, 'S': 18,
      'T': 19, 'U': 20, 'V': 21, 'W': 22, 'X': 23, 'Y': 24, 'Z': 25
    };
    const checkChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    
    int sum = 0;
    for (int i = 0; i < 15; i++) {
      final char = cf15[i];
      if (i % 2 == 0) {
        sum += oddMap[char] ?? 0;
      } else {
        sum += evenMap[char] ?? 0;
      }
    }
    
    final checkChar = checkChars[sum % 26];
    return cf15 + checkChar;
  }

  // Valida il Codice Fiscale confrontandolo con i dati anagrafici
  static String? validateCodiceFiscaleWithAnagrafica(String cf, String cognome, String nome, DateTime dataNascita, String sesso, {String? comuneCodice}) {
    final cfUpper = cf.toUpperCase().trim();
    
    // Validazione base
    final baseError = validateCodiceFiscale(cfUpper);
    if (baseError != null) return baseError;
    
    // Estrai parti dal CF
    final cfCognome = cfUpper.substring(0, 3);
    final cfNome = cfUpper.substring(3, 6);
    final cfAnno = cfUpper.substring(6, 8);
    final cfMese = cfUpper.substring(8, 9);
    final cfGiorno = cfUpper.substring(9, 11);
    
    // Verifica cognome
    final expectedCognome = _calculateCognome(cognome);
    if (cfCognome != expectedCognome) {
      return "Il Codice Fiscale non corrisponde al cognome inserito";
    }
    
    // Verifica nome
    final expectedNome = _calculateNome(nome);
    if (cfNome != expectedNome) {
      return "Il Codice Fiscale non corrisponde al nome inserito";
    }
    
    // Verifica anno
    final expectedAnno = dataNascita.year.toString().substring(2);
    if (cfAnno != expectedAnno) {
      return "Il Codice Fiscale non corrisponde all'anno di nascita";
    }
    
    // Verifica mese
    const mesi = ['A', 'B', 'C', 'D', 'E', 'H', 'L', 'M', 'P', 'R', 'S', 'T'];
    final expectedMese = mesi[dataNascita.month - 1];
    if (cfMese != expectedMese) {
      return "Il Codice Fiscale non corrisponde al mese di nascita";
    }
    
    // Verifica giorno e sesso
    final giornoCF = int.parse(cfGiorno);
    final isFemmina = giornoCF > 40;
    final giornoReale = isFemmina ? giornoCF - 40 : giornoCF;
    
    if (giornoReale != dataNascita.day) {
      return "Il Codice Fiscale non corrisponde al giorno di nascita";
    }
    
    // Verifica sesso
    final sessoUpper = sesso.toUpperCase();
    final isFemminaInput = sessoUpper == 'F' || sessoUpper == 'FEMMINA' || sessoUpper == 'FEMALE';
    if (isFemmina != isFemminaInput) {
      return "Il Codice Fiscale non corrisponde al sesso inserito";
    }
    
    return null;
  }

  // Valida completo Codice Fiscale (solo formato e checksum)
  static String? validateCodiceFiscale(String cf) {
    final cfUpper = cf.toUpperCase().trim();
    
    if (cfUpper.isEmpty) {
      return "Il Codice Fiscale è obbligatorio";
    }
    
    if (!isValidFormat(cfUpper)) {
      return "Formato Codice Fiscale non valido (deve essere di 16 caratteri)";
    }
    
    // Validazione checksum opzionale ma consigliata
    if (!validateChecksum(cfUpper)) {
      return "Codice Fiscale non valido (carattere di controllo errato)";
    }
    
    return null;
  }
}
