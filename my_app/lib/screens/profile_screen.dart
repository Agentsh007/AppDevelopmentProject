import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/models/user_model.dart';
import 'package:my_app/screens/home_screen.dart';
import 'package:my_app/screens/login_screen.dart';
import 'package:my_app/services/api_service.dart';
import 'package:my_app/services/session_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SessionService _sessionService = SessionService();
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();
  User? _user;
  bool _isLoading = true;
  String? _errorMessage;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final email = await _sessionService.getSessionEmail();
      final token = await _sessionService.getSessionToken();
      if (email == null || token == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Session expired. Please log in again.';
        });
        Future.delayed(Duration.zero, () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
        });
        return;
      }

      final user = await _apiService.getUserDetails(email, token);
      setState(() {
        _user = user;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load user data: $e';
      });
    }
  }

  Future<void> _pickProfilePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      await _uploadProfilePicture();
    }
  }

  Future<void> _uploadProfilePicture() async {
    if (_profileImage == null || _user == null) return;

    setState(() => _isLoading = true);
    try {
      final token = await _sessionService.getSessionToken();
      if (token == null) throw Exception('No valid session token');
        
      final imagePath = await _apiService.updateProfilePicture(_profileImage!, token, _user!.email);
    print('Image path: $imagePath');
      setState(() {
        _user = User(
          username: _user!.username,
          email: _user!.email,
          password: _user!.password,
          university: _user!.university,
          department: _user!.department,
          bloodGroup: _user!.bloodGroup,
          phoneNumber: _user!.phoneNumber,
          profilePicture: imagePath,
        );
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to update profile picture: $e';
      });
    }
  }

  Future<void> _logout() async {
    await _sessionService.clearSession();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
 
  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Account', style: GoogleFonts.poppins()),
        content: Text('Are you sure you want to delete your account? This action cannot be undone.', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: GoogleFonts.poppins(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final email = await _sessionService.getSessionEmail();
      final token = await _sessionService.getSessionToken();
      if (email == null || token == null) throw Exception('No valid session');
      await _apiService.deleteAccount(email, token);
      await _sessionService.clearSession();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deleted successfully')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to delete account: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
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
            : _errorMessage != null
                ? Center(
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.red),
                    ).animate().fadeIn(duration: 600.ms),
                  )
                : _user == null
                    ? Center(
                        child: Text(
                          'User data not found',
                          style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                        ).animate().fadeIn(duration: 600.ms),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: _pickProfilePicture,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: _profileImage != null
                                    ? FileImage(_profileImage!)
                                    : _user!.profilePicture.isNotEmpty
                                        ? NetworkImage('http://192.168.0.182:3000${_user!.profilePicture}') as ImageProvider
                                        : null,
                                child: _profileImage == null && _user!.profilePicture.isEmpty
                                    ? const Icon(Icons.person, size: 50, color: Colors.grey)
                                    : null,
                              ),
                            ).animate().scale(duration: 600.ms),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _pickProfilePicture,
                              child: Text(
                                'Change Profile Picture',
                                style: GoogleFonts.poppins(color: const Color(0xFF1A73E8)),
                              ),
                            ).animate().fadeIn(delay: 200.ms),
                            const SizedBox(height: 16),
                            Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInfoRow('Name', _user!.username),
                                    const SizedBox(height: 12),
                                    _buildInfoRow('Email', _user!.email),
                                    const SizedBox(height: 12),
                                    _buildInfoRow('University', _user!.university),
                                    const SizedBox(height: 12),
                                    _buildInfoRow('Department', _user!.department),
                                    const SizedBox(height: 12),
                                    _buildInfoRow('Phone', _user!.phoneNumber.isEmpty ? 'Not provided' : _user!.phoneNumber),
                                  ],
                                ),
                              ),
                            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.5, duration: 600.ms),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _logout,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A73E8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                              ),
                              child: Text(
                                'Logout',
                                style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                              ),
                            ).animate().fadeIn(delay: 400.ms),
                            const SizedBox(height: 16),
                            OutlinedButton(
                              onPressed: _deleteAccount,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                              ),
                              child: Text(
                                'Delete Account',
                                style: GoogleFonts.poppins(fontSize: 16, color: Colors.red),
                              ),
                            ).animate().fadeIn(delay: 500.ms),
                          ],
                        ),
                      ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(fontSize: 16),
          ),
        ),
      ],
    );
  }
}