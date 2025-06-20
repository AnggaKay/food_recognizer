import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:foodrecognizer/service/image_service.dart';
import 'package:foodrecognizer/ui/camera_screen.dart';
import 'package:foodrecognizer/widget/action_buttons.dart';
import 'package:foodrecognizer/widget/image_preview.dart';
import 'package:foodrecognizer/widget/picker_buttons.dart';
import 'package:foodrecognizer/widget/result_display.dart';
import 'package:foodrecognizer/controller/photo_picker_controller.dart';
import 'package:provider/provider.dart';

/// A screen that allows users to pick, crop, and analyze images.
class PhotoPickerScreen extends StatefulWidget {
  const PhotoPickerScreen({super.key});

  @override
  State<PhotoPickerScreen> createState() => _PhotoPickerScreenState();
}

class _PhotoPickerScreenState extends State<PhotoPickerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PhotoPickerController>().initialize(context);
    });
  }

  /// Opens a dialog to ask the user to choose between gallery and camera.
  Future<void> _showImageSourceDialog(BuildContext context) async {
    final controller = context.read<PhotoPickerController>();
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Image Source"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: const Text("Gallery"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: const Text("Camera"),
          ),
        ],
      ),
    );

    if (source != null) {
      await controller.pickImage(context, source);
    }
  }

  void _navigateToLiveFeed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameraScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Food Recognizer App')),
      backgroundColor: const Color(0xFFF0F2F5),
      body: Consumer<PhotoPickerController>(
        builder: (context, controller, child) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ImagePreview(
                      image: controller.image,
                      onTap: () => _showImageSourceDialog(context),
                    ),
                    const SizedBox(height: 24),
                    if (controller.serviceError != null)
                      Text(
                        controller.serviceError!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      )
                    else if (controller.analysisResult != null)
                      ResultDisplay(result: controller.analysisResult!)
                    else if (controller.image != null)
                      ActionButtons(
                        onAnalyze: () => controller.analyzeImage(context),
                        onCrop: () => controller.cropImage(context),
                      )
                    else
                      PickerButtons(
                        onPickImage: (source) =>
                            controller.pickImage(context, source),
                        onLiveFeed: () => _navigateToLiveFeed(context),
                      ),
                  ],
                ),
              ),
              if (controller.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }
}
