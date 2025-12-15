import 'package:flutter/material.dart';
import 'dart:async';
import 'package:wetrack/screens/role_selection.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _titleOpacityAnimation;
  late Animation<double> _taglineOpacityAnimation;
  late Animation<Offset> _taglineSlideAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Setup the Animation Controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Total animation time
    );

    // 2. Define the Title ("WeTrack") Pop (Elastic Effect)
    // It appears quickly and elastically
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );
    _titleOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // 3. Define the Tagline Slide & Fade (Staggered to start later)
    _taglineOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _taglineSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Start the animation
    _controller.forward();

    // Navigate after delay (2.8 seconds)
    Timer(const Duration(milliseconds: 2800), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00A7A7), Color(0xFF004C5C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Spacer to keep elements centered (or slightly above)
            const Spacer(flex: 3),

            // --- ANIMATED TITLE: WeTrack ---
            ScaleTransition(
              scale: _scaleAnimation, // Elastic Pop effect
              child: FadeTransition(
                opacity: _titleOpacityAnimation,
                child: const Text(
                  'WeTrack',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48, // Large, impactful font size
                    fontWeight: FontWeight.w900, // Extra bold
                    letterSpacing: 2.0, // Open, modern look
                    shadows: [
                      // Subtle text shadow for a powerful 3D feel
                      Shadow(
                        color: Colors.black38,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(
                height: 16), // Increased spacing between title and tagline

            // --- TAGLINE (Staggered Animation) ---
            SlideTransition(
              position: _taglineSlideAnimation, // Slide up from bottom
              child: FadeTransition(
                opacity: _taglineOpacityAnimation, // Fade in
                child: const Text(
                  'Smart Asset Management',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const Spacer(flex: 2),

            // --- LOADING INDICATOR (Subtle indication of activity) ---
            FadeTransition(
              opacity:
                  _taglineOpacityAnimation, // Use the same staggered opacity
              child: const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white54,
                  strokeWidth: 2,
                ),
              ),
            ),

            const SizedBox(height: 50), // Bottom padding
          ],
        ),
      ),
    );
  }
}
