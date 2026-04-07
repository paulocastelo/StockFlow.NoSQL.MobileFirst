class AppConstants {
  const AppConstants._();

  // Em celular físico, use o IP da máquina na rede local.
  // Não inclua `/api` aqui, porque os endpoints já adicionam esse prefixo.
  // No emulador Android, use `http://10.0.2.2:<porta>`.
  static const String apiBaseUrl = 'http://10.0.2.2:8080';
  static const String baseUrl = apiBaseUrl;

  static const String tokenKey = 'stockflow.token';
  static const String userKey = 'stockflow.user';
  static const String expiresKey = 'stockflow.expiresAtUtc';
}
