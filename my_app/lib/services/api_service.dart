import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:my_app/models/lost_item.dart';
import 'package:my_app/models/notification.dart';
import 'package:my_app/models/user_model.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.0.182:3000';

  Future<String> uploadImage(File image, String token) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'))
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('image', image.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      return jsonDecode(responseData)['path'];
    } else {
      throw Exception('Failed to upload image: ${response.statusCode}');
    }
  }

  Future<String> updateProfilePicture(
      File image, String token, String email) async {
    final imagePath = await uploadImage(image, token);
    final response = await http.patch(
      Uri.parse('$baseUrl/users/$email/profile-picture'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'profilePicture': imagePath}),
    );

    if (response.statusCode == 200) {
      return imagePath;
    } else {
      throw Exception(
          'Failed to update profile picture: ${response.statusCode}');
    }
  }

  Future<LostItem> reportLostItem(LostItem item, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/lost-items'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(item.toJson()),
    );

    if (response.statusCode == 201) {
      return LostItem.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to report lost item: ${response.statusCode}');
    }
  }

  Future<List<LostItem>> getLostItems(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/lost-items'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return json.map((e) => LostItem.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load lost items: ${response.statusCode}');
    }
  }

  Future<void> markItemAsFound(String itemId, String token) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/lost-items/$itemId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'found': true}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark item as found: ${response.statusCode}');
    }
  }

  Future<void> deleteLostItem(String itemId, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/lost-items/$itemId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete lost item: ${response.statusCode}');
    }
  }

  Future<List<AppNotification>> getNotifications(
      String userEmail, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/$userEmail'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return json.map((e) => AppNotification.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load notifications: ${response.statusCode}');
    }
  }

  Future<void> addNotification(
      AppNotification notification, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/notifications'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(notification.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add notification: ${response.statusCode}');
    }
  }

  Future<User?> getUserDetails(String email, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$email'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to fetch user details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch user details: $e');
    }
  }

  Future<void> deleteAccount(String email, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/users/$email'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete account: ${response.statusCode}');
    }
  }
}
