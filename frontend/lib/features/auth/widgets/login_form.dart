import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/utils/page_transitions.dart';
import 'package:frontend/core/utils/ui_helpers.dart';
import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/features/bumdes/screens/start_page_bumdes.dart';
import 'package:frontend/features/pembeli/screens/start_page.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;

  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;
    
    if (_phoneController.text.isEmpty || _passwordController.text.isEmpty) {
      SnackBarHelper.showError(context, 'Nomor HP dan kata sandi harus diisi');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await AuthService.login(
        phone: _phoneController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (result.success) {
        SnackBarHelper.showSuccess(
          context,
          result.message ?? 'Login berhasil!',
        );

        final role = result.user?['role'] ?? 'pembeli';
        if (role == 'bumdes') {
          context.pushReplacementSmooth(const StartPageBumdes());
        } else {
          context.pushReplacementSmooth(const StartPage());
        }
      } else {
        SnackBarHelper.showError(
          context,
          result.message ?? 'Login gagal',
        );
      }
    } finally {
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
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(hintText: 'Masukkan Nomor HP'),
        ),
        const SizedBox(height: 16),
        const Text(
          'Kata Sandi',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        TextFormField(
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
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Masuk'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Login untuk melanjutkan',
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
