import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';

  static Future<void> saveToken({
    required String token,
    required String userName,
    required String email,
    required String avatarUrl,
    String? tanggalLahir,
    String? alamat,
    String? role,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final userData = {
      "token": token,
      "user_name": userName,
      "email": email,
      "avatar_url": avatarUrl,
      "tanggal_lahir": tanggalLahir,
      "alamat": alamat,
      "role": role, // ✅ posisi disimpan di sini
    };

    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userDataKey, jsonEncode(userData));
  }

  static Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userDataKey);
    if (userDataString == null) return {};
    return Map<String, dynamic>.from(jsonDecode(userDataString));
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<bool> checkSession() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return false;

    try {
      final response = await ApiClient.get(
        '/employee/me',
        token: token,
      );

      if (response == null || response is! Map) {
        return false;
      }

      final isActive = response['is_active'];

      // handle semua kemungkinan tipe data
      final active = isActive == 1 || isActive == true || isActive == '1';

      if (!active) {
        await logout();
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<String> getUserName() async {
    final data = await getUserData();
    return (data['user_name'] as String?) ?? 'User';
  }

  static Future<String?> getAvatarUrl() async {
    final data = await getUserData();
    return data['avatar_url'];
  }

  static Future<String?> getEmail() async {
    final data = await getUserData();
    return data['email'];
  }

  static Future<String?> getTanggalLahir() async {
    final data = await getUserData();
    return data['tanggal_lahir'];
  }

  static Future<String?> getAlamat() async {
    final data = await getUserData();
    return data['alamat'];
  }

  /// ✅ Ambil posisi (role)
  static Future<String?> getRole() async {
    final data = await getUserData();
    return data['role'];
  }

  static Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userDataKey);
  }

  static Future<void> logout() async => clearData();

  /// ⏳ Opsional refresh data dari endpoint user
  static Future<void> refreshUserData() async {
    final token = await getToken();
    if (token == null) return;

    try {
      final response = await ApiClient.get('/employee/me', token: token);

      if (response is Map && response.containsKey('user')) {
        final user = response['user'];

        await saveToken(
          token: token,
          userName: user['name'] ?? '',
          email: user['email'] ?? '',
          avatarUrl: user['avatar'] ?? '',
          tanggalLahir: user['birthday'],
          alamat: user['alamat'],
          role: user['posisi'], // ✅ langsung posisi
        );
      }
    } catch (_) {}
  }
}
