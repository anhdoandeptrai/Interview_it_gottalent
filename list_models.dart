import 'dart:io';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// List all available Gemini models using REST API
/// This bypasses the SDK to directly check what models are available
void main() async {
  // Load .env file
  await dotenv.load(fileName: ".env");
  final apiKey = dotenv.env['GEMINI_API_KEY'];

  if (apiKey == null || apiKey.isEmpty) {
    print('❌ GEMINI_API_KEY not found in .env file');
    print('   Create .env file with: GEMINI_API_KEY=your_key_here');
    return;
  }

  print('🔍 Checking available Gemini models via REST API...\n');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey');

  try {
    final client = HttpClient();
    final request = await client.getUrl(url);
    final response = await request.close();

    if (response.statusCode == 200) {
      final contents = await response.transform(utf8.decoder).join();
      final json = jsonDecode(contents);

      print('✅ API Key is valid!\n');

      if (json['models'] != null) {
        final models = json['models'] as List;
        print('📋 Available models: ${models.length}\n');

        for (var model in models) {
          final name = model['name'] ?? '';
          final displayName = model['displayName'] ?? '';
          final description = model['description'] ?? '';
          final supportedMethods =
              model['supportedGenerationMethods'] as List? ?? [];

          // Extract model ID from full name (e.g., "models/gemini-pro" -> "gemini-pro")
          final modelId = name.replaceFirst('models/', '');

          print('📌 Model: $modelId');
          if (displayName.isNotEmpty) print('   Display Name: $displayName');
          if (description.isNotEmpty && description.length < 100) {
            print('   Description: $description');
          }
          print('   Supported: ${supportedMethods.join(", ")}');
          print('');
        }

        // Filter models that support generateContent
        final contentGenerators = models.where((m) {
          final methods = m['supportedGenerationMethods'] as List? ?? [];
          return methods.contains('generateContent');
        }).toList();

        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('✅ Models supporting generateContent:\n');
        for (var model in contentGenerators) {
          final name = (model['name'] ?? '').replaceFirst('models/', '');
          print('   • $name');
        }
        print('');

        if (contentGenerators.isNotEmpty) {
          final firstModel =
              (contentGenerators[0]['name'] ?? '').replaceFirst('models/', '');
          print('💡 Recommended: Use "$firstModel" in your code');
        }
      } else {
        print('⚠️ No models found in response');
      }
    } else {
      print('❌ HTTP ${response.statusCode}: Failed to fetch models');
      final contents = await response.transform(utf8.decoder).join();
      print('Response: $contents');
    }

    client.close();
  } catch (e) {
    print('❌ Error: $e');
    print('\n🔧 Troubleshooting:');
    print('   1. Verify API key at: https://aistudio.google.com/apikey');
    print('   2. Enable Gemini API in Google Cloud Console');
    print('   3. Check if billing is enabled');
    print('   4. Wait 5-10 minutes after creating new key');
  }

  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
}
