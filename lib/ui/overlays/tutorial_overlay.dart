import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../game/spider_slinger_game.dart';
import '../../config/game_routes.dart';
import '../../services/audio_service.dart';
import '../widgets/virtual_button.dart';
import 'package:google_fonts/google_fonts.dart';

class TutorialOverlay extends StatefulWidget {
  final SpiderSlingerGame game;

  const TutorialOverlay({super.key, required this.game});

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    widget.game.pauseEngine();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_completed', true);
    widget.game.overlays.remove(GameRoutes.tutorial);
    widget.game.resumeEngine();
    AudioService.initialize();
    AudioService.playBgm();
  }
  
  void _advanceStep() {
    if (_currentStep < 5) {
      setState(() => _currentStep++);
    } else {
      _completeTutorial();
    }
  }

  Widget _buildTooltip(String title, String subtitle, {double? top, double? bottom, double? left, double? right, Color? bgColor}) {
    final backgroundColor = bgColor ?? Colors.white;
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Transform(
        transform: Matrix4.skewX(-0.1)..rotateZ(-0.02),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: Colors.black, width: 6),
            boxShadow: const [
              BoxShadow(color: Colors.black, offset: Offset(10, 10)),
              BoxShadow(color: Color(0xFF26E0FF), offset: Offset(-6, -6)), // Cyan pop
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title.toUpperCase(),
                style: GoogleFonts.bangers(
                  fontSize: 38,
                  letterSpacing: 2.0,
                  color: const Color(0xFFFF3B3B), // Crimson title
                  shadows: const [
                    Shadow(offset: Offset(3, 3), color: Colors.black),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTargetButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isTarget,
  }) {
    final btn = VirtualButton(
      icon: icon,
      label: label,
      color: color,
      onPointerDown: isTarget ? _advanceStep : null,
    );

    return IgnorePointer(
      ignoring: !isTarget,
      child: Opacity(
        opacity: isTarget ? 1.0 : 0.0, // Invisible if not the target, but takes up space!
        child: isTarget
            ? ScaleTransition(scale: _pulseAnimation, child: btn)
            : btn,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Allow tapping anywhere ONLY for intro and outro steps
      onTap: (_currentStep == 0 || _currentStep == 5) ? _advanceStep : null,
      child: Container(
        color: Colors.black.withValues(alpha: 0.7),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Stack(
              children: [
                // Step 0: Welcome
                if (_currentStep == 0)
                  Center(
                    child: _buildTooltip(
                      'WELCOME TO INSECT BLITZ', 
                      'Tap anywhere to begin the interactive tutorial!',
                      bgColor: const Color(0xFFFFF59D), // Light yellow
                    ),
                  ),

                // Left side mock HUD layout
                if (_currentStep == 1) ...[
                  _buildTooltip('RUN RIGHT', 'Tap the highlighted RIGHT arrow to move.', bottom: 90, left: 0, bgColor: const Color(0xFFE1BEE7)), // Light purple
                ],
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTargetButton(
                        icon: Icons.arrow_back_rounded,
                        label: 'LEFT',
                        color: const Color(0xFF0B3D91),
                        isTarget: false, // We only teach RIGHT for simplicity
                      ),
                      const SizedBox(width: 24),
                      _buildTargetButton(
                        icon: Icons.arrow_forward_rounded,
                        label: 'RIGHT',
                        color: const Color(0xFF0B3D91),
                        isTarget: _currentStep == 1,
                      ),
                    ],
                  ),
                ),

                // Right side mock HUD layout
                if (_currentStep == 2)
                  _buildTooltip('JUMP', 'Tap the highlighted JUMP button\nto leap over pits and hazards.', bottom: 90, right: 280, bgColor: const Color(0xFFC8E6C9)), // Light green
                if (_currentStep == 3)
                  _buildTooltip('SWING', 'While in the air, tap SWING\nto launch yourself forward on a web.', bottom: 90, right: 0, bgColor: const Color(0xFFB3E5FC)), // Light blue
                if (_currentStep == 4)
                  _buildTooltip('SHOOT WEBS', 'Tap SHOOT to blast enemies.', bottom: 90, right: 140, bgColor: const Color(0xFFFFCCBC)), // Light red

                Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTargetButton(
                        icon: Icons.arrow_upward_rounded,
                        label: 'JUMP',
                        color: const Color(0xFFFFD23F), // Gold
                        isTarget: _currentStep == 2,
                      ),
                      const SizedBox(width: 24),
                      _buildTargetButton(
                        icon: Icons.gps_fixed_rounded,
                        label: 'SHOOT',
                        color: const Color(0xFFFF3B3B), // Crimson
                        isTarget: _currentStep == 4,
                      ),
                      const SizedBox(width: 24),
                      _buildTargetButton(
                        icon: Icons.waves_rounded,
                        label: 'SWING',
                        color: const Color(0xFF3A1C8C), // Indigo
                        isTarget: _currentStep == 3,
                      ),
                    ],
                  ),
                ),

                // Step 5: Finish
                if (_currentStep == 5)
                  Center(
                    child: _buildTooltip(
                      'YOU ARE READY!', 
                      'Tap anywhere to start the game. Good luck!',
                      bgColor: const Color(0xFFFFF59D), // Light yellow
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
