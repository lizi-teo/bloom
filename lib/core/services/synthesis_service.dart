import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SliderAnalysis {
  final int excellentCount;
  final int needsImprovementCount;
  final int poorCount;
  final int totalCount;

  SliderAnalysis({
    required this.excellentCount,
    required this.needsImprovementCount,
    required this.poorCount,
    required this.totalCount,
  });

  double get excellentPercentage => totalCount > 0 ? excellentCount / totalCount : 0.0;
  double get needsImprovementPercentage => totalCount > 0 ? needsImprovementCount / totalCount : 0.0;
  double get poorPercentage => totalCount > 0 ? poorCount / totalCount : 0.0;
}


class QuestionResult {
  final int questionId;
  final String title;
  final String questionText;
  final String componentType;
  final int responseCount;

  // For slider questions
  final SliderAnalysis? sliderAnalysis;
  final double? averageScore;

  // For text questions
  final List<String>? textResponses;

  QuestionResult({
    required this.questionId,
    required this.title,
    required this.questionText,
    required this.componentType,
    required this.responseCount,
    this.sliderAnalysis,
    this.averageScore,
    this.textResponses,
  });
}

class SessionSynthesis {
  final int sessionId;
  final String performanceSummary;
  final List<QuestionResult> questionResults;
  final int totalResponses;
  final DateTime createdAt;

  SessionSynthesis({
    required this.sessionId,
    required this.performanceSummary,
    required this.questionResults,
    required this.totalResponses,
    required this.createdAt,
  });
}

class SynthesisService {
  static SupabaseClient get _supabase => Supabase.instance.client;

  /// Analyzes slider responses and categorizes them into performance buckets
  static SliderAnalysis analyzeSliderResponses(List<int> values) {
    if (values.isEmpty) {
      return SliderAnalysis(
        excellentCount: 0,
        needsImprovementCount: 0,
        poorCount: 0,
        totalCount: 0,
      );
    }

    int excellentCount = 0;
    int needsImprovementCount = 0;
    int poorCount = 0;

    for (final value in values) {
      if (value >= 80) {
        excellentCount++;
      } else if (value >= 60) {
        needsImprovementCount++;
      } else {
        poorCount++;
      }
    }

    return SliderAnalysis(
      excellentCount: excellentCount,
      needsImprovementCount: needsImprovementCount,
      poorCount: poorCount,
      totalCount: values.length,
    );
  }

  /// Generates a simple performance summary based on slider analysis
  static String getPerformanceSummary(SliderAnalysis analysis) {
    if (analysis.totalCount == 0) {
      return 'No Data';
    }

    final excellentRatio = analysis.excellentPercentage;
    final goodRatio = analysis.excellentPercentage + analysis.needsImprovementPercentage;
    final poorRatio = analysis.poorPercentage;

    if (excellentRatio > 0.6) {
      return 'Highly Effective';
    } else if (goodRatio > 0.6) {
      return 'Effective';
    } else if (poorRatio > 0.4) {
      return 'Room for Growth';
    } else {
      return 'Mixed Results';
    }
  }




