# Sentiment Analysis Schema Flow

## Overview

This document outlines the database schema and data flow for implementing sentiment analysis across slider and text components in the Bloom feedback system. The design is flexible enough to handle any future slider configurations while maintaining consistent analysis output.

## Schema Flow Diagram

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│    sessions     │    │   templates     │    │   questions     │
│                 │    │                 │    │                 │
│ session_id (PK) │    │ template_id(PK) │    │ question_id(PK) │
│ template_id(FK) │◄───┤ template_name   │    │ question        │
│ session_name    │    │ image_url       │    │ component_type  │
│ session_code    │    │ supporting_text │    │ min_label       │
└─────────────────┘    └─────────────────┘    │ max_label       │
         │                                     │ title           │
         │                                     └─────────────────┘
         ▼                                              │
┌─────────────────┐    ┌─────────────────┐             │
│    results      │    │ results_answers │◄────────────┘
│                 │    │                 │
│ results_id (PK) │◄───┤ results_ans_id  │
│ session_id (FK) │    │ results_id (FK) │
│ created_at      │    │ questions_id(FK)│
└─────────────────┘    │ answer          │ ◄─── Raw answer data:
                       └─────────────────┘      • Slider: "83"
                                │                • Text: "be better"
                                │
                                ▼
                  ┌─────────────────────────────────────┐
                  │        feedback_sentiment           │
                  │                                     │
                  │ sentiment_id (PK)                   │
                  │ results_answers_id (FK)             │
                  │ component_type ('slider'/'text')    │
                  │                                     │
                  │ ┌─── Universal Fields ────────────┐ │
                  │ │ sentiment_score DECIMAL(-1,+1)  │ │
                  │ │ sentiment_label VARCHAR         │ │
                  │ │ confidence_score DECIMAL(0,1)   │ │
                  │ └─────────────────────────────────┘ │
                  │                                     │
                  │ ┌─── Component Analysis ──────────┐ │
                  │ │ component_analysis JSONB:       │ │
                  │ │                                 │ │
                  │ │ SLIDER:                         │ │
                  │ │ {                               │ │
                  │ │   "raw_value": 83,              │ │
                  │ │   "percentage": 0.83,           │ │
                  │ │   "scale_analysis": {           │ │
                  │ │     "min_sentiment": "negative",│ │
                  │ │     "max_sentiment": "positive",│ │
                  │ │     "direction": "positive_high"│ │
                  │ │   },                            │ │
                  │ │   "interpretation": "high_pos"  │ │
                  │ │ }                               │ │
                  │ │                                 │ │
                  │ │ TEXT:                           │ │
                  │ │ {                               │ │
                  │ │   "word_count": 2,              │ │
                  │ │   "tone": "constructive",       │ │
                  │ │   "suggestion_type": "improve"  │ │
                  │ │ }                               │ │
                  │ └─────────────────────────────────┘ │
                  │                                     │
                  │ interpretation_method VARCHAR       │
                  │ key_findings TEXT                   │
                  │ themes JSONB                        │
                  │ analyzed_at TIMESTAMP               │
                  │ analysis_model VARCHAR              │
                  │ gemini_raw_response TEXT            │
                  └─────────────────────────────────────┘
                                │
                                │ Aggregate by session_id
                                ▼
                  ┌─────────────────────────────────────┐
                  │    session_sentiment_summary        │
                  │                                     │
                  │ session_summary_id (PK)             │
                  │ session_id (FK)                     │
                  │                                     │
                  │ ┌─── Component Aggregations ──────┐ │
                  │ │ text_sentiment_score DECIMAL    │ │
                  │ │ text_response_count INTEGER     │ │
                  │ │ slider_sentiment_score DECIMAL  │ │
                  │ │ slider_response_count INTEGER   │ │
                  │ └─────────────────────────────────┘ │
                  │                                     │
                  │ ┌─── Overall Metrics ─────────────┐ │
                  │ │ overall_sentiment_score DECIMAL │ │
                  │ │ overall_sentiment_label VARCHAR │ │
                  │ │ confidence_score DECIMAL        │ │
                  │ └─────────────────────────────────┘ │
                  │                                     │
                  │ ┌─── Session Insights ────────────┐ │
                  │ │ key_themes JSONB                │ │
                  │ │ session_insights TEXT           │ │
                  │ │ component_breakdown JSONB:      │ │
                  │ │ {                               │ │
                  │ │   "text": {                     │ │
                  │ │     "avg_sentiment": 0.2,       │ │
                  │ │     "dominant_themes": [...]    │ │
                  │ │   },                            │ │
                  │ │   "slider": {                   │ │
                  │ │     "avg_sentiment": 0.7,       │ │
                  │ │     "high_scoring_areas": [...] │ │
                  │ │   }                             │ │
                  │ │ }                               │ │
                  │ └─────────────────────────────────┘ │
                  │                                     │
                  │ total_analyzed_answers INTEGER      │
                  │ analyzed_at TIMESTAMP               │
                  │ analysis_model VARCHAR              │
                  └─────────────────────────────────────┘
