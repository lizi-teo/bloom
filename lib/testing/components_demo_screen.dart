import 'package:flutter/material.dart';
import '../core/utils/responsive_utils.dart';
import '../core/components/molecules/decoration_tape.dart';
import '../core/components/atoms/sentiment_score.dart';
import '../core/components/atoms/template_question_score.dart';
import '../core/components/atoms/suggestion_chip.dart';
import '../features/results/dynamic_results_page.dart';
import 'sentiment_gif_demo_screen.dart';

class ComponentsDemoScreen extends StatefulWidget {
  const ComponentsDemoScreen({super.key});

  static const String routeName = '/components-demo';

  @override
  State<ComponentsDemoScreen> createState() => _ComponentsDemoScreenState();
}

class _ComponentsDemoScreenState extends State<ComponentsDemoScreen> {
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
            // Content section with description
            Container(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Header Components Demo',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'This page demonstrates various atom components with different configurations:',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Feature list
                  _buildFeatureList(context),

                  const SizedBox(height: 32),

                  // Screen size info
                  _buildScreenSizeInfo(context),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Dynamic Results Page Navigation Section
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🎯 Dynamic Results Page Demo',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'View the complete dynamic results page with all components integrated:',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const DynamicResultsPage(
                                  sessionId: 1,
                                  templateId: 1,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.assessment),
                          label: const Text('View Session 1 Results'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const DynamicResultsPage(
                                  sessionId: 12,
                                  templateId: 2,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.analytics),
                          label: const Text('View Session 12 Results'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: colorScheme.secondary,
                            foregroundColor: colorScheme.onSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Features demonstrated:',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Overall average calculation across all users\n'
                          '• Per-question average display\n'
                          '• Dynamic image loading in decoration tape\n'
                          '• Responsive layout design\n'
                          '• Real-time data from Supabase',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // Atom Components Section
            Container(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Atom Components',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Small, reusable UI components that form the foundation of the design system:',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Score Components Demo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Score Components',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Different score display styles for various contexts:',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Score components row 1
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          const SentimentScore(score: '95', sentimentType: SentimentType.positive),
                          const SizedBox(height: 8),
                          Text(
                            'Positive Score',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const SentimentScore(score: '67', sentimentType: SentimentType.neutral),
                          const SizedBox(height: 8),
                          Text(
                            'Neutral Score',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const SentimentScore(score: '35', sentimentType: SentimentType.negative),
                          const SizedBox(height: 8),
                          Text(
                            'Negative Score',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const TemplateQuestionScore(score: '78'),
                          const SizedBox(height: 8),
                          Text(
                            'Template Score',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Score components row 2 - Different sizes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          const SentimentScore(score: '100', sentimentType: SentimentType.positive, size: 80),
                          const SizedBox(height: 8),
                          Text(
                            'Large Positive',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const SentimentScore(score: '50', sentimentType: SentimentType.neutral, size: 80),
                          const SizedBox(height: 8),
                          Text(
                            'Large Neutral',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const SentimentScore(score: '15', sentimentType: SentimentType.negative, size: 80),
                          const SizedBox(height: 8),
                          Text(
                            'Large Negative',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const TemplateQuestionScore(score: '82', size: 80),
                          const SizedBox(height: 8),
                          Text(
                            'Large Template',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Sentiment GIF Container Demo Button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SentimentGifDemoScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.animation),
                      label: const Text('View Sentiment GIF Container Demo'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // Suggestion Chips Section
            Container(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Suggestion Chips',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Interactive chips for displaying key findings and insights:',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Single chips row
                  Wrap(
                    spacing: 12.0,
                    runSpacing: 12.0,
                    children: [
                      SuggestionChip(
                        label: 'high energy',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Selected: high energy'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                      SuggestionChip(
                        label: 'collaboration',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Selected: collaboration'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                      SuggestionChip(
                        label: 'focused',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Selected: focused'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                      SuggestionChip(
                        label: 'innovative thinking',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Selected: innovative thinking'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                      SuggestionChip(
                        label: 'team spirit',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Selected: team spirit'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                      const SuggestionChip(
                        label: 'stressed (non-interactive)',
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description of chip functionality
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Features:',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Uses theme colors (secondaryContainer/onSecondaryContainer)\n'
                          '• Matches Figma design: 8px border radius, 32px height\n'
                          '• Roboto Medium typography with 0.1 letter spacing\n'
                          '• Optional onPressed callback for interactivity\n'
                          '• Responsive tap areas with Material InkWell',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // Decorations Section
            Container(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Decoration Tape Components',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Decoration tape components that extract dominant colors from images and apply them as backgrounds:',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Decoration Tape Demo 1: Heart image (pink/red tones expected)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Example 1: Heart Template Image',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Background color extracted from heart image',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            const DecorationTape(
              imageUrl: 'https://ytuvkzwftndxqkpjltcg.supabase.co/storage/v1/object/sign/template-images/heart.png?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV8xNzQ0MGQ1OC02ZDA2LTQxYzAtYTkwMS05NmY1ODQ1ZGNmZjQiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJ0ZW1wbGF0ZS1pbWFnZXMvaGVhcnQucG5nIiwiaWF0IjoxNzU2NjM5NDMwLCJleHAiOjE3ODgxNzU0MzB9.H4ynXp3o9nAps8VQNMYaXPHZlWE2U9jIdqT3EyRKB9g',
            ),

            const SizedBox(height: 32),

            // Decoration Tape Demo 2: Balance image (different color tones)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Example 2: Balance Template Image',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Background color extracted from balance scales image',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            const DecorationTape(
              imageUrl: 'https://ytuvkzwftndxqkpjltcg.supabase.co/storage/v1/object/sign/template-images/balance.png?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV8xNzQ0MGQ1OC02ZDA2LTQxYzAtYTkwMS05NmY1ODQ1ZGNmZjQiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJ0ZW1wbGF0ZS1pbWFnZXMvYmFsYW5jZS5wbmciLCJpYXQiOjE3NTY1NTczNjgsImV4cCI6MTc4ODA5MzM2OH0.Ek0UzUJDNxG1khNpKXV6xjbPyWXTf4zt37b_-3BsrA8',
            ),

            const SizedBox(height: 48),

            const SizedBox(height: 48),
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

  Widget _buildFeatureList(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final features = [
      'Compact/Medium: Centered icon above title (100dp icon)',
      'Expanded: Title on left, larger icon on right (200dp icon)',
      'Responsive typography: 45sp (compact/medium) → 57sp (expanded)',
      'Responsive spacing based on Material Design 3 guidelines',
      'Customizable colors and fallback heart icon',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features
          .map((feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 8, right: 12),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        feature,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildScreenSizeInfo(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenSize = getScreenSize(context);
    final width = MediaQuery.of(context).size.width;

    String sizeDescription;
    String layoutDescription;

    switch (screenSize) {
      case ScreenSize.compact:
        sizeDescription = 'Compact (< 600dp)';
        layoutDescription = 'Mobile layout: Centered icon and title';
        break;
      case ScreenSize.medium:
        sizeDescription = 'Medium (600-959dp)';
        layoutDescription = 'Tablet layout: Centered icon and title';
        break;
      case ScreenSize.expanded:
        sizeDescription = 'Expanded (≥ 960dp)';
        layoutDescription = 'Desktop layout: Title left, icon right';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
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
          Text(
            'Current Screen Size',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$sizeDescription (${width.toInt()}dp)',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            layoutDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Resize your browser window to see the responsive behavior.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
