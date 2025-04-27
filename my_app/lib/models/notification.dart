class AppNotification {
  final String id;
  final String userEmail;
  final String message;
  final DateTime timestamp;
  final String finderEmail;

  AppNotification({
    required this.id,
    required this.userEmail,
    required this.message,
    required this.timestamp,
    required this.finderEmail,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userEmail': userEmail,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
        'finderEmail': finderEmail,
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    DateTime parsedTimestamp;
    try {
      parsedTimestamp = DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String());
    } catch (e) {
      print('Error parsing timestamp: $e, using current time as fallback');
      parsedTimestamp = DateTime.now();
    }

    return AppNotification(
      id: json['id'] ?? '',
      userEmail: json['userEmail'] ?? '',
      finderEmail: json['finderEmail'] ?? '',
      message: json['message'] ?? '',
      timestamp: parsedTimestamp,
    );
  }
}