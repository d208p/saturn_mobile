import 'api_client.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  // Login Method
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final data = await _apiClient.post('/login', body: {
        'email': email,
        'password': password,
      });

      if (data['token'] != null) {
        await _apiClient.setToken(data['token']);
      }
      return {'success': true, 'data': data};
    } on ApiException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (_) {
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  // Register Method
  Future<Map<String, dynamic>> register(
      String name, String email, String password, String passwordConfirmation) async {
    try {
      final data = await _apiClient.post('/register', body: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });

      if (data['token'] != null) {
        await _apiClient.setToken(data['token']);
      }
      return {'success': true, 'data': data};
    } on ApiException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (_) {
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  // Fetch Protected User Data
  Future<Map<String, dynamic>?> getUser() async {
    try {
      final token = await _apiClient.getToken();
      if (token == null) return null;

      return await _apiClient.get('/user');
    } catch (_) {
      return null;
    }
  }

  // Logout Method
  Future<void> logout() async {
    try {
      await _apiClient.post('/logout');
    } catch (_) {
      // Ignore network errors on logout
    } finally {
      await _apiClient.deleteToken();
    }
  }
}