import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../game/spider_slinger_game.dart';
import '../../config/game_routes.dart';
import '../widgets/comic_button.dart';
import '../widgets/comic_background_painter.dart';

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
      
      // Force tutorial to play for fresh registrations (fixes bypass on flutter run --profile)
      await prefs.setBool('tutorial_completed', false);

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

  Widget _buildTextField(TextEditingController controller, String label, String validationMsg) {
    return Transform(
      transform: Matrix4.skewX(-0.05),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 4),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(6, 6),
              blurRadius: 0,
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w900),
            floatingLabelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: InputBorder.none,
          ),
          validator: (value) => value == null || value.trim().isEmpty ? validationMsg : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.black,
        child: const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Painter (Yellow with halftones & lines)
          Positioned.fill(
            child: CustomPaint(
              painter: ComicBackgroundPainter(),
            ),
          ),
          
          // Form Container
          Center(
            child: Transform(
              transform: Matrix4.skewX(-0.05),
              child: Container(
                width: 450,
                padding: const EdgeInsets.all(32.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF26E0FF), // Cyan Background
                  border: Border.all(color: Colors.black, width: 6),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(12, 12),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform(
                          transform: Matrix4.skewX(-0.1),
                          child: Text(
                            'STUDENT\nREGISTRATION',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.bangers(
                              color: const Color(0xFFFF2F92), // Magenta
                              fontSize: 48,
                              height: 1.0,
                              letterSpacing: 2.0,
                              shadows: const [
                                Shadow(offset: Offset(-2, -2), color: Colors.white),
                                Shadow(offset: Offset(4, 4), color: Colors.black),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildTextField(_nameController, 'FULL NAME', 'Please enter your name!'),
                        const SizedBox(height: 24),
                        _buildTextField(_rollNumberController, 'ROLL NUMBER', 'Please enter your roll number!'),
                        const SizedBox(height: 32),
                        ComicButton(
                          label: 'ENTER AUDITORIUM',
                          color: const Color(0xFFF5D300), // Yellow
                          textColor: Colors.black,
                          icon: Icons.login,
                          onPressed: _saveAndProceed,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
