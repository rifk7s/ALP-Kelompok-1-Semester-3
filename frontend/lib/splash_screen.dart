import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/start_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isDotCenter = false;
  bool _isScalTheCircle = false;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isDotCenter = true;
      });
      Future.delayed(const Duration(milliseconds: 520), () {
        setState(() {
          _isScalTheCircle = true;
        });
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const StartPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeIn,
                ),
                child: child,
              ),
            ),
          );
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SizedBox(
        height: double.infinity,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Center(
              child: AnimatedScale(
                duration: const Duration(milliseconds: 600),
                curve: const Cubic(0.58, -0.30, 0.365, 1),
                scale: _isScalTheCircle ? 10 : 1,
                child: Container(
                  width: 96, // radius 48 * 2
                  height: 96,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: const Cubic(.47, -1.26, .36, 1),
              left: (MediaQuery.of(context).size.width / 2) -
                  12 -
                  (_isDotCenter ? 0 : 80),
              child: const CircleAvatar(
                radius: 12,
                backgroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
