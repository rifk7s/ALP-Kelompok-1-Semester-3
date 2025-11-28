import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/features/auth/widgets/login_form.dart';
import 'package:frontend/features/auth/widgets/register_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          // Top Section with Logo
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.35,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 162,
                    height: 163,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFFE8DCC6),
                            child: const Icon(
                              Icons.agriculture,
                              size: 50,
                              color: AppColors.primary,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // const Text(
                  //   "PanenKi'",
                  //   style: TextStyle(
                  //     fontSize: 24,
                  //     fontWeight: FontWeight.bold,
                  //     color: AppColors.white,
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
          // Bottom Section with Form
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _isLogin ? 'Masuk Sekarang' : 'Mulai Sekarang',
                        key: ValueKey<bool>(_isLogin),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Membuat akun atau masuk untuk menggunakan aplikasi',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Tabs
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isLogin = true;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _isLogin ? AppColors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: _isLogin
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.1),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : null,
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Center(
                                  child: Text(
                                    'Masuk',
                                    style: TextStyle(
                                      fontWeight: _isLogin ? FontWeight.bold : FontWeight.w500,
                                      color: _isLogin ? AppColors.textPrimary : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isLogin = false;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: !_isLogin ? AppColors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: !_isLogin
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.1),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : null,
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Center(
                                  child: Text(
                                    'Daftar',
                                    style: TextStyle(
                                      fontWeight: !_isLogin ? FontWeight.bold : FontWeight.w500,
                                      color: !_isLogin ? AppColors.textPrimary : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Form Content
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: _isLogin
                          ? const LoginForm(key: ValueKey('login'))
                          : const RegisterForm(key: ValueKey('register')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
