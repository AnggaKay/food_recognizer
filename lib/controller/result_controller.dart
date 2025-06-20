import 'package:flutter/material.dart';
import 'package:foodrecognizer/model/food_info.dart';
import 'package:foodrecognizer/model/nutrition_info.dart';
import 'package:foodrecognizer/service/gemini_service.dart';
import 'package:foodrecognizer/service/nutrition_repository.dart';

class ResultController extends ChangeNotifier {
  final GeminiService _geminiService;
  final NutritionRepository _nutritionRepository;

  ResultController({
    required GeminiService geminiService,
    required NutritionRepository nutritionRepository,
  }) : _geminiService = geminiService,
       _nutritionRepository = nutritionRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  FoodInfo? _foodInfo;
  FoodInfo? get foodInfo => _foodInfo;

  Future<void> fetchFoodDetails(String foodLabel, double confidence) async {
    _isLoading = true;
    _foodInfo = FoodInfo(label: foodLabel, confidence: confidence);
    notifyListeners();

    // First, try to get nutrition info from the local repository.
    NutritionInfo? nutritionResult = _nutritionRepository.getLocalNutritionInfo(
      foodLabel,
    );

    // If not found locally, fetch from the Gemini API as a fallback.
    if (nutritionResult == null) {
      final nutritionFuture = _geminiService.getNutritionInfoFromGemini(
        foodLabel,
      );
      nutritionResult = await nutritionFuture;
    }

    // Fetch description separately.
    final descriptionResult = await _geminiService.generateFoodDescription(
      foodLabel,
    );

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
