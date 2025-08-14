import 'dart:async';
import 'package:flutter/material.dart';

class LogoutScreen extends StatefulWidget {
  @override
  _LogoutScreenState createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _logoSlideAnimation;
  late Animation<Offset> _textSlideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    // Fade animation
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    // Logo slide animation (from left)
    _logoSlideAnimation = Tween<Offset>(
      begin: Offset(-1, 0), // Start from left (off-screen)
      end: Offset(0, 0),    // End at center
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Text slide animation (from right)
    _textSlideAnimation = Tween<Offset>(
      begin: Offset(1, 0),  // Start from right (off-screen)
      end: Offset(0, 0),   // End at center
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward(); // start all animations

    // Navigate after 3 seconds
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacementNamed('/entry');
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
      backgroundColor: Color(0xFF0a0a0a),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo with slide animation
            SlideTransition(
              position: _logoSlideAnimation,
              child: Image.asset(
                'assets/images/logo.png',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 20),
            // Text with slide and fade animation
            SlideTransition(
              position: _textSlideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'See You Again!',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}