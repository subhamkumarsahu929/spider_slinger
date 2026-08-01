import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _isVideoInitialized = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/splash.mp4');
    
    // Wait for BOTH the video to load AND exactly 3.5 seconds to pass
    Future.wait([
      _controller.initialize(),
      Future.delayed(const Duration(milliseconds: 3500)),
    ]).then((_) {
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
        _controller.play();
      }
    }).catchError((e) {
      // Fallback if video fails to load
      _navigateToGame();
    });

    // Listen for when the video finishes playing
    _controller.addListener(() {
      if (_controller.value.isInitialized && 
          _controller.value.position >= _controller.value.duration &&
          !_controller.value.isPlaying) {
        _navigateToGame();
      }
    });
  }

  void _navigateToGame() {
    // Navigate to the main game screen only once
    if (mounted && !_navigated) {
      _navigated = true;
      Navigator.of(context).pushReplacementNamed('/game');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Better for letterboxing
      body: Center(
        child: _isVideoInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : Text(
                'SPIDER-SLINGER',
                style: GoogleFonts.bangers(
                  fontSize: 64,
                  letterSpacing: 3.0,
                  color: const Color(0xFFE23636), // Crimson Red
                  shadows: const [
                    Shadow(offset: Offset(-2, -2), color: Colors.white),
                    Shadow(offset: Offset(4, 4), color: Colors.black),
                  ],
                ),
              ),
      ),
    );
  }
}
