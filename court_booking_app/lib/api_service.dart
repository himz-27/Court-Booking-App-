import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'config.dart';

class ApiResult {
  final bool ok;
  final int status;
  final Map<String, dynamic> data;
  ApiResult(this.ok, this.status, this.data);
  String get message =>
      (data['error'] ?? data['message'] ?? 'Unknown error').toString();
}

class ApiService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  static Future<String?> getToken() => _storage.read(key: _tokenKey);
  static Future<void> saveToken(String t) =>
      _storage.write(key: _tokenKey, value: t);
  static Future<void> clearToken() => _storage.delete(key: _tokenKey);

  static Future<ApiResult> _send(String method, String endpoint,
      {Map<String, dynamic>? body, bool auth = false}) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      if (auth) {
        final t = await getToken();
        if (t != null) headers['Authorization'] = 'Bearer $t';
      }
      final uri = Uri.parse('$apiBaseUrl/$endpoint');
      print('LOGIN API URL: $uri');
      final timeout = const Duration(seconds: 10);
      final res = method == 'GET'
          ? await http.get(uri, headers: headers).timeout(timeout)
          : await http
              .post(uri, headers: headers, body: jsonEncode(body ?? {}))
              .timeout(timeout);
      Map<String, dynamic> data;
      try {
        data = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {
        data = {'error': 'Invalid server response'};
      }
      return ApiResult(
          res.statusCode >= 200 && res.statusCode < 300, res.statusCode, data);
    } catch (e) {
      return ApiResult(false, 0, {'error': 'Network error: $e'});
    }
  }

  static Future<ApiResult> register(String name, String email, String password,
          String confirm) =>
      _send('POST', 'register.php', body: {
        'name': name,
        'email': email,
        'password': password,
        'confirm_password': confirm,
      });

  static Future<ApiResult> login(String email, String password) async {
    final r =
        await _send('POST', 'login.php', body: {'email': email, 'password': password});
    if (r.ok && r.data['token'] != null) {
      await saveToken(r.data['token'] as String);
    }
    return r;
  }

  static Future<ApiResult> profile() => _send('GET', 'profile.php', auth: true);

  static Future<void> logout() async {
    await _send('POST', 'logout.php', auth: true);
    await clearToken();
  }
}