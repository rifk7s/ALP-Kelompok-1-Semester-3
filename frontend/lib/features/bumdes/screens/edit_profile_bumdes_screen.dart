import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/services/profile_service.dart';
import 'package:frontend/core/services/storage_service.dart';

class EditProfileBumdesPage extends StatefulWidget {
  final Profile? initialProfile;
  
  const EditProfileBumdesPage({super.key, this.initialProfile});

  @override
  State<EditProfileBumdesPage> createState() => _EditProfileBumdesPageState();
}

class _EditProfileBumdesPageState extends State<EditProfileBumdesPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  
  final ProfileService _service = ProfileService();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Load initial profile data if provided
    if (widget.initialProfile != null) {
      nameController.text = widget.initialProfile!.name;
      phoneController.text = widget.initialProfile!.phone ?? '';
      addressController.text = widget.initialProfile!.address ?? '';
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,

      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          "Edit Profil",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textLight),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const CircleAvatar(
                    radius: 55,
                    backgroundImage: AssetImage("assets/images/profile.png"),
                  ),

                  Positioned(
                    bottom: -4,
                    right: -4,
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 18,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
            customInput("Nama Lengkap", nameController),
            const SizedBox(height: 16),
            customInput("No. HP", phoneController),
            const SizedBox(height: 16),
            customInput("Alamat", addressController, maxLines: 3),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : () {
                  print('BumDes Button tapped! Saving state: $_saving');
                  _handleSave();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Simpan Perubahan",
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget customInput(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textLight,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSave() async {
    print('========== BUMDES BUTTON CLICKED ==========');
    print('Name: ${nameController.text}');
    print('Phone: ${phoneController.text}');
    print('Address: ${addressController.text}');
    
    // Validate inputs
    if (nameController.text.trim().isEmpty) {
      print('ERROR: Name is empty');
      _showError('Nama tidak boleh kosong');
      return;
    }

    print('Validation passed, starting save...');
    setState(() => _saving = true);
    
    try {
      final token = await StorageService.getToken();
      
      if (token == null) {
        setState(() => _saving = false);
        _showError('Sesi telah berakhir, silakan login kembali');
        return;
      }

      print('Starting profile update...');
      
      // Call API to update profile
      final updated = await _service.updateProfile(
        data: {
          'name': nameController.text.trim(),
          'phone': phoneController.text.trim(),
          'address': addressController.text.trim(),
        },
        token: token,
      );

      print('Profile updated successfully');

      // Update cached user data in local storage
      final currentUser = await StorageService.getUser();
      if (currentUser != null) {
        currentUser['name'] = updated.name;
        currentUser['phone'] = updated.phone;
        currentUser['address'] = updated.address;
        await StorageService.saveUser(currentUser);
      }

      if (!mounted) return;
      
      setState(() => _saving = false);
      
      // Show success and return updated profile
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      // Wait a bit for user to see the success message
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted) return;
      Navigator.pop(context, updated);
      
    } catch (e) {
      print('Error updating profile: $e');
      if (!mounted) return;
      setState(() => _saving = false);
      _showError('Gagal memperbarui profil: ${e.toString()}');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
