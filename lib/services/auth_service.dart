import 'api_service.dart';

class AuthService {
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.instance.dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    final payload = response.data is Map ? response.data['data'] : null;
    final token = payload is Map ? payload['access_token']?.toString() : null;
    if (token == null || token.isEmpty)
      throw StateError('Token akses tidak tersedia pada respons login.');
    return token;
  }
}
