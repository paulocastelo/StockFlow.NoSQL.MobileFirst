import 'user_profile.dart';

class AuthResponse {
  final String accessToken;
  final String expiresAtUtc;
  final UserProfile user;

  AuthResponse({
    required this.accessToken,
    required this.expiresAtUtc,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        accessToken: json['accessToken'] as String,
        expiresAtUtc: json['expiresAtUtc'] as String,
        user: UserProfile.fromJson(json['user'] as Map<String, dynamic>),
      );
}
