import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GiphyService {
  static const String _baseUrl = 'https://api.giphy.com/v1/gifs';
  static String get _apiKey => const String.fromEnvironment('GIPHY_API_KEY');
  
  // Cache to avoid repeated API calls for same sentiment
  static final Map<String, List<String>> _gifCache = {};
  static final Random _random = Random();
  
  // Sentiment keyword mappings for dynamic GIF search - optimized for humor
  static const Map<String, List<String>> _sentimentKeywords = {
    'positive': [
      'excited celebration dance',
      'epic win victory',
      'mind blown amazing',
      'chef kiss perfect',
      'fire awesome',
      'nailed it success',
      'party time celebration',
      'happy dance joy',
      'boom mic drop',
      'yes finally won',
      'clapping applause bravo',
      'thumbs up approve'
    ],
    'neutral': [
      'confused shrug dunno',
      'awkward turtle weird',
      'this is fine meme',
      'thinking hmm maybe',
      'confused math lady',
      'eh whatever okay',
      'meh indifferent shrug',
      'unsure confused thinking',
      'neutral face blank',
      'kermit tea sip',
      'side eye suspicious',
      'pikachu surprised face'
    ],
    'negative': [
      'facepalm disappointed ugh',
      'eye roll annoyed',
      'dramatic sigh tired',
      'crying sad tears',
      'frustrated angry mad',
      'oh no disaster',
      'yikes awkward cringe',
      'sad panda disappointed',
      'headache stressed out',
      'not impressed unimpressed',
      'disappointed cricket silence',
      'sad violin tiny'
    ]
  };
  
  // Curated fallback GIFs for reliability - selected for maximum humor
  static const Map<String, List<String>> _fallbackGifs = {
    'positive': [
      'https://media.giphy.com/media/KYElw07kzDspaBOwf9/giphy.gif', // Epic celebration dance
      'https://media.giphy.com/media/l0MYt5jPR6QX5pnqM/giphy.gif', // Cheering crowd
      'https://media.giphy.com/media/26u4lOMA8JKSnL9Uk/giphy.gif', // Enthusiastic thumbs up
      'https://media.giphy.com/media/3oriO0OEd9QIDdllqo/giphy.gif', // Happy dancing
      'https://media.giphy.com/media/XD9o33QG9BoMis7iM4/giphy.gif', // Mind blown reaction
      'https://media.giphy.com/media/26BRv0ThflsHCqDrG/giphy.gif', // Victory success
      'https://media.giphy.com/media/3o6fJ1BM7R2EBRDnxK/giphy.gif', // Chef's kiss
    ],
    'neutral': [
      'https://media.giphy.com/media/26FLgGTPUDH6UGAbm/giphy.gif', // Classic shrug
      'https://media.giphy.com/media/3o7TKMt1VVNkHV2PaE/giphy.gif', // Confused thinking
      'https://media.giphy.com/media/xT0xeJpnrWC4XWblEk/giphy.gif', // Meh expression
      'https://media.giphy.com/media/l3q2K5jinAlChoCLS/giphy.gif', // Hmm contemplating
      'https://media.giphy.com/media/26BRBKqUiq586bRVm/giphy.gif', // Awkward turtle
      'https://media.giphy.com/media/QBd2kLB5qDmysEXre9/giphy.gif', // This is fine meme
      'https://media.giphy.com/media/WRQBXSCnEFJIuxktnw/giphy.gif', // Confused math lady
    ],
    'negative': [
      'https://media.giphy.com/media/XeLcgh8gT8o0F5SQ8i/giphy.gif', // Epic facepalm
      'https://media.giphy.com/media/Fjr6v88OPk7U4/giphy.gif', // Eye roll
      'https://media.giphy.com/media/ISOckXUybVfQ4/giphy.gif', // Dramatic crying
      'https://media.giphy.com/media/26uf759LlDftqZNVm/giphy.gif', // Disappointed sigh
      'https://media.giphy.com/media/3o6ZtokcdBGqmlgTiE/giphy.gif', // Frustrated reaction
      'https://media.giphy.com/media/l2JhOVyjSthvXsu4g/giphy.gif', // Oh no disaster
      'https://media.giphy.com/media/26BRrSvJUa0crqw4E/giphy.gif', // Not impressed
    ],
  };

  /// Gets a random GIF based on sentiment score
  /// Returns a different GIF each time for variety and fun
  static Future<String?> getRandomSentimentGif(double sentimentScore) async {
    try {
      final sentimentCategory = _getSentimentCategory(sentimentScore);
      debugPrint('Getting random GIF for sentiment: $sentimentCategory (score: $sentimentScore)');
      
      // Try to get from API first for variety
      final apiGif = await _fetchRandomGifFromAPI(sentimentCategory);
      if (apiGif != null) {
        debugPrint('Successfully fetched GIF from API');
        return apiGif;
      }
      
      // Fallback to curated GIFs
      final fallbackGif = _getRandomFallbackGif(sentimentCategory);
      debugPrint('Using fallback GIF');
      return fallbackGif;
      
    } catch (e) {
      debugPrint('Error getting sentiment GIF: $e');
      return _getRandomFallbackGif(_getSentimentCategory(sentimentScore));
    }
  }

  /// Determines sentiment category from score
  /// Score range: 0-100 (converted from -1 to 1 sentiment scale)
  /// 50 = neutral (0 on -1 to 1 scale)
  /// Thresholds align with SessionSentimentSummary.sentimentLabel logic:
  /// - 0.3 on -1 to 1 scale = 65 on 0-100 scale 
  /// - -0.3 on -1 to 1 scale = 35 on 0-100 scale
  static String _getSentimentCategory(double score) {
    if (score >= 65) return 'positive';  // Above 0.3 on -1 to 1 scale = positive
    if (score >= 35) return 'neutral';   // Between -0.3 and 0.3 = neutral  
    return 'negative';                   // Below -0.3 on -1 to 1 scale = negative
  }

  /// Fetches a random GIF from Giphy API based on sentiment category
  static Future<String?> _fetchRandomGifFromAPI(String sentimentCategory) async {
    try {
      if (_apiKey.isEmpty) {
        debugPrint('Giphy API key not configured, using fallback GIFs');
        return null;
      }

      // Get random keywords for this sentiment
      final keywords = _sentimentKeywords[sentimentCategory];
      if (keywords == null || keywords.isEmpty) return null;
      
      final randomKeyword = keywords[_random.nextInt(keywords.length)];
      
      // Search for GIFs with random offset for variety - prioritize funny content
      final offset = _random.nextInt(50); // Random offset up to 50 for variety
      final url = '$_baseUrl/search?api_key=$_apiKey&q=$randomKeyword funny&limit=10&offset=$offset&rating=g&lang=en';
      
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final gifs = data['data'] as List;
        
        if (gifs.isNotEmpty) {
          // Get random GIF from results
          final randomGif = gifs[_random.nextInt(gifs.length)];
          final gifUrl = randomGif['images']['fixed_height']['url'];
          
          // Cache this result
          if (!_gifCache.containsKey(sentimentCategory)) {
            _gifCache[sentimentCategory] = [];
          }
          _gifCache[sentimentCategory]!.add(gifUrl);
          
          return gifUrl;
        }
      }
      
      debugPrint('API request failed with status: ${response.statusCode}');
      return null;
      
    } catch (e) {
      debugPrint('Error fetching GIF from API: $e');
      return null;
    }
  }

  /// Gets a random fallback GIF from curated collections
  static String _getRandomFallbackGif(String sentimentCategory) {
    final fallbackList = _fallbackGifs[sentimentCategory];
    if (fallbackList == null || fallbackList.isEmpty) {
      // Ultimate fallback - return a generic happy GIF
      return _fallbackGifs['positive']!.first;
    }
    
    return fallbackList[_random.nextInt(fallbackList.length)];
  }

  /// Clears GIF cache (useful for testing or memory management)
  static void clearCache() {
    _gifCache.clear();
    debugPrint('GIF cache cleared');
  }

  /// Gets sentiment category label for display
  /// Aligns with SessionSentimentSummary thresholds: 65/35 on 0-100 scale
  static String getSentimentLabel(double score) {
    if (score >= 65) return 'Positive';
    if (score >= 35) return 'Neutral';
    return 'Negative';
  }

  /// Gets sentiment color based on score
  /// Aligns with SessionSentimentSummary thresholds: 65/35 on 0-100 scale
  static int getSentimentColorValue(double score) {
    if (score >= 65) return 0xFF02542D; // Positive green
    if (score >= 35) return 0xFF6750A4; // Neutral purple  
    return 0xFFBA1A1A; // Negative red
  }

  /// Gets sentiment background color based on score
  /// Aligns with SessionSentimentSummary thresholds: 65/35 on 0-100 scale
  static int getSentimentBackgroundColorValue(double score) {
    if (score >= 65) return 0xFFCFF7D3; // Light green
    if (score >= 35) return 0xFFE8DEF8; // Light purple
    return 0xFFFFDAD6; // Light red
  }

  /// Preloads GIFs for better performance (optional)
  static Future<void> preloadSentimentGifs() async {
    try {
      debugPrint('Preloading sentiment GIFs...');
      
      // Preload one GIF for each sentiment category
      await Future.wait([
        _fetchRandomGifFromAPI('positive'),
        _fetchRandomGifFromAPI('neutral'), 
        _fetchRandomGifFromAPI('negative'),
      ]);
      
      debugPrint('GIF preloading completed');
    } catch (e) {
      debugPrint('Error preloading GIFs: $e');
    }
  }
}