```

## Table Specifications

### feedback_sentiment (Enhanced)

**Purpose**: Store individual answer sentiment analysis for both slider and text components.

```sql
CREATE TABLE feedback_sentiment (
    sentiment_id BIGSERIAL PRIMARY KEY,
    results_answers_id BIGINT NOT NULL REFERENCES results_answers(results_answers_id) ON DELETE CASCADE,
    component_type VARCHAR(10) NOT NULL CHECK (component_type IN ('slider', 'text')),
    
    -- Universal sentiment fields
    sentiment_score DECIMAL(3,2) CHECK (sentiment_score >= -1.00 AND sentiment_score <= 1.00),
    sentiment_label VARCHAR(20) CHECK (sentiment_label IN ('positive', 'negative', 'neutral', 'mixed')),
    confidence_score DECIMAL(3,2) CHECK (confidence_score >= 0.00 AND confidence_score <= 1.00),
    
    -- Component-specific analysis
    component_analysis JSONB NOT NULL,
    interpretation_method VARCHAR(50) NOT NULL, -- e.g., 'semantic_scale', 'text_analysis'
    key_findings TEXT,
    themes JSONB,
    
    -- Metadata
    analyzed_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    analysis_model VARCHAR(50),
    processing_time_ms INTEGER,
    gemini_raw_response TEXT,
    
    -- Constraints
    UNIQUE(results_answers_id) -- One analysis per answer
);
```

### session_sentiment_summary

**Purpose**: Aggregate sentiment analysis results at the session level.

```sql
CREATE TABLE session_sentiment_summary (
    session_summary_id BIGSERIAL PRIMARY KEY,
    session_id BIGINT NOT NULL REFERENCES sessions(session_id) ON DELETE CASCADE,
    
    -- Component-specific aggregations
    text_sentiment_score DECIMAL(3,2),
    text_response_count INTEGER DEFAULT 0,
    slider_sentiment_score DECIMAL(3,2),
    slider_response_count INTEGER DEFAULT 0,
    
    -- Overall metrics
    overall_sentiment_score DECIMAL(3,2),
    overall_sentiment_label VARCHAR(20) CHECK (overall_sentiment_label IN ('positive', 'negative', 'neutral', 'mixed')),
    
    -- Session insights
    key_themes JSONB,
    session_insights TEXT,
    component_breakdown JSONB,
    
    -- Metadata
    total_analyzed_answers INTEGER NOT NULL DEFAULT 0,
    analyzed_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    analysis_model VARCHAR(50),
    confidence_score DECIMAL(3,2) CHECK (confidence_score >= 0.00 AND confidence_score <= 1.00),
    
    -- Constraints
    UNIQUE(session_id), -- One summary per session
    CHECK (overall_sentiment_score >= -1.00 AND overall_sentiment_score <= 1.00)
);
```

## Analysis Strategies

### Slider Component Analysis

**Generic Approach**: Works with any slider configuration by analyzing the semantic meaning of min/max labels.

**Current Examples**:
- `"Not heard"` → `"Fully heard"` (value: 83 = high positive)
- `"Developing"` → `"Exceptional"` (value: 76 = positive)
- `"Unclear"` → `"Crystal clear"` (value: 66 = neutral to positive)

**Future Examples**:
- `"Terrible"` → `"Amazing"`
- `"Strongly Disagree"` → `"Strongly Agree"`
- `"Never"` → `"Daily"` (context-dependent)
- `"Too Little"` → `"Too Much"` (neutral middle optimal)

**Analysis Steps**:
1. **Label Semantic Analysis**: Use Gemini to analyze min_label and max_label sentiment
2. **Scale Direction Detection**: Determine if higher values = more positive/negative
3. **Sentiment Score Calculation**: Convert 0-100 slider value to -1 to +1 sentiment score
4. **Context Integration**: Use question title/text to resolve ambiguous cases

**component_analysis JSON Structure for Sliders**:
```json
{
  "raw_value": 83,
  "percentage": 0.83,
  "scale_analysis": {
    "min_label": "Not heard",
    "max_label": "Fully heard",
    "min_sentiment": "negative",
    "max_sentiment": "positive",
    "direction": "positive_high",
    "confidence": 0.95
  },
  "interpretation": "high_positive",
  "contextual_factors": {
    "question_topic": "inclusivity",
    "scale_type": "satisfaction"
  }
}
```

### Text Component Analysis

**Approach**: Continue existing Gemini-based text analysis with enhanced structure.

**component_analysis JSON Structure for Text**:
```json
{
  "word_count": 2,
  "character_count": 9,
  "tone": "constructive",
  "suggestion_type": "improvement",
  "key_phrases": ["be better"],
  "emotional_indicators": [],
  "topic_categories": ["process_improvement"]
}
```

## Implementation Flow

### 1. Individual Analysis Pipeline

```
Answer Received
    ↓
