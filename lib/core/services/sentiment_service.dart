import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import '../config/sentiment_config.dart';

class SentimentResult {
  final String sentimentScore;
  final String keyFindings;
  final String rawResponse;

  SentimentResult({
    required this.sentimentScore,
    required this.keyFindings,
    required this.rawResponse,
  });

  // Helper method to get numeric value if possible
  int? get numericScore => int.tryParse(sentimentScore);

  // Factory constructor from JSON response
  factory SentimentResult.fromJson(Map<String, dynamic> json) {
    return SentimentResult(
      sentimentScore: json['sentiment_score']?.toString() ?? '0',
      keyFindings: json['key_findings']?.toString() ?? '',
      rawResponse: json.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sentiment_score': sentimentScore,
      'key_findings': keyFindings,
      'raw_response': rawResponse,
    };
  }
}

class SessionSentimentResult {
  final double sentimentScore;
  final List<String> strengths;
  final List<String> improvements;
  final int totalResponses;
  final String rawResponse;

  SessionSentimentResult({
    required this.sentimentScore,
    required this.strengths,
    required this.improvements,
    required this.totalResponses,
    required this.rawResponse,
  });

  String get sentimentLabel {
    if (sentimentScore >= 70) return 'Positive';
    if (sentimentScore >= 40) return 'Neutral';
    return 'Negative';
  }

  // Backward compatibility - combine both lists for old code
  List<String> get keyFindings => [...strengths, ...improvements];

  Map<String, dynamic> toJson() {
    return {
      'sentiment_score': sentimentScore,
      'strengths': strengths,
      'improvements': improvements,
      'total_responses': totalResponses,
      'raw_response': rawResponse,
    };
  }
}

// Enhanced models for multi-component sentiment analysis
class EnhancedSentimentResult {
  final int resultsAnswersId;
  final String componentType; // 'slider' or 'text'
  final double sentimentScore; // -1.0 to 1.0
  final String sentimentLabel; // 'positive', 'negative', 'neutral', 'mixed'
  final double confidenceScore; // 0.0 to 1.0
  final Map<String, dynamic> componentAnalysis;
  final String interpretationMethod;
  final String? keyFindings;
  final List<String>? themes;
  final String? analysisModel;
  final int? processingTimeMs;
  final String rawResponse;

  EnhancedSentimentResult({
    required this.resultsAnswersId,
    required this.componentType,
    required this.sentimentScore,
    required this.sentimentLabel,
    required this.confidenceScore,
    required this.componentAnalysis,
    required this.interpretationMethod,
    this.keyFindings,
    this.themes,
    this.analysisModel,
    this.processingTimeMs,
    required this.rawResponse,
  });

  Map<String, dynamic> toJson() {
    return {
      'results_answers_id': resultsAnswersId,
      'component_type': componentType,
      'sentiment_score': sentimentScore,
      'sentiment_label': sentimentLabel,
      'confidence_score': confidenceScore,
      'component_analysis': componentAnalysis,
      'interpretation_method': interpretationMethod,
      'key_findings': keyFindings,
      'themes': themes != null ? jsonEncode(themes) : null,
      'analysis_model': analysisModel,
      'processing_time_ms': processingTimeMs,
      'gemini_raw_response': rawResponse,
    };
  }
}

// Session-level sentiment aggregation result
class SessionSentimentSummary {
  final int sessionId;
  final double overallSentimentScore; // -1.0 to 1.0
  final String overallSentimentLabel;
  final double? textSentimentScore; // Average of text components
  final double? sliderSentimentScore; // Average of slider components
  final int textResponseCount;
  final int sliderResponseCount;
  final int totalResponseCount;
  final Map<String, dynamic> componentBreakdown;
  final List<String> keyThemes;
  final List<String> sessionInsights;
  final double confidenceScore;
  final String aggregationMethod;
  final String? analysisModel;
  final int? processingTimeMs;
  final DateTime createdAt;

  SessionSentimentSummary({
    required this.sessionId,
    required this.overallSentimentScore,
    required this.overallSentimentLabel,
    this.textSentimentScore,
    this.sliderSentimentScore,
    required this.textResponseCount,
    required this.sliderResponseCount,
    required this.totalResponseCount,
    required this.componentBreakdown,
    required this.keyThemes,
    required this.sessionInsights,
    required this.confidenceScore,
    required this.aggregationMethod,
    this.analysisModel,
    this.processingTimeMs,
    required this.createdAt,
  });

  String get sentimentLabel {
    if (overallSentimentScore > 0.3) return 'Positive';
    if (overallSentimentScore < -0.3) return 'Negative';
    if (overallSentimentScore.abs() < 0.1) return 'Neutral';
    return 'Mixed';
  }

  // Convert to database format
  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'overall_sentiment_score': overallSentimentScore,
      'overall_sentiment_label': overallSentimentLabel,
      'text_sentiment_score': textSentimentScore,
      'slider_sentiment_score': sliderSentimentScore,
      'text_response_count': textResponseCount,
      'slider_response_count': sliderResponseCount,
      'total_analyzed_answers': totalResponseCount,  // Fixed: match DB column name
      'component_breakdown': componentBreakdown,
      'key_themes': jsonEncode(keyThemes),
      'session_insights': sessionInsights.join(', '), // Fixed: store as text, not JSON
      'confidence_score': confidenceScore,
      'analysis_model': analysisModel,
      'analyzed_at': createdAt.toIso8601String(),  // Fixed: match DB column name
    };
  }

  // Create from database result
  factory SessionSentimentSummary.fromJson(Map<String, dynamic> json) {
    return SessionSentimentSummary(
      sessionId: json['session_id'] as int,
      overallSentimentScore: (json['overall_sentiment_score'] as num).toDouble(),
      overallSentimentLabel: json['overall_sentiment_label'] as String,
      textSentimentScore: json['text_sentiment_score'] != null 
          ? (json['text_sentiment_score'] as num).toDouble() 
          : null,
      sliderSentimentScore: json['slider_sentiment_score'] != null 
          ? (json['slider_sentiment_score'] as num).toDouble() 
          : null,
      textResponseCount: json['text_response_count'] as int,
      sliderResponseCount: json['slider_response_count'] as int,
      totalResponseCount: json['total_analyzed_answers'] as int,  // Fixed: match DB column name
      componentBreakdown: json['component_breakdown'] as Map<String, dynamic>,
      keyThemes: List<String>.from(jsonDecode(json['key_themes'] as String)),
      sessionInsights: (json['session_insights'] as String).split(', '), // Fixed: parse text, not JSON
      confidenceScore: (json['confidence_score'] as num).toDouble(),
      aggregationMethod: 'database_stored', // Fixed: provide default since DB doesn't store this
      analysisModel: json['analysis_model'] as String?,
      processingTimeMs: null, // Fixed: DB doesn't store this
      createdAt: DateTime.parse(json['analyzed_at'] as String), // Fixed: match DB column name
    );
  }
}

class SliderAnalysisResult {
  final int rawValue;
  final double percentage;
  final String minLabel;
  final String maxLabel;
  final String minSentiment;
  final String maxSentiment;
  final String scaleDirection; // 'positive_high', 'negative_high', 'context_dependent'
  final double confidenceScore;
  final String interpretation;

  SliderAnalysisResult({
    required this.rawValue,
    required this.percentage,
    required this.minLabel,
    required this.maxLabel,
    required this.minSentiment,
    required this.maxSentiment,
    required this.scaleDirection,
    required this.confidenceScore,
    required this.interpretation,
  });

  Map<String, dynamic> toJson() {
    return {
      'raw_value': rawValue,
      'percentage': percentage,
      'scale_analysis': {
        'min_label': minLabel,
        'max_label': maxLabel,
        'min_sentiment': minSentiment,
        'max_sentiment': maxSentiment,
        'direction': scaleDirection,
        'confidence': confidenceScore,
      },
      'interpretation': interpretation,
    };
  }
}

class SentimentService {
  static String get _apiKey => const String.fromEnvironment('GEMINI_API_KEY');
  
  static GenerativeModel? _model;

