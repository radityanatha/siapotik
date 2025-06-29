class ApiConfig {
  // Base URL untuk API - bisa diubah sesuai kebutuhan
  static const String baseUrl = 'https://ti054a04.agussbn.my.id/api';

  // Alternative base URLs for testing
  static const String alternativeBaseUrl = 'https://ti054a04.agussbn.my.id';
  static const String testBaseUrl = 'http://localhost:8000/api';

  // Timeout untuk request (dalam detik)
  static const int requestTimeout = 30;

  // Headers yang konsisten untuk semua request
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'SiaPotik-App/1.0',
  };

  // Endpoints
  static const String loginEndpoint = '/login';
  static const String obatEndpoint = '/petugas/obat';
  static const String antrianEndpoint = '/petugas/antrean';
  static const String riwayatEndpoint = '/petugas/riwayat';
  static const String detailAntrianEndpoint = '/petugas/detail-antrean';

  // Helper method untuk mendapatkan URL lengkap
  static String getFullUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }

  // Helper method untuk mendapatkan alternative URL
  static String getAlternativeUrl(String endpoint) {
    return '$alternativeBaseUrl$endpoint';
  }

  // Helper method untuk mendapatkan detail antrian URL
  static String getDetailAntrianUrl(int resepId) {
    return '$baseUrl$detailAntrianEndpoint/$resepId';
  }

  // Debug mode - set true untuk melihat log detail
  static const bool debugMode = true;
}