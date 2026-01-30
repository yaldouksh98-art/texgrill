import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/codice_fiscale_validator.dart';
import '../utils/security_utils.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final codiceFiscaleCtrl = TextEditingController();
  final nomeCtrl = TextEditingController();
  final cognomeCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  bool isLogin = true;
  bool obscurePassword = true;
  DateTime? dataNascita;
  String? sesso;

  Future<void> _handleAuth() async {
    // Validazione sicurezza
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = SecurityUtils.sanitizeInput(emailCtrl.text);
    final password = passCtrl.text; // Password non viene sanitizzata per preservare caratteri speciali

    // Validazione email
    if (!SecurityUtils.isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inserisci un indirizzo email valido")),
      );
      return;
    }

    // Validazione password per registrazione
    if (!isLogin) {
      final passwordError = SecurityUtils.validatePasswordStrength(password);
      if (passwordError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(passwordError)),
        );
        return;
      }

      // Validazione campi anagrafici per registrazione
      final nome = SecurityUtils.sanitizeInput(nomeCtrl.text);
      final cognome = SecurityUtils.sanitizeInput(cognomeCtrl.text);
      
      if (nome.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Inserisci il nome")),
        );
        return;
      }
      
      if (cognome.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Inserisci il cognome")),
        );
        return;
      }
      
      if (dataNascita == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Seleziona la data di nascita")),
        );
        return;
      }
      
      if (sesso == null || sesso!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Seleziona il sesso")),
        );
        return;
      }

      // Validazione Codice Fiscale con dati anagrafici
      final cf = SecurityUtils.sanitizeInput(codiceFiscaleCtrl.text);
      final cfError = CodiceFiscaleValidator.validateCodiceFiscaleWithAnagrafica(
        cf,
        cognome,
        nome,
        dataNascita!,
        sesso!,
      );
      if (cfError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(cfError)),
        );
        return;
      }

      // Verifica duplicati Codice Fiscale
      try {
        final cfQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('codiceFiscale', isEqualTo: cf.toUpperCase())
            .limit(1)
            .get();
        
        if (cfQuery.docs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Codice Fiscale già registrato. Questo codice fiscale è già associato a un altro account.")),
          );
          return;
        }
      } catch (e) {
        // Errore nella verifica, procedi comunque
      }
    }

    setState(() => loading = true);
    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        final cf = SecurityUtils.sanitizeInput(codiceFiscaleCtrl.text).toUpperCase();
        final nome = SecurityUtils.sanitizeInput(nomeCtrl.text);
        final cognome = SecurityUtils.sanitizeInput(cognomeCtrl.text);
        
        final res = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        await FirebaseFirestore.instance.collection('users').doc(res.user!.uid).set({
          'punti': 0,
          'premi_vinti': [],
          'email': email,
          'codiceFiscale': cf,
          'nome': nome,
          'cognome': cognome,
          'dataNascita': dataNascita!.toIso8601String(),
          'sesso': sesso,
          'ordini': [],
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: false));
      }
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMessage;
        switch (e.code) {
          case 'weak-password':
            errorMessage = "La password è troppo debole";
            break;
          case 'email-already-in-use':
            errorMessage = "Email già registrata";
            break;
          case 'invalid-email':
            errorMessage = "Email non valida";
            break;
          case 'user-not-found':
            errorMessage = "Utente non trovato";
            break;
          case 'wrong-password':
            errorMessage = "Password errata";
            break;
          case 'too-many-requests':
            errorMessage = "Troppi tentativi. Riprova più tardi";
            break;
          default:
            errorMessage = isLogin ? "Errore durante l'accesso" : "Errore durante la registrazione";
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isLogin ? "Errore durante l'accesso" : "Errore durante la registrazione")),
        );
      }
    }
    setState(() => loading = false);
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    codiceFiscaleCtrl.dispose();
    nomeCtrl.dispose();
    cognomeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network('https://i.ibb.co/RJGPBPs/Chat-GPT-Image-2-gen-2026-23-48-48.png', width: 200),
                  const SizedBox(height: 40),
                  Text(
                    isLogin ? "BENTORNATO!" : "CREA ACCOUNT",
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.amber),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isLogin ? "Accedi al tuo account" : "Registrati per iniziare",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textCapitalization: TextCapitalization.none,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Inserisci l'email";
                      }
                      if (!SecurityUtils.isValidEmail(value)) {
                        return "Email non valida";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: const Icon(Icons.email, color: Colors.amber),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white10,
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: passCtrl,
                    obscureText: obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Inserisci la password";
                      }
                      if (!isLogin) {
                        final error = SecurityUtils.validatePasswordStrength(value);
                        if (error != null) return error;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock, color: Colors.amber),
                      suffixIcon: IconButton(
                        icon: Icon(obscurePassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => obscurePassword = !obscurePassword),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white10,
                      helperText: isLogin ? null : "Min. 8 caratteri, maiuscola, minuscola, numero",
                      helperMaxLines: 2,
                    ),
                  ),
                  if (!isLogin) ...[
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: nomeCtrl,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Inserisci il nome";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Nome *",
                        prefixIcon: const Icon(Icons.person, color: Colors.amber),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white10,
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: cognomeCtrl,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Inserisci il cognome";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Cognome *",
                        prefixIcon: const Icon(Icons.person_outline, color: Colors.amber),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white10,
                      ),
                    ),
                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                          locale: const Locale('it', 'IT'),
                        );
                        if (picked != null) {
                          setState(() => dataNascita = picked);
                        }
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: TextEditingController(
                            text: dataNascita != null
                                ? "${dataNascita!.day.toString().padLeft(2, '0')}/${dataNascita!.month.toString().padLeft(2, '0')}/${dataNascita!.year}"
                                : "",
                          ),
                          decoration: InputDecoration(
                            labelText: "Data di Nascita *",
                            prefixIcon: const Icon(Icons.calendar_today, color: Colors.amber),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.white10,
                            suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.amber),
                            helperText: "Seleziona la data di nascita",
                          ),
                          validator: (value) {
                            if (dataNascita == null) {
                              return "Seleziona la data di nascita";
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: sesso,
                      decoration: InputDecoration(
                        labelText: "Sesso *",
                        prefixIcon: const Icon(Icons.wc, color: Colors.amber),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white10,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'M', child: Text("Maschio")),
                        DropdownMenuItem(value: 'F', child: Text("Femmina")),
                      ],
                      onChanged: (value) => setState(() => sesso = value),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Seleziona il sesso";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: codiceFiscaleCtrl,
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 16,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Inserisci il Codice Fiscale";
                        }
                        // Validazione base (la validazione completa con anagrafica viene fatta in _handleAuth)
                        return CodiceFiscaleValidator.validateCodiceFiscale(value);
                      },
                      decoration: InputDecoration(
                        labelText: "Codice Fiscale *",
                        prefixIcon: const Icon(Icons.badge, color: Colors.amber),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white10,
                        counterText: "",
                        helperText: "16 caratteri - verrà verificato con i dati anagrafici",
                      ),
                    ),
                  ],
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: loading ? null : _handleAuth,
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(isLogin ? "ACCEDI" : "REGISTRATI", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isLogin = !isLogin;
                        codiceFiscaleCtrl.clear();
                        nomeCtrl.clear();
                        cognomeCtrl.clear();
                        dataNascita = null;
                        sesso = null;
                      });
                    },
                    child: Text(
                      isLogin ? "Non hai un account? Registrati" : "Hai già un account? Accedi",
                      style: const TextStyle(color: Colors.amber),
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
