import 'package:flutter/foundation.dart';

class AppConstants {
  const AppConstants._();

  // Em celular físico, use o IP da máquina na rede local.
  // Não inclua `/api` aqui, porque os endpoints já adicionam esse prefixo.
  // No emulador Android, use `http://10.0.2.2:<porta>`.
  static String get apiBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080';
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'http://10.0.2.2:8080',
      _ => 'http://localhost:8080',
    };
  }

  static String get baseUrl => apiBaseUrl;

  static const String tokenKey = 'stockflow.token';
  static const String userKey = 'stockflow.user';
  static const String expiresKey = 'stockflow.expiresAtUtc';
}
