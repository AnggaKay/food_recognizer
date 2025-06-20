import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:foodrecognizer/model/nutrition_info.dart';

class NutritionRepository {
  // A map to hold nutrition data, indexed by a normalized food name for
  // case-insensitive lookups. This improves search performance.
  late final Map<String, NutritionInfo> _nutritionData;

  // A flag to ensure the data is loaded only once.
  bool _isInitialized = false;

  // Private constructor to enforce a single instance through the factory.
  NutritionRepository._();

  // A singleton pattern ensures there is only one instance of the repository,
  // preventing redundant data loading.
  static final NutritionRepository _instance = NutritionRepository._();

  // The factory constructor returns the singleton instance.
  factory NutritionRepository() {
    return _instance;
  }

  // Loads and parses the local nutrition JSON data from the assets.
  // This method is called once to initialize the repository.
  Future<void> initialize() async {
    // Avoids re-initialization if already loaded.
    if (_isInitialized) return;

    try {
      // Loads the JSON file as a string from the app's assets.
      final jsonString = await rootBundle.loadString(
        'assets/data/nutrition_data.json',
      );
      // Decodes the JSON string into a list of dynamic objects.
      final List<dynamic> jsonList = json.decode(jsonString);

      // Transforms the JSON list into a map of NutritionInfo objects.
      // The food name is normalized to lowercase to serve as a reliable key.
      _nutritionData = {
        for (var item in jsonList)
          (item['name'] as String).toLowerCase(): NutritionInfo.fromJson(item),
      };

      _isInitialized = true;
      print("NutritionRepository: Successfully initialized with local data.");
    } catch (e) {
      // If initialization fails, the app can still function by relying on the
      // remote API, but a warning is logged for debugging.
      print("NutritionRepository: Failed to load local nutrition data - $e");
      // Initialize with an empty map to prevent null errors.
      _nutritionData = {};
    }
  }

  // Retrieves nutrition information for a given food name from the local cache.
  NutritionInfo? getLocalNutritionInfo(String foodName) {
    if (!_isInitialized) {
      print("Warning: NutritionRepository not initialized.");
      return null;
    }
    // Normalizes the input food name to match the map's key format.
    final normalizedName = foodName.toLowerCase();
    return _nutritionData[normalizedName];
  }
}
