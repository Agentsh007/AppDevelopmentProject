import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:my_app/models/user_model.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:my_app/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedUniversity;
  String? _selectedDepartment;
  String? _selectedBloodGroup;
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  final List<String> universities = [
    'Harvard University',
    'Stanford University',
    'MIT',
    'Oxford University',
    'Cambridge University',
    // Add more universities as needed
  ];

  final List<String> departments = [
    'Computer Science',
    'Electrical Engineering',
    'Mechanical Engineering',
    'Biology',
    'Mathematics',
  ];

  final List<String> bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedUniversity == null || _selectedDepartment == null || _selectedBloodGroup == null || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select university, department, and blood group')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final user = User(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      university: _selectedUniversity!,
      department: _selectedDepartment!,
      bloodGroup: _selectedBloodGroup!,
      phoneNumber: _phoneController.text.trim(), // Optional field, can be added later
    );

    final success = await _authService.register(user);
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful! Please login.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration failed. Email may already be in use.')),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register', style: GoogleFonts.poppins(color: Colors.white)),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Create Account',
                    style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1A73E8)),
                  ).animate().fadeIn(duration: 600.ms),
                  const SizedBox(height: 8),
                  Text(
                    'Join Campus Connect',
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: GoogleFonts.poppins(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.person, color: Color(0xFF1A73E8)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter your username';
                      return null;
                    },
                  ).animate().slideY(begin: 0.5, duration: 600.ms),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: GoogleFonts.poppins(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.email, color: Color(0xFF1A73E8)),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter your email';
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Please enter a valid email';
                      return null;
                    },
                  ).animate().slideY(begin: 0.5, delay: 100.ms, duration: 600.ms),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: GoogleFonts.poppins(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.lock, color: Color(0xFF1A73E8)),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter your password';
                      if (value.length < 6) return 'Password must be at least 6 characters';
                      return null;
                    },
                  ).animate().slideY(begin: 0.5, delay: 200.ms, duration: 600.ms),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      labelStyle: GoogleFonts.poppins(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.lock, color: Color(0xFF1A73E8)),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please confirm your password';
                      if (value != _passwordController.text) return 'Passwords do not match';
                      return null;
                    },
                  ).animate().slideY(begin: 0.5, delay: 300.ms, duration: 600.ms),
                  const SizedBox(height: 16),
                  DropdownSearch<String>(
                    popupProps: const PopupProps.menu(showSearchBox: true),
                    items: universities,
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: 'University',
                        labelStyle: GoogleFonts.poppins(),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.school, color: Color(0xFF1A73E8)),
                      ),
                    ),
                    onChanged: (value) => setState(() => _selectedUniversity = value),
                    selectedItem: _selectedUniversity,
                  ).animate().slideY(begin: 0.5, delay: 400.ms, duration: 600.ms),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Department',
                      labelStyle: GoogleFonts.poppins(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.book, color: Color(0xFF1A73E8)),
                    ),
                    items: departments.map((dept) => DropdownMenuItem(value: dept, child: Text(dept, style: GoogleFonts.poppins()))).toList(),
                    onChanged: (value) => setState(() => _selectedDepartment = value),
                    value: _selectedDepartment,
                  ).animate().slideY(begin: 0.5, delay: 500.ms, duration: 600.ms),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Blood Group',
                      labelStyle: GoogleFonts.poppins(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.favorite, color: Color(0xFF1A73E8)),
                    ),
                    items: bloodGroups.map((group) => DropdownMenuItem(value: group, child: Text(group, style: GoogleFonts.poppins()))).toList(),
                    onChanged: (value) => setState(() => _selectedBloodGroup = value),
                    value: _selectedBloodGroup,
                  ).animate().slideY(begin: 0.5, delay: 600.ms, duration: 600.ms),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      labelStyle: GoogleFonts.poppins(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.person, color: Color(0xFF1A73E8)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter your phone number';
                      if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) return 'Please enter a valid phone number';
                      return null;
                    },
                  ).animate().slideY(begin: 0.5, duration: 600.ms),
                  const SizedBox(height: 24),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A73E8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'Register',
                            style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                          ),
                        ).animate().fadeIn(delay: 700.ms),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                    },
                    child: Text(
                      'Already have an account? Login',
                      style: GoogleFonts.poppins(color: const Color(0xFF1A73E8)),
                    ),
                  ).animate().fadeIn(delay: 800.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}