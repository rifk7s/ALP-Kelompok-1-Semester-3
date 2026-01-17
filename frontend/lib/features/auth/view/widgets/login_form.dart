import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/utils/ui_helpers.dart';
import 'package:frontend/core/widgets/loading_widgets.dart';
import 'package:frontend/features/auth/service/auth_service.dart';
import 'package:frontend/features/auth/bloc/auth_bloc.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _isSuccess = false;

  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  // Keys untuk shake animation
  final _phoneShakeKey = GlobalKey<ShakeWidgetState>();
  final _passwordShakeKey = GlobalKey<ShakeWidgetState>();

  Widget _buildSuccessIcon() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value.clamp(0.0, 1.0),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.white,
              size: 24,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;

    // Validation dengan shake animation
    bool hasError = false;

    if (_phoneController.text.isEmpty) {
      _phoneShakeKey.currentState?.shake();
      hasError = true;
    }

    if (_passwordController.text.isEmpty) {
      _passwordShakeKey.currentState?.shake();
      hasError = true;
    }

    if (hasError) {
      SnackBarHelper.showError(context, 'Nomor HP dan kata sandi harus diisi');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Minimum loading duration untuk menampilkan animasi
      final loginResult = await Future.wait([
        AuthService.login(
          phone: _phoneController.text,
          password: _passwordController.text,
        ),
        Future.delayed(
          const Duration(milliseconds: 800),
        ), // Minimum 800ms loading
      ]).then((value) => value[0]);

      if (!mounted) return;

      if (loginResult.success) {
        // Show success animation first (before updating auth state)
        setState(() => _isSuccess = true);

        // Wait for success animation to complete
        await Future.delayed(const Duration(milliseconds: 1000));

        if (!mounted) return;

        // Now update AuthBloc - this will trigger router redirect
        if (loginResult.user != null) {
          context.read<AuthBloc>().add(AuthLoggedIn(loginResult.user!));
        }
      } else {
        setState(() => _isLoading = false);
        SnackBarHelper.showError(context, loginResult.message ?? 'Login gagal');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nomor HP',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        ShakeWidget(
          key: _phoneShakeKey,
          child: TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: 'Masukkan Nomor HP'),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Kata Sandi',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        ShakeWidget(
          key: _passwordShakeKey,
          child: TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              hintText: 'Masukkan Kata Sandi',
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Ingat saya',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Lupa Kata Sandi?',
                style: TextStyle(color: AppColors.info),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOutCubic,
              decoration: BoxDecoration(
                color: _isSuccess
                    ? AppColors.success
                    : _isLoading
                    ? AppColors.grey400
                    : AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Theme(
                data: Theme.of(
                  context,
                ).copyWith(splashFactory: NoSplash.splashFactory),
                child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        minimumSize: const Size(double.infinity, 48),
                      ).copyWith(
                        overlayColor: WidgetStateProperty.all(
                          AppColors.transparent,
                        ),
                      ),
                  onPressed: _isLoading || _isSuccess ? null : _handleLogin,
                  child: _isSuccess
                      ? _buildSuccessIcon()
                      : _isLoading
                      ? const AppSmallLoadingIndicator(
                          color: AppColors.white,
                          size: 20.0,
                        )
                      : const Text('Masuk'),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Masuk untuk melanjutkan',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'atau',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: AppColors.border),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/svgs/google_icon.svg',
                height: 24,
                width: 24,
                placeholderBuilder: (context) =>
                    const SizedBox(width: 24, height: 24),
              ),
              const SizedBox(width: 12),
              const Text('Masuk menggunakan Google'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.facebook, size: 24, color: AppColors.info),
          label: const Text('Masuk menggunakan Facebook'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: AppColors.border),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
