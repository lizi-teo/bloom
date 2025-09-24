import 'package:flutter/material.dart';
import '../../services/synthesis_service.dart';
import '../../services/giphy_service.dart';
import '../../utils/responsive_utils.dart';
import '../../themes/spacing_theme.dart';
import '../../themes/app_theme.dart';
import '../../themes/design_tokens.dart';
import '../atoms/sentiment_gif_container.dart';

class SimpleResultsCard extends StatefulWidget {
  final int sessionId;

  const SimpleResultsCard({
    super.key,
    required this.sessionId,
  });

  @override
  State<SimpleResultsCard> createState() => _SimpleResultsCardState();
}

class _SimpleResultsCardState extends State<SimpleResultsCard> {
  bool _isLoading = true;
  SessionSynthesis? _sessionSynthesis;
  String? _error;
  String? _performanceGifUrl;
  bool _isLoadingNewGif = false;

  @override
  void initState() {
    super.initState();
    _loadSessionSynthesis();
  }

  Future<void> _loadSessionSynthesis() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final synthesis = await SynthesisService.analyzeSession(widget.sessionId);

      if (mounted) {
        setState(() {
          _sessionSynthesis = synthesis;
          _isLoading = false;
        });

        // Load performance GIF after synthesis is loaded
        await _loadPerformanceGif(synthesis.performanceSummary);
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

  double _performanceToSentimentScore(String performance) {
    switch (performance) {
      case 'Highly Effective':
        return 85.0; // Maps to positive sentiment
      case 'Effective':
        return 60.0; // Maps to neutral-positive sentiment
      case 'Mixed Results':
        return 45.0; // Maps to neutral sentiment
      case 'Room for Growth':
        return 20.0; // Maps to negative sentiment
      case 'No Ratings':
        return 45.0; // Maps to neutral sentiment
      default:
        return 45.0; // Default to neutral
    }
  }

  Future<void> _loadPerformanceGif(String performance) async {
    try {
      final sentimentScore = _performanceToSentimentScore(performance);
      final gifUrl = await GiphyService.getRandomSentimentGif(sentimentScore);

      if (mounted && gifUrl != null) {
        setState(() {
          _performanceGifUrl = gifUrl;
        });
      }
    } catch (e) {
      debugPrint('Error loading performance GIF: $e');
      // Let _performanceGifUrl remain null to show placeholder
    }
  }

  void _onGifTap() async {
    if (_sessionSynthesis == null || _isLoadingNewGif) return;

    setState(() {
      _isLoadingNewGif = true;
    });

    try {
      final sentimentScore = _performanceToSentimentScore(_sessionSynthesis!.performanceSummary);
      final newGifUrl = await GiphyService.getRandomSentimentGif(sentimentScore);

      if (mounted && newGifUrl != null) {
        setState(() {
          _performanceGifUrl = newGifUrl;
          _isLoadingNewGif = false;
        });
      } else {
        setState(() {
          _isLoadingNewGif = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading new GIF: $e');
      if (mounted) {
        setState(() {
          _isLoadingNewGif = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenSize = getScreenSize(context);

    if (_isLoading) {
      return Center(
        child: Padding(
          padding: _getResponsivePadding(screenSize, context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: colorScheme.primary),
              SizedBox(height: context.spacing.lg),
              Text(
                'Analyzing results...',
                style: theme.textTheme.bodyMedium?.copyWith(
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
            'Error loading results: $_error',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final synthesis = _sessionSynthesis!;

    if (synthesis.totalResponses == 0) {
      return Center(
        child: Padding(
          padding: _getResponsivePadding(screenSize, context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'No feedback to analyze yet',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.spacing.sm),
              Text(
                'Once participants submit their responses, insights will appear here.',
                style: theme.textTheme.bodyMedium?.copyWith(
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
        // Overall Results Card
        _buildOverallResultsCard(theme, synthesis),

        // Individual Question Cards
        ...synthesis.questionResults.map((questionResult) => Column(
          children: [
            SizedBox(height: _getResponsiveCardSpacing(screenSize, context)),
            _buildQuestionCard(theme, questionResult),
          ],
        )),
      ],
    );
  }

  Widget _buildOverallResultsCard(ThemeData theme, SessionSynthesis synthesis) {
    final colorScheme = theme.colorScheme;
    final screenSize = getScreenSize(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.all(DesignTokens.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Performance GIF
          Align(
            alignment: Alignment.centerLeft,
            child: SentimentGifContainer(
              gifUrl: _performanceGifUrl,
              size: _getResponsiveGifSize(screenSize),
              borderRadius: 16.0,
              showAnimation: true,
              onTap: _onGifTap,
            ),
          ),
          SizedBox(height: context.spacing.lg),

          // Title
          Text(
            'Overall results',
            style: _getTitleStyle(screenSize, theme).copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: context.spacing.lg),

          // Performance summary with icon
          Row(
            children: [
              _getPerformanceIcon(synthesis.performanceSummary, colorScheme),
              SizedBox(width: context.spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      synthesis.performanceSummary,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: _getPerformanceColor(synthesis.performanceSummary, colorScheme),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildDistributionItem(String label, int count, Color color, int total) {
    final percentage = total > 0 ? count / total : 0.0;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    widthFactor: percentage,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: context.spacing.sm),
              SizedBox(
                width: 24,
                child: Text(
                  '$count',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildQuestionCard(ThemeData theme, QuestionResult questionResult) {
    final colorScheme = theme.colorScheme;
    final screenSize = getScreenSize(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.all(DesignTokens.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and response count
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${questionResult.responseCount} participant${questionResult.responseCount == 1 ? '' : 's'} responded',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                    SizedBox(height: context.spacing.sm),
                    Text(
                      questionResult.title,
                      style: _getTitleStyle(screenSize, theme).copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: context.spacing.md),
            ],
          ),

          // Question text if available
          if (questionResult.questionText.isNotEmpty) ...[
            SizedBox(height: context.spacing.md),
            Text(
              questionResult.questionText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ],

          SizedBox(height: context.spacing.xl),

          // Question-specific content
          if (questionResult.componentType == 'slider' && questionResult.sliderAnalysis != null)
            _buildQuestionSliderAnalysis(theme, questionResult.sliderAnalysis!)
          else if (questionResult.componentType == 'text' && questionResult.textResponses != null)
            _buildQuestionTextResponses(theme, questionResult.textResponses!),
        ],
      ),
    );
  }

  Widget _buildQuestionSliderAnalysis(ThemeData theme, SliderAnalysis analysis) {
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: context.spacing.xl),
        Text(
          'Results',
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
        SizedBox(height: context.spacing.lg),

        // Distribution bars (smaller version for individual questions)
        _buildDistributionItem('Excellent', analysis.excellentCount, colorScheme.success, analysis.totalCount),
        SizedBox(height: context.spacing.sm),
        _buildDistributionItem('Needs Improvement', analysis.needsImprovementCount, colorScheme.caution, analysis.totalCount),
        SizedBox(height: context.spacing.sm),
        _buildDistributionItem('Poor', analysis.poorCount, colorScheme.critical, analysis.totalCount),
      ],
    );
  }

  Widget _buildQuestionTextResponses(ThemeData theme, List<String> responses) {
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Participant Responses',
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.spacing.lg),

        // Show all responses
        ...responses.map((response) => _buildTextResponseItem(theme, response)),
      ],
    );
  }

  Widget _buildTextResponseItem(ThemeData theme, String response) {
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: context.spacing.sm),
      padding: EdgeInsets.all(context.spacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: colorScheme.outline, width: 3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.format_quote,
            size: 16,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          SizedBox(width: context.spacing.sm),
          Expanded(
            child: Text(
              response,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }




  Widget _getPerformanceIcon(String performance, ColorScheme colorScheme) {
    IconData iconData;
    Color iconColor;

    switch (performance) {
      case 'Highly Effective':
        iconData = Icons.trending_up;
        iconColor = colorScheme.success;
        break;
      case 'Effective':
        iconData = Icons.thumb_up;
        iconColor = colorScheme.positive;
        break;
      case 'Room for Growth':
        iconData = Icons.lightbulb_outline;
        iconColor = colorScheme.caution;
        break;
      case 'Mixed Results':
        iconData = Icons.horizontal_rule;
        iconColor = colorScheme.onSurfaceVariant;
        break;
      default:
        iconData = Icons.help_outline;
        iconColor = colorScheme.onSurfaceVariant;
        break;
    }

    return Icon(iconData, color: iconColor, size: 32);
  }

  Color _getPerformanceColor(String performance, ColorScheme colorScheme) {
    switch (performance) {
      case 'Highly Effective':
        return colorScheme.success;
      case 'Effective':
        return colorScheme.positive;
      case 'Room for Growth':
        return colorScheme.caution;
      case 'Mixed Results':
        return colorScheme.onSurfaceVariant;
      default:
        return colorScheme.onSurface;
    }
  }

  // Helper methods for responsive design
  TextStyle _getTitleStyle(ScreenSize screenSize, ThemeData theme) {
    switch (screenSize) {
      case ScreenSize.compact:
        return theme.textTheme.headlineSmall!;
      case ScreenSize.medium:
        return theme.textTheme.headlineMedium!;
      case ScreenSize.expanded:
        return theme.textTheme.headlineLarge!;
    }
  }

  EdgeInsets _getResponsivePadding(ScreenSize screenSize, BuildContext context) {
    final spacing = context.spacing;
    switch (screenSize) {
      case ScreenSize.compact:
        return EdgeInsets.all(spacing.lgPlus);  // 20px
      case ScreenSize.medium:
        return EdgeInsets.all(spacing.xl);      // 24px
      case ScreenSize.expanded:
        return EdgeInsets.all(spacing.xxl);     // 32px
    }
  }

  double _getResponsiveCardSpacing(ScreenSize screenSize, BuildContext context) {
    final spacing = context.spacing;
    switch (screenSize) {
      case ScreenSize.compact:
        return spacing.xl;      // 24px
      case ScreenSize.medium:
        return spacing.xl;      // 24px
      case ScreenSize.expanded:
        return spacing.xxl;     // 32px
    }
  }


  double _getResponsiveGifSize(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.compact:
        return 100.0;
      case ScreenSize.medium:
        return 120.0;
      case ScreenSize.expanded:
        return 140.0;
    }
  }
}