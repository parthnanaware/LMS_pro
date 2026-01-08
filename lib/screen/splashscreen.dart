import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lms_pro/singin/login.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.4, end: 1.05), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 1.05, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.easeInOutQuint),
    ));

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * 3.14159,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
    ));

    // Start animation with slight delay for better feel
    Future.delayed(const Duration(milliseconds: 100), () {
      _controller.forward();
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => OnboardingScreen(),
          transitionDuration: const Duration(milliseconds: 1200),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: child,
            );
          },
        ),
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6366F1), // Indigo
              Color(0xFF8B5CF6), // Violet
              Color(0xFFEC4899), // Pink
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Enhanced animated background
            _buildAnimatedBackground(),

            // Main content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Enhanced logo container
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glow effect
                      AnimatedBuilder(
                        animation: _glowAnimation,
                        builder: (context, child) {
                          return Container(
                            width: 240,
                            height: 240,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withOpacity(0.3 * _glowAnimation.value),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      // Outer rotating ring
                      AnimatedBuilder(
                        animation: _rotateAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _rotateAnimation.value,
                            child: Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: SweepGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.4),
                                    Colors.white.withOpacity(0.1),
                                    Colors.white.withOpacity(0.4),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      // Main logo with enhanced styling
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.25),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 25,
                                  offset: const Offset(0, 15),
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(90),
                              child: Image.asset(
                                "assets/animations/student with laptop.gif",
                                width: 170,
                                height: 170,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.school_rounded,
                                    size: 64,
                                    color: Colors.white.withOpacity(0.95),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 45),

                  // Enhanced text content
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          AnimatedBuilder(
                            animation: _glowAnimation,
                            builder: (context, child) {
                              return Text(
                                "LearnHub Pro",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 42,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 15 * _glowAnimation.value,
                                      color: Colors.white.withOpacity(0.5),
                                      offset: const Offset(0, 0),
                                    ),
                                    Shadow(
                                      blurRadius: 30 * _glowAnimation.value,
                                      color: Colors.purpleAccent.withOpacity(0.3),
                                      offset: const Offset(0, 0),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Elevate Your Learning Experience",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 55),

                  // Smoother loading indicator
                  _buildEnhancedLoader(),
                ],
              ),
            ),

            // Enhanced bottom info
            Positioned(
              bottom: 45,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _fadeAnimation,
                  curve: const Interval(0.7, 1.0),
                ),
                child: Column(
                  children: [
                    Text(
                      "Version 1.0.0",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite,
                          size: 12,
                          color: Colors.pinkAccent.withOpacity(0.7),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Made with passion for education",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Stack(
      children: [
        // Large decorative elements
        Positioned(
          top: -80,
          right: -80,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        Positioned(
          bottom: -100,
          left: -100,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.purpleAccent.withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Floating particles with smoother movement
        ..._buildFloatingParticles(),
      ],
    );
  }

  List<Widget> _buildFloatingParticles() {
    final particles = [
      {'top': 120.0, 'left': 50.0, 'size': 6.0, 'delay': 0.0},
      {'top': 80.0, 'right': 70.0, 'size': 8.0, 'delay': 0.3},
      {'top': 200.0, 'left': 30.0, 'size': 5.0, 'delay': 0.6},
      {'bottom': 150.0, 'right': 40.0, 'size': 7.0, 'delay': 0.9},
      {'top': 280.0, 'right': 100.0, 'size': 4.0, 'delay': 1.2},
    ];

    return particles.map((particle) {
      return Positioned(
        top: particle['top'],
        left: particle['left'],
        right: particle['right'],
        bottom: particle['bottom'],
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = particle['delay']!;
            final value = (_controller.value - delay).clamp(0.0, 1.0);
            final opacity = (0.3 * value).clamp(0.0, 0.3);
            final offset = 20 * sin(value * 2 * 3.14159);

            return Transform.translate(
              offset: Offset(0, offset),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: particle['size'],
                  height: particle['size'],
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    }).toList();
  }

  Widget _buildEnhancedLoader() {
    return SizedBox(
      width: 140,
      child: Column(
        children: [
          // Smooth wave loading animation
          Container(
            width: 120,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final waveValue = _controller.value * 2;
                return Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 120 * (waveValue % 1),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.8),
                              Colors.white,
                              Colors.white.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 25),

          // Enhanced loading text
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final dots = ((_controller.value * 3) % 4).floor();
              return Text(
                "Loading${List.generate(dots, (_) => '.').join()}",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.0,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}