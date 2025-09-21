import 'package:flutter/material.dart';
import '../core/components/atoms/sentiment_gif_container.dart';

class SentimentGifDemoScreen extends StatefulWidget {
  const SentimentGifDemoScreen({super.key});

  @override
  State<SentimentGifDemoScreen> createState() => _SentimentGifDemoScreenState();
}

class _SentimentGifDemoScreenState extends State<SentimentGifDemoScreen> {
  bool _showAnimation = true;
  double _containerSize = 150;
  double _borderRadius = 20;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sentiment GIF Container'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Simple GIF Container',
                style: theme.textTheme.headlineMedium,
              ),
              SizedBox(height: 8.0),
              Text(
                'A clean container for displaying sentiment GIFs',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 32.0),

              // Main display
              Center(
                child: SentimentGifContainer(
                  size: _containerSize,
                  borderRadius: _borderRadius,
                  showAnimation: _showAnimation,
                  gifUrl: 'https://media.giphy.com/media/XD9o33QG9BoMis7iM4/giphy.gif',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('GIF container tapped!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 32.0),

              // Controls
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Container Settings',
                        style: theme.textTheme.titleMedium,
                      ),
                      SizedBox(height: 16.0),

                      // Size slider
                      Text('Size: ${_containerSize.toStringAsFixed(0)}px', style: theme.textTheme.bodyMedium),
                      Slider(
                        value: _containerSize,
                        min: 80,
                        max: 300,
                        divisions: 44,
                        label: _containerSize.toStringAsFixed(0),
                        onChanged: (value) {
                          setState(() {
                            _containerSize = value;
                          });
                        },
                      ),

                      SizedBox(height: 8.0),

                      // Border radius slider
                      Text('Border Radius: ${_borderRadius.toStringAsFixed(0)}px', style: theme.textTheme.bodyMedium),
                      Slider(
                        value: _borderRadius,
                        min: 0,
                        max: 50,
                        divisions: 50,
                        label: _borderRadius.toStringAsFixed(0),
                        onChanged: (value) {
                          setState(() {
                            _borderRadius = value;
                          });
                        },
                      ),

                      SizedBox(height: 8.0),

                      // Animation toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Gentle Animation',
                            style: theme.textTheme.bodyMedium,
                          ),
                          Switch(
                            value: _showAnimation,
                            onChanged: (value) {
                              setState(() {
                                _showAnimation = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24.0),

              // Example GIFs
              Text(
                'Example Sentiment GIFs',
                style: theme.textTheme.headlineSmall,
              ),
              SizedBox(height: 16.0),

              // Happy sentiment
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Happy',
                        style: theme.textTheme.titleMedium,
                      ),
                      SizedBox(height: 12.0),
                      Center(
                        child: SentimentGifContainer(
                          size: 120,
                          showAnimation: _showAnimation,
                          gifUrl: 'https://media.giphy.com/media/XD9o33QG9BoMis7iM4/giphy.gif',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16.0),

              // Neutral sentiment
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Neutral',
                        style: theme.textTheme.titleMedium,
                      ),
                      SizedBox(height: 12.0),
                      Center(
                        child: SentimentGifContainer(
                          size: 120,
                          showAnimation: _showAnimation,
                          gifUrl: 'https://media.giphy.com/media/3o7TKMt1VVNkHV2PaE/giphy.gif',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16.0),

              // Sad sentiment
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sad',
                        style: theme.textTheme.titleMedium,
                      ),
                      SizedBox(height: 12.0),
                      Center(
                        child: SentimentGifContainer(
                          size: 120,
                          showAnimation: _showAnimation,
                          gifUrl: 'https://media.giphy.com/media/ISOckXUybVfQ4/giphy.gif',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 32.0),

              // Different sizes showcase
              Text(
                'Size Variations',
                style: theme.textTheme.headlineSmall,
              ),
              SizedBox(height: 16.0),

              Wrap(
                spacing: 16.0,
                runSpacing: 16.0,
                alignment: WrapAlignment.center,
                children: [
                  SentimentGifContainer(
                    size: 60,
                    showAnimation: false,
                    borderRadius: 10,
                  ),
                  SentimentGifContainer(
                    size: 80,
                    showAnimation: false,
                    borderRadius: 15,
                  ),
                  SentimentGifContainer(
                    size: 100,
                    showAnimation: false,
                    borderRadius: 20,
                  ),
                  SentimentGifContainer(
                    size: 120,
                    showAnimation: false,
                    borderRadius: 25,
                  ),
                ],
              ),

              SizedBox(height: 32.0),

              // Without GIF (placeholder)
              Text(
                'Placeholder State',
                style: theme.textTheme.headlineSmall,
              ),
              SizedBox(height: 16.0),
              Text(
                'When no GIF URL is provided, a placeholder is shown:',
                style: theme.textTheme.bodyMedium,
              ),
              SizedBox(height: 16.0),

              Center(
                child: SentimentGifContainer(
                  size: 150,
                  showAnimation: _showAnimation,
                  // No gifUrl provided - will show placeholder
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
