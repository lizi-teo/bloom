# Sentiment Analysis User Stories

## Epic: Overall Session Sentiment Analysis
**As a facilitator, I want to understand the overall sentiment of my session based on all participant responses (both slider ratings and text feedback) so that I can gauge session effectiveness and identify areas for improvement.**

---

## User Stories

### Story 1: Overall Sentiment Display
**As a facilitator**  
**I want** to see an overall sentiment score for my session that combines both slider ratings and text responses  
**So that** I can quickly understand the general participant sentiment without being overwhelmed by individual question details

**Acceptance Criteria:**
- Overall sentiment is calculated as a weighted average of all analyzed responses (text + slider)
- Sentiment score is displayed prominently with a clear label (Positive, Negative, Neutral, Mixed)
- Visual indicator shows sentiment strength (color-coded circle with numerical score)
- Shows total number of analyzed responses for context
- Session-level key themes are displayed as tags below the overall score

---

### Story 2: Hidden Individual Sentiment for Sliders
**As a facilitator**  
**I want** individual slider question sentiment to be calculated but not prominently displayed in the UI  
**So that** the focus remains on overall session sentiment while still contributing to the calculation

**Acceptance Criteria:**
- Slider questions are analyzed for sentiment using semantic interpretation of labels
- Individual slider sentiment contributes to overall session sentiment calculation  
- Slider sentiment is not shown as a separate prominent metric in the UI
- Only the slider average score (e.g., "85/100") is displayed for each slider question
- Slider sentiment data is stored in the database for analysis purposes

---

### Story 3: Hidden Scores for Text Questions  
**As a facilitator**  
**I want** text questions to not display numerical scores in the UI  
**So that** the interface focuses on qualitative insights rather than quantitative metrics for open-ended responses

**Acceptance Criteria:**
- Text questions show no numerical score display in the UI
- Text questions display the question title and qualitative insights only
- Text sentiment contributes to overall session sentiment calculation
- Response count and key insights are shown instead of numerical scores
- Text sentiment analysis is performed and stored but not prominently displayed per question

---

### Story 4: Comprehensive Sentiment Calculation
**As a system**  
**I need** to analyze sentiment for both slider and text question types using appropriate methods  
**So that** the overall session sentiment accurately reflects all participant feedback

**Acceptance Criteria:**
- Text responses analyzed using Gemini AI for sentiment (-1 to +1 scale)
- Slider responses analyzed using semantic interpretation of min/max labels (-1 to +1 scale)
- Overall sentiment calculated as weighted average based on response counts
- Individual sentiment results stored in `feedback_sentiment` table
- Session-level aggregation stored in `session_sentiment_summary` table
- Empty or minimal responses handled gracefully with appropriate confidence scores

---

### Story 5: Session-Level Insights and Themes
**As a facilitator**  
**I want** to see key themes and insights extracted from all session responses  
**So that** I can understand specific areas of strength and improvement opportunities

**Acceptance Criteria:**
- Key themes extracted from both text findings and slider interpretations
- Themes displayed as color-coded tags matching overall sentiment
- Session insights include participation patterns and sentiment consistency
- Up to 5 most relevant themes displayed to avoid information overload
- Themes are actionable and focus on facilitator performance aspects

---

### Story 6: Automatic Sentiment Processing
**As a system**  
**I need** to automatically analyze sentiment when results are viewed  
**So that** facilitators always see up-to-date sentiment analysis without manual intervention

**Acceptance Criteria:**
- Sentiment analysis triggered automatically when accessing results page
- Individual answers analyzed first if not already processed
- Session-level aggregation created or updated as needed
- Existing sentiment summaries reused to avoid redundant API calls
- Error handling for failed analysis with graceful fallback behavior

---

## Technical Implementation Notes

### Database Schema
- `feedback_sentiment`: Individual answer sentiment analysis
- `session_sentiment_summary`: Aggregated session-level sentiment
- Both tables support slider and text component types

### Sentiment Calculation Method
- **Text**: Gemini AI analysis with structured prompts
- **Slider**: Semantic interpretation of labels (min/max sentiment mapping)
- **Overall**: Weighted average based on response type distribution
- **Scale**: -1.0 to +1.0 internally, converted to 0-100 for display

### UI Design Principles
- Overall sentiment prominently displayed with visual indicators
- Individual question sentiment subtly integrated or hidden
- Focus on actionable insights over raw metrics
- Clean, uncluttered interface prioritizing session-level understanding

---

## Definition of Done
- [ ] Overall sentiment displayed prominently on results page
- [ ] Slider question sentiment calculated but not individually displayed  
- [ ] Text question scores hidden from UI
- [ ] Both question types contribute to overall sentiment calculation
- [ ] Session themes and insights displayed
- [ ] Automatic processing when viewing results
- [ ] Database properly stores all sentiment data
- [ ] Error handling for edge cases (empty responses, API failures)
- [ ] Performance optimized to avoid redundant calculations