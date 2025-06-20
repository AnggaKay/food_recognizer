import 'package:google_generative_ai/google_generative_ai.dart';
import '../env/env.dart';

/// This is a standalone example file to demonstrate a simple Gemini API call.
/// You can run this file directly from your terminal to see the output.
///
/// How to run:
/// 1. Make sure your .env file with GEMINI_API_KEY is in the project root.
/// 2. Run the command: dart run lib/example/gemini_wisata_example.dart
void main() async {
  print("Running Gemini Wisata Example...");

  // Use the API key from your .env file
  final apiKey = Env.geminiApiKey;

  // Initialize the Generative Model
  // Note: 'gemini-1.5-flash' is used here as a modern and efficient model.
  final model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: apiKey,
    // The system instruction helps set the behavior of the model.
    systemInstruction: Content.system('Jelaskan dengan singkat saja'),
  );

  // The user's prompt
  const prompt = 'Berikan 10 wisata terbaik di Indonesia!';
  final content = [Content.text(prompt)];

  print("Sending prompt to Gemini: '$prompt'");
  print("-" * 30);

  // Generate content
  final response = await model.generateContent(content);

  // Print the response text
  print("Gemini Response:");
  print(response.text);
  print("-" * 30);
  print("Example finished.");
}
