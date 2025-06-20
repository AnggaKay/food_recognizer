import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foodrecognizer/controller/result_controller.dart';
import 'package:foodrecognizer/model/analysis_result.dart';
import 'package:foodrecognizer/model/food_info.dart';
import 'package:foodrecognizer/model/nutrition_info.dart';
import 'package:foodrecognizer/service/gemini_service.dart';
import 'package:foodrecognizer/ui/theme/app_theme.dart';
import 'package:provider/provider.dart';

class ResultScreen extends StatelessWidget {
  final File image;
  final AnalysisResult analysisResult;

  const ResultScreen({
    super.key,
    required this.image,
    required this.analysisResult,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ResultController(
        geminiService: Provider.of<GeminiService>(context, listen: false),
      )..fetchFoodDetails(analysisResult.label, analysisResult.confidence),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Result Page"),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Consumer<ResultController>(
          builder: (context, controller, child) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildImageCard(context),
                    const SizedBox(height: 16),
                    controller.isLoading &&
                            controller.foodInfo?.nutritionInfo == null
                        ? const Center(child: CircularProgressIndicator())
                        : _buildResultCard(context, controller.foodInfo),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImageCard(BuildContext context) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Image.file(
        image,
        width: double.infinity,
        height: 250,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, FoodInfo? foodInfo) {
    if (foodInfo == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("No information available."),
        ),
      );
    }
    final confidencePercentage = (foodInfo.confidence * 100).toStringAsFixed(2);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food Name and Confidence
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    foodInfo.label,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  "$confidencePercentage%",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // AI Description
            if (foodInfo.description != null) ...[
              Text(
                "Description",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(foodInfo.description!),
              const Divider(height: 24),
            ],

            // Nutrition Facts
            Text(
              "Nutrition Facts",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            _buildNutritionSection(context, foodInfo.nutritionInfo),

            const Divider(height: 24),

            // The reference section has been removed to avoid network errors
            // from the placeholder image and to create a cleaner UI.
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionSection(
    BuildContext context,
    NutritionInfo? nutrition,
  ) {
    if (nutrition == null) {
      return const Text(
        "Nutrition information could not be retrieved from the AI service.",
      );
    }
    if (nutrition.name.contains("Not Found")) {
      return Text(
        "No nutrition information could be found for ${nutrition.name.replaceAll(" (Not Found)", "")}.",
      );
    }

    return Column(
      children: [
        _nutritionRow(
          context,
          "Calories",
          "${nutrition.calories.toStringAsFixed(0)} kcal",
        ),
        _nutritionRow(
          context,
          "Carbs",
          "${nutrition.carbs.toStringAsFixed(1)} g",
        ),
        _nutritionRow(context, "Fat", "${nutrition.fat.toStringAsFixed(1)} g"),
        _nutritionRow(
          context,
          "Protein",
          "${nutrition.protein.toStringAsFixed(1)} g",
        ),
        _nutritionRow(
          context,
          "Fiber",
          "${nutrition.fiber.toStringAsFixed(1)} g",
        ),
      ],
    );
  }

  Widget _nutritionRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
