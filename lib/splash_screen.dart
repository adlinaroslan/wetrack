import 'package:flutter/material.dart';
import 'dart:async'; // Required for Timer or Future.delayed
import 'role_selection.dart'; // show role selection after splash

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;
  double _scale = 0.5; // Start small for zoom effect

  @override
  void initState() {
    super.initState();
    // Start the animation after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0; // Fade in
        _scale = 1.0; // Zoom to original size
      });
    });

    // Navigate to the role selection page after the animation and a display duration
    Timer(const Duration(seconds: 3), () {
      // Show splash screen for 3 seconds
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const RoleSelectionPage(),
        ), // Navigate to role selection (then login -> homepage)
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF00A7A7),
              Color(0xFF004C5C),
            ], // Your gradient colors
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(milliseconds: 1000), // Fade in duration
            curve: Curves.easeIn,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 1500), // Zoom duration
              curve: Curves.easeInOutBack, // A nice bouncy curve for the zoom
              transform: Matrix4.identity()..scale(_scale),
              child: const Text(
                'WeTrack',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
