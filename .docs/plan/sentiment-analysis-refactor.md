# Sentiment Analysis Refactor Plan

## Current State Analysis

### Over-Engineering Assessment

The current sentiment analysis implementation is significantly over-engineered for the types of data we're processing in the Bloom app. After analyzing the codebase and actual data, several critical issues emerge:

#### Slider Questions (80% of use cases)
**Current Implementation:**
- Uses Gemini AI to analyze semantic meaning of slider labels
- Determines scale direction through LLM interpretation
- Calculates sentiment scores via AI processing
- Generates confidence scores and detailed analysis

**Reality Check:**
For questions like "Team collaboration" with 0-100 scale ("Needs more involvement" → "A valuable team player"), this is unnecessary complexity. Slider data is inherently quantitative with directly derivable sentiment based on:
- Position on scale (higher values typically = more positive)
- Simple label semantic parsing
- Basic statistical aggregation

#### Text Questions (20% of use cases)
**Current Implementation:**
- Full NLP analysis using Gemini for all text responses
- Complex sentiment extraction and theme identification
- Detailed confidence scoring and key findings generation

**Reality Check:**
Most text responses are 1-3 words ("learn coding", "something", "Take a speech class") that don't contain sufficient context for meaningful sentiment analysis.

### Poor AI Performance on Actual Data

Analysis of real responses shows questionable AI interpretations:

```
"learn coding" → negative sentiment (-0.60) with "skill gap fuels participant frustration"
"something" → neutral with "brief_response: something"
"learn to swim" → neutral with "needs improvement, unclear"
```

These are clear over-interpretations of minimal data, suggesting the AI is manufacturing insights where none exist.

### Performance and Cost Issues

**Current Problems:**
- Gemini API calls for every answer (unnecessary cost)
- Processing time: 15-30 seconds per session
- Complex error handling and timeout management
- Database storage for marginally useful AI outputs
- "Analyzing feedback with AI..." loading states that frustrate users

**Impact:**
- Slower results page load times
- Unnecessary API costs
- Complex debugging and maintenance
- User experience degradation

## Proposed Refactor Strategy

### Phase 1: Replace Slider Analysis (High Impact, Low Risk)

**Approach:**
1. **Rule-based scoring**: Map slider values directly to sentiment scale
   - 80-100 = positive (0.6 to 1.0)
   - 60-79 = neutral (0.2 to 0.6)
   - 40-59 = mixed (-0.2 to 0.2)
   - 0-39 = negative (-1.0 to -0.2)

2. **Simple label direction detection**: Use keyword matching for scale semantics
   ```dart
   String determineScaleDirection(String minLabel, String maxLabel) {
     final negativeWords = ['poor', 'bad', 'never', 'not', 'needs'];
     final positiveWords = ['excellent', 'good', 'always', 'fully', 'great'];
     
     // Simple heuristic based on label content
     if (containsWords(maxLabel, positiveWords)) return 'positive_high';
     if (containsWords(minLabel, negativeWords)) return 'positive_high';
     return 'neutral'; // Default assumption
   }
   ```

3. **Keep existing database schema** but populate with rule-based results for compatibility

**Benefits:**
- Eliminate 80% of API costs
- Instant calculation (no loading time)
- More predictable and debuggable results
- Maintain all existing UI components

### Phase 2: Simplify Text Analysis (Medium Impact, Medium Risk)

**Intelligent Filtering:**
1. **Response length thresholds:**
   - 1-9 words: Use simple keyword sentiment
   - 10+ words: Keep AI analysis (rare but valuable)
   - Empty/whitespace: Mark as no_response

2. **Keyword-based sentiment for short responses:**
   ```dart
   SentimentResult analyzeShortText(String text) {
     final words = text.toLowerCase().split(' ');
     final positiveWords = ['good', 'great', 'excellent', 'helpful', 'clear'];
     final negativeWords = ['bad', 'poor', 'confusing', 'unclear', 'boring'];
     
     int positiveCount = words.where(positiveWords.contains).length;
     int negativeCount = words.where(negativeWords.contains).length;
     
     if (positiveCount > negativeCount) return SentimentResult.positive();
     if (negativeCount > positiveCount) return SentimentResult.negative();
     return SentimentResult.neutral();
   }
   ```

3. **Focus on actual participant responses** instead of AI-generated "key findings"

