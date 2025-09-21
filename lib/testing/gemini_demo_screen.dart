import 'package:flutter/material.dart';
import '../core/services/sentiment_service.dart';

class GeminiDemoScreen extends StatefulWidget {
  const GeminiDemoScreen({super.key});

  static const String routeName = '/gemini-demo';

  @override
  State<GeminiDemoScreen> createState() => _GeminiDemoScreenState();
}

class _GeminiDemoScreenState extends State<GeminiDemoScreen> {
  final _feedbackController = TextEditingController();
  SentimentResult? _sentimentResult;
  bool _isAnalyzing = false;
  
  // Enhanced sentiment analysis state
  String _enhancedTestResults = '';
  bool _isRunningEnhancedTest = false;

  // Sample feedback examples for quick testing
  final List<String> _sampleFeedbacks = [
    "The facilitator was really helpful and explained things clearly. I enjoyed the session and learned a lot.",
    "The session was confusing and the facilitator seemed unprepared. Could improve time management.",
    "Great energy and engagement! The facilitator kept everyone involved and made complex topics easy to understand.",
    "The facilitator was okay but could have been more interactive. Some parts were too rushed.",
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _analyzeFeedback() async {
    if (_feedbackController.text.trim().isEmpty) return;

    setState(() {
      _isAnalyzing = true;
      _sentimentResult = null;
    });

    try {
      final result = await SentimentService.analyzeSentiment(_feedbackController.text);
      if (mounted) {
        setState(() {
          _sentimentResult = result;
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error analyzing feedback: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _loadSampleFeedback(String feedback) {
    _feedbackController.text = feedback;
    setState(() {
      _sentimentResult = null;
    });
  }

  Future<void> _runEnhancedSentimentTest() async {
    setState(() {
      _isRunningEnhancedTest = true;
      _enhancedTestResults = 'Running enhanced sentiment analysis test...\n\n';
    });

    try {
      // Run the test
      await SentimentService.testEnhancedSentiment();
      
      setState(() {
        _enhancedTestResults += '✅ Enhanced sentiment test completed successfully!\n';
        _enhancedTestResults += 'Check the debug console for detailed results.\n\n';
      });
      
    } catch (e) {
      setState(() {
        _enhancedTestResults += '❌ Enhanced sentiment test failed: $e\n\n';
      });
    } finally {
      setState(() {
        _isRunningEnhancedTest = false;
      });
    }
  }

  Future<void> _analyzeRealData() async {
    setState(() {
      _isRunningEnhancedTest = true;
      _enhancedTestResults = 'Analyzing real data from database...\n\n';
    });

    try {
      // Analyze existing answers
      final results = await SentimentService.analyzeExistingAnswers(limit: 5);
      
      setState(() {
        _enhancedTestResults += '✅ Analyzed ${results.length} real answers successfully!\n\n';
        
        for (int i = 0; i < results.length; i++) {
          final result = results[i];
          _enhancedTestResults += 'Answer ${i + 1}:\n';
          _enhancedTestResults += '  Type: ${result.componentType}\n';
          _enhancedTestResults += '  Score: ${result.sentimentScore.toStringAsFixed(2)}\n';
          _enhancedTestResults += '  Label: ${result.sentimentLabel}\n';
          _enhancedTestResults += '  Confidence: ${result.confidenceScore.toStringAsFixed(2)}\n\n';
        }
        
        _enhancedTestResults += 'Check Supabase feedback_sentiment table for stored data.\n';
      });
      
    } catch (e) {
      setState(() {
        _enhancedTestResults += '❌ Real data analysis failed: $e\n\n';
      });
    } finally {
      setState(() {
        _isRunningEnhancedTest = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header removed - using simple title instead
            Container(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Gemini AI Demo',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🤖 AI-Powered Sentiment Analysis',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Test the Gemini API integration by analyzing feedback sentiment. The AI will provide a sentiment score (0-100) and key insights for facilitators.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Sample feedback buttons
                  Text(
                    'Quick Test Examples:',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _sampleFeedbacks.asMap().entries.map((entry) {
                      final index = entry.key;
                      final feedback = entry.value;
                      final preview = feedback.length > 50 ? '${feedback.substring(0, 50)}...' : feedback;

                      return ElevatedButton(
                        onPressed: () => _loadSampleFeedback(feedback),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.secondaryContainer,
                          foregroundColor: colorScheme.onSecondaryContainer,
                        ),
                        child: Text('Sample ${index + 1}: $preview'),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),

                  // Feedback input section
                  Text(
                    'Enter Feedback to Analyze:',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: TextField(
                      controller: _feedbackController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Enter feedback about a facilitator or session...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                        hintStyle: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      style: TextStyle(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Analyze button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isAnalyzing ? null : _analyzeFeedback,
                      icon: _isAnalyzing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.psychology),
                      label: Text(_isAnalyzing ? 'Analyzing...' : 'Analyze Sentiment'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Enhanced sentiment testing section
                  _buildEnhancedTestingSection(theme, colorScheme),

                  const SizedBox(height: 32),

                  // Results section
                  if (_sentimentResult != null) ...[
                    _buildResultsSection(theme, colorScheme),
                  ],

                  const SizedBox(height: 32),

                  // Info section
                  _buildInfoSection(theme, colorScheme),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back),
        label: const Text('Back'),
      ),
    );
  }

  Widget _buildResultsSection(ThemeData theme, ColorScheme colorScheme) {
    final result = _sentimentResult!;
    final score = result.numericScore ?? 50;

    Color scoreColor;
    String scoreDescription;
    IconData scoreIcon;

    if (score >= 70) {
      scoreColor = Colors.green;
      scoreDescription = 'Positive';
      scoreIcon = Icons.sentiment_very_satisfied;
    } else if (score >= 40) {
      scoreColor = Colors.orange;
      scoreDescription = 'Neutral';
      scoreIcon = Icons.sentiment_neutral;
    } else {
      scoreColor = Colors.red;
      scoreDescription = 'Negative';
      scoreIcon = Icons.sentiment_very_dissatisfied;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Analysis Results',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Sentiment score
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  scoreIcon,
                  color: scoreColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sentiment Score',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${result.sentimentScore}/100 ($scoreDescription)',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: scoreColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Key findings
          Text(
            'Key Insights:',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          if (result.keyFindings.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: result.keyFindings
                  .split(',')
                  .map((finding) => finding.trim())
                  .where((finding) => finding.isNotEmpty)
                  .map((finding) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          finding,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ] else ...[
            Text(
              'No specific insights extracted',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Raw response (expandable)
          ExpansionTile(
            title: Text(
              'Raw API Response',
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  result.rawResponse,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'How it works',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• Uses Google Gemini 1.5 Flash model for analysis\n'
            '• Provides sentiment scores from 0 (very negative) to 100 (very positive)\n'
            '• Extracts actionable keywords for facilitator improvement\n'
            '• Handles errors gracefully with fallback analysis\n'
            '• Processes text in real-time with low latency',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedTestingSection(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.secondary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.science,
                color: colorScheme.secondary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Enhanced Sentiment Testing (Phase 1)',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Text(
            'Test the new slider + text sentiment analysis with database integration',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Test buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isRunningEnhancedTest ? null : _runEnhancedSentimentTest,
                  icon: _isRunningEnhancedTest
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.psychology),
                  label: const Text('Sample Test'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.secondary,
                    foregroundColor: colorScheme.onSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isRunningEnhancedTest ? null : _analyzeRealData,
                  icon: _isRunningEnhancedTest
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.storage),
                  label: const Text('Real Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.tertiary,
                    foregroundColor: colorScheme.onTertiary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          
          // Results display
          if (_enhancedTestResults.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.terminal,
                        color: colorScheme.onSurfaceVariant,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Test Results:',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SelectableText(
                      _enhancedTestResults,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontFamily: 'monospace',
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 12),
          
          // Instructions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Instructions:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '• Sample Test: Tests with hardcoded slider/text examples\n'
                  '• Real Data: Analyzes actual answers from your database\n'
                  '• Check debug console for detailed logs\n'
                  '• Check Supabase feedback_sentiment table for stored results',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
