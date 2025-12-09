import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/utils/page_transitions.dart';
import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/features/pembeli/screens/start_page.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _addressController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Semua field harus diisi')));
      return;
    }

    if (_passwordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kata sandi minimal 8 karakter')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.register(
      name: _nameController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
      address: _addressController.text,
      role: 'pembeli',
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result.success) {
      // Auto-login setelah register berhasil
      final loginResult = await AuthService.login(
        phone: _phoneController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (loginResult.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi berhasil! Selamat datang.')),
        );
        context.pushReplacementSmooth(const StartPage());
      } else {
        // Register berhasil tapi login gagal - suruh login manual
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi berhasil! Silakan login.')),
        );
      }
    } else {
      String errorMsg = result.message ?? 'Registrasi gagal';
      if (result.errors != null) {
        final errors = result.errors!.values
            .expand((e) => e as List)
            .join('\n');
        errorMsg = errors;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMsg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nama',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(hintText: 'Masukkan Nama Lengkap'),
        ),
        const SizedBox(height: 16),
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
          'Atur Kata Sandi',
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
        const Text(
          'Alamat',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _addressController,
          maxLines: 2,
          decoration: const InputDecoration(hintText: 'Masukkan Alamat'),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleRegister,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Daftar Sebagai Pembeli'),
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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ingin daftar sebagai petani?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Datang ke kantor BUMDes:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.danger,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Jl. Desa Sengka No. 10',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              const Text(
                '0811-2222-3333',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
