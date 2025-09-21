import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/sentiment_service.dart';
import '../../services/giphy_service.dart';
import '../../utils/responsive_utils.dart';
import '../atoms/template_question_score.dart';
import '../atoms/sentiment_score.dart';
import '../atoms/sentiment_gif_container.dart';
import '../../themes/spacing_theme.dart';

class EnhancedResultsCard extends StatefulWidget {
  final int sessionId;

  const EnhancedResultsCard({
    super.key,
    required this.sessionId,
  });

  @override
  State<EnhancedResultsCard> createState() => _EnhancedResultsCardState();
}

class _EnhancedResultsCardState extends State<EnhancedResultsCard> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _questionData = [];
  SessionSentimentSummary? _sentimentSummary;
  int _submissionCount = 0;
  String? _error;
  String? _sentimentGifUrl;
  bool _isLoadingGif = false;
  final Map<int, bool> _expandedStates = {};

  // Helper method to get sentiment colors (subtle, for text only)
  Color _getSentimentColor(String sentimentLabel, ColorScheme colorScheme) {
    switch (sentimentLabel.toLowerCase()) {
      case 'positive':
        return Colors.green.shade600;
      case 'negative':
        return Colors.red.shade600;
      case 'mixed':
        return Colors.orange.shade600;
      case 'neutral':
      default:
        return colorScheme.onSurface;
    }
  }


  // Helper method to get sentiment type based on numerical score
  SentimentType _getSentimentTypeFromScore(double score) {
    if (score >= 70) {
      return SentimentType.positive;
    } else if (score >= 40) {
      return SentimentType.neutral;
    } else {
      return SentimentType.negative;
    }
  }


  // Helper method to convert to title case
  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Helper method for responsive title styling
  TextStyle _getSentimentTitleStyle(ScreenSize screenSize, ThemeData theme) {
    switch (screenSize) {
      case ScreenSize.compact:
        return theme.textTheme.headlineSmall!; // headlineSmall for mobile
      case ScreenSize.medium:
        return theme.textTheme.headlineMedium!; // headlineMedium for tablet
      case ScreenSize.expanded:
        return theme.textTheme.headlineLarge!; // headlineLarge for desktop
    }
  }

  // Helper method for responsive padding - using Flutter theme spacing
  EdgeInsets _getResponsivePadding(ScreenSize screenSize, BuildContext context) {
    final spacing = context.spacing;
    switch (screenSize) {
      case ScreenSize.compact:
        return EdgeInsets.all(spacing.lg); // Standard content padding - mobile
      case ScreenSize.medium:
        return EdgeInsets.all(spacing.xl); // Section separation - tablet
      case ScreenSize.expanded:
        return EdgeInsets.all(spacing.xxl); // Large content blocks - desktop
    }
  }

  // Helper method for responsive card spacing - using Flutter theme spacing
  double _getResponsiveCardSpacing(ScreenSize screenSize, BuildContext context) {
    final spacing = context.spacing;
    switch (screenSize) {
      case ScreenSize.compact:
        return spacing.lg; // Standard content padding - mobile
      case ScreenSize.medium:
        return spacing.lg + spacing.xs; // Medium component spacing (20dp) - tablet
      case ScreenSize.expanded:
        return spacing.xl; // Section separation - desktop
    }
  }

  // Helper method for responsive content padding - card content spacing
  EdgeInsets _getResponsiveContentPadding(ScreenSize screenSize, BuildContext context) {
    final spacing = context.spacing;
    switch (screenSize) {
      case ScreenSize.compact:
        return EdgeInsets.all(spacing.lg + spacing.xs); // Medium component spacing (20dp) for card content
      case ScreenSize.medium:
        return EdgeInsets.all(spacing.xl); // Section separation for tablet cards
      case ScreenSize.expanded:
        return EdgeInsets.all(spacing.xxl); // Large content blocks for desktop cards
    }
  }

  // Helper method for responsive element spacing - between components
  double _getResponsiveElementSpacing(ScreenSize screenSize, BuildContext context) {
    final spacing = context.spacing;
    switch (screenSize) {
      case ScreenSize.compact:
        return spacing.sm; // Component internal padding - mobile
      case ScreenSize.medium:
        return spacing.md; // Small component gaps - tablet
      case ScreenSize.expanded:
        return spacing.lg; // Standard content padding - desktop
    }
  }

  // Helper method for responsive internal padding - within components
  EdgeInsets _getResponsiveInternalPadding(ScreenSize screenSize, BuildContext context) {
    final spacing = context.spacing;
    switch (screenSize) {
      case ScreenSize.compact:
        return EdgeInsets.all(spacing.md); // Small component gaps - mobile
      case ScreenSize.medium:
        return EdgeInsets.all(spacing.lg); // Standard content padding - tablet
      case ScreenSize.expanded:
        return EdgeInsets.all(spacing.lg); // Standard content padding - desktop
    }
  }

  // Helper method to format user responses with proper sentence case
  String _formatUserResponse(String text) {
    if (text.isEmpty) return text;
    
    // Trim and normalize whitespace
    String cleaned = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    
    // Handle common technical terms that should maintain their casing
    final Map<String, String> preserveTerms = {
      'html': 'HTML',
      'css': 'CSS',
      'javascript': 'JavaScript',
      'api': 'API',
      'ui': 'UI',
      'ux': 'UX',
      'front end': 'front end',
      'back end': 'back end',
      'fullstack': 'full stack',
    };
    
    // Split into sentences (basic approach)
    List<String> sentences = cleaned.split(RegExp(r'[.!?]+'));
    List<String> formattedSentences = [];
    
    for (String sentence in sentences) {
      if (sentence.trim().isEmpty) continue;
      
      String trimmed = sentence.trim();
      
      // Capitalize first letter
      if (trimmed.isNotEmpty) {
        trimmed = trimmed[0].toUpperCase() + trimmed.substring(1).toLowerCase();
        
        // Restore preserved terms
        preserveTerms.forEach((key, value) {
          RegExp regex = RegExp('\\b${RegExp.escape(key)}\\b', caseSensitive: false);
          trimmed = trimmed.replaceAllMapped(regex, (match) => value);
        });
        
        formattedSentences.add(trimmed);
      }
    }
    
    String result = formattedSentences.join('. ');
    
    // Ensure it ends with proper punctuation
    if (result.isNotEmpty && !result.endsWith('.') && !result.endsWith('!') && !result.endsWith('?')) {
      result += '.';
    }
    
    return result;
  }

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    try {
      final supabase = Supabase.instance.client;

      // Get session template with timeout
      final sessionData = await supabase
          .from('sessions')
          .select('template_id')
          .eq('session_id', widget.sessionId)
          .single()
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('Session data request timed out'),
          );

      final templateId = sessionData['template_id'];

      // Get all questions for this template with their answers and sentiment data with timeout
      final questionsWithAnswers = await _loadQuestionAnswersAndSentiment(templateId)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Questions data request timed out'),
          );
      
      // Load session-level sentiment summary (now much faster with rule-based analysis)
      debugPrint('📊 Loading sentiment summary for session ${widget.sessionId}');
      final sentimentSummary = await SentimentService.getOrCreateSessionSummary(widget.sessionId)
          .timeout(
            const Duration(seconds: 10), // Reduced timeout due to faster analysis
            onTimeout: () => throw Exception('Sentiment summary request timed out'),
          );
      debugPrint('📊 Sentiment summary loaded: ${sentimentSummary.overallSentimentScore}');

      // Get unique submission count
      final submissionCount = await _getSubmissionCount();

      if (mounted) {
        setState(() {
          _questionData = questionsWithAnswers;
          _sentimentSummary = sentimentSummary;
          _submissionCount = submissionCount;
          _isLoading = false;
        });

        // Load appropriate GIF for overall sentiment
        _loadSentimentGif();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> _loadQuestionAnswersAndSentiment(int templateId) async {
    final supabase = Supabase.instance.client;
    
    // Get all questions for this template with timeout
    final questionsData = await supabase
        .from('templates_questions')
        .select('''
          questions!inner(
            question_id,
            title,
            question,
            component_type_id,
            min_label,
            max_label,
            _component_type!inner(name)
          )
        ''')
        .eq('template_id', templateId)
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw Exception('Questions data request timed out for template $templateId'),
        );

    final questionResults = <Map<String, dynamic>>[];

    for (final questionJunction in questionsData) {
      final question = questionJunction['questions'] as Map<String, dynamic>;
      final questionId = question['question_id'];
      final componentTypeName = question['_component_type']['name'] as String;

      // Get all answers for this question in this session with timeout
      final answersData = await supabase
          .from('results_answers')
          .select('''
            results_answers_id,
            answer,
            results!inner(session_id),
            feedback_sentiment(
              sentiment_score,
              sentiment_label,
              confidence_score,
              key_findings,
              component_analysis
            )
          ''')
          .eq('questions_id', questionId)
          .eq('results.session_id', widget.sessionId)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Question answers request timed out for question $questionId'),
          );

      // Process answers based on component type
      Map<String, dynamic> processedData;
      
      if (componentTypeName == 'slider') {
        processedData = _processSliderData(question, answersData);
      } else if (componentTypeName == 'text') {
        processedData = _processTextData(question, answersData);
      } else {
        // Skip unsupported component types
        continue;
      }

      // Add question metadata
      processedData['question'] = question;
      processedData['component_type'] = componentTypeName;
      processedData['raw_answers'] = answersData;

      questionResults.add(processedData);
    }

    return questionResults;
  }

  Map<String, dynamic> _processSliderData(Map<String, dynamic> question, List<dynamic> answersData) {
    final numericAnswers = <double>[];
    final sentimentData = <Map<String, dynamic>>[];

    for (final answer in answersData) {
      final answerValue = double.tryParse(answer['answer'] ?? '0');
      if (answerValue != null) {
        numericAnswers.add(answerValue);
      }

      // Collect sentiment data if available
      final feedbackSentiment = answer['feedback_sentiment'];
      
      if (feedbackSentiment != null && feedbackSentiment is Map<String, dynamic> && feedbackSentiment.isNotEmpty) {
        sentimentData.add(feedbackSentiment);
      } else if (feedbackSentiment != null && feedbackSentiment is List && feedbackSentiment.isNotEmpty) {
        // Handle case where feedback_sentiment returns as a list
        for (final sentiment in feedbackSentiment) {
          if (sentiment is Map<String, dynamic> && sentiment.isNotEmpty) {
            sentimentData.add(sentiment);
          }
        }
      }
    }

    final average = numericAnswers.isNotEmpty 
        ? numericAnswers.reduce((a, b) => a + b) / numericAnswers.length
        : 0.0;

    final avgSentiment = sentimentData.isNotEmpty
        ? sentimentData.map((s) => s['sentiment_score'] as double).reduce((a, b) => a + b) / sentimentData.length
        : null;

    return {
      'average': average,
      'count': numericAnswers.length,
      'sentiment_average': avgSentiment,
      'sentiment_data': sentimentData,
      'display_type': 'slider',
    };
  }

  Map<String, dynamic> _processTextData(Map<String, dynamic> question, List<dynamic> answersData) {
    final textAnswers = <String>[];
    final sentimentData = <Map<String, dynamic>>[];
    final detailedAnswers = <Map<String, dynamic>>[];

    for (final answer in answersData) {
      final answerText = answer['answer'] as String? ?? '';
      if (answerText.trim().isNotEmpty) {
        textAnswers.add(answerText);

        // Create detailed answer object with metadata
        final sentimentInfo = answer['feedback_sentiment'] as Map<String, dynamic>?;
        final confidenceScore = sentimentInfo?['confidence_score'] as double?;
        final sentimentScore = sentimentInfo?['sentiment_score'] as double?;
        final keyFindings = sentimentInfo?['key_findings'] as String?;

        try {
          final wordCount = answerText.trim().isEmpty ? 0 : answerText.trim().split(RegExp(r'\s+')).length;
          
          detailedAnswers.add({
            'original_text': answerText,
            'formatted_text': _formatUserResponse(answerText),
            'sentiment_score': sentimentScore,
            'confidence_score': confidenceScore ?? 0.0,
            'key_findings': keyFindings,
            'word_count': wordCount,
          });
          
          debugPrint('🔍 Added answer: "$answerText" (words: $wordCount, confidence: ${confidenceScore ?? 0.0})');
        } catch (e) {
          debugPrint('❌ Error processing answer: $e');
          // Skip problematic answers rather than crashing
        }
      }

      // Collect sentiment data if available
      if (answer['feedback_sentiment'] != null) {
        sentimentData.add(answer['feedback_sentiment']);
      }
    }

    // Sort detailed answers by insight value (confidence score, then word count)
    detailedAnswers.sort((a, b) {
      final confA = a['confidence_score'] as double;
      final confB = b['confidence_score'] as double;
      
      if (confA != confB) {
        return confB.compareTo(confA); // Higher confidence first
      }
      
      // If confidence scores are equal, prefer longer answers
      final wordsA = a['word_count'] as int;
      final wordsB = b['word_count'] as int;
      return wordsB.compareTo(wordsA);
    });

    // Filter out empty responses, allow all non-empty responses including single words
    final meaningfulAnswers = detailedAnswers.where((answer) => 
      (answer['word_count'] as int) >= 1
    ).toList();

    // Split into top insights and remaining answers
    final topInsights = meaningfulAnswers.take(3).toList();
    final remainingAnswers = meaningfulAnswers.skip(3).toList();

    final avgSentiment = sentimentData.isNotEmpty
        ? sentimentData.map((s) => s['sentiment_score'] as double).reduce((a, b) => a + b) / sentimentData.length
        : null;

    return {
      'text_answers': textAnswers,
      'detailed_answers': detailedAnswers,
      'top_insights': topInsights,
      'remaining_answers': remainingAnswers,
      'count': textAnswers.length,
      'sentiment_average': avgSentiment,
      'sentiment_data': sentimentData,
      'display_type': 'text',
    };
  }

  Future<int> _getSubmissionCount() async {
    try {
      final supabase = Supabase.instance.client;
      
      // Get unique submission count by counting distinct results for this session
      final response = await supabase
          .from('results')
          .select('results_id')
          .eq('session_id', widget.sessionId);
      
      return response.length;
    } catch (e) {
      debugPrint('ERROR getting submission count: $e');
      return 0;
    }
  }

  Future<void> _loadSentimentGif() async {
    if (!mounted || _sentimentSummary == null) return;

    setState(() {
      _isLoadingGif = true;
      _sentimentGifUrl = null;
    });

    try {
      // Convert -1 to 1 scale to 0-100 for GiphyService compatibility
      final sentimentScore = ((_sentimentSummary!.overallSentimentScore + 1.0) / 2.0) * 100.0;
      final gifUrl = await GiphyService.getRandomSentimentGif(sentimentScore)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('GIF request timed out'),
          );

      if (mounted) {
        setState(() {
          _sentimentGifUrl = gifUrl;
          _isLoadingGif = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingGif = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        _buildContent(theme),
      ],
    );
  }

  Widget _buildContent(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final screenSize = getScreenSize(context);

    if (_isLoading) {
      return Center(
        child: Padding(
          padding: _getResponsivePadding(screenSize, context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: colorScheme.primary,
              ),
              SizedBox(height: context.spacing.lg),
              Text(
                'Loading results...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: _getResponsivePadding(screenSize, context),
          child: Text(
            'Error loading data: $_error',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_questionData.isEmpty) {
      return Center(
        child: Padding(
          padding: _getResponsivePadding(screenSize, context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'No feedback to analyze yet',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.spacing.sm),
              Text(
                'Once participants submit their responses, sentiment analysis and insights will appear here instantly.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overall sentiment section (if we have sentiment data)
        if (_sentimentSummary != null && _sentimentSummary!.totalResponseCount > 0) ...[
          _buildOverallSentimentCard(theme),
          SizedBox(height: _getResponsiveCardSpacing(screenSize, context)),
        ],
        
        // Question-by-question results as separate cards
        ..._questionData.map((questionData) => Column(
          children: [
            _buildQuestionCard(theme, questionData),
            SizedBox(height: _getResponsiveCardSpacing(screenSize, context)),
          ],
        )),
      ],
    );
  }

  Widget _buildOverallSentimentCard(ThemeData theme) {
    final summary = _sentimentSummary!;
    final colorScheme = theme.colorScheme;
    final screenSize = getScreenSize(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer, // Use theme surface container
        borderRadius: BorderRadius.circular(20),
      ),
      padding: _getResponsiveContentPadding(screenSize, context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Sentiment analysis',
            style: _getSentimentTitleStyle(screenSize, theme).copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: context.spacing.xl),
          
          // Sentiment GIF
          if (_sentimentGifUrl != null) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SentimentGifContainer(
                    size: 120,
                    gifUrl: _sentimentGifUrl,
                    showAnimation: !_isLoadingGif,
                    onTap: () async {
                      await _loadSentimentGif();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Found a new ${summary.overallSentimentLabel.toLowerCase()} GIF that captures the mood! ✨'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: context.spacing.xl),
          ],

          // Text section with sentiment and stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _toTitleCase(summary.overallSentimentLabel),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: _getSentimentColor(summary.overallSentimentLabel, colorScheme),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: context.spacing.sm),
              
              // Stats row with responders count
              Row(
                children: [
                  Icon(
                    Icons.sentiment_satisfied_alt,
                    size: 24,
                    color: const Color(0xFFEADDFF),
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    '$_submissionCount',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFFEADDFF),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Suggestion chips for key themes
          if (summary.keyThemes.isNotEmpty && !summary.keyThemes.contains('no_feedback_collected')) ...[
            SizedBox(height: context.spacing.lg),
            Wrap(
              spacing: context.spacing.lg,
              runSpacing: context.spacing.sm,
              children: summary.keyThemes.take(3).map((theme) => _buildSuggestionChip(theme, colorScheme)).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String label, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer, // Use theme secondary container
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }

  Widget _buildQuestionScore(Map<String, dynamic> questionData) {
    final average = questionData['average'] as double;
    final sentimentAverage = questionData['sentiment_average'] as double?;
    
    // If we have sentiment data, use SentimentScore component
    if (sentimentAverage != null) {
      // Convert sentiment average (-1 to 1) to 0-100 scale for display
      final sentimentScore = ((sentimentAverage + 1.0) / 2.0 * 100).round();
      final sentimentType = _getSentimentTypeFromScore(sentimentScore.toDouble());
      
      return SentimentScore(
        score: sentimentScore.toString(),
        sentimentType: sentimentType,
        size: 56,
      );
    } else {
      // Use TemplateQuestionScore for neutral display
      return TemplateQuestionScore(
        score: average.round().toString(),
        size: 56,
      );
    }
  }

  Widget _buildQuestionCard(ThemeData theme, Map<String, dynamic> questionData) {
    final question = questionData['question'] as Map<String, dynamic>;
    final title = question['title'] as String? ?? 'Question';
    final questionText = question['question'] as String? ?? '';
    final displayType = questionData['display_type'] as String;
    final colorScheme = theme.colorScheme;
    final screenSize = getScreenSize(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer, // Use theme surface container
        borderRadius: BorderRadius.circular(20),
      ),
      padding: _getResponsiveContentPadding(screenSize, context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and score
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${questionData['count']} participant${questionData['count'] == 1 ? '' : 's'} responded',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: context.spacing.sm),
                    Text(
                      title,
                      style: _getSentimentTitleStyle(screenSize, theme).copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.0),
              
              // Score display for slider questions
              if (displayType == 'slider') ...[
                _buildQuestionScore(questionData),
              ],
            ],
          ),
          
          if (questionText.isNotEmpty) ...[
            SizedBox(height: context.spacing.md),
            Text(
              questionText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ],
          
          SizedBox(height: context.spacing.xl),
          
          // Answer chips (AI-generated insights)
          _buildAnswerChips(questionData),
          
          // Text answers display (only for text questions)
          if (questionData['display_type'] == 'text' && 
              (questionData['top_insights'] as List<dynamic>? ?? []).isNotEmpty) ...[
            SizedBox(height: context.spacing.xl),
            _buildTextAnswersDisplay(questionData, theme),
          ],
        ],
      ),
    );
  }

  Widget _buildAnswerChips(Map<String, dynamic> questionData) {
    final sentimentData = questionData['sentiment_data'] as List<dynamic>? ?? [];
    final displayType = questionData['display_type'] as String? ?? '';
    
    if (sentimentData.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // For slider questions, show single aggregated sentiment chip
    if (displayType == 'slider') {
      return _buildAggregatedSliderChip(sentimentData);
    }
    
    // For text questions, don't show AI key insights chips - only show participant responses
    if (displayType == 'text') {
      return const SizedBox.shrink();
    }
    
    // Fallback for other component types (future-proofing)
    return const SizedBox.shrink();
  }

  Widget _buildAggregatedSliderChip(List<dynamic> sentimentData) {
    if (sentimentData.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Extract sentiment scores from feedback_sentiment table data
    final sentimentScores = <double>[];
    
    for (final sentiment in sentimentData) {
      final score = sentiment['sentiment_score'] as double?;
      if (score != null) {
        sentimentScores.add(score);
      }
    }
    
    if (sentimentScores.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Calculate average sentiment score from database values
    final averageScore = sentimentScores.reduce((a, b) => a + b) / sentimentScores.length;
    
    // Convert from -1 to 1 scale to 0-100 for _generateSliderKeyFindings compatibility
    final scaledScore = ((averageScore + 1.0) / 2.0 * 100).round();
    
    // Use existing sentiment mapping logic from SentimentService
    String aggregatedLabel;
    if (scaledScore >= 90) {
      aggregatedLabel = 'excellent';
    } else if (scaledScore >= 80) {
      aggregatedLabel = 'very good';
    } else if (scaledScore >= 70) {
      aggregatedLabel = 'good';
    } else if (scaledScore >= 60) {
      aggregatedLabel = 'fair';
    } else if (scaledScore >= 40) {
      aggregatedLabel = 'needs improvement';
    } else {
      aggregatedLabel = 'poor';
    }
    
    return Wrap(
      spacing: context.spacing.lg,
      runSpacing: context.spacing.sm,
      children: [
        Chip(
          label: Text(
            _toTitleCase(aggregatedLabel),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }

  Widget _buildTextAnswersDisplay(Map<String, dynamic> questionData, ThemeData theme) {
    try {
      debugPrint('🔍 Building text answers display for question data: ${questionData.keys}');
      
      final displayType = questionData['display_type'] as String;
      debugPrint('🔍 Display type: $displayType');
      
      // Only show for text questions
      if (displayType != 'text') {
        debugPrint('🔍 Skipping non-text question');
        return const SizedBox.shrink();
      }

      final topInsights = questionData['top_insights'] as List<dynamic>? ?? [];
      final remainingAnswers = questionData['remaining_answers'] as List<dynamic>? ?? [];
      
      debugPrint('🔍 Top insights count: ${topInsights.length}');
      debugPrint('🔍 Remaining answers count: ${remainingAnswers.length}');
      
      if (topInsights.isEmpty) {
        debugPrint('🔍 No top insights to display');
        return const SizedBox.shrink();
      }

      final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: EdgeInsets.only(bottom: 12.0),
          child: Text(
            'Participant responses',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Top 3 answers
        ...topInsights.map((answer) => _buildResponseCard(answer, theme)),
        
        // Show more section if there are remaining answers
        if (remainingAnswers.isNotEmpty) ...[
          SizedBox(height: context.spacing.md),
          _buildShowMoreSection(remainingAnswers, theme, questionData['question']['question_id']),
        ],
      ],
    );
    } catch (e, stackTrace) {
      debugPrint('❌ Error in _buildTextAnswersDisplay: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      return Container(
        padding: EdgeInsets.all(context.spacing.lg),
        child: Text(
          'Error loading text answers: $e',
          style: TextStyle(color: theme.colorScheme.error),
        ),
      );
    }
  }

  Widget _buildResponseCard(Map<String, dynamic> answer, ThemeData theme) {
    try {
      debugPrint('🔍 Building response card for answer: ${answer.keys}');
      
      final colorScheme = theme.colorScheme;
      final screenSize = getScreenSize(context);
      final formattedText = answer['formatted_text'] as String? ?? 'No text available';
      final sentimentScore = answer['sentiment_score'] as double?;
      
      debugPrint('🔍 Response card - formatted text: "$formattedText", sentiment: $sentimentScore');
    
    // Determine sentiment color for accent
    Color? accentColor;
    if (sentimentScore != null) {
      if (sentimentScore > 0.2) {
        accentColor = Colors.green.shade600;
      } else if (sentimentScore < -0.2) {
        accentColor = Colors.red.shade600;
      } else {
        accentColor = Colors.orange.shade600;
      }
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: _getResponsiveElementSpacing(screenSize, context)),
      padding: _getResponsiveInternalPadding(screenSize, context),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: accentColor != null 
          ? Border(left: BorderSide(color: accentColor, width: 3))
          : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quote icon
          Icon(
            Icons.format_quote,
            size: 20,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          SizedBox(width: _getResponsiveElementSpacing(screenSize, context)),
          
          // Response text
          Expanded(
            child: Text(
              formattedText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
    } catch (e, stackTrace) {
      debugPrint('❌ Error in _buildResponseCard: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      return Container(
        padding: EdgeInsets.all(context.spacing.lg),
        child: Text(
          'Error loading response: $e',
          style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
        ),
      );
    }
  }

  Widget _buildShowMoreSection(List<dynamic> remainingAnswers, ThemeData theme, int questionId) {
    final isExpanded = _expandedStates[questionId] ?? false;
    final screenSize = getScreenSize(context);
    
    return Column(
      children: [
        // Show more button - aligned to the right
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                _expandedStates[questionId] = !isExpanded;
              });
            },
            icon: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              size: 20,
            ),
            label: Text(
              isExpanded 
                ? 'Show less'
                : 'Show more',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary.withValues(alpha: 0.8),
            ),
          ),
        ),
        
        // Expandable section
        if (isExpanded) ...[
          SizedBox(height: _getResponsiveElementSpacing(screenSize, context)),
          ...remainingAnswers.map((answer) => _buildResponseCard(answer, theme)),
        ],
      ],
    );
  }

}