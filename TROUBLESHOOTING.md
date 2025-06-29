# Troubleshooting API Issues

## Masalah Umum dan Solusi

### 1. Data Tidak Muncul
**Gejala:** Aplikasi tidak menampilkan data dari API

**Kemungkinan Penyebab:**
- Koneksi internet bermasalah
- Server API tidak berjalan
- URL API salah
- Format response tidak sesuai

**Solusi:**
1. Periksa koneksi internet
2. Pastikan server API berjalan di `https://ti054a04.agussbn.my.id`
3. Cek log aplikasi untuk error detail
4. Refresh halaman dengan pull-to-refresh

### 2. Error "Connection Timeout"
**Gejala:** Aplikasi menampilkan error timeout

**Solusi:**
1. Periksa koneksi internet
2. Coba lagi setelah beberapa saat
3. Periksa apakah server API sedang maintenance

### 3. Error "HTTP 404" atau "HTTP 500"
**Gejala:** Error HTTP status code

**Solusi:**
1. Periksa apakah endpoint API benar
2. Hubungi administrator server
3. Cek dokumentasi API di `https://ti054a04.agussbn.my.id/docs/api/#/`

## Debug Mode

Aplikasi memiliki debug mode yang dapat diaktifkan di `lib/config/api_config.dart`:

```dart
static const bool debugMode = true;
```

Ketika debug mode aktif, aplikasi akan menampilkan:
- URL yang diakses
- Response status code
- Response body (200 karakter pertama)
- Error detail

## Testing API

Untuk testing API secara manual, gunakan file `lib/utils/api_test.dart`:

```dart
// Test konektivitas jaringan
await ApiTest.testNetworkConnectivity();

// Test koneksi API
await ApiTest.testApiConnection();
```

## Konfigurasi API

Semua konfigurasi API dapat diubah di `lib/config/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'https://ti054a04.agussbn.my.id/api';
  static const int requestTimeout = 30;
  // ... konfigurasi lainnya
}
```

## Log Aplikasi

Untuk melihat log aplikasi:
1. Buka terminal/console
2. Jalankan aplikasi dengan `flutter run`
3. Perhatikan output log dengan emoji:
   - 🔍 Fetching: URL yang diakses
   - 📡 Response Status: Status code response
   - ✅ Success: Berhasil
   - ❌ Error: Error yang terjadi

## Kontak Support

Jika masalah masih berlanjut:
1. Screenshot error yang muncul
2. Copy log error dari console
3. Hubungi administrator server API

# SiaPotik App Troubleshooting Guide

## ✅ SOLVED: Login Issues

### Problem: 401 Unauthorized Error
The app was receiving 401 Unauthorized responses when attempting to login.

### ✅ Solution Found
**The issue was with the parameter name in the login request.**

- **❌ Wrong format**: `{username: "petugas1@gmail.com", password: "petugas123"}`
- **✅ Correct format**: `{email: "petugas1@gmail.com", password: "petugas123"}`

**Laravel backend expects the parameter to be named `email`, not `username`.**

### Changes Made
1. **Updated API Service** (`lib/services/api_service.dart`):
   - Changed primary parameter from `username` to `email`
   - Added fallback formats for compatibility

2. **Updated Auth Service** (`lib/services/auth_service.dart`):
   - Modified to use `email` parameter
   - Added proper Laravel response handling

3. **Updated API Configuration** (`lib/config/api_config.dart`):
   - Changed `obatEndpoint` from `/admin/obat` to `/petugas/obat`
   - Now uses the correct endpoint for petugas access to medicine stock

4. **Enhanced Error Handling**:
   - Better response parsing for Laravel format
   - Improved error messages

5. **Added Testing Tools**:
   - New `testObatEndpoint()` method to verify medicine stock API
   - Enhanced debugging capabilities

### Testing Results
From the API test logs:
```
🧪 Test 1: [username, password] → ❌ 401 Unauthorized
🧪 Test 2: [email, password] → ✅ 200 Success with token
```

### CORS Implementation
Regarding CORS in Flutter:
- **Flutter doesn't need CORS configuration** - CORS is a web browser security feature
- **Mobile apps bypass CORS** - They can make direct HTTP requests
- **Your Laravel backend CORS setup is working correctly** - The issue was parameter naming, not CORS

### Previous Possible Causes and Solutions:

#### 1. Server Connectivity Issues
- **Symptom**: Connection timeout or "connection closed unexpectedly"
- **Solution**:
  - Check if the API server is running
  - Verify the base URL in `lib/config/api_config.dart`
  - Try the "Test API Connection" button in the login screen

#### 2. Incorrect Credentials
- **Symptom**: 401 Unauthorized with "Login gagal" message
- **Solution**:
  - ✅ **FIXED**: Use `email` parameter instead of `username`
  - Verify the correct username and password
  - Check with the API administrator for correct credentials

#### 3. API Endpoint Issues
- **Symptom**: 404 Not Found or unexpected responses
- **Solution**:
  - Verify the login endpoint in `lib/config/api_config.dart`
  - Check if the API expects different parameter names
  - Use the test utilities to debug endpoint issues

### Testing Tools

#### 1. API Test Button
- Located on the login screen
- Tests network connectivity, server health, and login endpoints
- Provides detailed console output for debugging

#### 2. Mock Login (For Development)
- Use credentials: `test@test.com` / `test123`
- Bypasses server authentication for testing
- Only works when server is unreachable

#### 3. Console Logs
- Enable debug mode in `lib/config/api_config.dart`
- Check console output for detailed error messages
- Look for patterns in failed requests

### Debugging Steps

1. **Check Network Connectivity**
   ```dart
   await ApiTest.testNetworkConnectivity();
   ```

2. **Test Server Health**
   ```dart
   await ApiTest.testServerHealth();
   ```

3. **Test Login Endpoint**
   ```dart
   await ApiTest.testLoginEndpoint();
   ```

4. **Test Obat Endpoint**
   ```dart
   await ApiTest.testObatEndpoint();
   ```

5. **Check API Configuration**
   - Verify `baseUrl` in `api_config.dart`
   - Check endpoint paths
   - Confirm headers are correct

### Common Error Messages

- `"Login gagal"` - Server authentication failed
- `"Unauthorized: Username atau password salah"` - Invalid credentials
- `"Connection closed unexpectedly"` - Server connectivity issue
- `"HTTP 404"` - Endpoint not found

### Contact Information

If issues persist, contact the API administrator with:
- Error logs from console
- Network test results
- API endpoint configuration
- Expected vs actual behavior