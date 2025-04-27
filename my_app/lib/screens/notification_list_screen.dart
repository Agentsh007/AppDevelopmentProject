// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:my_app/models/notification.dart';
// import 'package:my_app/models/user_model.dart';
// import 'package:my_app/services/api_service.dart';
// import 'package:my_app/services/notification_service.dart';
// import 'package:my_app/screens/finder_details_screen.dart';

// import '../services/session_service.dart';

// class NotificationListScreen extends StatefulWidget {
//   final String userEmail;

//   const NotificationListScreen({super.key, required this.userEmail});

//   @override
//   State<NotificationListScreen> createState() => _NotificationListScreenState();
// }

// class _NotificationListScreenState extends State<NotificationListScreen> {
//   final NotificationService _notificationService = NotificationService();
//   final ApiService _apiService = ApiService();
//    final SessionService _sessionService = SessionService();
//   List<AppNotification> _notifications = [];
//   bool _isLoading = true;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _loadNotifications();
//   }

//   Future<void> _loadNotifications() async {
//     if (widget.userEmail.isEmpty) {
//       setState(() {
//         _notifications = [];
//         _isLoading = true;
//       });
//       return;
//     }

//     try {
//       final token = await _sessionService.getSessionToken();
//       final notifications = await _notificationService.getNotifications(widget.userEmail, token!);
//       setState(() {
//         _notifications = notifications;
//         _isLoading = false;
//         _errorMessage = null;
//       });
//     } catch (e) {
//       setState(() {
//         _notifications = [];
//         _isLoading = false;
//         _errorMessage = 'Failed to load notifications: $e';
//       });
//     }
//   }

//   void _showFinderDetails(AppNotification notification) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => FinderDetailsScreen(finderEmail: notification.finderEmail),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Notifications',
//           style: GoogleFonts.poppins(color: Colors.white),
//         ),
//         backgroundColor: const Color(0xFF1A73E8),
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFFF5F7FA), Color(0xFFE8ECEF)],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Column(
//           children: [
//             if (_errorMessage != null)
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Text(
//                   _errorMessage!,
//                   style: GoogleFonts.poppins(fontSize: 14, color: Colors.red),
//                 ),
//               ),
//             Expanded(
//               child: _isLoading
//                   ? const Center(child: CircularProgressIndicator())
//                   : _notifications.isEmpty
//                       ? Center(
//                           child: Text(
//                             'No notifications',
//                             style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
//                           ).animate().fadeIn(duration: 600.ms),
//                         )
//                       : ListView.builder(
//                           padding: const EdgeInsets.all(16.0),
//                           itemCount: _notifications.length,
//                           itemBuilder: (context, index) {
//                             final notification = _notifications[index];
//                             return Card(
//                               elevation: 4,
//                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                               margin: const EdgeInsets.only(bottom: 16),
//                               child: ListTile(
//                                 title: Text(
//                                   notification.message,
//                                   style: GoogleFonts.poppins(fontSize: 16),
//                                 ),
//                                 subtitle: Text(
//                                   'Found by: ${notification.finderEmail}',
//                                   style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
//                                 ),
//                                 trailing: Text(
//                                   '${notification.timestamp.day}/${notification.timestamp.month}/${notification.timestamp.year}',
//                                   style: GoogleFonts.poppins(fontSize: 12),
//                                 ),
//                                 onTap: () => _showFinderDetails(notification),
//                               ),
//                             ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.5);
//                           },
//                         ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:my_app/models/notification.dart';
import 'package:my_app/screens/finder_details_screen.dart';
import 'package:my_app/screens/login_screen.dart';
import 'package:my_app/services/notification_service.dart';
import 'package:my_app/services/session_service.dart';

class NotificationListScreen extends StatefulWidget {
  final String userEmail;

  const NotificationListScreen({super.key, required this.userEmail});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  final NotificationService _notificationService = NotificationService();
  final SessionService _sessionService = SessionService();
  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (widget.userEmail.isEmpty) {
      setState(() {
        _notifications = [];
        _isLoading = false;
        _errorMessage = 'No user email provided. Please log in.';
      });
      return;
    }

    try {
      final token = await _sessionService.getSessionToken();
      if (token == null) {
        setState(() {
          _notifications = [];
          _isLoading = false;
          _errorMessage = 'Session expired. Please log in again.';
        });
        Future.delayed(Duration.zero, () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen(destination: NotificationListScreen(userEmail: widget.userEmail))),
          );
        });
        return;
      }

      final notifications = await _notificationService.getNotifications(widget.userEmail, token);
      setState(() {
        _notifications = notifications;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _notifications = [];
        _isLoading = false;
        _errorMessage = 'Failed to load notifications: $e';
      });
    }
  }

  void _showFinderDetails(AppNotification notification) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FinderDetailsScreen(finderEmail: notification.finderEmail),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A73E8),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F7FA), Color(0xFFE8ECEF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _errorMessage!,
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.red),
                ),
              ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _notifications.isEmpty
                      ? Center(
                          child: Text(
                            'No notifications',
                            style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
                          ).animate().fadeIn(duration: 600.ms),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _notifications.length,
                          itemBuilder: (context, index) {
                            final notification = _notifications[index];
                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              margin: const EdgeInsets.only(bottom: 16),
                              child: ListTile(
                                title: Text(
                                  notification.message,
                                  style: GoogleFonts.poppins(fontSize: 16),
                                ),
                                subtitle: Text(
                                  'Found by: ${notification.finderEmail}',
                                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                                ),
                                trailing: Text(
                                  '${notification.timestamp.day}/${notification.timestamp.month}/${notification.timestamp.year}',
                                  style: GoogleFonts.poppins(fontSize: 12),
                                ),
                                onTap: () => _showFinderDetails(notification),
                              ),
                            ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.5);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}