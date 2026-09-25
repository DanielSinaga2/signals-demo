import 'package:signals/signals.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

final isLoadingLogin = signal(false);
final isLoggedIn = signal(false);
final authError = signal<String?>(null);
final accessToken = signal<String?>(null);
Future<bool> login(String email, String password) async {
  isLoadingLogin.value = true;
  authError.value = null;
  try {
    final token = await AuthService().login(email: email, password: password);
    accessToken.value = token;
    ApiService.instance.setAccessToken(token);
    isLoggedIn.value = true;
    return true;
  } catch (error) {
    authError.value = error is StateError
        ? error.message.toString()
        : ApiService.instance.errorMessage(error);
    return false;
  } finally {
    isLoadingLogin.value = false;
  }
}
