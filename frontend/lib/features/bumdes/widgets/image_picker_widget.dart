import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/services/api_config.dart';

/// Widget for picking and displaying multiple images
/// Used in product upload and edit screens
/// Supports both local files (for upload) and URLs (for edit mode)
class BumdesImagePicker extends StatefulWidget {
  final List<File> selectedImages;
  final List<Map<String, dynamic>>? existingImages;
  final List<Map<String, dynamic>>? existingImageUrls; // URLs from backend storage
  final Function(List<File>) onImagesChanged;
  final Function(List<int>)? onImagesToDelete;
  final bool isEnabled;

  const BumdesImagePicker({
    super.key,
    required this.selectedImages,
    this.existingImages,
    this.existingImageUrls,
    required this.onImagesChanged,
    this.onImagesToDelete,
    this.isEnabled = true,
  });

  @override
  State<BumdesImagePicker> createState() => _BumdesImagePickerState();
}

class _BumdesImagePickerState extends State<BumdesImagePicker> {
  final ImagePicker _picker = ImagePicker();
  List<int> _imagesToDelete = [];

  @override
  void initState() {
    super.initState();
    _imagesToDelete = widget.existingImages
            ?.where((img) => img['marked_for_delete'] == true)
            .map<int>((img) => img['id'] as int)
            .toList() ??
        [];
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [];

    // Selected new images section
    if (widget.selectedImages.isNotEmpty) {
      children.addAll([
        const Text(
          'Gambar Baru:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _buildNewImageWidgets(),
        ),
        const SizedBox(height: 16),
      ]);
    }

    // Existing images section
    if (widget.existingImages != null && widget.existingImages!.isNotEmpty) {
      children.addAll([
        const Text(
          'Gambar Tersimpan:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _buildExistingImageWidgets(),
        ),
        const SizedBox(height: 16),
      ]);
    }

    // Add image button
    if (widget.isEnabled) {
      children.add(
        InkWell(
          onTap: _pickImages,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primary,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Tambah Gambar',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  List<Widget> _buildNewImageWidgets() {
    if (widget.selectedImages.isEmpty) return [];

    return widget.selectedImages.asMap().entries.map((entry) {
      final index = entry.key;
      final image = entry.value;
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              image,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          if (widget.isEnabled)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _removeNewImage(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: AppColors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
        ],
      );
    }).toList();
  }

  List<Widget> _buildExistingImageWidgets() {
    final List<Map<String, dynamic>> allImages = [];

    // Add images from database (with file paths)
    if (widget.existingImages != null && widget.existingImages!.isNotEmpty) {
      allImages.addAll(widget.existingImages!);
    }

    // Add image URLs from backend storage
    if (widget.existingImageUrls != null && widget.existingImageUrls!.isNotEmpty) {
      allImages.addAll(widget.existingImageUrls!);
    }

    return allImages.asMap().entries.map((entry) {
      final image = entry.value;
      final isMarkedForDelete = _imagesToDelete.contains(image['id']);

      // Get the image path and convert to URL if needed
      final imagePath = image['image_path'] as String?;
      if (imagePath == null || imagePath.isEmpty) {
        return const SizedBox.shrink();
      }

      // Convert relative storage path to full URL
      final imageUrl = ApiConfig.getImageUrl(imagePath);

      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100,
                  height: 100,
                  color: AppColors.greyLight,
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 32),
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 100,
                  height: 100,
                  color: AppColors.greyLight,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
          if (widget.isEnabled)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _toggleExistingImageDelete(image['id'] as int),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isMarkedForDelete
                        ? AppColors.success
                        : AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isMarkedForDelete ? Icons.undo : Icons.close,
                    color: AppColors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
        ],
      );
    }).toList();
  }

  Future<void> _pickImages() async {
    try {
      // Check if adding images would exceed limit
      final currentCount = widget.selectedImages.length;
      if (currentCount >= 5) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Maksimal 5 foto")),
          );
        }
        return;
      }

      final List<XFile> images = await _picker.pickMultiImage();

      if (!mounted) return;

      if (images.isEmpty) {
        // User cancelled or didn't select any photos
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tidak ada foto yang dipilih")),
        );
        return;
      }

      // Check total after adding
      if (currentCount + images.length > 5) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Total foto tidak boleh lebih dari 5")),
          );
        }
        // Only add up to the limit
        images.take(5 - currentCount);
      }

      final imageFiles = images
          .take(5 - currentCount)
          .map((xFile) => File(xFile.path))
          .toList();

      setState(() {
        widget.selectedImages.addAll(imageFiles);
      });
      widget.onImagesChanged(widget.selectedImages);

      if (mounted && imageFiles.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${imageFiles.length} foto ditambahkan")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e')),
        );
      }
    }
  }

  void _removeNewImage(int index) {
    setState(() {
      widget.selectedImages.removeAt(index);
    });
    widget.onImagesChanged(widget.selectedImages);
  }

  void _toggleExistingImageDelete(int imageId) {
    setState(() {
      if (_imagesToDelete.contains(imageId)) {
        _imagesToDelete.remove(imageId);
      } else {
        _imagesToDelete.add(imageId);
      }
    });
    widget.onImagesToDelete?.call(_imagesToDelete);
  }
}
