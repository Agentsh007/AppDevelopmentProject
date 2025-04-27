import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:my_app/models/user_model.dart';
import 'package:my_app/services/api_service.dart';
import 'package:my_app/services/session_service.dart';

class FinderDetailsScreen extends StatefulWidget {
  final String finderEmail;

  const FinderDetailsScreen({super.key, required this.finderEmail});

  @override
  State<FinderDetailsScreen> createState() => _FinderDetailsScreenState();
}

class _FinderDetailsScreenState extends State<FinderDetailsScreen> {
  final ApiService _apiService = ApiService();
  final SessionService _sessionService = SessionService();
  User? _finder;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFinderDetails();
  }

  Future<void> _loadFinderDetails() async {
    try {
      final token = await _sessionService.getSessionToken();
      final user = await _apiService.getUserDetails(widget.finderEmail, token!);
      setState(() {
        _finder = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading finder details: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Finder Details',
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _finder == null
                ? Center(
                    child: Text(
                      'Finder not found',
                      style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
                    ).animate().fadeIn(duration: 600.ms),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Finder Information',
                          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1A73E8)),
                        ).animate().fadeIn(duration: 600.ms),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Name: ${_finder!.username}',
                                  style: GoogleFonts.poppins(fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Phone: ${_finder!.phoneNumber.isEmpty ? "Not provided" : _finder!.phoneNumber}',
                                  style: GoogleFonts.poppins(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.5),
                      ],
                    ),
                  ),
      ),
    );
  }
}