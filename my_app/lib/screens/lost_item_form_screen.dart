import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:my_app/models/lost_item.dart';
import 'package:my_app/services/api_service.dart';
import 'package:my_app/services/session_service.dart';

class LostItemFormScreen extends StatefulWidget {
  const LostItemFormScreen({super.key});

  @override
  State<LostItemFormScreen> createState() => _LostItemFormScreenState();
}

class _LostItemFormScreenState extends State<LostItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService();
  final SessionService _sessionService = SessionService();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final token = await _sessionService.getSessionToken();
      final email = await _sessionService.getSessionEmail();
      final imagePath = await _apiService.uploadImage(_image!, token!);
      final item = LostItem(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        userEmail: email!,
        imagePath: imagePath,
        found: false,
      );
      await _apiService.reportLostItem(item, token);
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error reporting lost item: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Lost Item', style: GoogleFonts.poppins(color: Colors.white)),
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
                    'Report a Lost Item',
                    style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1A73E8)),
                  ).animate().fadeIn(duration: 600.ms),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Item Name',
                      labelStyle: GoogleFonts.poppins(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.label, color: Color(0xFF1A73E8)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter the item name';
                      return null;
                    },
                  ).animate().slideY(begin: 0.5, duration: 600.ms),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: GoogleFonts.poppins(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.description, color: Color(0xFF1A73E8)),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter a description';
                      return null;
                    },
                  ).animate().slideY(begin: 0.5, delay: 100.ms, duration: 600.ms),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: 'Location',
                      labelStyle: GoogleFonts.poppins(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.location_on, color: Color(0xFF1A73E8)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter the location';
                      return null;
                    },
                  ).animate().slideY(begin: 0.5, delay: 200.ms, duration: 600.ms),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _image == null
                          ? Center(child: Text('Select Image', style: GoogleFonts.poppins()))
                          : Image.file(_image!, fit: BoxFit.cover),
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 24),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A73E8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'Submit',
                            style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                          ),
                        ).animate().fadeIn(delay: 400.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}