import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'app_theme.dart';
import 'design_tokens.dart';
import '../components/molecules/slider_card.dart';
import '../components/molecules/text_field_card.dart';
import '../../features/sessions/models/question.dart';

/// Example app showing how to use the theme system
class ThemedApp extends StatelessWidget {
  const ThemedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Bloom App',
            theme: themeProvider.currentTheme,
            home: const ThemeExampleScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

/// Example screen demonstrating theme usage
class ThemeExampleScreen extends StatelessWidget {
  const ThemeExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Example'),
        actions: [
          PopupMenuButton<ThemeVariant>(
            icon: const Icon(Icons.palette),
            onSelected: (variant) => themeProvider.setTheme(variant),
            itemBuilder: (context) => themeProvider.availableVariants
                .map((variant) => PopupMenuItem(
                      value: variant,
                      child: Row(
                        children: [
                          Icon(
                            variant == themeProvider.currentVariant ? Icons.check : Icons.circle_outlined,
                          ),
                          const SizedBox(width: DesignTokens.spacing8),
                          Text(themeProvider.getVariantDisplayName(variant)),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Color Palette Preview
            Text(
              'Color Palette',
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: DesignTokens.spacing16),
            Wrap(
              spacing: DesignTokens.spacing8,
              runSpacing: DesignTokens.spacing8,
              children: [
                _ColorChip('Primary', context.colors.primary),
                _ColorChip('Secondary', context.colors.secondary),
                _ColorChip('Tertiary', context.colors.tertiary),
                _ColorChip('Surface', context.colors.surface),
                _ColorChip('Surface', context.colors.surface),
                _ColorChip('Error', context.colors.error),
              ],
            ),

            const SizedBox(height: DesignTokens.spacing32),

            // Typography Preview
            Text(
              'Typography',
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: DesignTokens.spacing16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Display Large', style: context.textTheme.displayLarge),
                Text('Headline Medium', style: context.textTheme.headlineMedium),
                Text('Title Large', style: context.textTheme.titleLarge),
                Text('Body Large', style: context.textTheme.bodyLarge),
                Text('Label Medium', style: context.textTheme.labelMedium),
              ],
            ),

            const SizedBox(height: DesignTokens.spacing32),

            // Button Examples
            Text(
              'Buttons',
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: DesignTokens.spacing16),
            Wrap(
              spacing: DesignTokens.spacing8,
              runSpacing: DesignTokens.spacing8,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Elevated'),
                ),
                FilledButton(
                  onPressed: () {},
                  child: const Text('Filled'),
                ),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Outlined'),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Text'),
                ),
              ],
            ),

            const SizedBox(height: DesignTokens.spacing32),

            // Card Example
            Text(
              'Card',
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: DesignTokens.spacing16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(DesignTokens.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Card Title',
                      style: context.textTheme.titleMedium,
                    ),
                    const SizedBox(height: DesignTokens.spacing8),
                    Text(
                      'This is an example card using the Material Design 3 tokens.',
                      style: context.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: DesignTokens.spacing32),

            // Input Example
            Text(
              'Input Fields',
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: DesignTokens.spacing16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Label',
                hintText: 'Enter text here',
              ),
            ),

            const SizedBox(height: DesignTokens.spacing32),

            // Slider Card Example
            Text(
              'Slider Card Component',
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: DesignTokens.spacing16),
            _SliderCardExample(),

            const SizedBox(height: DesignTokens.spacing32),

            // Text Field Card Example
            Text(
              'Text Field Card Component',
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: DesignTokens.spacing16),
            _TextFieldCardExample(),

            const SizedBox(height: DesignTokens.spacing32),

            // Current Theme Info
            Text(
              'Current Theme: ${themeProvider.getVariantDisplayName(themeProvider.currentVariant)}',
              style: context.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: themeProvider.toggleLightDark,
        child: Icon(
          themeProvider.isDark ? Icons.light_mode : Icons.dark_mode,
        ),
      ),
    );
  }
}

/// Helper widget to display color chips
class _ColorChip extends StatelessWidget {
  final String label;
  final Color color;

  const _ColorChip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: color,
        radius: 12,
      ),
      label: Text(label),
    );
  }
}

/// Example slider card component
class _SliderCardExample extends StatefulWidget {
  @override
  _SliderCardExampleState createState() => _SliderCardExampleState();
}

class _SliderCardExampleState extends State<_SliderCardExample> {
  int _clarityValue = 65;
  int _paceValue = 42;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SliderCard(
          questionTitle: 'Clarity',
          questionName: 'How clear were the goals and next steps?',
          minLabel: 'Unclear',
          maxLabel: 'Crystal clear',
          value: _clarityValue,
          onChanged: (value) {
            setState(() {
              _clarityValue = value;
            });
          },
          onChangeEnd: (value) {
            debugPrint('Clarity final value: $value');
          },
        ),
        const SizedBox(height: DesignTokens.spacing16),
        SliderCard(
          questionTitle: 'Pace',
          questionName: 'Was the pace right for the group?',
          minLabel: 'Too slow',
          maxLabel: 'Too fast',
          value: _paceValue,
          onChanged: (value) {
            setState(() {
              _paceValue = value;
            });
          },
          onChangeEnd: (value) {
            debugPrint('Pace final value: $value');
          },
        ),
      ],
    );
  }
}

/// Example text field card component
class _TextFieldCardExample extends StatefulWidget {
  @override
  _TextFieldCardExampleState createState() => _TextFieldCardExampleState();
}

class _TextFieldCardExampleState extends State<_TextFieldCardExample> {
  String _improvementResponse = '';
  String _nextRetroResponse = '';

  @override
  Widget build(BuildContext context) {
    // Create example questions from Supabase data
    final improvementQuestion = Question(
      questionId: 6,
      question: 'Describe one moment I could have handled better.',
      title: 'Improvement',
      componentTypeId: 2,
    );

    final nextRetroQuestion = Question(
      questionId: 8,
      question: 'What should I do differently in the next retrospective?',
      title: 'Next retro improvement',
      componentTypeId: 2,
    );

    return Column(
      children: [
        TextFieldCard.fromQuestion(
          question: improvementQuestion,
          initialValue: _improvementResponse,
          onChanged: (value) {
            setState(() {
              _improvementResponse = value;
            });
          },
          onSubmitted: (value) {
            debugPrint('Improvement response submitted: $value');
          },
          hintText: 'Share your thoughts on what could be improved...',
          maxLength: 500,
        ),
        const SizedBox(height: DesignTokens.spacing16),
        TextFieldCard.fromQuestion(
          question: nextRetroQuestion,
          initialValue: _nextRetroResponse,
          onChanged: (value) {
            setState(() {
              _nextRetroResponse = value;
            });
          },
          onSubmitted: (value) {
            debugPrint('Next retro response submitted: $value');
          },
          hintText: 'What changes would make the next retro better?',
          maxLength: 300,
        ),
        const SizedBox(height: DesignTokens.spacing16),
        // Show current responses
        if (_improvementResponse.isNotEmpty || _nextRetroResponse.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Responses:',
                    style: context.textTheme.titleMedium,
                  ),
                  if (_improvementResponse.isNotEmpty) ...[
                    const SizedBox(height: DesignTokens.spacing8),
                    Text('Improvement: $_improvementResponse'),
                  ],
                  if (_nextRetroResponse.isNotEmpty) ...[
                    const SizedBox(height: DesignTokens.spacing8),
                    Text('Next Retro: $_nextRetroResponse'),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}
