import 'package:prbd_2526_a07/core/services/auth_service.dart';

// Règles de validation pour l'inscription sync/async
class User {
  // sync

  static String? validateFullName(String value) {
    final name = value.trim();
    if (name.isEmpty) {
      return 'Veuillez entrer un nom complet';
    }
    if (name.length < 3) {
      return 'Le nom doit contenir au moins 3 caractères';
    }
    return null;
  }


  static String? validateEmail(String value) {
    final email = value.trim();
    if (email.isEmpty) {
      return 'Veuillez entrer une adresse email valide';
    }
    // Format simple : au moins un @ et un point après
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Veuillez entrer une adresse email valide';
    }
    return null;
  }


  static String? validatePassword(String value) {
    if (value.isEmpty) {
      return 'Veuillez entrer un mot de passe';
    }
    if (value.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Le mot de passe doit contenir au moins un chiffre';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Le mot de passe doit contenir au moins une majuscule';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Le mot de passe doit contenir au moins une minuscule';
    }
    if (!RegExp(r'[,;.:!?/\$%&@#]').hasMatch(value)) {
      return 'Le mot de passe doit contenir au moins un caractère spécial';
    }
    return null;
  }

  static String? validateConfirmPassword(String value, String password) {
    if (value.isEmpty) {
      return 'Veuillez confirmer votre mot de passe';
    }
    if (value != password) {
      return 'Les deux mots de passe doivent être identiques';
    }
    // re-vérifie aussi les règles du mot de passe (si l'utilisateur ne confirme pas)
    return validatePassword(value);
  }

  // async (appel backend avec debounce dans le controller)

  // true côté serveur = dispo pas d'erreur
  static Future<String?> validateEmailAvailable(String value) async {
    final email = value.trim();
    if (email.isEmpty) return null; // le sync gère déjà le vide

    final available = await AuthService.isEmailAvailable(email);
    return available ? null : 'Cet email est déjà utilisé';
  }

  // true côté serveur = dispo pas d'erreur
  static Future<String?> validateFullNameAvailable(String value) async {
    final name = value.trim();
    if (name.isEmpty) return null;

    final available = await AuthService.isFullNameAvailable(name);
    return available ? null : 'Ce nom complet est déjà utilisé';
  }
}