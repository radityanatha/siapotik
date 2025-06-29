import '../services/api_service.dart';
import 'dart:convert';

class AuthService {
  static String? _authToken;
  static Map<String, dynamic>? _userData;

  // Getter untuk token
  static String? get authToken => _authToken;

  // Getter untuk user data
  static Map<String, dynamic>? get userData => _userData;

  // Setter untuk token
  static void setAuthToken(String token) {
    _authToken = token;
  }

  // Setter untuk user data
  static void setUserData(Map<String, dynamic> data) {
    _userData = data;
  }

  // Method untuk logout
  static void logout() {
    _authToken = null;
    _userData = null;
  }

  // Method untuk cek apakah user sudah login
  static bool get isLoggedIn => _authToken != null;

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      print('🔐 Attempting login for user: $username');

      // Gunakan endpoint login yang benar
      final response = await ApiService.post('/login', {
        'email': username, // Laravel backend expects 'email' parameter
        'password': password,
      });

      print('✅ Login response: $response');

      // Handle Laravel response format
      if (response['status'] == true && response['token'] != null) {
        setAuthToken(response['token']);
        setUserData(response['data'] ?? response);
        print('🔑 Token saved: ${response['token']}');
        print('👤 User data: ${response['data']}');
      } else if (response['token'] != null) {
        // Fallback for different response formats
        setAuthToken(response['token']);
        setUserData(response);
        print('🔑 Token saved: ${response['token']}');
      } else {
        throw Exception('Token tidak ditemukan dalam response');
      }

      return response;
    } catch (e) {
      print('❌ Login failed: $e');

      // For testing purposes, allow mock login with specific credentials
      if (username == 'test@test.com' && password == 'test123') {
        print('🧪 Using mock login for testing');
        final mockResponse = {
          'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
          'user': {
            'id': 1,
            'name': 'Test User',
            'email': username,
            'role': 'petugas'
          },
          'message': 'Mock login successful'
        };

        setAuthToken(mockResponse['token'] as String);
        setUserData(mockResponse);
        print('🔑 Mock token saved: ${mockResponse['token']}');

        return mockResponse;
      }

      throw Exception('Login gagal: $e');
    }
  }

  // Method untuk mendapatkan headers dengan authentication
  static Map<String, String> getAuthHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }
}
