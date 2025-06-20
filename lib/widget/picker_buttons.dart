import 'package:flutter/material.dart';
import 'package:foodrecognizer/ui/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';

class PickerButtons extends StatelessWidget {
  final Function(ImageSource) onPickImage;
  final VoidCallback onLiveFeed;

  const PickerButtons({
    super.key,
    required this.onPickImage,
    required this.onLiveFeed,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = Theme.of(context).elevatedButtonTheme.style;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.photo_library_outlined),
          label: const Text('Pick from Gallery'),
          onPressed: () => onPickImage(ImageSource.gallery),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          icon: const Icon(Icons.camera_alt_outlined),
          label: const Text('Take a Picture'),
          onPressed: () => onPickImage(ImageSource.camera),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          icon: const Icon(Icons.videocam_outlined),
          label: const Text('Live Feed'),
          onPressed: onLiveFeed,
          style: buttonStyle?.copyWith(
            backgroundColor: MaterialStateProperty.all(AppTheme.accentColor),
          ),
        ),
      ],
    );
  }
}
