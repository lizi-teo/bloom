import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

class GeminiService {
  late final GenerativeModel _model;
  
  GeminiService(String apiKey) {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
  }

  /// Generate text response from a prompt
  Future<String?> generateText(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text;
    } catch (e) {
      debugPrint('Error generating text: $e');
      return null;
    }
  }

  /// Stream text response for real-time generation
  Stream<String> streamText(String prompt) async* {
    try {
      final content = [Content.text(prompt)];
      final response = _model.generateContentStream(content);
      
      await for (final chunk in response) {
        if (chunk.text != null) {
          yield chunk.text!;
        }
      }
    } catch (e) {
      debugPrint('Error streaming text: $e');
    }
  }

  /// Generate content with chat history
  Future<String?> chat(List<Content> history, String message) async {
    try {
      final chat = _model.startChat(history: history);
      final response = await chat.sendMessage(Content.text(message));
      return response.text;
    } catch (e) {
      debugPrint('Error in chat: $e');
      return null;
    }
  }
}