Determine Component Type
    ↓
┌─ SLIDER ────────────────┐    ┌─ TEXT ──────────────────┐
│ 1. Extract slider value │    │ 1. Extract text content │
│ 2. Get question labels  │    │ 2. Analyze with Gemini  │
│ 3. Analyze label        │    │ 3. Extract themes       │
│    semantics via Gemini │    │ 4. Determine sentiment  │
│ 4. Calculate sentiment  │    │ 5. Store analysis       │
│ 5. Store analysis       │    └─────────────────────────┘
└─────────────────────────┘
    ↓
Store in feedback_sentiment table
```

### 2. Session Aggregation Pipeline

```
All Answers Analyzed
    ↓
Group by session_id
    ↓
Calculate Component Averages
    ↓
Determine Overall Sentiment
    ↓
Extract Session-Level Themes
    ↓
Store in session_sentiment_summary
```

## Generic Slider Handling Logic

### Sentiment Score Calculation Algorithm

```javascript
function calculateSliderSentiment(value, minLabel, maxLabel, questionTitle) {
  // Step 1: Analyze labels semantically
  const labelAnalysis = analyzeLabelsWithGemini(minLabel, maxLabel, questionTitle);
  
  // Step 2: Determine scale direction
  const scaleDirection = labelAnalysis.direction; // 'positive_high', 'negative_high', 'context_dependent'
  
  // Step 3: Convert to percentage (0-1)
  const percentage = value / 100;
  
  // Step 4: Calculate sentiment score (-1 to +1)
  let sentimentScore;
  
  switch (scaleDirection) {
    case 'positive_high':
      // Higher values = more positive
      sentimentScore = (percentage - 0.5) * 2;
      break;
    case 'negative_high':
      // Higher values = more negative
      sentimentScore = (0.5 - percentage) * 2;
      break;
    case 'neutral_optimal':
      // Middle values = optimal (e.g., "Too Little" → "Too Much")
      sentimentScore = 1 - Math.abs(percentage - 0.5) * 2;
      break;
    case 'context_dependent':
      // Use question context to determine
      sentimentScore = analyzeContextualSentiment(percentage, questionTitle, labelAnalysis);
      break;
  }
  
  return Math.max(-1, Math.min(1, sentimentScore)); // Clamp to [-1, 1]
}
```

## Indexes and Performance

```sql
-- Performance indexes
CREATE INDEX idx_feedback_sentiment_results_answers_id ON feedback_sentiment(results_answers_id);
CREATE INDEX idx_feedback_sentiment_component_type ON feedback_sentiment(component_type);
CREATE INDEX idx_feedback_sentiment_analyzed_at ON feedback_sentiment(analyzed_at);
CREATE INDEX idx_feedback_sentiment_sentiment_label ON feedback_sentiment(sentiment_label);

CREATE INDEX idx_session_sentiment_summary_session_id ON session_sentiment_summary(session_id);
CREATE INDEX idx_session_sentiment_summary_analyzed_at ON session_sentiment_summary(analyzed_at);
CREATE INDEX idx_session_sentiment_summary_overall_label ON session_sentiment_summary(overall_sentiment_label);
```

## Migration Considerations

1. **Existing Data**: Current `feedback_sentiment` table will need to be migrated or rebuilt with new structure
2. **Backward Compatibility**: Maintain existing text analysis while adding slider support
3. **Data Validation**: Ensure all existing sentiment scores fall within new constraints
4. **Reprocessing**: May need to reprocess existing slider responses with new analysis logic

## Future Extensions

1. **Button Component**: Can be added by extending `component_type` enum and analysis logic
2. **Multi-Language Support**: Add language detection and analysis in appropriate language
3. **Custom Scales**: Support for non-0-100 slider ranges
4. **Weighted Aggregation**: Different weights for different question types in session summary
5. **Temporal Analysis**: Track sentiment changes over time for recurring sessions