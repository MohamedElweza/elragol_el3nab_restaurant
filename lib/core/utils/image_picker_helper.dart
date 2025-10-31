import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'constants/app_constants.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Show image picker dialog with options for camera and gallery
  static Future<File?> showImagePickerDialog(BuildContext context) async {
    return showDialog<File?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'اختيار صورة',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('التقاط صورة من الكاميرا'),
                onTap: () async {
                  final file = await _pickImage(ImageSource.camera);
                  Navigator.of(context).pop(file);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('اختيار من المعرض'),
                onTap: () async {
                  final file = await _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop(file);
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('إلغاء'),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Pick image from camera or gallery
  static Future<File?> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      print('Error picking image: $e');
    }
    return null;
  }

  /// Get default placeholder image path based on type
  static String getPlaceholderImage(String type) {
    switch (type.toLowerCase()) {
      case 'vendor':
      case 'restaurant':
        return 'assets/images/default_restaurant.png';
      case 'food':
      case 'item':
      case 'menu':
        return 'assets/images/default_food.png';
      default:
        return 'assets/images/default_image.png';
    }
  }

  /// Check if the image path is a placeholder
  static bool isPlaceholderImage(String? imagePath) {
    if (imagePath == null) return true;
    return imagePath.startsWith('assets/images/default_');
  }

  /// Get full URL for vendor logo
  static String getVendorLogoUrl(String? logoPath) {
    if (logoPath == null || logoPath.isEmpty) {
      return getPlaceholderImage('vendor');
    }
    if (logoPath.startsWith('/')) {
      return '${AppConstants.baseUrl}$logoPath';
    }
    return logoPath;
  }

  /// Get image widget with proper fallback handling
  static Widget buildImageWidget({
    String? imagePath,
    String placeholderType = 'default',
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
  }) {
    Widget imageWidget;

    if (imagePath != null && !isPlaceholderImage(imagePath)) {
      // Network image from API (full URL or relative path from server)
      if (imagePath.startsWith('http') || imagePath.startsWith('/uploads/')) {
        String fullImageUrl = imagePath;
        
        // Convert relative path to full URL
        if (imagePath.startsWith('/uploads/')) {
          fullImageUrl = '${AppConstants.baseUrl}$imagePath';
        }
        
        imageWidget = CachedNetworkImage(
          imageUrl: fullImageUrl,
          width: width,
          height: height,
          fit: fit,
          httpHeaders: {
            'ngrok-skip-browser-warning': 'true',
          },
          placeholder: (context, url) => Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: borderRadius,
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          errorWidget: (context, url, error) {
            print('Error loading cached image: $url - $error');
            return Image.asset(
              getPlaceholderImage(placeholderType),
              width: width,
              height: height,
              fit: fit,
            );
          },
        );
      }
      // Local file (actual device file paths)
      else if (imagePath.startsWith('/') && !imagePath.startsWith('/uploads/')) {
        imageWidget = Image.file(
          File(imagePath),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              getPlaceholderImage(placeholderType),
              width: width,
              height: height,
              fit: fit,
            );
          },
        );
      }
      // Asset image
      else {
        imageWidget = Image.asset(
          imagePath,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              getPlaceholderImage(placeholderType),
              width: width,
              height: height,
              fit: fit,
            );
          },
        );
      }
    } else {
      // Use placeholder
      imageWidget = Image.asset(
        getPlaceholderImage(placeholderType),
        width: width,
        height: height,
        fit: fit,
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}