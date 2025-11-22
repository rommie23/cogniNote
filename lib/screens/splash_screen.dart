import 'package:flutter/material.dart';
import '../main.dart' show ConsentWrapper;

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _loadingPulseController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Title Fade-In Animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // Title Scale Animation
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.85,
      upperBound: 1.0,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    );

    // Loading pulse animation
    _loadingPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
      lowerBound: 0.3,
      upperBound: 1.0,
    )..repeat(reverse: true);

    // Start animations
    _fadeController.forward();
    _scaleController.forward();

    // Move to next screen
    Future.delayed(const Duration(milliseconds: 2000), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ConsentWrapper()),
      );
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _loadingPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFfaf7ff),
              Color(0xFFf3d9ff),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Main Title
                  Text(
                    "Cognitive Journal",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 34,
                      letterSpacing: 0.5,
                      color: Color(0xFF5a189a),
                      fontWeight: FontWeight.w900,
                      shadows: [
                        Shadow(
                          color: Color(0x448000FF),
                          offset: Offset(0, 2),
                          blurRadius: 6,
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    "by DevLark",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.deepPurple.shade300,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Underline shimmer bar
                  Container(
                    width: 120,
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF7b2cbf),
                          Color(0xFFc77dff),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),

                  const SizedBox(height: 45),

                  // Pulsing loading dot
                  ScaleTransition(
                    scale: _loadingPulseController,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7b2cbf),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7b2cbf).withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
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