**UX Improvements:**
- Show actual participant quotes prominently
- Add response quality indicators (word count, meaningfulness)
- Remove misleading AI "insights" for minimal responses

### Phase 3: Optimize Performance & User Experience

**Technical Improvements:**
1. Remove API timeout handling and complex error states
2. Implement instant sentiment calculation for sliders
3. Streamline database queries and reduce complexity
4. Add response caching for faster subsequent loads

**User Experience:**
- Eliminate "Analyzing feedback with AI..." loading states
- Show immediate results for quantitative data
- Provide more meaningful, actionable insights for facilitators

## Implementation Strategy

### 1. Feature Flag Approach
```dart
class SentimentConfig {
  static const bool useRuleBasedSliders = true; // Feature flag
  static const int minWordsForAI = 10; // Configurable threshold
}
```

### 2. Backwards Compatibility
- Keep existing database schema
- Maintain API contracts
- Ensure UI components work with both approaches

### 3. A/B Testing Framework
- Test rule-based vs AI approaches with real sessions
- Measure accuracy, user satisfaction, and performance
- Gradual rollout with fallback options

### 4. Migration Path
1. Implement rule-based service alongside existing AI service
2. Add feature flags to switch between approaches
3. Test with subset of sessions
4. Measure performance and accuracy improvements
5. Full migration once validated

## Expected Benefits

### Immediate Wins
- **80% reduction in API costs** (eliminate slider analysis)
- **Instant results page loading** (no waiting for AI)
- **More reliable sentiment scores** for quantitative data
- **Simplified debugging and maintenance**

### User Experience Improvements
- Faster feedback for facilitators
- More accurate insights for their specific use cases
- Clearer distinction between quantitative ratings and qualitative feedback
- Reduced cognitive load from over-interpreted AI findings

### Technical Benefits
- Simpler codebase with fewer edge cases
- Reduced dependency on external AI services
- More predictable performance characteristics
- Easier testing and validation

## When AI Actually Adds Value

AI sentiment analysis remains valuable for:
- **Long-form text responses** (50+ words with context)
- **Complex emotional expressions** with nuanced language
- **Cross-cultural sentiment analysis** for global teams
- **Trend analysis** across multiple sessions

**Our Current Data Profile:**
- Mostly numeric ratings (sliders)
- Short phrases and single words
- Clear positive/negative indicators
- Limited cultural/linguistic complexity

## Risk Mitigation

### Technical Risks
- **Compatibility**: Maintain existing database schema and API contracts
- **Performance**: Benchmark new approach against current implementation
- **Accuracy**: Validate rule-based results against human judgment

### Product Risks
- **User Expectations**: Communicate improvements as "faster, more accurate insights"
- **Facilitator Trust**: Show actual participant responses alongside computed sentiment
- **Feature Parity**: Ensure all current functionality remains available

### Implementation Risks
- **Gradual Rollout**: Feature flags allow safe experimentation
- **Fallback Options**: Keep AI analysis available for edge cases
- **Monitoring**: Track accuracy and user satisfaction metrics

## Success Metrics

### Performance Metrics
- Results page load time: Target <2 seconds (currently 15-30 seconds)
- API cost reduction: Target 80% decrease
- Error rate reduction: Target 95% decrease in timeout/API errors

### Quality Metrics
- Sentiment accuracy: Validate against facilitator feedback
- User satisfaction: Survey facilitators on insight quality
- Feature usage: Monitor which insights are most valuable

### Technical Metrics
- Code complexity reduction: Measure cyclomatic complexity
- Test coverage improvement: Simpler logic = better testing
- Maintenance overhead reduction: Fewer API integrations to manage

## Timeline

### Week 1-2: Foundation
- Implement rule-based sentiment service
- Add feature flags and configuration
- Create A/B testing framework

### Week 3-4: Testing
- Deploy with feature flags to subset of sessions
- Gather performance and accuracy data
- Iterate based on feedback

### Week 5-6: Rollout
- Gradual migration to new approach
- Monitor metrics and user feedback
- Full deployment once validated

### Week 7-8: Cleanup
- Remove deprecated AI code paths
- Optimize database queries
- Document new architecture

This refactor aligns the technical implementation with the actual data characteristics and user needs, providing faster, more accurate, and more cost-effective sentiment analysis for the Bloom app.