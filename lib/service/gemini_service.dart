import 'dart:convert';
import 'package:foodrecognizer/env/env.dart';
import 'package:foodrecognizer/model/nutrition_info.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

// No longer needs google_generative_ai or env
class GeminiService {
  // Use 'late final' for a cleaner, non-nullable model initialization.
  // This avoids null checks in every method call.
  late final GenerativeModel _model;

  // A flag to check if initialization was successful.
  bool _isInitialized = false;

  GeminiService() {
    final apiKey = Env.geminiApiKey;
    if (apiKey.isNotEmpty && !apiKey.contains("YOUR")) {
      // We use the modern 'gemini-1.5-flash' model from your example.
      _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
      _isInitialized = true;
    } else {
      print(
        "GeminiService: API Key not found or is a placeholder. Service will be disabled.",
      );
    }
  }

  Future<String?> generateFoodDescription(String foodName) async {
    if (!_isInitialized) {
      return "Could not generate description: API key not configured.";
    }

    try {
      // The instruction is kept within the prompt for task-specific guidance.
      final prompt =
          "Berikan deskripsi singkat dan menarik tentang makanan '$foodName' dalam 2-3 kalimat. Fokus pada rasa, asal, dan bahan utamanya.";
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return response.text ??
          "Tidak dapat menghasilkan deskripsi untuk makanan ini.";
    } catch (e) {
      print("GeminiService: Exception during description generation - $e");
      return "Terjadi kesalahan saat menghubungi layanan AI.";
    }
  }

  String _cleanJsonString(String rawJson) {
    // The Gemini API may wrap the JSON in markdown code blocks.
    // This removes the wrapping '```json' and '```' if present.
    final startIndex = rawJson.indexOf('{');
    final endIndex = rawJson.lastIndexOf('}');

    if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
      return rawJson.substring(startIndex, endIndex + 1);
    }
    // Return the original string if it doesn't appear to be wrapped.
    return rawJson;
  }

  Future<NutritionInfo?> getNutritionInfoFromGemini(String foodName) async {
    if (!_isInitialized) {
      return null;
    }

    try {
      // The instruction for strict JSON output is best kept here.
      final prompt =
          "Untuk makanan '$foodName', berikan estimasi fakta nutrisi untuk porsi 100g. Jawab HANYA dengan format JSON yang valid, tanpa teks tambahan, kutipan, atau markdown. JSON harus memiliki kunci berikut: \"calories\" (number), \"fat_total_g\" (number), \"carbohydrates_total_g\" (number), \"protein_g\" (number), \"fiber_g\" (number). Contoh: {\"calories\": 539, \"fat_total_g\": 33.6, \"carbohydrates_total_g\": 44.8, \"protein_g\": 13.9, \"fiber_g\": 2.5}";
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text != null) {
        final cleanedJson = _cleanJsonString(response.text!);
        final jsonResponse = json.decode(cleanedJson);
        jsonResponse['name'] = foodName;
        return NutritionInfo.fromJson(jsonResponse);
      }
      return null;
    } catch (e) {
      print("GeminiService: Exception during nutrition fetching - $e");
      return NutritionInfo.notFound(foodName);
    }
  }
}
