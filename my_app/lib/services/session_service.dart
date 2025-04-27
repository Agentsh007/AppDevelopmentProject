import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class SessionService {
  static const String _tokenKey = 'jwt_token';

  Future<void> saveSession(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<bool> isSessionValid() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null) return false;

    try {
      final isExpired = JwtDecoder.isExpired(token);
      if (isExpired) {
        await clearSession();
        return false;
      }
      return true;
    } catch (e) {
      await clearSession();
      return false;
    }
  }

  Future<String?> getSessionToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null || !(await isSessionValid())) return null;
    return token;
  }

  Future<String?> getSessionEmail() async {
    final token = await getSessionToken();
    if (token == null) return null;
    final decoded = JwtDecoder.decode(token);
    return decoded['email'] as String?;
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}