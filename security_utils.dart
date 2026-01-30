import 'dart:convert';

class SecurityUtils {
  // Valida formato email
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  // Valida forza password (min 8 caratteri, maiuscola, minuscola, numero)
  static String? validatePasswordStrength(String password) {
    if (password.length < 8) {
      return "La password deve contenere almeno 8 caratteri";
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return "La password deve contenere almeno una lettera maiuscola";
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return "La password deve contenere almeno una lettera minuscola";
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return "La password deve contenere almeno un numero";
    }
    return null;
  }

  // Sanitizza input per prevenire injection (rimuove caratteri pericolosi)
  static String sanitizeInput(String input) {
    return input.trim().replaceAll(RegExp("[<>\"'#]"), ''); 
  }
}