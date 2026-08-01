import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../game/spider_slinger_game.dart';
import '../../config/game_routes.dart';

class UserRegistrationOverlay extends StatefulWidget {
  final SpiderSlingerGame game;

  const UserRegistrationOverlay({super.key, required this.game});

  @override
  State<UserRegistrationOverlay> createState() => _UserRegistrationOverlayState();
}

class _UserRegistrationOverlayState extends State<UserRegistrationOverlay> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rollNumberController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkExistingData();
  }

  Future<void> _checkExistingData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('student_name');
    final rollNumber = prefs.getString('roll_number');

    if (name != null && name.isNotEmpty && rollNumber != null && rollNumber.isNotEmpty) {
      // Data exists, update game state and move to main menu immediately
      _updateGameStateAndProceed(name, rollNumber);
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveAndProceed() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final rollNumber = _rollNumberController.text.trim();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('student_name', name);
      await prefs.setString('roll_number', rollNumber);

      _updateGameStateAndProceed(name, rollNumber);
    }
  }

  void _updateGameStateAndProceed(String name, String rollNumber) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.game.gameState.setStudentInfo(name, rollNumber);
      widget.game.overlays.remove(GameRoutes.registration);
      widget.game.overlays.add(GameRoutes.mainMenu);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rollNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    return Container(
      color: Colors.black.withValues(alpha: 0.9),
      child: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade900,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'STUDENT REGISTRATION',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      labelStyle: TextStyle(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _rollNumberController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Roll Number',
                      labelStyle: TextStyle(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Please enter your roll number' : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveAndProceed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    ),
                    child: const Text('ENTER AUDITORIUM', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
