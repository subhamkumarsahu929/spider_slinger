import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../game/spider_slinger_game.dart';
import '../../config/game_routes.dart';
import '../../services/audio_service.dart';

class TutorialOverlay extends StatefulWidget {
  final SpiderSlingerGame game;

  const TutorialOverlay({super.key, required this.game});

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    // Pause the game while the tutorial is showing so the player doesn't die in the background
    widget.game.pauseEngine();
  }

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'WELCOME TO SPIDER-SLINGER 🕸️',
      'subtitle': 'Traverse, Swing, Combat, and Survive!',
      'content': 'Take control of Spider-Man in a procedural 2D platformer. Swing from ceilings, dodge deadly hazards, and defeat waves of enemies leading up to Venom!',
      'illustration': 'intro',
    },
    {
      'title': 'RUNNING & JUMPING 🏃',
      'subtitle': 'Basic Controls',
      'content': '• Hold Left/Right Orange buttons to run.\n• Tap the Green button to jump over spikes and deep pits.',
      'illustration': 'movement',
    },
    {
      'title': 'CEILING WEB HANG 🕸️',
      'subtitle': 'Vertical Traverse',
      'content': '• Jump into the air first!\n• Press and hold the Purple (SWING) button while in mid-air to shoot a web and hang upside down from the ceiling.',
      'illustration': 'hang',
    },
    {
      'title': 'MOMENTUM SWING 🚀',
      'subtitle': 'Launch Forward',
      'content': '• While hanging from a ceiling web anchor...\n• Hold the RIGHT button and release the Purple (SWING) button to launch forward in a massive arc!',
      'illustration': 'swing',
    },
    {
      'title': 'WEB SHOOTING 💥',
      'subtitle': 'Combat System',
      'content': '• Tap the Red (SHOOT) button to fire web projectiles.\n• Take down crawling enemies, airborne flies, and deal damage to Venom!',
      'illustration': 'combat',
    },
  ];

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_steps.length, (index) {
        return Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentStep == index ? Colors.redAccent.shade700 : Colors.grey.shade600,
          ),
        );
      }),
    );
  }

  Widget _buildButtonRepresentation(IconData icon, Color color, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.35),
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 6),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildIllustration(String type) {
    switch (type) {
      case 'intro':
        return const Icon(Icons.sports_esports_outlined, color: Colors.redAccent, size: 80);
      case 'movement':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildButtonRepresentation(Icons.arrow_back_rounded, Colors.orange, 'LEFT'),
            const SizedBox(width: 16),
            _buildButtonRepresentation(Icons.arrow_forward_rounded, Colors.orange, 'RIGHT'),
            const SizedBox(width: 32),
            _buildButtonRepresentation(Icons.arrow_upward_rounded, Colors.green, 'JUMP'),
          ],
        );
      case 'hang':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildButtonRepresentation(Icons.arrow_upward_rounded, Colors.green, 'JUMP'),
            const Icon(Icons.arrow_right_alt, color: Colors.white54, size: 30),
            _buildButtonRepresentation(Icons.waves_rounded, Colors.purple, 'HOLD SWING'),
          ],
        );
      case 'swing':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildButtonRepresentation(Icons.arrow_forward_rounded, Colors.orange, 'HOLD RIGHT'),
            const Icon(Icons.add, color: Colors.white54, size: 24),
            _buildButtonRepresentation(Icons.waves_rounded, Colors.purple, 'RELEASE SWING'),
          ],
        );
      case 'combat':
        return _buildButtonRepresentation(Icons.gps_fixed_rounded, Colors.red, 'SHOOT');
      default:
        return const SizedBox();
    }
  }

  Future<void> _completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_completed', true);
    widget.game.overlays.remove(GameRoutes.tutorial);
    // Resume the game now that the tutorial is dismissed
    widget.game.overlays.add(GameRoutes.hud);
    widget.game.resumeEngine();
    AudioService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final stepData = _steps[_currentStep];

    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Container(
          width: 580,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade900,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 15,
                spreadRadius: 2,
              )
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  stepData['title'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stepData['subtitle'],
                  style: TextStyle(
                    color: Colors.redAccent.shade100,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  height: 90,
                  alignment: Alignment.center,
                  child: _buildIllustration(stepData['illustration']),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    stepData['content'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                _buildStepIndicator(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _completeTutorial,
                      child: const Text(
                        'SKIP TUTORIAL',
                        style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_currentStep < _steps.length - 1) {
                          setState(() {
                            _currentStep++;
                          });
                        } else {
                          _completeTutorial();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: Text(
                        _currentStep < _steps.length - 1 ? 'NEXT' : 'LET\'S PLAY!',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
