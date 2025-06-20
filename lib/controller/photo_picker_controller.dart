import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foodrecognizer/model/analysis_result.dart';
import 'package:foodrecognizer/service/image_service.dart';
import 'package:foodrecognizer/service/ml_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class PhotoPickerController extends ChangeNotifier {
  final ImageService _imageService = ImageService();

  File? _image;
  File? get image => _image;

  AnalysisResult? _analysisResult;
  AnalysisResult? get analysisResult => _analysisResult;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _serviceError;
  String? get serviceError => _serviceError;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> pickImage(BuildContext context, ImageSource source) async {
    _setLoading(true);
    _analysisResult = null;
    final file = await _imageService.pickImage(source);
    if (file != null) {
      _image = file;
    }
    _setLoading(false);
  }

  Future<void> cropImage(BuildContext context) async {
    if (_image == null) return;
    _setLoading(true);
    _analysisResult = null;
    final file = await _imageService.cropImage(_image!);
    if (file != null) {
      _image = file;
    }
    _setLoading(false);
  }

  Future<void> analyzeImage(BuildContext context) async {
    if (_image == null) return;
    _setLoading(true);
    final mlService = context.read<MLService>();
    _analysisResult = await mlService.analyzeImage(_image!);
    if (_analysisResult == null && _serviceError == null) {
      _serviceError =
          'Could not identify the food. Please try a different image.';
    }
    _setLoading(false);
  }

  Future<void> initialize(BuildContext context) async {
    final mlService = context.read<MLService>();
    if (!mlService.isInitialized) {
      _serviceError =
          'ML Service could not be initialized. Please check your internet connection and restart the app.';
      notifyListeners();
    }
  }

  // void analyzeImage(BuildContext context) {
  //   if (_image == null) return;
  //   // TODO: Implement image analysis logic
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text('Analyzing image... (not implemented)')),
  //   );
  // }
}
