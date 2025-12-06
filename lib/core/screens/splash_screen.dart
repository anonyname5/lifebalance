import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../../features/home/screens/home_screen.dart';

/// Splash screen shown when app starts
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _fadeOutAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Fade in animation (0.0 to 0.6 of the controller)
    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Fade out animation (0.7 to 1.0 of the controller)
    _fadeOutAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    // Scale animation (0.0 to 0.5 of the controller)
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    // Wait for fade in and display time (1.5 seconds)
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Start fade out animation
    if (mounted) {
      // Animate from 0.7 to 1.0 (fade out)
      await _controller.animateTo(1.0, curve: Curves.easeOut);
    }
    
    // Navigate after fade out completes with smooth transition
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Smooth fade transition for home screen entry
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
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // Use fade out animation when transitioning, otherwise use fade in
          final opacity = _controller.value > 0.7 
              ? _fadeOutAnimation.value 
              : _fadeInAnimation.value;
          
          return Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Opacity(
              opacity: opacity,
              child: Center(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Icon/Logo
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.balance,
                          size: 70,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // App Name
                      Text(
                        AppStrings.appName,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // App Tagline
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          AppStrings.appTagline,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      // Loading Indicator
                      const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
