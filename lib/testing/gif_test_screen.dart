import 'package:flutter/material.dart';
import '../core/services/giphy_service.dart';
import '../core/components/atoms/sentiment_gif_container.dart';

class GifTestScreen extends StatefulWidget {
  const GifTestScreen({super.key});

  static const String routeName = '/gif-test';

  @override
  State<GifTestScreen> createState() => _GifTestScreenState();
}

class _GifTestScreenState extends State<GifTestScreen> {
  String? _positiveGif;
  String? _neutralGif;
  String? _negativeGif;

  bool _loadingPositive = false;
  bool _loadingNeutral = false;
  bool _loadingNegative = false;

  @override
  void initState() {
    super.initState();
    _loadAllGifs();
  }

  Future<void> _loadAllGifs() async {
    // Load one GIF for each sentiment category
    await Future.wait([
      _loadPositiveGif(),
      _loadNeutralGif(),
      _loadNegativeGif(),
    ]);
  }

  Future<void> _loadPositiveGif() async {
    setState(() => _loadingPositive = true);
    try {
      final gif = await GiphyService.getRandomSentimentGif(85.0); // High positive score
      setState(() {
        _positiveGif = gif;
        _loadingPositive = false;
      });
    } catch (e) {
      setState(() => _loadingPositive = false);
      debugPrint('Error loading positive GIF: $e');
    }
  }

  Future<void> _loadNeutralGif() async {
    setState(() => _loadingNeutral = true);
    try {
      final gif = await GiphyService.getRandomSentimentGif(55.0); // Neutral score
      setState(() {
        _neutralGif = gif;
        _loadingNeutral = false;
      });
    } catch (e) {
      setState(() => _loadingNeutral = false);
      debugPrint('Error loading neutral GIF: $e');
    }
  }

  Future<void> _loadNegativeGif() async {
    setState(() => _loadingNegative = true);
    try {
      final gif = await GiphyService.getRandomSentimentGif(25.0); // Low negative score
      setState(() {
        _negativeGif = gif;
        _loadingNegative = false;
      });
    } catch (e) {
      setState(() => _loadingNegative = false);
      debugPrint('Error loading negative GIF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic GIF Test'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dynamic Sentiment GIF Testing',
                style: theme.textTheme.headlineMedium,
              ),
              SizedBox(height: 8.0),
              Text(
                'Each GIF should be different every time you refresh. Tap any GIF to reload it!',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 32.0),

              // Positive Sentiment
              _buildSentimentCard(
                title: 'Positive Sentiment (Score: 85)',
                description: 'Happy, celebration, success GIFs',
                gifUrl: _positiveGif,
                isLoading: _loadingPositive,
                onRefresh: _loadPositiveGif,
                color: const Color(0xFF02542D),
                backgroundColor: const Color(0xFFCFF7D3),
              ),

              SizedBox(height: 24.0),

              // Neutral Sentiment
              _buildSentimentCard(
                title: 'Neutral Sentiment (Score: 55)',
                description: 'Thinking, shrug, meh GIFs',
                gifUrl: _neutralGif,
                isLoading: _loadingNeutral,
                onRefresh: _loadNeutralGif,
                color: theme.colorScheme.primary,
                backgroundColor: theme.colorScheme.primaryContainer,
              ),

              SizedBox(height: 24.0),

              // Negative Sentiment
              _buildSentimentCard(
                title: 'Negative Sentiment (Score: 25)',
                description: 'Disappointed, concerned, sad GIFs',
                gifUrl: _negativeGif,
                isLoading: _loadingNegative,
                onRefresh: _loadNegativeGif,
                color: theme.colorScheme.error,
                backgroundColor: theme.colorScheme.errorContainer,
              ),

              SizedBox(height: 32.0),

              // Refresh All Button
              Center(
                child: ElevatedButton.icon(
                  onPressed: _loadAllGifs,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh All GIFs'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16.0),

              // Clear Cache Button
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    GiphyService.clearCache();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('GIF cache cleared!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear GIF Cache'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSentimentCard({
    required String title,
    required String description,
    required String? gifUrl,
    required bool isLoading,
    required VoidCallback onRefresh,
    required Color color,
    required Color backgroundColor,
  }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: onRefresh,
                  icon: Icon(
                    Icons.refresh,
                    color: color,
                  ),
                  tooltip: 'Load new random GIF',
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            SizedBox(height: 16.0),
            Center(
              child: SentimentGifContainer(
                size: 120,
                borderRadius: 16.0,
                gifUrl: gifUrl,
                showAnimation: !isLoading,
                onTap: () async {
                  onRefresh();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Loading new ${title.toLowerCase().split(' ')[0]} GIF...'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),
            if (isLoading) ...[
              SizedBox(height: 8.0),
              Center(
                child: Text(
                  'Loading new GIF...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
