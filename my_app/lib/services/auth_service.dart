import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_app/models/user_model.dart';
import 'package:my_app/services/session_service.dart';

class AuthService {
  static const String baseUrl = 'http://192.168.0.182:3000';
  final SessionService _sessionService = SessionService();

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _sessionService.saveSession(data['token']);
        return true;
      }
      return false;
    } catch (e) {
      print('Error during login: $e');
      return false;
    }
  }

  Future<bool> register(User user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      print('Error during registration: $e');
      return false;
    }
  }
}