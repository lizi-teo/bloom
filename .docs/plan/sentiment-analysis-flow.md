# Sentiment Analysis Flow Documentation

## Overview
The sentiment analysis system in Bloom provides facilitators with AI-powered insights into participant feedback, aggregating responses from all participants to show overall session sentiment and engagement metrics.

## How It Works

### 1. Data Collection Flow
```
Participants → Submit Responses → Supabase Database → AI Analysis → Results Display
```

### 2. Database Structure
- **`results_answers`**: Individual participant responses to questions
- **`feedback_sentiment`**: AI sentiment analysis for each response
- **`session_sentiment_summary`**: Aggregated sentiment data per session

### 3. Sentiment Analysis Process

#### Step 1: Individual Response Analysis
- Each participant response (text or slider) gets analyzed by AI
- Creates sentiment score (-1 to +1) and confidence level
- Stored in `feedback_sentiment` table

#### Step 2: Session Aggregation
- `SentimentService.aggregateSessionSentiment()` collects all responses for a session
- Calculates weighted average across all participants
- Generates overall sentiment label (Positive/Negative/Neutral/Mixed)

#### Step 3: Results Display
- Shows collective sentiment from all participants
- Displays participation count (unique responses analyzed)
- Includes AI-generated themes and insights

## What Users See in Results

### Sentiment Analysis Section
- **Sentiment GIF**: Visual representation of collective mood
- **Sentiment Label**: Overall conclusion (e.g., "Positive")
- **Participation Icon + Count**: Number of analyzed responses
- **Theme Chips**: Key themes extracted from all feedback

### Data Interpretation
- **"Positive"** = Collective sentiment from ALL participants combined
- **Icon Count** = Total responses that were analyzed for sentiment
- **Themes** = Common patterns across all participant feedback

## Technical Implementation

### Key Components
1. **`SentimentService`**: Core logic for sentiment analysis and aggregation
2. **`EnhancedResultsCard`**: UI component displaying sentiment results
3. **`SessionSentimentSummary`**: Data model for aggregated results

### Data Flow Code Path
```dart
// 1. Load session sentiment summary
SentimentService.getOrCreateSessionSummary(sessionId)

// 2. Query all responses for session
_getSessionSentimentResults(sessionId)
  └── results_answers (filtered by session_id)
  └── feedback_sentiment (for those answers)

// 3. Calculate aggregated metrics
totalResponseCount: sentimentResults.length
overallSentimentScore: weighted_average(all_scores)
overallSentimentLabel: _getSentimentLabel(overallScore)

// 4. Display in UI
EnhancedResultsCard
  └── _buildOverallSentimentCard()
      └── Shows sentiment + participation count
```

### Calculation Example
If 3 people each answer 2 questions:
- **Individual Analysis**: 6 sentiment scores generated
- **Aggregation**: 6 scores averaged together
- **Result**: One overall sentiment representing collective mood
- **Display**: "Positive" with icon showing "6" (total analyzed responses)

## Benefits for Facilitators
- **Quick Insights**: Instant understanding of session mood
- **Participation Visibility**: See engagement levels at a glance
- **AI-Powered Themes**: Discover patterns across all feedback
- **Data-Driven Decisions**: Make informed decisions based on collective sentiment

## Data Accuracy
- All data sourced directly from Supabase database
- Real-time aggregation when viewing results
- Confidence scores indicate analysis reliability
- Weighted averaging accounts for different response types (text vs. slider)

## Other learnings
  Issues Found:

  1. Overly Creative Prompts: The prompt at lines 474-503 asks the AI to look "BEYOND the surface content" and identify "hidden emotional needs" and "unconscious facilitator behaviors" - this encourages the AI
  to extrapolate beyond what participants actually said.
  2. Vague Key Findings: The prompt asks for insights that are "not obvious from reading the feedback directly" which can lead to over-interpretation.
  3. Limited Context: The AI doesn't see the actual questions participants were answering, so it may misinterpret responses.
  4. High Temperature: While temperature is set to 0.1 (line 271), the creative nature of the prompts still allows for speculation.