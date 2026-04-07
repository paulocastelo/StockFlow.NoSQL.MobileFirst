import 'api_client.dart';
import '../models/auth_response.dart';

class AuthApi {
  final ApiClient _client;

  AuthApi(this._client);

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final data = await _client.post('/api/auth/login', body: {
      'email': email,
      'password': password,
    });

    return AuthResponse.fromJson(data as Map<String, dynamic>);
  }
}
