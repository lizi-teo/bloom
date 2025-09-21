import 'package:flutter/material.dart';
import '../core/components/molecules/slider_card.dart';
import '../core/components/molecules/text_field_card.dart';
import '../core/components/molecules/enhanced_results_sheet.dart';
import '../core/components/molecules/session_list_card.dart';
import '../core/components/molecules/session_qr_code_card.dart';
import '../core/components/atoms/suggestion_chip.dart';

class CardsDemoScreen extends StatefulWidget {
  const CardsDemoScreen({super.key});

  static const String routeName = '/cards-demo';

  @override
  State<CardsDemoScreen> createState() => _CardsDemoScreenState();
}

class _CardsDemoScreenState extends State<CardsDemoScreen> {
  int _sliderValue = 50;
  String _textValue = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Cards Demo'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: Container(
        // Force dark background to test card visibility
        color: const Color(0xFF121212), // Dark background
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Molecule Components Demo',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Testing cards on dark background to verify colors',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Session List Card Demo
                SessionListCard(
                  sessionName: 'Team Retrospective',
                  submissionsCount: '12 submissions',
                  imageBackgroundColor: const Color(0xFF836BE9),
                  imageWidget: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 32,
                  ),
                  primaryActionLabel: 'View',
                  secondaryActionLabel: 'Edit',
                  onPrimaryAction: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('View session pressed'),
                      ),
                    );
                  },
                  onSecondaryAction: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Edit session pressed'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Another Session List Card without secondary action
                SessionListCard(
                  sessionName: 'Daily Standup Check-in',
                  submissionsCount: '5 submissions',
                  imageBackgroundColor: theme.colorScheme.tertiary,
                  primaryActionLabel: 'Open',
                  showSecondaryAction: false,
                  onPrimaryAction: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Open session pressed'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Slider Card Demo
                SliderCard(
                  questionTitle: 'Energy Level',
                  questionName: 'How energized do you feel right now?',
                  minLabel: 'Low',
                  maxLabel: 'High',
                  value: _sliderValue,
                  onChanged: (value) {
                    setState(() {
                      _sliderValue = value;
                    });
                  },
                  min: 0,
                  max: 100,
                ),
                const SizedBox(height: 24),

                // Text Field Card Demo
                TextFieldCard(
                  questionTitle: 'Daily Reflection',
                  questionName: 'What was the highlight of your day?',
                  hintText: 'Share your thoughts...',
                  initialValue: _textValue,
                  onChanged: (value) {
                    setState(() {
                      _textValue = value;
                    });
                  },
                  maxLength: 500,
                ),
                const SizedBox(height: 24),

                // Another Slider Card with different values
                SliderCard(
                  questionTitle: 'Stress Level',
                  questionName: 'How stressed do you feel today?',
                  minLabel: 'Calm',
                  maxLabel: 'Very Stressed',
                  value: 25,
                  onChanged: (value) {
                    // Demo card - no state change needed
                  },
                  min: 0,
                  max: 100,
                ),
                const SizedBox(height: 24),

                // Another Text Field Card
                TextFieldCard(
                  questionTitle: 'Goals',
                  questionName: 'What do you want to accomplish tomorrow?',
                  hintText: 'List your goals...',
                  initialValue: '',
                  onChanged: (value) {
                    // Demo card - no state change needed
                  },
                  maxLines: 5,
                  maxLength: 300,
                ),
                const SizedBox(height: 24),

                // Enhanced Results Card Demo (combines Results + Sentiment)
                EnhancedResultsCard(
                  sessionId: 1,
                ),
                const SizedBox(height: 24),

                // Session QR Code Card Demo
                SessionQrCodeCard(
                  title: 'Thanks for helping me improve',
                  subtitle: 'This is anonymous and takes ~60 seconds',
                  instructionText: 'Please scan the QR code below or copy the link to access the feedback form.',
                  participantAccessUrl: 'https://bloom-app.example.com/session/ABC123',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('QR Code card tapped!'),
                        backgroundColor: colorScheme.primary,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Suggestion Chips Demo Section
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Key Insights',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Based on responses, here are the key themes:',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [
                          SuggestionChip(
                            label: 'high energy',
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Insight selected: high energy'),
                                ),
                              );
                            },
                          ),
                          SuggestionChip(
                            label: 'focused',
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Insight selected: focused'),
                                ),
                              );
                            },
                          ),
                          const SuggestionChip(
                            label: 'motivated',
                          ),
                          const SuggestionChip(
                            label: 'collaborative',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Information panel
                Container(
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.only(top: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Card Color Test',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This page uses a dark background (0xFF121212) to test how the molecule components appear. The cards should have proper contrast and be easily readable.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Current slider value: $_sliderValue',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
