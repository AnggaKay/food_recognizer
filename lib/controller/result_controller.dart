import 'package:flutter/material.dart';
import 'package:foodrecognizer/model/food_info.dart';
import 'package:foodrecognizer/model/nutrition_info.dart';
import 'package:foodrecognizer/service/gemini_service.dart';

class ResultController extends ChangeNotifier {
  final GeminiService _geminiService;

  ResultController({required GeminiService geminiService})
    : _geminiService = geminiService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  FoodInfo? _foodInfo;
  FoodInfo? get foodInfo => _foodInfo;

  Future<void> fetchFoodDetails(String foodLabel, double confidence) async {
    _isLoading = true;
    _foodInfo = FoodInfo(label: foodLabel, confidence: confidence);
    notifyListeners();

    // Call services individually to allow for partial success, making the app
    // more resilient to flaky network connections.
    final nutritionFuture = _geminiService.getNutritionInfoFromGemini(
      foodLabel,
    );
    final descriptionFuture = _geminiService.generateFoodDescription(foodLabel);

    // Await both results
    final nutritionResult = await nutritionFuture;
    final descriptionResult = await descriptionFuture;

    _foodInfo = _foodInfo?.copyWith(
      nutritionInfo: nutritionResult,
      description: descriptionResult,
      // The placeholder reference image is removed to prevent network errors.
      referenceImageUrl: null,
    );

    _isLoading = false;
    notifyListeners();
  }
}
