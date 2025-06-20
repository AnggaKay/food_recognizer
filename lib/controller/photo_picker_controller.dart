import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foodrecognizer/model/analysis_result.dart';
import 'package:foodrecognizer/service/image_service.dart';
import 'package:foodrecognizer/service/ml_service.dart';
import 'package:foodrecognizer/ui/camera_screen.dart';
import 'package:foodrecognizer/ui/result/result_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

// This controller manages the state and business logic for the PhotoPickerScreen.
class PhotoPickerController extends ChangeNotifier {
  // Services used by the controller.
  final ImageService _imageService = ImageService();
  final MLService _mlService;

  // Constructor requires an initialized MLService.
  PhotoPickerController({required MLService mlService})
    : _mlService = mlService;

  // State properties.
  File? _image;
  File? get image => _image;

  AnalysisResult? _analysisResult;
  AnalysisResult? get analysisResult => _analysisResult;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _serviceError;
  String? get serviceError => _serviceError;

  // Internal method to manage the loading state and notify listeners.
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Resets the state when a new image is picked.
  void _resetState() {
    _analysisResult = null;
    _serviceError = null;
  }

  // Handles picking an image from the specified source.
  Future<void> pickImage(ImageSource source) async {
    _setLoading(true);
    _resetState();
    final file = await _imageService.pickImage(source);
    if (file != null) {
      _image = file;
    }
    _setLoading(false);
  }

  // Handles cropping the current image.
  Future<void> cropImage(BuildContext context) async {
    if (_image == null) return;
    _setLoading(true);
    _resetState();
    final file = await _imageService.cropImage(_image!);
    if (file != null) {
      _image = file;
    }
    _setLoading(false);
  }

  // Analyzes the image and navigates to the result screen.
  Future<void> analyzeImage(BuildContext context) async {
    if (_image == null) return;
    _setLoading(true);
    _analysisResult = await _mlService.analyzeImage(_image!);
    _setLoading(false);

    if (_analysisResult != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ResultScreen(image: _image!, analysisResult: _analysisResult!),
        ),
      );
    } else {
      _serviceError =
          'Could not identify the food. Please try a different image.';
      notifyListeners();
    }
  }

  // Checks if the ML service is ready and reports an error if not.
  void initialize(BuildContext context) {
    if (!_mlService.isInitialized) {
      _serviceError =
          'ML Service could not be initialized. Please check your internet connection and restart the app.';
      notifyListeners();
    }
  }

  // Shows a dialog to choose between gallery and camera.
  Future<void> showImageSourceDialog(BuildContext context) async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Image Source"),
        content: const Text("Choose where to get the image from."),
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
      await pickImage(source);
    }
  }

  // Navigates to the live camera feed screen.
  void navigateToLiveFeed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameraScreen()),
    );
  }
}
