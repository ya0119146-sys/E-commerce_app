import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/localization/app_translations.dart';

/// Cover and additional product image picker/manager section for ProductForm.
class ProductFormImagesSection extends StatelessWidget {
  final File? coverImage;
  final String? existingCoverUrl;
  final bool coverRemoved;
  final List<String> existingImages;
  final List<File> additionalImages;
  final VoidCallback onPickCover;
  final VoidCallback onRemoveCover;
  final VoidCallback onPickAdditional;
  final ValueChanged<String> onRemoveExistingImage;
  final ValueChanged<File> onRemoveAdditionalImage;

  const ProductFormImagesSection({
    super.key,
    required this.coverImage,
    required this.existingCoverUrl,
    required this.coverRemoved,
    required this.existingImages,
    required this.additionalImages,
    required this.onPickCover,
    required this.onRemoveCover,
    required this.onPickAdditional,
    required this.onRemoveExistingImage,
    required this.onRemoveAdditionalImage,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final hasExistingCover = existingCoverUrl != null && !coverRemoved;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cover Image Header with Optional Remove Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Cover Image'.tr(context),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (coverImage != null || hasExistingCover)
              GestureDetector(
                onTap: onRemoveCover,
                child: Text(
                  'Remove'.tr(context),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.redAccent.shade200,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onPickCover,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.muted(brightness),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(
                color: AppColors.border(brightness).withValues(alpha: 0.3),
              ),
              image: coverImage != null
                  ? DecorationImage(
                      image: FileImage(coverImage!),
                      fit: BoxFit.cover,
                    )
                  : (hasExistingCover
                        ? DecorationImage(
                            image: NetworkImage(existingCoverUrl!),
                            fit: BoxFit.cover,
                          )
                        : null),
            ),
            child: (coverImage == null && !hasExistingCover)
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_a_photo_outlined, size: 36),
                        const SizedBox(height: 6),
                        Text(
                          'Tap to choose cover'.tr(context),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 20),

        // Additional Images Header & Pick Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Additional Images'.tr(context),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: onPickAdditional,
              icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
              label: Text('Add More'.tr(context)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (additionalImages.isNotEmpty || existingImages.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ...existingImages.map(
                  (url) => _RemovableImageTile(
                    brightness: brightness,
                    imageProvider: NetworkImage(url),
                    onRemove: () => onRemoveExistingImage(url),
                  ),
                ),
                ...additionalImages.map(
                  (file) => _RemovableImageTile(
                    brightness: brightness,
                    imageProvider: FileImage(file),
                    onRemove: () => onRemoveAdditionalImage(file),
                  ),
                ),
              ],
            ),
          )
        else
          GestureDetector(
            onTap: onPickAdditional,
            child: Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.muted(brightness),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(
                  color: AppColors.border(brightness).withValues(alpha: 0.3),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_photo_alternate_outlined),
                    const SizedBox(height: 4),
                    Text(
                      'Pick multiple images'.tr(context),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _RemovableImageTile extends StatelessWidget {
  final Brightness brightness;
  final ImageProvider imageProvider;
  final VoidCallback onRemove;

  const _RemovableImageTile({
    required this.brightness,
    required this.imageProvider,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.border(brightness).withValues(alpha: 0.3),
            ),
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 4,
          right: 12,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
