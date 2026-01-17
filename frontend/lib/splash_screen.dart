import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/features/auth/service/auth_service.dart';
import 'package:frontend/features/shared/service/chat_service.dart';
import 'package:frontend/core/network/network_detector.dart';
import 'package:frontend/core/router/route_constants.dart';
import 'package:frontend/features/auth/bloc/auth_bloc.dart';
// navigation handled by router (go_router) using named routes
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool _isDotCenter = false;
  bool _isExiting = false;
  String? _userRole;

  late AnimationController _exitController;
  late Animation<double> _circleScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _backgroundFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Exit animation controller
    _exitController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    // Circle expands to fill screen (96px -> ~screen size)
    // Calculate scale to cover screen: roughly 4-5x is enough for most screens
    _circleScaleAnimation = Tween<double>(begin: 1.0, end: 5.0).animate(
      CurvedAnimation(
        parent: _exitController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeInOutCubic),
      ),
    );

    // Logo fades out as circle expands (faster than scale)
    _logoFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _exitController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // Background syncs - not needed visually but helps transition
    _backgroundFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _exitController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
      ),
    );

    _startAnimation();
  }

  @override
  void dispose() {
    _exitController.dispose();
    super.dispose();
  }

  void _startAnimation() async {
    // Check for existing session while showing splash (await so we decide correct target)
    await _checkExistingSession();

    // Entrance: dot moves to center
    if (!mounted) return;
    setState(() {
      _isDotCenter = true;
    });

    // Wait for dot animation, then start exit sequence
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _isExiting = true;
    });

    // Start exit animation
    await _exitController.forward();
    if (!mounted) return;
    _navigateToHome();
  }

  Future<void> _checkExistingSession() async {
    // Auto-detect correct backend IP on app startup
    await NetworkDetector.detectAndSetActiveIP();

    final result = await AuthService.getMe();
    if (result.success && result.user != null) {
      _userRole = result.user!['role'];
      // Update AuthBloc with logged-in user
      if (mounted) {
        context.read<AuthBloc>().add(AuthLoggedIn(result.user!));
      }
      // Sign in to Firebase if token exists
      await ChatService.signInToFirebase();
    } else {
      // Explicitly set unauthenticated if no valid session
      if (mounted) {
        context.read<AuthBloc>().add(const AuthStatusChanged(false));
      }
    }
  }

  void _navigateToHome() {
    // Route based on user role and navigate using GoRouter
    if (_userRole == 'bumdes') {
      context.goNamed(RouteNames.bumdesHome);
    } else if (_userRole != null) {
      context.goNamed(RouteNames.pembeliHome);
    } else {
      // No authenticated user found, go to login
      context.goNamed(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: AnimatedBuilder(
        animation: _exitController,
        builder: (context, child) {
          return Stack(
            children: [
              // Background that fades to home screen color during exit
              Positioned.fill(
                child: Container(
                  color: Color.lerp(
                    AppColors.primary,
                    AppColors.surface,
                    _backgroundFadeAnimation.value,
                  ),
                ),
              ),
              // Main content
              SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // Logo circle with exit animation
                    Center(
                      child: Opacity(
                        opacity: _logoFadeAnimation.value,
                        child: Transform.scale(
                          scale: _isExiting ? _circleScaleAnimation.value : 1.0,
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.surface,
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
                    ),
                    // Animated dot
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 500),
                      curve: const Cubic(.47, -1.26, .36, 1),
                      left:
                          (MediaQuery.of(context).size.width / 2) -
                          12 -
                          (_isDotCenter ? 0 : 80),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: _isExiting ? 0.0 : 1.0,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColors.surface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
