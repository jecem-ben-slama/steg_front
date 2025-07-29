import 'package:flutter/material.dart';

class LocalizationService {
  static final Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      'welcomeBack': 'Welcome Back!',
      'email': 'Email',
      'password': 'Password',
      'login': 'Login',
      'forgotPassword': 'Forgot Password?',
      'loginFailedError': 'Login Failed: ',
      'unknownRole': 'Unknown user role',
    },
    'fr': {
      'welcomeBack': 'Bienvenue !',
      'email': 'E-mail',
      'password': 'Mot de passe',
      'login': 'Connexion',
      'forgotPassword': 'Mot de passe oublié ?',
      'loginFailedError': 'Échec de la connexion : ',
      'unknownRole': 'Rôle utilisateur inconnu',
    },
    // Add more languages as needed
  };

  static String getTranslatedText(String key, Locale locale) {
    return _localizedStrings[locale.languageCode]?[key] ??
        key; // Fallback to key if not found
  }

  static final List<Locale> supportedLocales = [
    const Locale('en', ''),
    const Locale('fr', ''),
    // Add more locales for supported languages
  ];
}