  /// Analyzes a complete session and returns synthesis results including individual questions
  static Future<SessionSynthesis> analyzeSession(int sessionId) async {
    try {
      debugPrint('📊 Starting session synthesis for session $sessionId');

      // First get all questions for this session with their data
      final questionsData = await _supabase
          .from('results_answers')
          .select('''
            answer,
            questions!inner(
              question_id,
              title,
              question,
              component_type_id,
              _component_type!inner(name)
            ),
            results!inner(session_id)
          ''')
          .eq('results.session_id', sessionId);

      if (questionsData.isEmpty) {
        debugPrint('📊 No questions found for session $sessionId');
        return SessionSynthesis(
          sessionId: sessionId,
          performanceSummary: 'No Data',
          questionResults: [],
          totalResponses: 0,
          createdAt: DateTime.now(),
        );
      }

      debugPrint('📊 Found ${questionsData.length} answers for session $sessionId');

      // Group answers by question
      final questionAnswers = <int, List<Map<String, dynamic>>>{};
      final questionMetadata = <int, Map<String, dynamic>>{};

      for (final answerRow in questionsData) {
        final question = answerRow['questions'] as Map<String, dynamic>;
        final questionId = question['question_id'] as int;

        // Store question metadata
        questionMetadata[questionId] = question;

        // Group answers by question
        if (!questionAnswers.containsKey(questionId)) {
          questionAnswers[questionId] = [];
        }
        questionAnswers[questionId]!.add(answerRow);
      }

      debugPrint('📊 Grouped answers into ${questionAnswers.length} questions');

      // Analyze each question individually
      final questionResults = <QuestionResult>[];
      final allSliderValues = <int>[];

      for (final questionId in questionAnswers.keys) {
        final answers = questionAnswers[questionId]!;
        final metadata = questionMetadata[questionId]!;
        final componentType = metadata['_component_type']['name'] as String;

        final result = await _analyzeQuestion(
          questionId: questionId,
          answers: answers,
          metadata: metadata,
          componentType: componentType,
        );

        questionResults.add(result);

        // Collect slider values for overall performance summary
        if (componentType == 'slider' && result.sliderAnalysis != null) {
          for (final answerRow in answers) {
            final answer = answerRow['answer'] as String?;
            if (answer != null) {
              final value = int.tryParse(answer);
              if (value != null) {
                allSliderValues.add(value);
              }
            }
          }
        }
      }

      // Generate performance summary from slider questions only
      String performanceSummary = 'Mixed';
      if (allSliderValues.isNotEmpty) {
        final overallSliderAnalysis = analyzeSliderResponses(allSliderValues);
        performanceSummary = getPerformanceSummary(overallSliderAnalysis);
      } else {
        performanceSummary = 'No Ratings';
      }

      debugPrint('📊 Session analysis complete: $performanceSummary with ${questionResults.length} questions');

      return SessionSynthesis(
        sessionId: sessionId,
        performanceSummary: performanceSummary,
        questionResults: questionResults,
        totalResponses: questionsData.length,
        createdAt: DateTime.now(),
      );

    } catch (e) {
      debugPrint('❌ Error in session synthesis: $e');
      return SessionSynthesis(
        sessionId: sessionId,
        performanceSummary: 'Error',
        questionResults: [],
        totalResponses: 0,
        createdAt: DateTime.now(),
      );
    }
  }

  /// Analyzes a single question's responses
  static Future<QuestionResult> _analyzeQuestion({
    required int questionId,
    required List<Map<String, dynamic>> answers,
    required Map<String, dynamic> metadata,
    required String componentType,
  }) async {
    final title = metadata['title'] as String? ?? 'Question';
    final questionText = metadata['question'] as String? ?? '';

    if (componentType == 'slider') {
      // Extract slider values
      final values = <int>[];
      for (final answerRow in answers) {
        final answer = answerRow['answer'] as String?;
        if (answer != null) {
          final value = int.tryParse(answer);
          if (value != null) {
            values.add(value);
          }
        }
      }

      final sliderAnalysis = analyzeSliderResponses(values);
      final averageScore = values.isNotEmpty
          ? values.reduce((a, b) => a + b) / values.length
          : 0.0;

      return QuestionResult(
        questionId: questionId,
        title: title,
        questionText: questionText,
        componentType: componentType,
        responseCount: values.length,
        sliderAnalysis: sliderAnalysis,
        averageScore: averageScore,
      );

    } else if (componentType == 'text') {
      // Extract text responses
      final responses = <String>[];
      for (final answerRow in answers) {
        final answer = answerRow['answer'] as String?;
        if (answer != null && answer.trim().isNotEmpty) {
          responses.add(answer.trim());
        }
      }

      return QuestionResult(
        questionId: questionId,
        title: title,
        questionText: questionText,
        componentType: componentType,
        responseCount: responses.length,
        textResponses: responses,
      );
    }

    // Fallback for unknown component types
    return QuestionResult(
      questionId: questionId,
      title: title,
      questionText: questionText,
      componentType: componentType,
      responseCount: 0,
    );
  }

  /// Gets slider answers for a specific question in a session
  static Future<List<int>> getSliderAnswersForQuestion(int sessionId, int questionId) async {
    try {
      final response = await _supabase
          .from('results_answers')
          .select('answer, results!inner(session_id)')
          .eq('results.session_id', sessionId)
          .eq('questions_id', questionId);

      final answers = <int>[];
      for (final row in response) {
        final answer = row['answer'] as String?;
        if (answer != null) {
          final value = int.tryParse(answer);
          if (value != null) {
            answers.add(value);
          }
        }
      }

      return answers;
    } catch (e) {
      debugPrint('❌ Error getting slider answers: $e');
      return [];
    }
  }

  /// Gets text answers for a specific question in a session
  static Future<List<String>> getTextAnswersForQuestion(int sessionId, int questionId) async {
    try {
      final response = await _supabase
          .from('results_answers')
          .select('answer, results!inner(session_id)')
          .eq('results.session_id', sessionId)
          .eq('questions_id', questionId);

      final answers = <String>[];
      for (final row in response) {
        final answer = row['answer'] as String?;
        if (answer != null && answer.trim().isNotEmpty) {
          answers.add(answer);
        }
      }

      return answers;
    } catch (e) {
      debugPrint('❌ Error getting text answers: $e');
      return [];
    }
  }
}