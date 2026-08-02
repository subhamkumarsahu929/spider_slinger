import 'package:flutter/material.dart';
import '../../game/spider_slinger_game.dart';
import '../../config/game_routes.dart';
import '../widgets/comic_button.dart';
import 'package:google_fonts/google_fonts.dart';

class HowToPlayOverlay extends StatefulWidget {
  final SpiderSlingerGame game;

  const HowToPlayOverlay({super.key, required this.game});

  @override
  State<HowToPlayOverlay> createState() => _HowToPlayOverlayState();
}

class _HowToPlayOverlayState extends State<HowToPlayOverlay> {
  int _currentStep = 0;

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'WELCOME TO INSECT BLITZ',
      'subtitle': 'Traverse, Swing, Combat, and Survive!',
      'content': 'Take control of Spider-Man in a procedural 2D platformer. Dodge deadly hazards, swing from ceilings, and defeat waves of enemies leading up to the final Venom boss fight!',
      'icon': Icons.sports_esports_outlined,
      'color': const Color(0xFFFFF59D), // Yellow
    },
    {
      'title': 'RUNNING & JUMPING',
      'subtitle': 'Basic Controls',
      'content': 'Use the LEFT and RIGHT arrows to run.\nTap JUMP to leap over deadly floor spikes and bottomless pits.',
      'icon': Icons.directions_run_rounded,
      'color': const Color(0xFFE1BEE7), // Purple
    },
    {
      'title': 'SWINGING',
      'subtitle': 'Advanced Traversal',
      'content': 'While in mid-air, tap SWING to shoot a web up to the ceiling and launch yourself forward!\nUse this to cross massive gaps.',
      'icon': Icons.waves_rounded,
      'color': const Color(0xFFB3E5FC), // Blue
    },
    {
      'title': 'COMBAT',
      'subtitle': 'Defeating Enemies',
      'content': 'Tap SHOOT to fire web projectiles.\nTake down crawling enemies and airborne flies to increase your score and survive until Venom appears!',
      'icon': Icons.gps_fixed_rounded,
      'color': const Color(0xFFFFCCBC), // Red
    },
  ];

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_steps.length, (index) {
        return Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentStep == index ? const Color(0xFFFF3B3B) : Colors.grey.shade600,
            border: Border.all(color: Colors.black, width: 2),
          ),
        );
      }),
    );
  }

  void _close() {
    widget.game.overlays.remove(GameRoutes.howToPlay);
    widget.game.overlays.add(GameRoutes.mainMenu);
  }

  @override
  Widget build(BuildContext context) {
    final stepData = _steps[_currentStep];

    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Transform(
          transform: Matrix4.skewX(-0.05),
          child: Container(
            width: 600,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: stepData['color'],
              border: Border.all(color: Colors.black, width: 8),
              boxShadow: const [
                BoxShadow(color: Colors.black, offset: Offset(12, 12)),
                BoxShadow(color: Colors.white, offset: Offset(-6, -6)),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform(
                    transform: Matrix4.skewX(-0.05),
                    child: Text(
                      stepData['title'],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.bangers(
                        color: const Color(0xFFFF3B3B),
                        fontSize: 42,
                        letterSpacing: 2.0,
                        shadows: const [
                          Shadow(offset: Offset(3, 3), color: Colors.black),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stepData['subtitle'],
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 4),
                      boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
                    ),
                    child: Icon(stepData['icon'], size: 50, color: Colors.black),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      stepData['content'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildStepIndicator(),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ComicButton(
                        label: 'CLOSE',
                        color: Colors.white,
                        textColor: Colors.black,
                        icon: Icons.close,
                        onPressed: _close,
                      ),
                      ComicButton(
                        label: _currentStep < _steps.length - 1 ? 'NEXT' : 'GOT IT',
                        color: const Color(0xFF0B3D91),
                        icon: _currentStep < _steps.length - 1 ? Icons.arrow_forward : Icons.check,
                        onPressed: () {
                          if (_currentStep < _steps.length - 1) {
                            setState(() => _currentStep++);
                          } else {
                            _close();
                          }
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
