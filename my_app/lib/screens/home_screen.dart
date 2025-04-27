import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:my_app/screens/login_screen.dart';
import 'package:my_app/screens/lost_and_found_screen.dart';
import 'package:my_app/screens/report_problem_screen.dart';
import 'package:my_app/services/session_service.dart';

import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  final SessionService _sessionService = SessionService();

  HomeScreen({super.key});

  Future<void> _navigateWithAuth(BuildContext context, Widget destination) async {
    final isLoggedIn = await _sessionService.isSessionValid();
    if (isLoggedIn) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => destination));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen(destination: LostAndFoundScreen())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Campus Connect',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A73E8),
         actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () async {
              final isLoggedIn = await _sessionService.isSessionValid();
              if (isLoggedIn) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen(destination: ProfileScreen())));
              }
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildCard(
                context,
                title: 'Campus Explore',
                icon: Icons.explore,
                color: const Color(0xFF34C759),
                onTap: () {
                  // Placeholder for Campus Explore
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Campus Explore coming soon!')),
                  );
                },
              ),
              _buildCard(
                context,
                title: 'Lost & Found Hub',
                icon: Icons.find_in_page,
                color: const Color(0xFFFF9500),
                onTap: () => _navigateWithAuth(context, const LostAndFoundScreen()),
              ),
              _buildCard(
                context,
                title: 'Report Problem',
                icon: Icons.report_problem,
                color: const Color(0xFFFF3B30),
                onTap: () => _navigateWithAuth(context, const ReportProblemScreen()),
              ),
              _buildCard(
                context,
                title: 'Blood Donate',
                icon: Icons.favorite,
                color: const Color(0xFF5856D6),
                onTap: () {
                  // Placeholder for Blood Donate
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Blood Donate coming soon!')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.8), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 600.ms).scale(delay: 200.ms),
    );
  }
}