  static GenerativeModel get model {
    if (_model == null) {
      debugPrint('DEBUG: Initializing Gemini model...');
      debugPrint('DEBUG: API Key length: ${_apiKey.length}');
      debugPrint('DEBUG: API Key starts with: ${_apiKey.isNotEmpty ? _apiKey.substring(0, _apiKey.length > 10 ? 10 : _apiKey.length) : 'EMPTY'}...');
      
      if (_apiKey.isEmpty) {
        throw Exception('GEMINI_API_KEY not configured. Make sure to run: flutter run -d chrome --dart-define-from-file=.env');
      }
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.1, // Low temperature for consistent analysis
          topK: 1,
          topP: 1,
          maxOutputTokens: 500,
        ),
      );
      debugPrint('DEBUG: Model initialized successfully');
    }
    return _model!;
  }

  static SupabaseClient get _supabase => Supabase.instance.client;

  /// Enhanced sentiment analysis that handles both slider and text components
  /// Uses rule-based analysis for sliders and intelligent text analysis
  /// Analyzes the answer and stores results in the enhanced feedback_sentiment table
  static Future<EnhancedSentimentResult> analyzeEnhancedSentiment({
    required int resultsAnswersId,
    required String answer,
    required String componentType,
    String? questionTitle,
    String? minLabel,
    String? maxLabel,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      if (SentimentConfig.enableDetailedLogging) {
        debugPrint('DEBUG: Starting enhanced sentiment analysis...');
        debugPrint('DEBUG: Component type: $componentType, Answer: $answer');
      }

      late EnhancedSentimentResult result;

      // Use rule-based analysis for sliders
      if (componentType == 'slider' && SentimentConfig.shouldUseRuleBased(componentType)) {
        result = await _analyzeSliderSentimentRuleBased(
          resultsAnswersId: resultsAnswersId,
          sliderValue: int.tryParse(answer) ?? 0,
          questionTitle: questionTitle ?? '',
          minLabel: minLabel ?? '',
          maxLabel: maxLabel ?? '',
        );
      }
      // Use intelligent text analysis
      else if (componentType == 'text') {
        result = await _analyzeTextSentimentIntelligent(
          resultsAnswersId: resultsAnswersId,
          text: answer,
          questionTitle: questionTitle,
        );
      }
      // Fallback for unsupported types or disabled features
      else if (componentType == 'slider') {
        result = await _analyzeSliderSentiment(
          resultsAnswersId: resultsAnswersId,
          sliderValue: int.tryParse(answer) ?? 0,
          questionTitle: questionTitle ?? '',
          minLabel: minLabel ?? '',
          maxLabel: maxLabel ?? '',
        );
      } else {
        throw Exception('Unsupported component type: $componentType');
      }

      // Store result in database
      await _storeSentimentResult(result);
      
      stopwatch.stop();
      if (SentimentConfig.enableDetailedLogging) {
        debugPrint('DEBUG: Enhanced sentiment analysis completed in ${stopwatch.elapsedMilliseconds}ms');
      }
      
      return result;

    } catch (e) {
      stopwatch.stop();
      debugPrint('ERROR in enhanced sentiment analysis: $e');
      
      // Return error result
      return EnhancedSentimentResult(
        resultsAnswersId: resultsAnswersId,
        componentType: componentType,
        sentimentScore: 0.0,
        sentimentLabel: 'neutral',
        confidenceScore: 0.0,
        componentAnalysis: {'error': 'analysis_failed'},
        interpretationMethod: 'error_handling',
        keyFindings: 'Analysis failed: ${e.toString()}',
        analysisModel: 'rule_based_fallback',
        processingTimeMs: stopwatch.elapsedMilliseconds,
        rawResponse: 'Error: ${e.toString()}',
      );
    }
  }

  /// Analyzes sentiment of multiple user feedback texts for a session
  /// Uses individual-then-aggregate approach for accurate sentiment measurement
  /// Returns SessionSentimentResult with averaged sentiment score and key findings
  static Future<SessionSentimentResult> analyzeSessionSentiment(
    List<String> feedbackTexts,
    int totalRespondents,
  ) async {
    try {
      debugPrint('DEBUG: Starting session sentiment analysis...');
      debugPrint('DEBUG: Feedback texts count: ${feedbackTexts.length}');
      debugPrint('DEBUG: Total respondents: $totalRespondents');

      if (feedbackTexts.isEmpty) {
        return SessionSentimentResult(
          sentimentScore: 0.0,
          strengths: [],
          improvements: [],
          totalResponses: 0,
          rawResponse: 'No feedback provided',
        );
      }

      // Step 1: Analyze individual responses and calculate average score
      final individualScores = <double>[];
      final validResponses = <String>[];
      final emptyResponseCount = feedbackTexts.where((text) => text.trim().isEmpty).length;
      
      debugPrint('DEBUG: Total responses: ${feedbackTexts.length}, Empty responses: $emptyResponseCount');
      
      for (final text in feedbackTexts) {
        final trimmedText = text.trim();
        if (trimmedText.isNotEmpty) {
          final individualResult = await _analyzeSingleFeedback(trimmedText);
          final score = double.tryParse(individualResult.sentimentScore) ?? 50.0;
          individualScores.add(score);
          validResponses.add(trimmedText);
          debugPrint('DEBUG: Individual score for "$trimmedText": $score');
        } else {
          debugPrint('DEBUG: Skipping empty response');
        }
      }

      final averageScore = individualScores.isNotEmpty 
          ? individualScores.reduce((a, b) => a + b) / individualScores.length
          : 0.0;

      debugPrint('DEBUG: Average sentiment score: $averageScore');

      // Step 2: Analyze combined feedback for key insights only
      // Only use valid responses for insight analysis
      final combinedFeedback = validResponses.isNotEmpty ? validResponses.join(' | ') : '';
      final insightsResult = validResponses.isNotEmpty 
          ? await _analyzeSessionCombinedFeedback(combinedFeedback, totalRespondents)
          : (
              strengths: <String>['insufficient_responses'],
              improvements: emptyResponseCount > totalRespondents * 0.5 
                ? <String>['encourage_more_detailed_feedback', 'improve_question_clarity']
                : <String>[],
              rawResponse: 'Insufficient valid responses for analysis',
            );

      return SessionSentimentResult(
        sentimentScore: averageScore,
        strengths: insightsResult.strengths,
        improvements: insightsResult.improvements,
        totalResponses: validResponses.length, // Count only valid responses
        rawResponse: insightsResult.rawResponse,
      );

    } catch (e) {
      debugPrint('ERROR analyzing session sentiment: $e');
      return SessionSentimentResult(
        sentimentScore: 0.0,
        strengths: ['analysis_failed'],
        improvements: [],
        totalResponses: feedbackTexts.length,
        rawResponse: 'Error: ${e.toString()}',
      );
    }
  }

  /// Analyzes sentiment of user feedback text
  /// Returns SentimentResult with score (0-100) and key findings
  static Future<SentimentResult> analyzeSentiment(String feedbackText) async {
    try {
      debugPrint('DEBUG: Starting sentiment analysis...');
      debugPrint('DEBUG: Feedback text length: ${feedbackText.length}');
      
      if (feedbackText.trim().isEmpty) {
        return SentimentResult(
          sentimentScore: '50',
          keyFindings: 'no_content',
          rawResponse: 'Empty feedback text',
        );
      }

      debugPrint('DEBUG: Building prompt...');
      final prompt = _buildSentimentPrompt(feedbackText);
      final content = [Content.text(prompt)];
      
      debugPrint('DEBUG: Calling Gemini API...');
      final response = await model.generateContent(content);
      debugPrint('DEBUG: API call completed');
      debugPrint('DEBUG: Response text: ${response.text}');
      
      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Empty response from Gemini API');
      }

      debugPrint('DEBUG: Parsing response...');
      final result = _parseSentimentResponse(response.text!, feedbackText);
      debugPrint('DEBUG: Analysis completed successfully');
      return result;
      
    } catch (e) {
      debugPrint('ERROR analyzing sentiment: $e');
      debugPrint('ERROR stack trace: ${e.runtimeType}');
      return SentimentResult(
        sentimentScore: 'analysis_failed',
        keyFindings: 'error_occurred',
        rawResponse: 'Error: ${e.toString()}',
      );
    }
  }

  static String _buildSentimentPrompt(String feedbackText, {String? questionContext}) {
    return '''
Analyze this participant feedback about a facilitator's performance. Focus only on what the participant explicitly communicated.

Feedback text: "$feedbackText"
Question context: "${questionContext ?? 'General feedback'}"

Based on the actual words and tone used by the participant:
1. Determine the overall sentiment (positive, negative, or neutral)
2. Identify the main topic or concern mentioned by the participant
3. Focus on direct, factual observations from the text

Guidelines:
- Only interpret what is directly stated or clearly implied
- Avoid speculation about hidden meanings or unconscious behaviors  
- Base findings on the participant's actual words and expressions
- Keep interpretations conservative and close to the original text

Respond with ONLY a valid JSON object:

{
  "sentiment_score": [integer from 0-100, where 0=very negative, 50=neutral, 100=very positive],
  "key_findings": "[2-4 words describing the main topic mentioned by the participant]"
}

Example format:
{"sentiment_score": 65, "key_findings": "appreciated clear explanations"}
{"sentiment_score": 40, "key_findings": "wanted more time"}
{"sentiment_score": 80, "key_findings": "felt heard and supported"}
''';
  }


  static SentimentResult _parseSentimentResponse(String responseText, String originalText) {
    try {
      // Clean the response - remove any markdown formatting or extra text
      String cleanedResponse = responseText.trim();
      
      // Remove markdown code block markers if present
      if (cleanedResponse.startsWith('```json')) {
        cleanedResponse = cleanedResponse.substring(7);
      }
      if (cleanedResponse.startsWith('```')) {
        cleanedResponse = cleanedResponse.substring(3);
      }
      if (cleanedResponse.endsWith('```')) {
        cleanedResponse = cleanedResponse.substring(0, cleanedResponse.length - 3);
      }
      
      cleanedResponse = cleanedResponse.trim();

      // Find JSON object in the response
      final jsonStart = cleanedResponse.indexOf('{');
      final jsonEnd = cleanedResponse.lastIndexOf('}');
      
      if (jsonStart == -1 || jsonEnd == -1) {
        throw Exception('No JSON object found in response');
      }
      
      final jsonString = cleanedResponse.substring(jsonStart, jsonEnd + 1);
      
      // Parse JSON - using a simple manual approach to avoid import issues
      final scoreMatch = RegExp(r'"sentiment_score"\s*:\s*(\d+)').firstMatch(jsonString);
      final findingsMatch = RegExp(r'"key_findings"\s*:\s*"([^"]*)"').firstMatch(jsonString);
      
      if (scoreMatch == null || findingsMatch == null) {
        throw Exception('Invalid JSON format');
      }
      
      final score = scoreMatch.group(1)!;
      final findings = findingsMatch.group(1)!;
      
      return SentimentResult(
        sentimentScore: score,
        keyFindings: findings,
        rawResponse: responseText,
      );
      
    } catch (e) {
      debugPrint('Error parsing sentiment response: $e');
      debugPrint('Raw response: $responseText');
      
      // Fallback: try to extract basic sentiment from text
      final fallbackScore = _extractFallbackSentiment(originalText);
      
      return SentimentResult(
        sentimentScore: fallbackScore.toString(),
        keyFindings: 'parsing_error',
        rawResponse: responseText,
      );
    }
  }

  static int _extractFallbackSentiment(String text) {
    final lowerText = text.toLowerCase();
    
    // Simple keyword-based sentiment fallback
    final positiveWords = ['good', 'great', 'excellent', 'helpful', 'clear', 'effective'];
    final negativeWords = ['bad', 'poor', 'confusing', 'unclear', 'boring', 'ineffective'];
    
    int positiveCount = 0;
    int negativeCount = 0;
    
    for (final word in positiveWords) {
      if (lowerText.contains(word)) positiveCount++;
    }
    
    for (final word in negativeWords) {
      if (lowerText.contains(word)) negativeCount++;
    }
    
    if (positiveCount > negativeCount) return 70;
    if (negativeCount > positiveCount) return 30;
    return 50; // neutral
  }

  /// Analyzes individual feedback for session analysis
  static Future<SentimentResult> _analyzeSingleFeedback(String feedbackText, {String? questionContext}) async {
    try {
      if (feedbackText.trim().isEmpty) {
        return SentimentResult(
          sentimentScore: '50',
          keyFindings: 'no_content',
          rawResponse: 'Empty feedback text',
        );
      }

      final prompt = _buildSentimentPrompt(feedbackText, questionContext: questionContext);
      final content = [Content.text(prompt)];
      
      final response = await model.generateContent(content);
      
      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Empty response from Gemini API');
      }

      return _parseSentimentResponse(response.text!, feedbackText);
      
    } catch (e) {
      debugPrint('ERROR analyzing individual feedback: $e');
      return SentimentResult(
        sentimentScore: 'analysis_failed',
        keyFindings: 'error_occurred',
        rawResponse: 'Error: ${e.toString()}',
      );
    }
  }

  /// Analyzes combined session feedback for categorized insights
  static Future<({List<String> strengths, List<String> improvements, String rawResponse})> _analyzeSessionCombinedFeedback(
    String combinedFeedback,
    int totalRespondents,
  ) async {
    try {
      final prompt = _buildSessionInsightsPrompt(combinedFeedback, totalRespondents);
      final content = [Content.text(prompt)];
      
      final response = await model.generateContent(content);
      
      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Empty response from Gemini API');
      }

      return _parseSessionInsightsResponse(response.text!);
      
    } catch (e) {
      debugPrint('ERROR analyzing session combined feedback: $e');
      return (
        strengths: <String>['analysis_failed'],
        improvements: <String>[],
        rawResponse: 'Error: ${e.toString()}',
      );
    }
  }

  static String _buildSessionInsightsPrompt(String combinedFeedback, int totalRespondents) {
    return '''
Analyze this combined feedback from $totalRespondents users about their facilitator's performance during a session. Extract key insights and classify them as strengths or areas for improvement.

Combined feedback: "$combinedFeedback"

Please respond with ONLY a valid JSON object containing exactly these fields:

{
  "strengths": [array of strings - positive insights about what the facilitator did well],
  "improvements": [array of strings - constructive areas where the facilitator could improve]
}

Guidelines:
- Focus on patterns and themes across all responses
- Classify insights clearly as either strengths or improvement areas
- Keep findings concise and specific (3-6 words each)
- Extract actionable insights for facilitator development
- Prioritize the most important themes in each category
- Respond ONLY with the JSON object, no additional text

Example format:
{"strengths": ["clear communication appreciated", "good energy and engagement", "participants felt heard"], "improvements": ["could improve time management", "more interactive activities needed"]}
''';
  }

  static ({List<String> strengths, List<String> improvements, String rawResponse}) _parseSessionInsightsResponse(String responseText) {
    try {
      // Clean the response - remove any markdown formatting or extra text
      String cleanedResponse = responseText.trim();
      
      // Remove markdown code block markers if present
      if (cleanedResponse.startsWith('```json')) {
        cleanedResponse = cleanedResponse.substring(7);
      }
      if (cleanedResponse.startsWith('```')) {
        cleanedResponse = cleanedResponse.substring(3);
      }
      if (cleanedResponse.endsWith('```')) {
        cleanedResponse = cleanedResponse.substring(0, cleanedResponse.length - 3);
      }
      
      cleanedResponse = cleanedResponse.trim();

      // Find JSON object in the response
      final jsonStart = cleanedResponse.indexOf('{');
      final jsonEnd = cleanedResponse.lastIndexOf('}');
      
      if (jsonStart == -1 || jsonEnd == -1) {
        throw Exception('No JSON object found in response');
      }
      
      final jsonString = cleanedResponse.substring(jsonStart, jsonEnd + 1);
      
      // Parse strengths array
      final strengthsMatch = RegExp(r'"strengths"\s*:\s*\[(.*?)\]', dotAll: true).firstMatch(jsonString);
      final strengths = <String>[];
      
      if (strengthsMatch != null) {
        final strengthsString = strengthsMatch.group(1)!;
        final strengthMatches = RegExp(r'"([^"]*)"').allMatches(strengthsString);
        for (final match in strengthMatches) {
          final strength = match.group(1)!;
          if (strength.isNotEmpty) {
            strengths.add(strength);
          }
        }
      }
      
      // Parse improvements array
      final improvementsMatch = RegExp(r'"improvements"\s*:\s*\[(.*?)\]', dotAll: true).firstMatch(jsonString);
      final improvements = <String>[];
      
      if (improvementsMatch != null) {
        final improvementsString = improvementsMatch.group(1)!;
        final improvementMatches = RegExp(r'"([^"]*)"').allMatches(improvementsString);
        for (final match in improvementMatches) {
          final improvement = match.group(1)!;
          if (improvement.isNotEmpty) {
            improvements.add(improvement);
          }
        }
      }
      
      return (
        strengths: strengths,
        improvements: improvements,
        rawResponse: responseText,
      );
      
    } catch (e) {
      debugPrint('Error parsing session insights response: $e');
      debugPrint('Raw response: $responseText');
      
      return (
        strengths: <String>['parsing_error'],
        improvements: <String>[],
        rawResponse: responseText,
      );
    }
  }

  /// NEW: Rule-based slider sentiment analysis (instant, no AI required)
  static Future<EnhancedSentimentResult> _analyzeSliderSentimentRuleBased({
    required int resultsAnswersId,
    required int sliderValue,
    required String questionTitle,
    required String minLabel,
    required String maxLabel,
  }) async {
    try {
      if (SentimentConfig.enableDetailedLogging) {
        debugPrint('DEBUG: Rule-based slider analysis - Value: $sliderValue, Min: "$minLabel", Max: "$maxLabel"');
      }

      // Step 1: Get sentiment score from slider value
      final sentimentScore = SentimentConfig.getSliderSentimentScore(sliderValue);
      
      // Step 2: Determine scale direction
      final scaleDirection = SentimentConfig.getScaleDirection(minLabel, maxLabel);
      
      // Step 3: Adjust score based on scale direction
      final adjustedScore = scaleDirection == 'negative_high' ? -sentimentScore : sentimentScore;
      
      // Step 4: Generate sentiment label
      final sentimentLabel = SentimentConfig.getSentimentLabel(adjustedScore);
      
      // Step 5: Generate key findings based on value ranges
      final keyFindings = _generateSliderKeyFindings(sliderValue, minLabel, maxLabel, null);
      
      // Step 6: Build component analysis
      final componentAnalysis = {
        'raw_value': sliderValue,
        'percentage': sliderValue / 100.0,
        'scale_analysis': {
          'min_label': minLabel,
          'max_label': maxLabel,
          'direction': scaleDirection,
          'confidence': 1.0, // Rule-based = high confidence
        },
        'interpretation': 'Rule-based analysis: $keyFindings',
        'contextual_factors': {
          'question_title': questionTitle,
          'scale_type': 'satisfaction',
        },
      };

      return EnhancedSentimentResult(
        resultsAnswersId: resultsAnswersId,
        componentType: 'slider',
        sentimentScore: adjustedScore,
        sentimentLabel: sentimentLabel,
        confidenceScore: 1.0, // Rule-based analysis has high confidence
        componentAnalysis: componentAnalysis,
        interpretationMethod: 'rule_based',
        keyFindings: keyFindings,
        analysisModel: 'rule_based_v1',
        processingTimeMs: 0, // Instant processing
        rawResponse: 'Rule-based slider analysis completed',
      );

    } catch (e) {
      debugPrint('ERROR in rule-based slider analysis: $e');
      throw Exception('Rule-based slider analysis failed: $e');
    }
  }

  /// NEW: Intelligent text analysis that chooses AI vs keyword-based approach
  static Future<EnhancedSentimentResult> _analyzeTextSentimentIntelligent({
    required int resultsAnswersId,
    required String text,
    String? questionTitle,
  }) async {
    try {
      final trimmedText = text.trim();
      
      // Handle empty responses
      if (trimmedText.isEmpty) {
        if (SentimentConfig.enableDetailedLogging) {
          debugPrint('DEBUG: Empty text response, returning neutral');
        }
        return _createEmptyTextResult(resultsAnswersId);
      }

      final words = trimmedText.split(RegExp(r'\s+'));
      final wordCount = words.length;
      
      if (SentimentConfig.enableDetailedLogging) {
        debugPrint('DEBUG: Text analysis - Word count: $wordCount, Text: "$trimmedText"');
      }

      // Use AI for longer responses
      if (SentimentConfig.shouldUseAI(trimmedText, 'text')) {
        if (SentimentConfig.enableDetailedLogging) {
          debugPrint('DEBUG: Using AI analysis for substantial text ($wordCount words)');
        }
        return await _analyzeTextSentiment(
          resultsAnswersId: resultsAnswersId,
          text: trimmedText,
          questionTitle: questionTitle,
        );
      }
      
      // Use keyword-based analysis for short responses
      if (SentimentConfig.enableDetailedLogging) {
        debugPrint('DEBUG: Using keyword-based analysis for short text ($wordCount words)');
      }
      return await _analyzeTextSentimentKeywordBased(
        resultsAnswersId: resultsAnswersId,
        text: trimmedText,
        questionTitle: questionTitle,
      );

    } catch (e) {
      debugPrint('ERROR in intelligent text analysis: $e');
      throw Exception('Intelligent text analysis failed: $e');
    }
  }

  /// NEW: Keyword-based sentiment analysis for short text responses
  static Future<EnhancedSentimentResult> _analyzeTextSentimentKeywordBased({
    required int resultsAnswersId,
    required String text,
    String? questionTitle,
  }) async {
    try {
      final lowerText = text.toLowerCase();
      final words = lowerText.split(RegExp(r'\s+'));
      
      // Count sentiment keywords
      int positiveCount = 0;
      int negativeCount = 0;
      int neutralCount = 0;
      
      for (final word in words) {
        if (SentimentConfig.positiveKeywords.contains(word)) {
          positiveCount++;
        } else if (SentimentConfig.negativeKeywords.contains(word)) {
          negativeCount++;
        } else if (SentimentConfig.neutralKeywords.contains(word)) {
          neutralCount++;
        }
      }
      
      // Calculate sentiment score
      double sentimentScore = 0.0;
      String sentimentLabel = 'neutral';
      String keyFindings = '';
      
      if (positiveCount > negativeCount && positiveCount > 0) {
        sentimentScore = 0.6; // Positive
        sentimentLabel = 'positive';
        keyFindings = 'positive_keywords_detected';
      } else if (negativeCount > positiveCount && negativeCount > 0) {
        sentimentScore = -0.6; // Negative
        sentimentLabel = 'negative';
        keyFindings = 'negative_keywords_detected';
      } else if (neutralCount > 0) {
        sentimentScore = 0.0; // Neutral
        sentimentLabel = 'neutral';
        keyFindings = 'neutral_keywords_detected';
      } else {
        // No sentiment keywords found - use response characteristics
        if (words.length == 1) {
          keyFindings = 'single_word_response';
        } else if (words.length <= 3) {
          keyFindings = 'brief_response';
        } else {
          keyFindings = 'no_sentiment_indicators';
        }
      }
      
      final componentAnalysis = {
        'word_count': words.length,
        'character_count': text.length,
        'tone': _detectTone(text),
        'sentiment_keywords': {
          'positive_count': positiveCount,
          'negative_count': negativeCount,
          'neutral_count': neutralCount,
        },
        'analysis_method': 'keyword_based',
        'response_status': 'keyword_analyzed',
      };

      return EnhancedSentimentResult(
        resultsAnswersId: resultsAnswersId,
        componentType: 'text',
        sentimentScore: sentimentScore,
        sentimentLabel: sentimentLabel,
        confidenceScore: (positiveCount + negativeCount + neutralCount) > 0 ? 0.8 : 0.4,
        componentAnalysis: componentAnalysis,
        interpretationMethod: 'keyword_based',
        keyFindings: keyFindings,
        themes: words.take(3).toList(),
        analysisModel: 'keyword_based_v1',
        processingTimeMs: 0, // Instant processing
        rawResponse: 'Keyword-based analysis completed',
      );

    } catch (e) {
      debugPrint('ERROR in keyword-based text analysis: $e');
      throw Exception('Keyword-based text analysis failed: $e');
    }
  }

  /// Helper method to create empty text result
  static EnhancedSentimentResult _createEmptyTextResult(int resultsAnswersId) {
    final componentAnalysis = {
      'word_count': 0,
      'character_count': 0,
      'tone': 'no_response',
      'key_phrases': <String>[],
      'response_status': 'unanswered',
    };

    return EnhancedSentimentResult(
      resultsAnswersId: resultsAnswersId,
      componentType: 'text',
      sentimentScore: 0.0,
      sentimentLabel: 'neutral',
      confidenceScore: 1.0, // High confidence for empty response
      componentAnalysis: componentAnalysis,
      interpretationMethod: 'empty_response_handling',
      keyFindings: 'no_response_provided',
      themes: <String>[],
      analysisModel: 'rule_based_v1',
      rawResponse: 'Empty response - no analysis performed',
    );
  }

  /// ORIGINAL: Analyzes slider sentiment using semantic interpretation of labels (AI-based)
  static Future<EnhancedSentimentResult> _analyzeSliderSentiment({
    required int resultsAnswersId,
    required int sliderValue,
    required String questionTitle,
    required String minLabel,
    required String maxLabel,
  }) async {
    try {
      debugPrint('DEBUG: Analyzing slider sentiment - Value: $sliderValue, Min: "$minLabel", Max: "$maxLabel"');

      // Step 1: Analyze the scale semantically
      final scaleAnalysis = await _analyzeSliderScale(minLabel, maxLabel, questionTitle);
      
      // Step 2: Convert slider value to percentage
      final percentage = sliderValue / 100.0;
      
      // Step 3: Calculate sentiment score based on scale direction
      double sentimentScore = _calculateSliderSentimentScore(percentage, scaleAnalysis.scaleDirection);
      
      // Step 4: Determine sentiment label
      String sentimentLabel = _getSentimentLabel(sentimentScore);
      
      // Step 5: Build component analysis
      final componentAnalysis = {
        'raw_value': sliderValue,
        'percentage': percentage,
        'scale_analysis': {
          'min_label': minLabel,
          'max_label': maxLabel,
          'min_sentiment': scaleAnalysis.minSentiment,
          'max_sentiment': scaleAnalysis.maxSentiment,
          'direction': scaleAnalysis.scaleDirection,
          'confidence': scaleAnalysis.confidenceScore,
        },
        'interpretation': scaleAnalysis.interpretation,
        'contextual_factors': {
          'question_title': questionTitle,
          'scale_type': 'satisfaction', // Could be enhanced to detect different scale types
        },
      };

      return EnhancedSentimentResult(
        resultsAnswersId: resultsAnswersId,
        componentType: 'slider',
        sentimentScore: sentimentScore,
        sentimentLabel: sentimentLabel,
        confidenceScore: scaleAnalysis.confidenceScore,
        componentAnalysis: componentAnalysis,
        interpretationMethod: 'semantic_scale',
        keyFindings: _generateSliderKeyFindings(sliderValue, minLabel, maxLabel, scaleAnalysis),
        analysisModel: 'gemini-1.5-flash',
        rawResponse: 'Slider analysis completed',
      );

    } catch (e) {
      debugPrint('ERROR analyzing slider sentiment: $e');
      throw Exception('Slider analysis failed: $e');
    }
  }

  /// Analyzes text sentiment using existing logic but returns enhanced format
  static Future<EnhancedSentimentResult> _analyzeTextSentiment({
    required int resultsAnswersId,
    required String text,
    String? questionTitle,
  }) async {
    try {
      // Handle empty or whitespace-only text
      final trimmedText = text.trim();
      if (trimmedText.isEmpty) {
        debugPrint('DEBUG: Empty text answer detected, returning neutral result');
        final componentAnalysis = {
          'word_count': 0,
          'character_count': 0,
          'tone': 'no_response',
          'key_phrases': <String>[],
          'original_score': 50.0,
          'response_status': 'unanswered',
        };

        return EnhancedSentimentResult(
          resultsAnswersId: resultsAnswersId,
          componentType: 'text',
          sentimentScore: 0.0, // Neutral on -1 to 1 scale
          sentimentLabel: 'neutral',
          confidenceScore: 1.0, // High confidence for empty response
          componentAnalysis: componentAnalysis,
          interpretationMethod: 'empty_response_handling',
          keyFindings: 'no_response_provided',
          themes: <String>[],
          analysisModel: 'rule_based',
          rawResponse: 'Empty response - no analysis performed',
        );
      }

      // Handle very short responses (1-2 words)
      final words = trimmedText.split(RegExp(r'\s+'));
      if (words.length <= 2 && trimmedText.length <= 10) {
        debugPrint('DEBUG: Very short text response detected: "$trimmedText"');
        
        final componentAnalysis = {
          'word_count': words.length,
          'character_count': trimmedText.length,
          'tone': _detectTone(trimmedText),
          'key_phrases': words,
          'original_score': _extractFallbackSentiment(trimmedText).toDouble(),
          'response_status': 'minimal_response',
        };

        final fallbackScore = _extractFallbackSentiment(trimmedText);
        final sentimentScore = (fallbackScore - 50.0) / 50.0;

        return EnhancedSentimentResult(
          resultsAnswersId: resultsAnswersId,
          componentType: 'text',
          sentimentScore: sentimentScore,
          sentimentLabel: _getSentimentLabel(sentimentScore),
          confidenceScore: 0.6, // Lower confidence for minimal responses
          componentAnalysis: componentAnalysis,
          interpretationMethod: 'minimal_response_analysis',
          keyFindings: 'brief_response: ${words.join(' ')}',
          themes: words,
          analysisModel: 'rule_based',
          rawResponse: 'Minimal response analyzed with fallback logic',
        );
      }
      
      // Use existing text analysis method for substantial responses with question context
      final oldResult = await _analyzeSingleFeedback(trimmedText, questionContext: questionTitle);
      
      // Convert old 0-100 score to -1 to 1 scale
      final oldScore = double.tryParse(oldResult.sentimentScore) ?? 50.0;
      final sentimentScore = (oldScore - 50.0) / 50.0; // Convert 0-100 to -1 to 1
      
      final componentAnalysis = {
        'word_count': words.length,
        'character_count': trimmedText.length,
        'tone': _detectTone(trimmedText),
        'key_phrases': _extractKeyPhrases(trimmedText),
        'original_score': oldScore,
        'response_status': 'complete_response',
      };

      return EnhancedSentimentResult(
        resultsAnswersId: resultsAnswersId,
        componentType: 'text',
        sentimentScore: sentimentScore,
        sentimentLabel: _getSentimentLabel(sentimentScore),
        confidenceScore: 0.8, // Default confidence for text analysis
        componentAnalysis: componentAnalysis,
        interpretationMethod: 'text_analysis',
        keyFindings: oldResult.keyFindings,
        themes: _extractKeyPhrases(trimmedText),
        analysisModel: 'gemini-1.5-flash',
        rawResponse: oldResult.rawResponse,
      );

    } catch (e) {
      debugPrint('ERROR analyzing text sentiment: $e');
      throw Exception('Text analysis failed: $e');
    }
  }

  /// Analyzes slider scale semantics using Gemini
  static Future<SliderAnalysisResult> _analyzeSliderScale(
    String minLabel, 
    String maxLabel, 
    String questionTitle,
  ) async {
    try {
      final prompt = _buildSliderScalePrompt(minLabel, maxLabel, questionTitle);
      final content = [Content.text(prompt)];
      
      final response = await model.generateContent(content);
      
      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Empty response from Gemini API for slider analysis');
      }

      return _parseSliderScaleResponse(response.text!, minLabel, maxLabel);

    } catch (e) {
      debugPrint('ERROR analyzing slider scale: $e');
      // Return fallback analysis
      return SliderAnalysisResult(
        rawValue: 0,
        percentage: 0.0,
        minLabel: minLabel,
        maxLabel: maxLabel,
        minSentiment: 'neutral',
        maxSentiment: 'neutral',
        scaleDirection: 'context_dependent',
        confidenceScore: 0.3,
        interpretation: 'fallback_analysis',
      );
    }
  }

  /// Builds prompt for slider scale semantic analysis
  static String _buildSliderScalePrompt(String minLabel, String maxLabel, String questionTitle) {
    return '''
Analyze this slider scale to determine the sentiment direction and meaning.

Question: "$questionTitle"
Minimum label: "$minLabel"
Maximum label: "$maxLabel"

Determine:
1. The sentiment of the minimum label (positive, negative, or neutral)
2. The sentiment of the maximum label (positive, negative, or neutral)  
3. The scale direction (positive_high, negative_high, or context_dependent)
4. Your confidence in this analysis (0.0 to 1.0)
5. A brief interpretation of what high values represent

Respond with ONLY a valid JSON object:

{
  "min_sentiment": "positive|negative|neutral",
  "max_sentiment": "positive|negative|neutral", 
  "scale_direction": "positive_high|negative_high|context_dependent",
  "confidence": [number 0.0-1.0],
  "interpretation": "[brief description of what high values mean]"
}

Examples:
- "Poor" → "Excellent" = {"min_sentiment": "negative", "max_sentiment": "positive", "scale_direction": "positive_high", "confidence": 0.95, "interpretation": "high_satisfaction"}
- "Never" → "Always" depends on context = {"min_sentiment": "neutral", "max_sentiment": "neutral", "scale_direction": "context_dependent", "confidence": 0.7, "interpretation": "frequency_dependent"}
''';
  }

  /// Parses slider scale analysis response
  static SliderAnalysisResult _parseSliderScaleResponse(String responseText, String minLabel, String maxLabel) {
    try {
      // Clean the response
      String cleanedResponse = responseText.trim();
      if (cleanedResponse.startsWith('```json')) {
        cleanedResponse = cleanedResponse.substring(7);
      }
      if (cleanedResponse.startsWith('```')) {
        cleanedResponse = cleanedResponse.substring(3);
      }
      if (cleanedResponse.endsWith('```')) {
        cleanedResponse = cleanedResponse.substring(0, cleanedResponse.length - 3);
      }
      cleanedResponse = cleanedResponse.trim();

      // Parse JSON manually to avoid import issues
      final minSentimentMatch = RegExp(r'"min_sentiment"\s*:\s*"([^"]*)"').firstMatch(cleanedResponse);
      final maxSentimentMatch = RegExp(r'"max_sentiment"\s*:\s*"([^"]*)"').firstMatch(cleanedResponse);
      final scaleDirectionMatch = RegExp(r'"scale_direction"\s*:\s*"([^"]*)"').firstMatch(cleanedResponse);
      final confidenceMatch = RegExp(r'"confidence"\s*:\s*([0-9.]+)').firstMatch(cleanedResponse);
      final interpretationMatch = RegExp(r'"interpretation"\s*:\s*"([^"]*)"').firstMatch(cleanedResponse);

      return SliderAnalysisResult(
        rawValue: 0,
        percentage: 0.0,
        minLabel: minLabel,
        maxLabel: maxLabel,
        minSentiment: minSentimentMatch?.group(1) ?? 'neutral',
        maxSentiment: maxSentimentMatch?.group(1) ?? 'neutral',
        scaleDirection: scaleDirectionMatch?.group(1) ?? 'context_dependent',
        confidenceScore: double.tryParse(confidenceMatch?.group(1) ?? '0.5') ?? 0.5,
        interpretation: interpretationMatch?.group(1) ?? 'unknown',
      );

    } catch (e) {
      debugPrint('ERROR parsing slider scale response: $e');
      return SliderAnalysisResult(
        rawValue: 0,
        percentage: 0.0,
        minLabel: minLabel,
        maxLabel: maxLabel,
        minSentiment: 'neutral',
        maxSentiment: 'neutral',
        scaleDirection: 'context_dependent',
        confidenceScore: 0.3,
        interpretation: 'parse_error',
      );
    }
  }

  /// Calculates sentiment score based on scale direction
  static double _calculateSliderSentimentScore(double percentage, String scaleDirection) {
    switch (scaleDirection) {
      case 'positive_high':
        // Higher values = more positive
        return (percentage - 0.5) * 2.0;
      case 'negative_high':
        // Higher values = more negative  
        return (0.5 - percentage) * 2.0;
      case 'context_dependent':
      default:
        // Assume positive_high as default
        return (percentage - 0.5) * 2.0;
    }
  }

  /// Gets sentiment label from score
  static String _getSentimentLabel(double sentimentScore) {
    if (sentimentScore > 0.3) return 'positive';
    if (sentimentScore < -0.3) return 'negative';
    if (sentimentScore.abs() < 0.1) return 'neutral';
    return 'mixed';
  }

  /// Generates key findings for slider analysis (compatible with both AI and rule-based)
  static String _generateSliderKeyFindings(int value, String minLabel, String maxLabel, SliderAnalysisResult? analysis) {
    // Generate simple sentiment tags based on slider value
    if (value >= 90) {
      return 'excellent';
    } else if (value >= 80) {
      return 'very good';
    } else if (value >= 70) {
      return 'good';
    } else if (value >= 60) {
      return 'fair';
    } else if (value >= 40) {
      return 'needs improvement';
    } else {
      return 'poor';
    }
  }

  /// Detects tone from text (simple implementation)
  static String _detectTone(String text) {
    final lowerText = text.toLowerCase();
    if (lowerText.contains('better') || lowerText.contains('improve') || lowerText.contains('more')) {
      return 'constructive';
    } else if (lowerText.contains('good') || lowerText.contains('great') || lowerText.contains('excellent')) {
      return 'positive';
    } else if (lowerText.contains('bad') || lowerText.contains('poor') || lowerText.contains('terrible')) {
      return 'negative';
    }
    return 'neutral';
  }

  /// Extracts key phrases from text
  static List<String> _extractKeyPhrases(String text) {
    final words = text.toLowerCase().split(RegExp(r'[^a-zA-Z0-9]+'));
    final meaningfulWords = words.where((word) => word.length > 3).toList();
    return meaningfulWords.take(5).toList();
  }

  /// Stores sentiment result in database
  static Future<void> _storeSentimentResult(EnhancedSentimentResult result) async {
    try {
      await _supabase.from('feedback_sentiment').insert(result.toJson());
      debugPrint('DEBUG: Sentiment result stored in database');
    } catch (e) {
      debugPrint('ERROR storing sentiment result: $e');
      // Don't throw - we still want to return the analysis result
    }
  }

  /// Test method to validate enhanced sentiment analysis functionality
  /// Call this to test with sample data before using with real answers
  static Future<void> testEnhancedSentiment() async {
    try {
      debugPrint('=== Testing Enhanced Sentiment Analysis ===');
      
      // Test 1: Slider Analysis
      debugPrint('\n--- Test 1: Slider Analysis ---');
      final sliderResult = await analyzeEnhancedSentiment(
        resultsAnswersId: 999, // Test ID
        answer: '83',
        componentType: 'slider',
        questionTitle: 'Inclusivity',
        minLabel: 'Not heard',
        maxLabel: 'Fully heard',
      );
      
      debugPrint('Slider Result:');
      debugPrint('  Score: ${sliderResult.sentimentScore}');
      debugPrint('  Label: ${sliderResult.sentimentLabel}');
      debugPrint('  Confidence: ${sliderResult.confidenceScore}');
      debugPrint('  Key Findings: ${sliderResult.keyFindings}');
      
      // Test 2: Text Analysis
      debugPrint('\n--- Test 2: Text Analysis ---');
      final textResult = await analyzeEnhancedSentiment(
        resultsAnswersId: 998, // Test ID
        answer: 'be better',
        componentType: 'text',
      );
      
      debugPrint('Text Result:');
      debugPrint('  Score: ${textResult.sentimentScore}');
      debugPrint('  Label: ${textResult.sentimentLabel}');
      debugPrint('  Confidence: ${textResult.confidenceScore}');
      debugPrint('  Key Findings: ${textResult.keyFindings}');
      
      // Test 3: Empty Text Analysis
      debugPrint('\n--- Test 3: Empty Text Analysis ---');
      final emptyResult = await analyzeEnhancedSentiment(
        resultsAnswersId: 997, // Test ID
        answer: '',
        componentType: 'text',
      );
      
      debugPrint('Empty Text Result:');
      debugPrint('  Score: ${emptyResult.sentimentScore}');
      debugPrint('  Label: ${emptyResult.sentimentLabel}');
      debugPrint('  Confidence: ${emptyResult.confidenceScore}');
      debugPrint('  Key Findings: ${emptyResult.keyFindings}');
      debugPrint('  Method: ${emptyResult.interpretationMethod}');
      
      // Test 4: Whitespace-only Text Analysis
      debugPrint('\n--- Test 4: Whitespace-only Text Analysis ---');
      final whitespaceResult = await analyzeEnhancedSentiment(
        resultsAnswersId: 996, // Test ID
        answer: '   \n\t  ',
        componentType: 'text',
      );
      
      debugPrint('Whitespace Text Result:');
      debugPrint('  Score: ${whitespaceResult.sentimentScore}');
      debugPrint('  Label: ${whitespaceResult.sentimentLabel}');
      debugPrint('  Confidence: ${whitespaceResult.confidenceScore}');
      debugPrint('  Key Findings: ${whitespaceResult.keyFindings}');
      debugPrint('  Method: ${whitespaceResult.interpretationMethod}');
      
      // Test 5: Very short text Analysis
      debugPrint('\n--- Test 5: Very Short Text Analysis ---');
      final shortResult = await analyzeEnhancedSentiment(
        resultsAnswersId: 995, // Test ID
        answer: 'ok',
        componentType: 'text',
      );
      
      debugPrint('Short Text Result:');
      debugPrint('  Score: ${shortResult.sentimentScore}');
      debugPrint('  Label: ${shortResult.sentimentLabel}');
      debugPrint('  Confidence: ${shortResult.confidenceScore}');
      debugPrint('  Key Findings: ${shortResult.keyFindings}');
      debugPrint('  Method: ${shortResult.interpretationMethod}');
      
      // Test 6: Session Analysis with Empty Responses
      debugPrint('\n--- Test 6: Session Analysis with Empty Responses ---');
      final sessionResult = await analyzeSessionSentiment([
        'Great session, very inclusive',
        '',
        '   ',
        'Could be better organized',
        'no',
        '',
        'Excellent facilitation skills'
      ], 7);
      
      debugPrint('Session Result with Empty Responses:');
      debugPrint('  Score: ${sessionResult.sentimentScore}');
      debugPrint('  Label: ${sessionResult.sentimentLabel}');
      debugPrint('  Total Valid Responses: ${sessionResult.totalResponses}');
      debugPrint('  Strengths: ${sessionResult.strengths}');
      debugPrint('  Improvements: ${sessionResult.improvements}');
      
      debugPrint('\n=== Enhanced Sentiment Analysis Test Completed ===');
      
      // Test 7: Session Aggregation
      debugPrint('\n--- Test 7: Session Aggregation ---');
      try {
        await testSessionAggregation();
      } catch (e) {
        debugPrint('Session aggregation test failed: $e');
      }
      
    } catch (e) {
      debugPrint('ERROR in enhanced sentiment test: $e');
    }
  }

  /// Analyzes existing answers from the database using enhanced sentiment analysis
  /// Useful for testing with real data or migrating existing answers
  static Future<List<EnhancedSentimentResult>> analyzeExistingAnswers({
    int? sessionId,
    int? limit = 10,
  }) async {
    try {
      debugPrint('=== Analyzing Existing Answers ===');
      
      // Query to get answers with question context
      String query = '''
        results_answers_id,
        answer,
        questions!inner(
          question_id,
          question,
          title,
          min_label,
          max_label,
          _component_type!inner(
            name
          )
        ),
        results!inner(
          session_id
        )
      ''';
      
      var queryBuilder = _supabase
          .from('results_answers')
          .select(query);
      
      if (sessionId != null) {
        queryBuilder = queryBuilder.eq('results.session_id', sessionId);
      }
      
      final response = await (limit != null ? queryBuilder.limit(limit) : queryBuilder);
      
      final results = <EnhancedSentimentResult>[];
      
      for (final row in response) {
        final question = row['questions'] as Map<String, dynamic>;
        final componentType = question['_component_type']['name'] as String;
        
        // Only analyze slider and text components
        if (componentType == 'slider' || componentType == 'text') {
          try {
            final result = await analyzeEnhancedSentiment(
              resultsAnswersId: row['results_answers_id'] as int,
              answer: row['answer'] as String,
              componentType: componentType,
              questionTitle: question['title'] as String?,
              minLabel: question['min_label'] as String?,
              maxLabel: question['max_label'] as String?,
            );
            
            results.add(result);
            debugPrint('Analyzed answer ${row['results_answers_id']}: ${result.sentimentLabel} (${result.sentimentScore.toStringAsFixed(2)})');
            
          } catch (e) {
            debugPrint('ERROR analyzing answer ${row['results_answers_id']}: $e');
          }
        }
      }
      
      debugPrint('=== Analysis Complete: ${results.length} answers processed ===');
      return results;
      
    } catch (e) {
      debugPrint('ERROR analyzing existing answers: $e');
      return [];
    }
  }

  /// Creates or updates session-level sentiment aggregation
  /// Analyzes all sentiment results for a session and creates summary
  static Future<SessionSentimentSummary> aggregateSessionSentiment(int sessionId) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      debugPrint('=== Starting Session Sentiment Aggregation for Session $sessionId ===');
      
      // Step 1: Get all sentiment results for this session
      final sentimentResults = await _getSessionSentimentResults(sessionId);
      
      if (sentimentResults.isEmpty) {
        debugPrint('No sentiment results found for session $sessionId - creating empty state summary');
        return _createEmptySessionSummary(sessionId, stopwatch.elapsedMilliseconds);
      }
      
      debugPrint('Found ${sentimentResults.length} sentiment results for session $sessionId');
      
      // Step 2: Separate by component type and calculate averages
      final textResults = sentimentResults.where((r) => r['component_type'] == 'text').toList();
      final sliderResults = sentimentResults.where((r) => r['component_type'] == 'slider').toList();
      
      final textScores = textResults.map((r) => r['sentiment_score'] as double).toList();
      final sliderScores = sliderResults.map((r) => r['sentiment_score'] as double).toList();
      
      final double? textAverage = textScores.isNotEmpty 
          ? textScores.reduce((a, b) => a + b) / textScores.length 
          : null;
      final double? sliderAverage = sliderScores.isNotEmpty 
          ? sliderScores.reduce((a, b) => a + b) / sliderScores.length 
          : null;
      
      debugPrint('Text average: $textAverage (${textScores.length} responses)');
      debugPrint('Slider average: $sliderAverage (${sliderScores.length} responses)');
      
      // Step 3: Calculate weighted overall sentiment score
      final overallScore = _calculateOverallSentimentScore(textAverage, sliderAverage, textScores.length, sliderScores.length);
      
      // Step 4: Extract themes and insights
      final themes = await _extractSessionThemes(sentimentResults);
      final insights = await _generateSessionInsights(sentimentResults, textAverage, sliderAverage);
      
      // Step 5: Build component breakdown
      final componentBreakdown = _buildComponentBreakdown(textResults, sliderResults, textAverage, sliderAverage);
      
      // Step 6: Calculate confidence score
      final confidenceScore = _calculateSessionConfidenceScore(sentimentResults);
      
      stopwatch.stop();
      
      // Step 7: Create session summary
      final summary = SessionSentimentSummary(
        sessionId: sessionId,
        overallSentimentScore: overallScore,
        overallSentimentLabel: _getSentimentLabel(overallScore),
        textSentimentScore: textAverage,
        sliderSentimentScore: sliderAverage,
        textResponseCount: textScores.length,
        sliderResponseCount: sliderScores.length,
        totalResponseCount: sentimentResults.length,
        componentBreakdown: componentBreakdown,
        keyThemes: themes,
        sessionInsights: insights,
        confidenceScore: confidenceScore,
        aggregationMethod: 'weighted_average',
        analysisModel: 'gemini-1.5-flash',
        processingTimeMs: stopwatch.elapsedMilliseconds,
        createdAt: DateTime.now(),
      );
      
      // Step 8: Store in database
      await _storeSessionSentimentSummary(summary);
      
      debugPrint('=== Session Sentiment Aggregation Complete: ${overallScore.toStringAsFixed(3)} (${summary.overallSentimentLabel}) ===');
      return summary;
      
    } catch (e) {
      stopwatch.stop();
      debugPrint('ERROR in session sentiment aggregation: $e');
      rethrow;
    }
  }

  /// Gets all sentiment results for a session from the database
  static Future<List<Map<String, dynamic>>> _getSessionSentimentResults(int sessionId) async {
    try {
      // First get all results_answers_id for this session
      final sessionAnswers = await _supabase
          .from('results_answers')
          .select('results_answers_id, results!inner(session_id)')
          .eq('results.session_id', sessionId);
      
      if (sessionAnswers.isEmpty) {
        return [];
      }
      
      final answerIds = sessionAnswers.map((row) => row['results_answers_id'] as int).toList();
      
      // Then get sentiment data for those answer IDs
      final response = await _supabase
          .from('feedback_sentiment')
          .select('''
            sentiment_id,
            results_answers_id,
            component_type,
            sentiment_score,
            sentiment_label,
            confidence_score,
            component_analysis,
            key_findings,
            themes
          ''')
          .inFilter('results_answers_id', answerIds);
      
      return List<Map<String, dynamic>>.from(response);
      
    } catch (e) {
      debugPrint('ERROR getting session sentiment results: $e');
      rethrow;
    }
  }

  /// Calculates weighted overall sentiment score from component averages
  static double _calculateOverallSentimentScore(
    double? textAverage, 
    double? sliderAverage, 
    int textCount, 
    int sliderCount,
  ) {
    if (textAverage == null && sliderAverage == null) {
      return 0.0; // No data
    }
    
    if (textAverage == null) {
      return sliderAverage!; // Only slider data
    }
    
    if (sliderAverage == null) {
      return textAverage; // Only text data
    }
    
    // Weighted average based on response counts
    final totalCount = textCount + sliderCount;
    final textWeight = textCount / totalCount;
    final sliderWeight = sliderCount / totalCount;
    
    return (textAverage * textWeight) + (sliderAverage * sliderWeight);
  }

  /// Extracts key themes from all sentiment results in a session
  static Future<List<String>> _extractSessionThemes(List<Map<String, dynamic>> sentimentResults) async {
    try {
      final allFindings = <String>[];
      final allThemes = <String>[];
      
      for (final result in sentimentResults) {
        // Add key findings
        final findings = result['key_findings'] as String?;
        if (findings != null && findings.isNotEmpty && findings != 'no_response_provided') {
          allFindings.add(findings);
        }
        
        // Add themes if available
        final themesJson = result['themes'] as String?;
        if (themesJson != null && themesJson.isNotEmpty) {
          try {
            final themes = List<String>.from(jsonDecode(themesJson));
            allThemes.addAll(themes);
          } catch (e) {
            // Handle non-JSON themes (fallback)
            if (themesJson != '[]') {
              allThemes.add(themesJson);
            }
          }
        }
      }
      
      // Combine all themes and findings
      final allKeywords = [...allFindings, ...allThemes];
      
      if (allKeywords.isEmpty) {
        return ['insufficient_feedback'];
      }
      
      // Use Gemini to identify key themes
      final combinedText = allKeywords.join(', ');
      final prompt = _buildThemeExtractionPrompt(combinedText);
      
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      
      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Empty response from Gemini for theme extraction');
      }
      
      return _parseThemeExtractionResponse(response.text!);
      
    } catch (e) {
      debugPrint('ERROR extracting session themes: $e');
      return ['theme_extraction_failed'];
    }
  }

  /// Generates session-level insights based on sentiment data
  static Future<List<String>> _generateSessionInsights(
    List<Map<String, dynamic>> sentimentResults,
    double? textAverage,
    double? sliderAverage,
  ) async {
    try {
      final insights = <String>[];
      
      // Response participation insights
      final textCount = sentimentResults.where((r) => r['component_type'] == 'text').length;
      final sliderCount = sentimentResults.where((r) => r['component_type'] == 'slider').length;
      final totalCount = sentimentResults.length;
      
      if (totalCount < 3) {
        insights.add('low_participation');
      } else if (totalCount >= 10) {
        insights.add('high_participation');
      }
      
      // Sentiment pattern insights
      if (textAverage != null && sliderAverage != null) {
        final difference = (textAverage - sliderAverage).abs();
        if (difference > 0.5) {
          if (textAverage > sliderAverage) {
            insights.add('text_more_positive_than_ratings');
          } else {
            insights.add('ratings_more_positive_than_text');
          }
        } else {
          insights.add('consistent_sentiment_across_components');
        }
      }
      
      // Overall sentiment insights
      final overallScore = _calculateOverallSentimentScore(textAverage, sliderAverage, textCount, sliderCount);
      if (overallScore > 0.5) {
        insights.add('highly_positive_session');
      } else if (overallScore < -0.5) {
        insights.add('areas_need_attention');
      } else {
        insights.add('mixed_feedback_patterns');
      }
      
      // Confidence-based insights
      final avgConfidence = sentimentResults
          .map((r) => r['confidence_score'] as double)
          .reduce((a, b) => a + b) / sentimentResults.length;
      
      if (avgConfidence < 0.6) {
        insights.add('low_confidence_analysis');
      }
      
      return insights;
      
    } catch (e) {
      debugPrint('ERROR generating session insights: $e');
      return ['insight_generation_failed'];
    }
  }

  /// Builds detailed component breakdown for the session
  static Map<String, dynamic> _buildComponentBreakdown(
    List<Map<String, dynamic>> textResults,
    List<Map<String, dynamic>> sliderResults,
    double? textAverage,
    double? sliderAverage,
  ) {
    return {
      'text_components': {
        'count': textResults.length,
        'average_sentiment': textAverage,
        'sentiment_distribution': _calculateSentimentDistribution(
          textResults.map((r) => r['sentiment_score'] as double).toList()
        ),
        'common_themes': textResults
            .where((r) => r['key_findings'] != null && r['key_findings'] != 'no_response_provided')
            .map((r) => r['key_findings'])
            .take(5)
            .toList(),
      },
      'slider_components': {
        'count': sliderResults.length,
        'average_sentiment': sliderAverage,
        'sentiment_distribution': _calculateSentimentDistribution(
          sliderResults.map((r) => r['sentiment_score'] as double).toList()
        ),
        'raw_values': sliderResults
            .map((r) => r['component_analysis'])
            .where((analysis) => analysis != null)
            .map((analysis) => (analysis as Map<String, dynamic>)['raw_value'])
            .toList(),
      },
      'overall_patterns': {
        'response_quality': _assessResponseQuality(textResults, sliderResults),
        'engagement_level': _assessEngagementLevel(textResults.length, sliderResults.length),
      },
    };
  }

  /// Calculates sentiment distribution (positive, neutral, negative percentages)
  static Map<String, double> _calculateSentimentDistribution(List<double> scores) {
    if (scores.isEmpty) return {'positive': 0.0, 'neutral': 0.0, 'negative': 0.0};
    
    final positive = scores.where((s) => s > 0.3).length / scores.length;
    final negative = scores.where((s) => s < -0.3).length / scores.length;
    final neutral = 1.0 - positive - negative;
    
    return {
      'positive': positive,
      'neutral': neutral,
      'negative': negative,
    };
  }

  /// Assesses response quality based on content analysis
  static String _assessResponseQuality(
    List<Map<String, dynamic>> textResults,
    List<Map<String, dynamic>> sliderResults,
  ) {
    final textQuality = textResults.where((r) {
      final analysis = r['component_analysis'] as Map<String, dynamic>?;
      if (analysis == null) return false;
      final wordCount = analysis['word_count'] as int? ?? 0;
      return wordCount > 3; // More than 3 words considered quality
    }).length;
    
    final qualityRatio = textResults.isNotEmpty ? textQuality / textResults.length : 0.0;
    
    if (qualityRatio > 0.7) return 'high_quality';
    if (qualityRatio > 0.4) return 'moderate_quality';
    return 'low_quality';
  }

  /// Assesses engagement level based on response counts
  static String _assessEngagementLevel(int textCount, int sliderCount) {
    final totalResponses = textCount + sliderCount;
    if (totalResponses >= 15) return 'high_engagement';
    if (totalResponses >= 8) return 'moderate_engagement';
    return 'low_engagement';
  }

  /// Calculates session confidence score based on individual result confidences
  static double _calculateSessionConfidenceScore(List<Map<String, dynamic>> sentimentResults) {
    if (sentimentResults.isEmpty) return 0.0;
    
    final confidenceScores = sentimentResults
        .map((r) => r['confidence_score'] as double)
        .toList();
    
    final average = confidenceScores.reduce((a, b) => a + b) / confidenceScores.length;
    
    // Adjust confidence based on sample size
    final sampleSizeBonus = sentimentResults.length >= 10 ? 0.1 : 0.0;
    final adjustedConfidence = (average + sampleSizeBonus).clamp(0.0, 1.0);
    
    return adjustedConfidence;
  }

  /// Builds prompt for theme extraction
  static String _buildThemeExtractionPrompt(String combinedText) {
    return '''
Extract 3-5 key themes from this combined feedback and sentiment analysis data.

Combined data: "$combinedText"

Identify the most important recurring themes, patterns, or topics. Focus on actionable insights that would help a facilitator improve their performance.

Respond with ONLY a valid JSON array of strings:

["theme1", "theme2", "theme3"]

Guidelines:
- Keep themes concise (2-4 words each)
- Focus on facilitator performance aspects
- Prioritize actionable feedback themes
- Extract patterns that appear multiple times
- Use professional, constructive language

Example format:
["clear communication", "time management", "participant engagement"]
''';
  }

  /// Parses theme extraction response
  static List<String> _parseThemeExtractionResponse(String responseText) {
    try {
      String cleanedResponse = responseText.trim();
      
      // Remove markdown code block markers if present
      if (cleanedResponse.startsWith('```json')) {
        cleanedResponse = cleanedResponse.substring(7);
      }
      if (cleanedResponse.startsWith('```')) {
        cleanedResponse = cleanedResponse.substring(3);
      }
      if (cleanedResponse.endsWith('```')) {
        cleanedResponse = cleanedResponse.substring(0, cleanedResponse.length - 3);
      }
      
      cleanedResponse = cleanedResponse.trim();
      
      // Find JSON array
      final arrayStart = cleanedResponse.indexOf('[');
      final arrayEnd = cleanedResponse.lastIndexOf(']');
      
      if (arrayStart == -1 || arrayEnd == -1) {
        throw Exception('No JSON array found in response');
      }
      
      final jsonString = cleanedResponse.substring(arrayStart, arrayEnd + 1);
      final themes = List<String>.from(jsonDecode(jsonString));
      
      return themes.where((theme) => theme.isNotEmpty).take(5).toList();
      
    } catch (e) {
      debugPrint('Error parsing theme extraction response: $e');
      return ['parsing_error', 'manual_review_needed'];
    }
  }

  /// Stores session sentiment summary in database
  static Future<void> _storeSessionSentimentSummary(SessionSentimentSummary summary) async {
    try {
      // First try to update existing summary
      final existingResponse = await _supabase
          .from('session_sentiment_summary')
          .select('session_summary_id')  // Fixed: match actual DB column name
          .eq('session_id', summary.sessionId);
      
      if (existingResponse.isNotEmpty) {
        // Update existing
        await _supabase
            .from('session_sentiment_summary')
            .update(summary.toJson())
            .eq('session_id', summary.sessionId);
        debugPrint('Updated existing session sentiment summary for session ${summary.sessionId}');
      } else {
        // Insert new
        await _supabase
            .from('session_sentiment_summary')
            .insert(summary.toJson());
        debugPrint('Created new session sentiment summary for session ${summary.sessionId}');
      }
      
    } catch (e) {
      debugPrint('ERROR storing session sentiment summary: $e');
      rethrow;
    }
  }

  /// Gets existing session sentiment summary from database
  static Future<SessionSentimentSummary?> getSessionSentimentSummary(int sessionId) async {
    try {
      final response = await _supabase
          .from('session_sentiment_summary')
          .select()
          .eq('session_id', sessionId)
          .limit(1);
      
      if (response.isEmpty) {
        return null;
      }
      
      return SessionSentimentSummary.fromJson(response.first);
      
    } catch (e) {
      debugPrint('ERROR getting session sentiment summary: $e');
      return null;
    }
  }

  /// Tests session aggregation with sample data
  static Future<void> testSessionAggregation({int? sessionId}) async {
    try {
      debugPrint('=== Testing Session Sentiment Aggregation ===');
      
      // Use provided session ID or find a session with data
      int targetSessionId = sessionId ?? await _findSessionWithData();
      
      if (targetSessionId == -1) {
        debugPrint('No sessions with sentiment data found. Creating sample data first...');
        return;
      }
      
      debugPrint('Testing aggregation for session $targetSessionId');
      
      // Run aggregation
      final summary = await aggregateSessionSentiment(targetSessionId);
      
      debugPrint('Session Aggregation Results:');
      debugPrint('  Session ID: ${summary.sessionId}');
      debugPrint('  Overall Score: ${summary.overallSentimentScore.toStringAsFixed(3)}');
      debugPrint('  Overall Label: ${summary.overallSentimentLabel}');
      debugPrint('  Text Score: ${summary.textSentimentScore?.toStringAsFixed(3) ?? 'N/A'}');
      debugPrint('  Slider Score: ${summary.sliderSentimentScore?.toStringAsFixed(3) ?? 'N/A'}');
      debugPrint('  Response Counts: ${summary.textResponseCount} text, ${summary.sliderResponseCount} slider');
      debugPrint('  Key Themes: ${summary.keyThemes}');
      debugPrint('  Session Insights: ${summary.sessionInsights}');
      debugPrint('  Confidence: ${summary.confidenceScore.toStringAsFixed(3)}');
      debugPrint('  Processing Time: ${summary.processingTimeMs}ms');
      
      debugPrint('\n=== Session Aggregation Test Completed ===');
      
    } catch (e) {
      debugPrint('ERROR in session aggregation test: $e');
    }
  }

  /// Creates an empty session summary for sessions with no sentiment data
  static SessionSentimentSummary _createEmptySessionSummary(int sessionId, int processingTimeMs) {
    return SessionSentimentSummary(
      sessionId: sessionId,
      overallSentimentScore: 0.0,
      overallSentimentLabel: 'No Data',
      textSentimentScore: null,
      sliderSentimentScore: null,
      textResponseCount: 0,
      sliderResponseCount: 0,
      totalResponseCount: 0,
      componentBreakdown: {
        'text_components': {
          'count': 0,
          'average_sentiment': null,
          'sentiment_distribution': {'positive': 0.0, 'neutral': 0.0, 'negative': 0.0},
          'common_themes': [],
        },
        'slider_components': {
          'count': 0,
          'average_sentiment': null,
          'sentiment_distribution': {'positive': 0.0, 'neutral': 0.0, 'negative': 0.0},
          'raw_values': [],
        },
        'overall_patterns': {
          'response_quality': 'no_responses',
          'engagement_level': 'no_engagement',
        },
      },
      keyThemes: ['no_feedback_collected'],
      sessionInsights: ['no_sentiment_data_available', 'session_needs_feedback_analysis'],
      confidenceScore: 0.0,
      aggregationMethod: 'empty_state_handling',
      analysisModel: null,
      processingTimeMs: processingTimeMs,
      createdAt: DateTime.now(),
    );
  }

  /// Finds a session that has sentiment data for testing
  static Future<int> _findSessionWithData() async {
    try {
      final response = await _supabase
          .from('feedback_sentiment')
          .select('results_answers!inner(results!inner(session_id))')
          .limit(1);
      
      if (response.isNotEmpty) {
        final sessionId = response.first['results_answers']['results']['session_id'] as int;
        return sessionId;
      }
      
      return -1;
      
    } catch (e) {
      debugPrint('ERROR finding session with data: $e');
      return -1;
    }
  }

  /// Handles aggregation for sessions that may not have any sentiment data yet
  /// Returns either existing summary, new aggregation, or empty state
  static Future<SessionSentimentSummary> getOrCreateSessionSummary(int sessionId) async {
    try {
      debugPrint('DEBUG: getOrCreateSessionSummary called for session $sessionId');
      
      // First check if summary already exists
      final existingSummary = await getSessionSentimentSummary(sessionId);
      if (existingSummary != null) {
        debugPrint('DEBUG: Found existing session summary for session $sessionId');
        return existingSummary;
      }
      
      debugPrint('DEBUG: No existing summary found, processing individual answers first');
      
      // First, analyze individual answers if they haven't been processed yet
      try {
        await analyzeExistingAnswers(sessionId: sessionId);
        debugPrint('DEBUG: Individual answer analysis completed for session $sessionId');
      } catch (e) {
        debugPrint('DEBUG: Individual answer analysis failed or no answers to process: $e');
      }
      
      // Now try to create new aggregation (this handles empty state internally)
      return await aggregateSessionSentiment(sessionId);
      
    } catch (e) {
      debugPrint('ERROR in getOrCreateSessionSummary: $e');
      // Return empty state as fallback
      return _createEmptySessionSummary(sessionId, 0);
    }
  }
}