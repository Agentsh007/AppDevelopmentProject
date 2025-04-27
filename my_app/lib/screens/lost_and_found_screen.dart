import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import 'package:my_app/models/lost_item.dart';
import 'package:my_app/models/notification.dart';
import 'package:my_app/screens/lost_item_form_screen.dart';
import 'package:my_app/screens/notification_list_screen.dart';
import 'package:my_app/services/api_service.dart';
import 'package:my_app/services/notification_service.dart';
import 'package:my_app/services/session_service.dart';

class LostAndFoundScreen extends StatefulWidget {
  const LostAndFoundScreen({super.key});

  @override
  State<LostAndFoundScreen> createState() => _LostAndFoundScreenState();
}

class _LostAndFoundScreenState extends State<LostAndFoundScreen> {
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();
  final SessionService _sessionService = SessionService();
  List<LostItem> _lostItems = [];
  String? _currentUserEmail;
  bool _isLoading = true;
  Set<String> _markedAsFound = {};

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadLostItems();
  }

  Future<void> _loadCurrentUser() async {
    final email = await _sessionService.getSessionEmail();
    setState(() {
      _currentUserEmail = email;
    });
    if (_currentUserEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please log in again.')),
      );
    }
  }

  Future<void> _loadLostItems() async {
    try {
      final token = await _sessionService.getSessionToken();
      if (token == null) throw Exception('No valid session token');
      final items = await _apiService.getLostItems(token);
      setState(() {
        _lostItems = items;
        _markedAsFound = items.where((item) => item.found).map((item) => item.id).toSet();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading lost items: $e')),
      );
    }
  }

  Future<void> _markAsFound(LostItem item) async {
    if (_currentUserEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to mark an item as found')),
      );
      return;
    }

    if (_currentUserEmail == item.userEmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot mark your own item as found')),
      );
      return;
    }

    try {
      final token = await _sessionService.getSessionToken();
      if (token == null) throw Exception('No valid session token');
      await _apiService.markItemAsFound(item.id, token);
      final notification = AppNotification(
        id: const Uuid().v4(),
        userEmail: item.userEmail,
        message: 'Your lost item "${item.description}" has been found!',
        timestamp: DateTime.now(),
        finderEmail: _currentUserEmail!,
      );
      await _notificationService.addNotification(notification, token);
      setState(() {
        _markedAsFound.add(item.id);
      });
      await _loadLostItems();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item marked as found and owner notified')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking item as found: $e')),
      );
    }
  }

  Future<void> _deleteItem(LostItem item) async {
    try {
      final token = await _sessionService.getSessionToken();
      if (token == null) throw Exception('No valid session token');
      await _apiService.deleteLostItem(item.id, token);
      await _loadLostItems();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting item: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lost and Found Hub',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A73E8),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              if (_currentUserEmail == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please log in to view notifications')),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotificationListScreen(userEmail: _currentUserEmail!),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F7FA), Color(0xFFE8ECEF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _lostItems.isEmpty
                ? Center(
                    child: Text(
                      'No lost items found',
                      style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
                    ).animate().fadeIn(duration: 600.ms),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _lostItems.length,
                    itemBuilder: (context, index) {
                      final item = _lostItems[index];
                      final isFound = _markedAsFound.contains(item.id) || item.found;
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: item.imagePath.isNotEmpty
                                    ? Image.network(
                                        'http://192.168.0.182:3000${item.imagePath}',
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => const Icon(
                                          Icons.broken_image,
                                          size: 80,
                                          color: Colors.grey,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.image,
                                        size: 80,
                                        color: Colors.grey,
                                      ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.description,
                                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Location: ${item.location}',
                                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                                    ),
                                    if (isFound)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          'Status: Found',
                                          style: GoogleFonts.poppins(fontSize: 14, color: Colors.green),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  if (!isFound && item.userEmail != _currentUserEmail)
                                    IconButton(
                                      icon: const Icon(Icons.check_circle, color: Colors.green),
                                      onPressed: () => _markAsFound(item),
                                    ),
                                  if (item.userEmail == _currentUserEmail)
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteItem(item),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.5, duration: 600.ms);
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1A73E8),
        onPressed: () async {
          if (_currentUserEmail == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please log in to add a lost item')),
            );
            return;
          }
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LostItemFormScreen()),
          );
          if (result == true) {
            await _loadLostItems();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ).animate().scale(delay: 300.ms, duration: 600.ms),
    );
  }
}