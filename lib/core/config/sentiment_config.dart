/// Configuration for sentiment analysis features
/// Controls which analysis methods are used for different component types
class SentimentConfig {
  // Feature flags for sentiment analysis approaches
  static const bool useRuleBasedSliders = true;
  static const bool useAIForLongText = true;
  static const int minWordsForAI = 10;
  
  // Fallback configuration
  static const bool fallbackToAI = false; // Start with false for safer rollout
  static const bool enableDetailedLogging = true;
  
  // Performance optimization
  static const int maxConcurrentAnalyses = 5;
  static const Duration analysisTimeout = Duration(seconds: 10);
  
  // Sentiment scoring thresholds (on -1 to 1 scale)
  static const double positiveThreshold = 0.3;
  static const double negativeThreshold = -0.3;
  
  // Slider scoring configuration
  static const Map<String, double> sliderSentimentMapping = {
    '90-100': 1.0,    // Excellent
    '80-89': 0.6,     // Very good
    '70-79': 0.3,     // Good
    '60-69': 0.1,     // Fair
    '40-59': -0.1,    // Needs improvement
    '0-39': -0.6,     // Poor
  };
  
  // Text analysis keywords for short responses
  static const List<String> positiveKeywords = [
    'good', 'great', 'excellent', 'amazing', 'awesome', 'fantastic',
    'helpful', 'clear', 'effective', 'perfect', 'love', 'brilliant',
    'outstanding', 'wonderful', 'impressed', 'satisfied', 'pleased'
  ];
  
  static const List<String> negativeKeywords = [
    'bad', 'poor', 'terrible', 'awful', 'horrible', 'disappointing',
    'confusing', 'unclear', 'boring', 'ineffective', 'hate', 'frustrated',
    'annoying', 'useless', 'waste', 'disappointed', 'unhappy'
  ];
  
  static const List<String> neutralKeywords = [
    'okay', 'fine', 'average', 'normal', 'standard', 'typical',
    'adequate', 'acceptable', 'moderate', 'fair', 'decent'
  ];
  
  // Scale direction detection keywords
  static const List<String> negativeScaleWords = [
    'poor', 'bad', 'never', 'not', 'needs', 'lacking', 'insufficient',
    'weak', 'low', 'minimal', 'none', 'zero', 'absent'
  ];
  
  static const List<String> positiveScaleWords = [
    'excellent', 'good', 'always', 'fully', 'great', 'strong',
    'high', 'maximum', 'complete', 'perfect', 'outstanding'
  ];
  
  /// Determines if rule-based analysis should be used for the given component type
  static bool shouldUseRuleBased(String componentType) {
    switch (componentType.toLowerCase()) {
      case 'slider':
        return useRuleBasedSliders;
      case 'text':
        return false; // Always evaluate text length first
      default:
        return false;
    }
  }
  
  /// Determines if AI analysis should be used for text based on content
  static bool shouldUseAI(String text, String componentType) {
    if (componentType.toLowerCase() != 'text') return false;
    if (!useAIForLongText) return false;
    
    final wordCount = text.trim().split(RegExp(r'\s+')).length;
    return wordCount >= minWordsForAI;
  }
  
  /// Gets sentiment score range for slider value
  static double getSliderSentimentScore(int sliderValue) {
    if (sliderValue >= 90) return sliderSentimentMapping['90-100']!;
    if (sliderValue >= 80) return sliderSentimentMapping['80-89']!;
    if (sliderValue >= 70) return sliderSentimentMapping['70-79']!;
    if (sliderValue >= 60) return sliderSentimentMapping['60-69']!;
    if (sliderValue >= 40) return sliderSentimentMapping['40-59']!;
    return sliderSentimentMapping['0-39']!;
  }
  
  /// Gets sentiment label from score
  static String getSentimentLabel(double sentimentScore) {
    if (sentimentScore > positiveThreshold) return 'positive';
    if (sentimentScore < negativeThreshold) return 'negative';
    if (sentimentScore.abs() < 0.1) return 'neutral';
    return 'mixed';
  }
  
  /// Determines scale direction from labels
  static String getScaleDirection(String minLabel, String maxLabel) {
    final minLower = minLabel.toLowerCase();
    final maxLower = maxLabel.toLowerCase();
    
    // Check if min label contains negative words (suggesting positive_high scale)
    final minHasNegative = negativeScaleWords.any((word) => minLower.contains(word));
    
    // Check if max label contains positive words (suggesting positive_high scale)
    final maxHasPositive = positiveScaleWords.any((word) => maxLower.contains(word));
    
    if (minHasNegative || maxHasPositive) {
      return 'positive_high'; // Higher values = more positive
    }
    
    // Check for negative_high scale (rare but possible)
    final minHasPositive = positiveScaleWords.any((word) => minLower.contains(word));
    final maxHasNegative = negativeScaleWords.any((word) => maxLower.contains(word));
    
    if (minHasPositive || maxHasNegative) {
      return 'negative_high'; // Higher values = more negative
    }
    
    // Default assumption: positive_high
    return 'positive_high';
  }
}