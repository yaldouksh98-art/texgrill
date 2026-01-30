# 🔥 TexGrill App - Setup per Replit

## 📦 Come Importare il Progetto su Replit

### STEP 1: Crea nuovo Repl
1. Vai su https://replit.com
2. Click **"+ Create Repl"**
3. Scegli template **"Flutter"**
4. Nome: **"texgrill-app"**
5. Click **"Create Repl"**

---

### STEP 2: Carica i File

#### Metodo A: Upload ZIP (più veloce)
1. Comprimi la cartella `replit_texgrill` in un file ZIP
2. Su Replit: Click sui 3 puntini accanto a "Files" → **"Upload folder"**
3. Carica lo ZIP
4. Estrai i file nella root del progetto

#### Metodo B: Copia/Incolla Manuale
1. **Sostituisci `pubspec.yaml`**:
   - Apri il file `pubspec.yaml` su Replit
   - Cancella tutto il contenuto
   - Copia il contenuto dal file `pubspec.yaml` fornito
   - Salva (Ctrl+S)

2. **Copia la cartella `lib/`**:
   - Elimina la cartella `lib/` esistente su Replit
   - Carica tutta la cartella `lib/` fornita

3. **Copia la cartella `assets/`**:
   - Crea cartella `assets/` su Replit se non esiste
   - Carica le 3 immagini onboarding

4. **Copia la cartella `web/`** (opzionale):
   - Carica la cartella `web/` se vuoi personalizzare le icone

---

### STEP 3: Installa Dipendenze

Nel terminale di Replit esegui:

```bash
flutter pub get
```

Se vedi errori, esegui:

```bash
flutter clean
flutter pub get
```

---

### STEP 4: Avvia l'App

Click sul bottone **"Run" ▶️** in alto

Oppure nel terminale:

```bash
flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0
```

---

## ✅ Verifiche Pre-Run

Prima di avviare, assicurati che:
- ✅ `pubspec.yaml` sia stato sostituito con la nuova versione
- ✅ Cartella `lib/` sia completa (7 sottocartelle: main.dart + 6 folder)
- ✅ Cartella `assets/` contenga le 3 immagini
- ✅ `flutter pub get` sia stato eseguito senza errori

---

## 🔧 Modifiche Principali Applicate

### Dipendenze Aggiornate:
| Pacchetto | Versione Vecchia | Versione Nuova | Motivo |
|-----------|------------------|----------------|--------|
| `cloud_functions` | ^4.0.7 | ^5.6.2 | ✅ Compatibilità con firebase_core 3.x |
| `firebase_core` | ^3.3.0 | ^3.6.0 | ✅ Ultima versione stabile |
| `cloud_firestore` | ^5.2.0 | ^5.4.4 | ✅ Ultima versione stabile |
| `firebase_auth` | ^5.1.0 | ^5.3.1 | ✅ Ultima versione stabile |
| `intl` | ^0.19.0 | ^0.20.0 | ✅ Compatibilità Dart 3 |
| `flutter_lints` | ^3.0.0 | ^5.0.0 | ✅ Ultima versione |

### Nessuna Modifica al Codice:
- ✅ Tutti i file `.dart` sono identici
- ✅ Struttura progetto intatta
- ✅ Logica business invariata
- ✅ Solo aggiornamento dipendenze

---

## 🚀 Dopo il Primo Avvio

Una volta che l'app gira:

1. **Testa le funzionalità principali**:
   - Login/Registrazione
   - Navigazione tra pagine
   - Carrello
   - Menu

2. **Configura Firebase** (se necessario):
   - Verifica che le credenziali Firebase nel `main.dart` siano corrette
   - Aggiungi regole Firestore se mancano

3. **Personalizza**:
   - Aggiungi nuove funzionalità
   - Modifica il tema
   - Aggiungi nuovi asset

---

## 🐛 Troubleshooting

### Errore: "Package not found"
```bash
flutter pub get
flutter pub upgrade
```

### Errore: "Firebase not initialized"
Verifica che nel file `lib/main.dart` ci siano le credenziali corrette:
```dart
apiKey: "TUA_API_KEY",
authDomain: "TUO_AUTH_DOMAIN",
projectId: "TUO_PROJECT_ID",
// ...
```

### Errore: "Asset not found"
Assicurati che le immagini siano nella cartella `assets/` e che siano specificate nel `pubspec.yaml`

### App lenta su Replit
È normale su Replit. Per prestazioni migliori:
- Usa "Always On" (piano a pagamento)
- Oppure sviluppa in locale

---

## 📱 Struttura Progetto

```
texgrill_app/
├── lib/
│   ├── main.dart                    # Entry point
│   ├── models/                      # Modelli dati
│   │   ├── cart_item.dart
│   │   ├── menu_item.dart
│   │   ├── ordine.dart
│   │   ├── prenotazione.dart
│   │   ├── livello.dart
│   │   └── carousel_item.dart
│   ├── screens/                     # Schermate
│   │   ├── splash_page.dart
│   │   ├── onboarding_page.dart
│   │   ├── login_page.dart
│   │   ├── home_page.dart
│   │   ├── menu_page.dart
│   │   ├── carrello_page.dart
│   │   ├── ordine_page.dart
│   │   ├── scelta_ordine_page.dart
│   │   ├── storico_ordini_page.dart
│   │   ├── prenotazione_page.dart
│   │   ├── coupon_page.dart
│   │   ├── opinione_page.dart
│   │   ├── lavora_con_noi_page.dart
│   │   └── texgrill_card.dart
│   ├── services/                    # Servizi
│   │   ├── cart_service.dart
│   │   └── app_analytics.dart
│   ├── utils/                       # Utility
│   │   ├── auth_guard.dart
│   │   ├── codice_fiscale_validator.dart
│   │   ├── date_of_birth_validator.dart
│   │   ├── order_rate_limiter.dart
│   │   └── security_utils.dart
│   └── widgets/                     # Widget riutilizzabili
│       ├── home_carousel.dart
│       ├── lucky_wheel_dialog.dart
│       └── texgrill_card.dart
├── assets/                          # Risorse
│   ├── onboarding1.png
│   ├── onboarding2.png
│   └── onboarding3.png
├── web/                             # Configurazione web
└── pubspec.yaml                     # Dipendenze

```

---

## 🎉 Pronto!

Ora hai il progetto TexGrill completamente compatibile con Replit!

Per qualsiasi problema, controlla:
1. Che `flutter pub get` sia completato senza errori
2. Che tutte le cartelle siano state caricate
3. Console di Replit per messaggi di errore specifici

**Buon sviluppo! 🚀🔥**
