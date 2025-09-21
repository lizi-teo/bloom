# Sentiment Analysis Implementation Plan - Sep 6, 2025

## Project Status

### ✅ Completed Database Schema Work
- **`feedback_sentiment` table**: Rebuilt with enhanced structure supporting both slider and text components
- **`session_sentiment_summary` table**: Created with component-specific aggregation fields
- **Schema documentation**: Complete flow diagram created in `.docs/plan/sentiment-analysis-schema-flow.md`
- **All relationships**: Verified and working (feedback_sentiment → results_answers, session_sentiment_summary → sessions)

### Current Data Structure
```
Component Types Available:
- Slider (1): Values 0-100 with min_label/max_label context
- Text (2): Free-form text responses  
- Button (3): Multiple choice selections (future phase)

Sample Data:
- Slider: "83" with labels "Not heard" → "Fully heard"
- Text: "be better", "different beer", "you're learning a lot"
```

## Next Implementation Priority

### 🎯 Phase 1: Sentiment Analysis Service Enhancement

**Goal**: Extend existing `sentiment_service.dart` to handle both slider and text components with storage in new database structure.

#### Task Breakdown:

1. **Examine Current Service**
   - Review existing `lib/core/services/sentiment_service.dart`
   - Understand current text analysis implementation
   - Identify extension points for multi-component support

2. **Add Slider Analysis Logic**
   - Implement generic slider interpretation using Gemini
   - Analyze min_label/max_label semantically to determine scale direction
   - Convert 0-100 values to -1 to +1 sentiment scores
   - Handle any future slider configurations (not just current ones)

3. **Update Database Integration**
   - Modify service to store results in enhanced `feedback_sentiment` table
   - Implement `component_analysis` JSONB storage structure
   - Add `component_type` field population
   - Store interpretation method and confidence scores

4. **Component Analysis Structures**
   ```json
   // Slider component_analysis
   {
     "raw_value": 83,
     "percentage": 0.83,
     "scale_analysis": {
       "min_sentiment": "negative",
       "max_sentiment": "positive", 
       "direction": "positive_high"
     },
     "interpretation": "high_positive"
   }
   
   // Text component_analysis  
   {
     "word_count": 2,
     "tone": "constructive",
     "suggestion_type": "improvement"
   }
   ```

### 🎯 Phase 2: Session Aggregation Logic

**Goal**: Create session-level sentiment summaries combining all component types.

#### Task Breakdown:

1. **Aggregation Service**
   - Calculate component-specific averages (text_sentiment_score, slider_sentiment_score)
   - Determine overall_sentiment_score (weighted combination)
   - Extract session-level themes and insights

2. **Storage in session_sentiment_summary**
   - Populate all component aggregation fields
   - Create component_breakdown JSONB with detailed analysis
   - Store session insights and key themes

### 🎯 Phase 3: Frontend Integration

**Goal**: Display sentiment analysis results in the results page.

#### Task Breakdown:

1. **Update Results Page**
   - Show sentiment insights alongside existing results
   - Display component-specific breakdowns
   - Add sentiment visualization components

2. **Testing with Real Data**
   - Validate slider interpretation with existing data
   - Test session aggregation accuracy
   - Verify sentiment scores make sense contextually

## Data Storage Flow

```
Answer Submitted → Individual Analysis → Session Aggregation
     ↓                    ↓                     ↓
results_answers     feedback_sentiment  session_sentiment_summary
   - answer           - sentiment_score    - text_sentiment_score  
   - questions_id     - component_type     - slider_sentiment_score
                      - component_analysis - overall_sentiment_score
                                          - component_breakdown
```

## Key Implementation Notes

### Generic Slider Handling Algorithm
```javascript
1. Analyze min_label/max_label with Gemini for semantic meaning
2. Determine scale direction:
   - positive_high: higher values = more positive
   - negative_high: higher values = more negative  
   - context_dependent: use question context
3. Convert to sentiment score: (percentage - 0.5) * 2 for positive_high
4. Store interpretation method and confidence
```

### Future Extensibility
- Design supports adding button component analysis later
- JSONB structures allow flexible component-specific data
- Service architecture can handle new component types easily

## Phase 1 Implementation Complete! ✅

### 🎉 What's Been Completed:

**Enhanced SentimentService (`lib/core/services/sentiment_service.dart`):**
- ✅ New models: `EnhancedSentimentResult`, `SliderAnalysisResult`
- ✅ Generic slider sentiment analysis with semantic label interpretation
- ✅ Enhanced text analysis with improved structure
- ✅ Database integration storing results in `feedback_sentiment` table
- ✅ Test methods for validation and real data analysis

