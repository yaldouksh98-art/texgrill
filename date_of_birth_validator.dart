/// Validazione e utility per data di nascita
class DateOfBirthValidator {
  /// Controlla se la data di nascita è valida
  /// Returns: messaggio di errore se non valida, null se valida
  static String? validate(DateTime? dateOfBirth, {int minAge = 13}) {
    if (dateOfBirth == null) {
      return 'Data di nascita richiesta';
    }

    final now = DateTime.now();
    final age = now.year - dateOfBirth.year;
    final isBeforeBirthday = now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day);

    final actualAge = isBeforeBirthday ? age - 1 : age;

    if (dateOfBirth.isAfter(now)) {
      return 'La data di nascita non può essere nel futuro';
    }

    if (actualAge < minAge) {
      return 'Devi avere almeno $minAge anni';
    }

    if (actualAge > 150) {
      return 'Data di nascita non valida';
    }

    return null; // ✅ Valida
  }

  /// Calcola l'età da una data di nascita
  static int getAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    final isBeforeBirthday = now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day);
    if (isBeforeBirthday) age--;
    return age;
  }

  /// Formatta una data di nascita (dd/MM/yyyy)
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Parsa una stringa in formato dd/MM/yyyy
  static DateTime? parseDate(String dateString) {
    try {
      final parts = dateString.split('/');
      if (parts.length != 3) return null;
      return DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    } catch (_) {
      return null;
    }
  }
}
