import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import 'auth_service.dart';

class ApiService {
  // Helper method untuk GET request
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final url = Uri.parse(ApiConfig.getFullUrl(endpoint));

      if (ApiConfig.debugMode) {
        print('🔍 Fetching: $url');
      }

      // Gunakan headers dengan authentication
      final headers = AuthService.getAuthHeaders();

      final response = await http.get(url, headers: headers)
          .timeout(Duration(seconds: ApiConfig.requestTimeout));

      if (ApiConfig.debugMode) {
        print('📡 Response Status: ${response.statusCode}');
        print('📄 Response Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');
      }

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Silakan login terlebih dahulu');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (ApiConfig.debugMode) {
        print('❌ API Error: $e');
      }
      throw Exception('Gagal mengambil data: $e');
    }
  }

  // Helper method untuk POST request
  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse(ApiConfig.getFullUrl(endpoint));

      if (ApiConfig.debugMode) {
        print('📤 POST to: $url');
        print('📦 Data: $data');
      }

      // Gunakan headers dengan authentication (kecuali untuk login)
      final headers = endpoint == '/login'
          ? ApiConfig.defaultHeaders
          : AuthService.getAuthHeaders();

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(data),
      ).timeout(Duration(seconds: ApiConfig.requestTimeout));

      if (ApiConfig.debugMode) {
        print('📡 Response Status: ${response.statusCode}');
        print('📄 Response Body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);

        // Handle Laravel response format
        if (responseData is Map<String, dynamic>) {
          if (responseData['status'] == true) {
            // Laravel success response
            return responseData;
          } else if (responseData['message'] != null && responseData['message'].toString().toLowerCase().contains('gagal')) {
            // Laravel error response
            throw Exception('Login gagal: ${responseData['message']}');
          }
        }

        return responseData;
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);
        final message = responseData['message'] ?? 'Username atau password salah';
        throw Exception('Unauthorized: $message');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (ApiConfig.debugMode) {
        print('❌ API Error: $e');
      }
      throw Exception('Gagal mengirim data: $e');
    }
  }

  // API endpoints untuk obat
  static Future<List<Map<String, dynamic>>> getObatList() async {
    final response = await get(ApiConfig.obatEndpoint);
    if (response['data'] != null && response['data'] is List) {
      return List<Map<String, dynamic>>.from(response['data']);
    }
    throw Exception('Format data obat tidak valid');
  }

  // API endpoints untuk antrian
  static Future<List<Map<String, dynamic>>> getAntrianList() async {
    final response = await get(ApiConfig.antrianEndpoint);
    if (response['data'] != null && response['data'] is List) {
      return List<Map<String, dynamic>>.from(response['data']);
    }
    throw Exception('Format data antrian tidak valid');
  }

  // API endpoints untuk detail antrian
  static Future<List<Map<String, dynamic>>> getAntrianDetail(int resepId) async {
    final response = await get('${ApiConfig.detailAntrianEndpoint}/$resepId');
    if (response['data'] != null && response['data'] is List) {
      return List<Map<String, dynamic>>.from(response['data']);
    } else if (response is Map<String, dynamic> && response.containsKey('data') && response['data'] is List) {
      return List<Map<String, dynamic>>.from(response['data']);
    } else if (response is Map<String, dynamic> && response.isNotEmpty) {
      // Jika response langsung berisi data (bukan dalam key 'data')
      return [response];
    }
    return [];
  }

  // API endpoints untuk riwayat
  static Future<List<Map<String, dynamic>>> getRiwayatList() async {
    final response = await get(ApiConfig.riwayatEndpoint);
    if (response['data'] != null && response['data'] is List) {
      return List<Map<String, dynamic>>.from(response['data']);
    }
    throw Exception('Format data riwayat tidak valid');
  }

  // API endpoint untuk login
  static Future<Map<String, dynamic>> login(String username, String password) async {
    // Try different parameter formats - email format works with Laravel backend
    final parameterFormats = [
      {'email': username, 'password': password}, // Primary format for Laravel
      {'username': username, 'password': password}, // Fallback
      {'user': username, 'pass': password}, // Alternative
    ];

    for (int i = 0; i < parameterFormats.length; i++) {
      try {
        print('🧪 Trying login format ${i + 1}: ${parameterFormats[i].keys.toList()}');

        final response = await post(ApiConfig.loginEndpoint, parameterFormats[i]);

        // If we get here, login was successful
        print('✅ Login successful with format ${i + 1}');
        return response;
      } catch (e) {
        print('❌ Login failed with format ${i + 1}: $e');
        if (i == parameterFormats.length - 1) {
          // This was the last attempt, re-throw the error
          throw e;
        }
        // Continue to next format
      }
    }

    throw Exception('All login formats failed');
  }
}