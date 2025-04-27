import 'package:my_app/models/notification.dart';
import 'package:my_app/services/api_service.dart';

class NotificationService {
  final ApiService _apiService = ApiService();

  Future<List<AppNotification>> getNotifications(String userEmail, String token) async {
    try {
      return await _apiService.getNotifications(userEmail, token);
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  Future<void> addNotification(AppNotification notification, String token) async {
    try {
      await _apiService.addNotification(notification, token);
    } catch (e) {
      print('Error adding notification: $e');
      throw Exception('Failed to add notification: $e');
    }
  }
}