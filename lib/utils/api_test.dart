import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../services/auth_service.dart';

class ApiTest {
  static Future<void> testApiConnection() async {
    print('🔍 Testing API Connection...');

    try {
      // Test 1: Basic connectivity
      print('📡 Testing basic connectivity...');
      final response = await http.get(
        Uri.parse(ApiConfig.getFullUrl(ApiConfig.obatEndpoint)),
        headers: ApiConfig.defaultHeaders,
      ).timeout(const Duration(seconds: 10));

      print('✅ Status Code: ${response.statusCode}');
      print('📄 Response Headers: ${response.headers}');
      print('📝 Response Body (first 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ API Response Structure: ${data.keys.toList()}');
        if (data['data'] != null) {
          print('✅ Data array length: ${(data['data'] as List).length}');
        }
      }

    } catch (e) {
      print('❌ API Test Failed: $e');

      // Test alternative endpoints
      await _testAlternativeEndpoints();
    }
  }

  static Future<void> testLoginEndpoint() async {
    print('🔐 Testing Login Endpoint...');

    // Test different credential formats - Laravel format works
    final testCredentials = [
      {
        'email': 'petugas1@gmail.com', // ✅ Laravel format - WORKS
        'password': 'petugas123'
      },
      {
        'username': 'petugas1@gmail.com', // ❌ Old format - FAILS
        'password': 'petugas123'
      },
      {
        'user': 'petugas1@gmail.com',
        'pass': 'petugas123'
      },
      {
        'username': 'petugas1',
        'password': 'petugas123'
      }
    ];

    // Test different base URLs
    final baseUrls = [
      ApiConfig.baseUrl,
      ApiConfig.alternativeBaseUrl,
    ];

    for (final baseUrl in baseUrls) {
      print('🌐 Testing base URL: $baseUrl');

      for (int i = 0; i < testCredentials.length; i++) {
        final credentials = testCredentials[i];
        print('🧪 Test ${i + 1}: Trying credentials format: ${credentials.keys.toList()}');

        try {
          final url = '$baseUrl${ApiConfig.loginEndpoint}';
          print('📤 POST to: $url');

          final response = await http.post(
            Uri.parse(url),
            headers: ApiConfig.defaultHeaders,
            body: json.encode(credentials),
          ).timeout(const Duration(seconds: 10));

          print('📡 Status: ${response.statusCode}');
          print('📄 Headers: ${response.headers}');
          print('📝 Body: ${response.body}');

          if (response.statusCode == 200) {
            print('✅ SUCCESS with base URL: $baseUrl, format ${i + 1}!');
            final data = json.decode(response.body);
            print('🔑 Token: ${data['token'] ?? 'No token found'}');
            print('👤 User: ${data['data']?['name'] ?? 'No user data'}');
            return;
          } else if (response.statusCode == 401) {
            print('❌ Unauthorized with base URL: $baseUrl, format ${i + 1}');
          } else {
            print('⚠️ Unexpected status ${response.statusCode} with base URL: $baseUrl, format ${i + 1}');
          }
        } catch (e) {
          print('❌ Error with base URL: $baseUrl, format ${i + 1}: $e');
        }

        // Wait a bit between requests
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  static Future<void> testServerHealth() async {
    print('🏥 Testing Server Health...');

    final healthEndpoints = [
      '/',
      '/api',
      '/api/health',
      '/health',
      '/status',
    ];

    final baseUrls = [
      ApiConfig.baseUrl.replaceAll('/api', ''),
      ApiConfig.baseUrl,
    ];

    for (final baseUrl in baseUrls) {
      print('🌐 Testing base URL: $baseUrl');

      for (final endpoint in healthEndpoints) {
        final url = '$baseUrl$endpoint';
        try {
          print('🔍 Testing: $url');

          final response = await http.get(
            Uri.parse(url),
            headers: ApiConfig.defaultHeaders,
          ).timeout(const Duration(seconds: 5));

          print('📡 Status: ${response.statusCode}');
          if (response.statusCode == 200) {
            print('✅ Server is responding at: $url');
            print('📝 Response: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');
          }
        } catch (e) {
          print('❌ Failed to reach: $url - $e');
        }
      }
    }
  }

  static Future<void> _testAlternativeEndpoints() async {
    final endpoints = [
      ApiConfig.antrianEndpoint,
      ApiConfig.riwayatEndpoint,
      ApiConfig.obatEndpoint,
    ];

    for (final endpoint in endpoints) {
      try {
        print('🔍 Testing endpoint: $endpoint');
        final response = await http.get(
          Uri.parse(ApiConfig.getFullUrl(endpoint)),
          headers: ApiConfig.defaultHeaders,
        ).timeout(const Duration(seconds: 5));

        print('📡 $endpoint - Status: ${response.statusCode}');
        if (response.statusCode == 200) {
          print('✅ $endpoint - Working');
        } else {
          print('❌ $endpoint - Failed: ${response.reasonPhrase}');
        }
      } catch (e) {
        print('❌ $endpoint - Error: $e');
      }
    }
  }

  static Future<void> testNetworkConnectivity() async {
    print('🌐 Testing network connectivity...');

    try {
      // Extract host from base URL
      final uri = Uri.parse(ApiConfig.baseUrl);
      final host = uri.host;

      // Test DNS resolution
      final result = await InternetAddress.lookup(host);
      print('✅ DNS Resolution: ${result.first.address}');

      // Test HTTPS connection
      final socket = await SecureSocket.connect(host, 443);
      print('✅ HTTPS Connection: Established');
      await socket.close();

    } catch (e) {
      print('❌ Network Test Failed: $e');
    }
  }

  static Future<void> testObatEndpoint() async {
    print('💊 Testing Obat Endpoint...');

    try {
      final url = ApiConfig.getFullUrl(ApiConfig.obatEndpoint);
      print('🔍 Testing obat endpoint: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: AuthService.getAuthHeaders(),
      ).timeout(const Duration(seconds: 10));

      print('📡 Status: ${response.statusCode}');
      print('📄 Headers: ${response.headers}');
      print('📝 Body (first 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Obat endpoint working!');
        print('📊 Response structure: ${data.keys.toList()}');

        if (data['data'] != null && data['data'] is List) {
          print('📦 Found ${(data['data'] as List).length} obat items');
          if ((data['data'] as List).isNotEmpty) {
            final firstObat = (data['data'] as List).first;
            print('💊 Sample obat: ${firstObat.keys.toList()}');
          }
        } else {
          print('⚠️ No data array found in response');
        }
      } else if (response.statusCode == 401) {
        print('❌ Unauthorized - need to login first');
      } else {
        print('❌ Unexpected status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error testing obat endpoint: $e');
    }
  }
}