### 📚 New API Usage

**Main Analysis Method:**
```dart
// Analyze any answer (slider or text) with enhanced sentiment analysis
final result = await SentimentService.analyzeEnhancedSentiment(
  resultsAnswersId: answerId,
  answer: answerValue, // "83" for slider, "be better" for text
  componentType: 'slider', // or 'text'
  questionTitle: 'Inclusivity', // optional but recommended
  minLabel: 'Not heard', // for sliders
  maxLabel: 'Fully heard', // for sliders
);

// Result contains:
// - sentimentScore: -1.0 to 1.0 (standardized across components)
// - sentimentLabel: 'positive', 'negative', 'neutral', 'mixed'
// - componentAnalysis: JSONB with component-specific insights
// - Automatically stored in feedback_sentiment table
```

**Test Methods:**
```dart
// Test with sample data
await SentimentService.testEnhancedSentiment();

// Analyze existing real data from database
final results = await SentimentService.analyzeExistingAnswers(
  sessionId: 1, // optional filter
  limit: 10,    // optional limit
);
```

**Generic Slider Analysis Features:**
- 🔄 Semantic interpretation of any min/max label combination
- 🎯 Contextual sentiment scoring based on question title
- 📊 Confidence scoring for analysis quality
- 💾 Structured storage in JSONB component_analysis field

**Example Component Analysis Data:**
```json
// Slider (value: 83, "Not heard" → "Fully heard")
{
  "raw_value": 83,
  "percentage": 0.83,
  "scale_analysis": {
    "min_sentiment": "negative",
    "max_sentiment": "positive", 
    "direction": "positive_high",
    "confidence": 0.95
  },
  "interpretation": "high_satisfaction"
}

// Text ("be better")
{
  "word_count": 2,
  "tone": "constructive",
  "key_phrases": ["better"]
}
```

### 🧪 Testing the Implementation

**Quick Test:**
```dart
// Add this to any widget or test to try the new functionality
await SentimentService.testEnhancedSentiment();
```

**Real Data Test:**
```dart
// Analyze existing answers from your database
final results = await SentimentService.analyzeExistingAnswers(sessionId: 1);
```

## Success Criteria

### ✅ Phase 1 Complete:
- ✅ Service analyzes both slider and text responses
- ✅ Results stored in enhanced `feedback_sentiment` table
- ✅ Generic slider interpretation works with any label combination
- ✅ Component-specific analysis data properly structured in JSONB

### Phase 2 Complete:
- [ ] Session-level aggregation working
- [ ] Component breakdowns calculated correctly
- [ ] `session_sentiment_summary` populated with meaningful insights
- [ ] Overall sentiment reflects both component types appropriately

### Phase 3 Complete:
- [ ] Results page shows sentiment analysis
- [ ] Users can see component-specific insights
- [ ] Sentiment data provides actionable feedback insights

## Testing Strategy

1. **Unit Tests**: Individual component analysis functions
2. **Integration Tests**: End-to-end sentiment flow with real data
3. **Data Validation**: Verify sentiment scores make contextual sense
4. **Performance Tests**: Ensure analysis doesn't slow down feedback submission

## Files to Work With

### Primary Implementation:
- `lib/core/services/sentiment_service.dart` - Main service to extend
- `lib/features/results/dynamic_results_page.dart` - Frontend integration
- `lib/core/components/molecules/sentiment_answers_card.dart` - Display component

### Reference Documentation:
- `.docs/plan/sentiment-analysis-schema-flow.md` - Complete schema design
- `CLAUDE.md` - Project instructions and shortcuts
- This file - Implementation plan and status

## Context for Future Sessions

When continuing this work:
1. ✅ **Phase 1 Complete**: Enhanced sentiment service with slider + text analysis
2. 🎯 **Next Priority**: Session aggregation logic (Phase 2)
3. 📊 **Database Ready**: All tables configured and working
4. 🧪 **Testing Available**: Use `testEnhancedSentiment()` and `analyzeExistingAnswers()`
5. 🔄 **Generic Design**: Slider analysis works with any label configuration
6. 💾 **Data Storage**: All results automatically saved to `feedback_sentiment` table

### 🚀 Ready for Phase 2: Session Aggregation
- Service foundation complete and tested
- Database integration working
- Generic slider interpretation validated
- Ready to build session-level summary logic