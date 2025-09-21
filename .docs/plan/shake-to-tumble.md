# Shake-to-Tumble Sheep Implementation Plan

## Project Overview
Building a shake-to-shuffle icebreaker feature for a facilitator app. Users shake their phone to make a sheep image tumble around the screen, settle in a position, and reveal their "mood" for the day.

## Technology Stack
- **Framework**: Flutter
- **Target**: Mobile-first web app
- **Development Tool**: Claude Code for iterative development

## File Structure

The implementation will be organized in the new `icebreakers` folder structure:

```
lib/features/icebreakers/
├── shake_to_tumble/
│   ├── screens/
│   │   ├── shake_to_tumble_screen.dart          # Main icebreaker screen
│   │   └── facilitator_dashboard_screen.dart    # Group management interface
│   ├── widgets/
│   │   ├── tumble_card.dart                     # Physics-enabled card widget
│   │   ├── onboarding_animation.dart            # Shake gesture tutorial
│   │   ├── alternative_input_widget.dart        # Non-shake interaction options
│   │   └── group_results_view.dart              # Real-time participant display
│   └── models/
│       ├── tumble_animation_state.dart          # Animation state management
│       ├── shake_to_tumble_result.dart          # Final mood result
│       └── session_state.dart                   # Group session management
└── shared/
    ├── services/
    │   ├── shake_detector_service.dart          # Reusable shake detection
    │   ├── icebreaker_session_service.dart      # Group participation management
    │   ├── accessibility_service.dart           # Alternative input handling
    │   └── analytics_service.dart               # Usage tracking and insights
    ├── models/
    │   ├── icebreaker_mood.dart                 # Common mood data structure
    │   ├── icebreaker_result.dart               # Base result interface
    │   ├── session_config.dart                  # Facilitator customization
    │   └── participant.dart                     # Individual participant data
    └── widgets/
        ├── mood_reveal_card.dart                # Reusable mood display component
        ├── accessibility_controls.dart          # Alternative input options
        └── session_export_widget.dart           # Results export functionality
```

**Key Files:**
- **Main entry point**: `lib/features/icebreakers/shake_to_tumble/screens/shake_to_tumble_screen.dart`
- **Pubspec location**: `/Users/lizzieteo/Development/bloom-app/pubspec.yaml`
- **Existing component**: `/Users/lizzieteo/Development/bloom-app/lib/core/components/atoms/icebreaker_card.dart`

## Phase 1: Basic Shake Detection
**Goal**: Detect device shake gestures reliably

### Tasks:
- [ ] Add `sensors_plus` package to `/Users/lizzieteo/Development/bloom-app/pubspec.yaml`
- [ ] Create `lib/features/icebreakers/shared/services/shake_detector_service.dart`
  - Set up accelerometer stream listening
  - Implement shake threshold detection (magnitude > 12.0)
  - Add debouncing to prevent multiple rapid triggers
  - Include web platform compatibility checks
- [ ] Create `lib/features/icebreakers/shake_to_tumble/screens/shake_to_tumble_screen.dart`
  - Basic screen structure with Scaffold
  - Integrate ShakeDetectorService
  - Add simple visual feedback (text or color change) when shake detected
- [ ] Add routing for new screen (update app routing configuration)
- [ ] Test shake sensitivity on different devices/browsers
- [ ] Add error handling for sensor permissions

### Success Criteria:
- Shake gesture consistently detected
- No false positives from normal movement
- Works in web browser environment

---

## Phase 2: Single Image Tumble Animation
**Goal**: Make one sheep image tumble realistically when shake is detected

### Component Strategy:
**Decision**: Create `TumbleCard` as a new widget that **composes** `IcebreakerCard` rather than extending it, to avoid breaking existing functionality.

### Tasks:
- [ ] Create `lib/features/icebreakers/shake_to_tumble/widgets/tumble_card.dart`
  - Use composition: wrap IcebreakerCard with physics animations
  - Add `AnimationController` for position (x, y coordinates)
  - Add `AnimationController` for tumble physics (separate from IcebreakerCard's tap animation)
  - Implement `TickerProviderStateMixin` for multiple animation controllers
- [ ] Implement physics-based tumbling animation
  - Enhanced rotation animation (continuous spins during tumble)
  - Translation animation with gravity effect and screen bounds
  - Random initial velocity and direction
- [ ] Add gravity and boundary collision detection
  - Use `MediaQuery` to get screen dimensions
  - Implement bounce physics when hitting boundaries
  - Gradual deceleration to simulate air resistance
- [ ] Integrate TumbleCard into shake_to_tumble_screen.dart
- [ ] Add easing curves for smooth animation start/stop transitions

### Success Criteria:
- Sheep rotates and moves convincingly during tumble
- Animation feels natural and satisfying
- Sheep doesn't disappear off-screen

---

## Phase 3: Settle Animation & Physics
**Goal**: Make sheep come to rest in a believable way

### Tasks:
- [ ] Implement settling animation (gradual slow-down)
- [ ] Add bounce effect when sheep "lands"
- [ ] Random final position generation
- [ ] Smooth transition from tumble to settle
- [ ] Optional: slight idle animation when settled

### Success Criteria:
- Sheep gracefully transitions from chaotic tumble to rest
- Bounce feels satisfying and natural
- Final position is random but always visible

---

## Phase 4: Mood Reveal UI
**Goal**: Show personality/mood description after sheep settles

### Tasks:
- [ ] Create mood reveal overlay/card
- [ ] Design smooth reveal animation (fade in, slide up, etc.)
- [ ] Add sheep personality descriptions (9 different moods)
- [ ] Implement random mood selection
- [ ] Add confirmation button or auto-advance timer

### Success Criteria:
- Mood reveals smoothly after settle animation
- Text is readable and engaging
- Users can easily proceed to next step

---

## Phase 5: Polish & User Experience
**Goal**: Add finishing touches and improve feel

### Tasks:
- [ ] Add haptic feedback for shake and settle
- [ ] Implement sound effects (optional baa sound)
- [ ] Add loading states and error handling
- [ ] Optimize animations for performance
- [ ] Add accessibility features (alternative input methods)
- [ ] Polish visual design and spacing

### Success Criteria:
- Interactions feel responsive and delightful
- App works smoothly on various devices
- Accessible to users who can't shake device

---

## Phase 6: Group Experience & Facilitator Features
**Goal**: Enable group workshop functionality with facilitator controls

### Tasks:
- [ ] Create `IcebreakerSessionService` for managing group participation
- [ ] Implement facilitator dashboard with real-time participant view
- [ ] Add synchronized reveal timing controls
- [ ] Build group results visualization (mood distribution, trends)
- [ ] Create discussion prompt generator based on group mood combinations
- [ ] Add session export functionality (CSV, PDF reports)
- [ ] Implement QR code sharing for easy participant joining
- [ ] Add facilitator notes and custom session naming

### Success Criteria:
- Facilitator can see all participants' progress in real-time
- Group reveal timing is synchronized and controllable
- Session results can be exported for follow-up discussions

---

## Phase 7: Enhanced User Experience & Accessibility
**Goal**: Create inclusive, polished interaction flows

### Tasks:
- [ ] Design onboarding animation showing shake gesture
- [ ] Implement progressive instruction disclosure
- [ ] Add alternative input methods (tap/click for non-shake users)
- [ ] Create recovery flow when shake detection fails
- [ ] Build retry mechanism if user doesn't like their result
- [ ] Add visual accessibility options (high contrast, larger text)
- [ ] Implement reduced motion settings for motion sensitivity
- [ ] Design waiting state micro-animations
- [ ] Add celebration animations for mood reveal

### Success Criteria:
- All users can complete the icebreaker regardless of device capabilities
- Clear visual feedback guides users through each step
- Experience feels polished and engaging throughout

---

## Phase 8: Content Customization & Theming
**Goal**: Enable flexible content adaptation for different contexts

### Tasks:
- [ ] Create expandable mood system architecture (support 12+ moods)
- [ ] Build themed sheep collections (seasons, emotions, energy levels)
- [ ] Implement custom mood description editor for facilitators
- [ ] Add context-specific prompt variations (team building, retrospectives, check-ins)
- [ ] Create mood combination insights and discussion starters
- [ ] Build facilitator customization panel
- [ ] Add multi-language support framework
- [ ] Implement seasonal/holiday themed variations

### Success Criteria:
- Facilitators can customize experience for their specific workshop context
- Content feels fresh and relevant for repeat use
- Multi-language support enables global workshop use

---

## Phase 9: Multi-Image System & Advanced Physics
**Goal**: Expand to multiple sheep options with enhanced tumble mechanics

### Tasks:
- [ ] Refactor to support array of sheep images (9+ unique sheep)
- [ ] Implement weighted random selection based on mood distributions
- [ ] Create sheep personality matching system
- [ ] Add advanced physics (different tumble styles per sheep)
- [ ] Ensure consistent performance with multiple image loading
- [ ] Map specific sheep to specific mood ranges
- [ ] Add sheep animation variations (different bounce styles)
- [ ] Test performance optimization across devices

### Success Criteria:
- Each sheep feels unique with distinct personality and physics
- Random selection feels balanced and fair
- Performance remains smooth with expanded content

---

## Technical Considerations

### Existing Components to Leverage:
- **IcebreakerCard** (`/Users/lizzieteo/Development/bloom-app/lib/core/components/atoms/icebreaker_card.dart`)
  - Already has `AnimationController` with scale/rotation animations
  - Has `SingleTickerProviderStateMixin` setup
  - Contains image display with error handling
  - Size configurable (default 180px)
  - Can be extended for tumble physics

### Key Flutter Packages Needed:
- `sensors_plus` - For accelerometer/shake detection
- `flutter/animation` - For physics and custom animations  
- Built-in `Transform` and `AnimationController` widgets (already in IcebreakerCard)
- `provider` or `riverpod` - For session state management across group participants
- `web_socket_channel` - For real-time facilitator/participant communication
- `csv` - For session results export functionality
- `qr_flutter` - For generating session join QR codes
- `shared_preferences` - For accessibility settings persistence
- `device_info_plus` - For device capability detection and fallbacks

### Implementation Architecture:

**State Management**: Use `StatefulWidget` with multiple `AnimationController`s:
- `_tumbleController` - Controls the chaotic tumble phase
- `_settleController` - Controls the settling/landing phase  
- `_revealController` - Controls mood reveal animations

**Data Structures**:
```dart
// lib/features/icebreakers/shared/models/icebreaker_mood.dart
class IcebreakerMood {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final Color color;
  final String discussionPrompt;
  final List<String> alternativeDescriptions;
}

// lib/features/icebreakers/shake_to_tumble/models/tumble_animation_state.dart
enum TumblePhase { idle, onboarding, tumbling, settling, revealing, completed }

class TumbleAnimationState {
  final TumblePhase phase;
  final double x, y;
  final double velocityX, velocityY;
  final double rotation;
  final IcebreakerMood? selectedMood;
  final bool hasAlternativeInput;
  final String? errorMessage;
}

// lib/features/icebreakers/shared/models/session_config.dart
class SessionConfig {
  final String sessionId;
  final String facilitatorName;
  final List<IcebreakerMood> availableMoods;
  final bool allowRetries;
  final Duration revealDelay;
  final bool enableSoundEffects;
  final bool enableHapticFeedback;
  final AccessibilityConfig accessibility;
}

// lib/features/icebreakers/shared/models/participant.dart
class Participant {
  final String id;
  final String name;
  final IcebreakerMood? selectedMood;
  final DateTime? completionTime;
  final bool usedAlternativeInput;
  final int attemptCount;
}

// lib/features/icebreakers/shared/models/session_state.dart
class SessionState {
  final String sessionId;
  final SessionPhase phase;
  final List<Participant> participants;
  final SessionConfig config;
  final Map<String, dynamic> analytics;
}

enum SessionPhase { setup, active, revealing, completed, exported }
```

**Animation Coordination**:
- Sequential phase management using animation status listeners
- Physics calculations updated on each frame using `AnimationController.addListener()`
- Screen boundary detection using `MediaQuery.of(context).size`

### Performance Notes:
- Leverage existing `AnimationController` in IcebreakerCard for 60fps animations
- `Transform` widgets already implemented for efficient rotations/scaling
- Use `TickerProviderStateMixin` for multiple AnimationControllers (tumble + settle + reveal)
- Optimize image loading for web performance (already handled in IcebreakerCard)
- Consider `RepaintBoundary` for complex physics animations

### Responsive Design:
- Test on various screen sizes
- Ensure sheep scaling works on tablets
- Consider landscape vs portrait orientations

### Error Handling & Recovery Flows:
- **Sensor Permission Denied**: Graceful fallback to alternative input methods
- **Network Connectivity Issues**: Offline mode with local session management
- **Animation Performance Degradation**: Automatic quality reduction on slower devices
- **Browser Compatibility**: Feature detection with progressive enhancement
- **Shake Detection Failure**: Manual tumble button with same physics
- **Group Session Disconnection**: Automatic reconnection with state recovery
- **Export Failures**: Retry mechanisms with local backup storage
- **Accessibility Override**: Always available alternative completion paths

### Accessibility & Inclusive Design:
- **Motor Accessibility**: Alternative to shake gesture (tap, swipe, button press)
- **Visual Accessibility**: High contrast themes, larger text options, screen reader support
- **Cognitive Accessibility**: Clear instruction progression, optional text descriptions of animations
- **Reduced Motion**: Settings to disable physics animations while maintaining core functionality
- **Keyboard Navigation**: Full experience accessible via keyboard/screen reader
- **Multi-language**: Internationalization framework for mood descriptions and instructions
- **Device Capability**: Automatic detection of device limitations with appropriate fallbacks

### Analytics & Session Management:
- **Usage Tracking**: Completion rates, average time, retry patterns, accessibility feature usage
- **Performance Monitoring**: Animation frame rates, physics calculation efficiency, memory usage
- **Group Insights**: Mood distribution patterns, participation rates, discussion prompt effectiveness
- **Error Analytics**: Common failure points, device compatibility issues, user recovery paths
- **A/B Testing Framework**: For optimizing animation timing, instruction clarity, mood descriptions

### Browser Compatibility:
- Test accelerometer support across browsers (Chrome, Safari, Firefox, Edge)
- Progressive enhancement: full experience on mobile, adapted experience on desktop
- Handle permission requests for device sensors gracefully
- Fallback input methods for browsers without sensor support
- WebGL performance considerations for complex physics animations

---

## Development Workflow

### Phase-by-Phase Development:
1. **Start each phase** with Claude Code assistance for file creation and boilerplate
2. **Test immediately** using hot reload for rapid iteration on animations
3. **Debug systematically**:
   - Use Flutter Inspector to monitor animation performance
   - Add debug prints for shake detection and physics values
   - Test sensor permissions on both mobile and web platforms

### Testing Strategy:
- **Phase 1**: Test shake detection with `flutter run -d chrome` and mobile devices
- **Phase 2-3**: Use animation debug tools and frame rate monitoring
- **Phase 4**: Test mood reveal timing and readability across screen sizes
- **All phases**: Cross-browser testing (Chrome, Safari, Firefox)

### Hot Reload Optimization:
- Separate physics calculations into pure functions for better hot reload
- Use const constructors where possible to maintain widget state
- Structure animation code to preserve state during development

### Performance Monitoring:
- Monitor frame rates during physics animations (target: 60fps)
- Use Flutter's performance profiler for animation bottlenecks
- Test memory usage with multiple animation controllers

### User Feedback Collection:
- **After Phase 4**: Deploy test version to gather feedback on "fun factor"
- Focus on interaction clarity and completion rates
- Document animation timing preferences for future icebreakers

### Code Organization:
- Commit after each major milestone within phases
- Use feature branches for experimental animation approaches
- Keep shared components generic for reuse in future icebreakers

---

## Success Metrics

### Individual Experience Metrics:
- **Interaction Clarity**: Users understand the shake gesture within 10 seconds
- **Completion Rate**: >90% of participants complete the icebreaker successfully
- **Engagement Level**: Positive feedback on "fun factor" and emotional response
- **Accessibility Success**: All users can complete regardless of device/ability limitations
- **Performance Quality**: Smooth 60fps animations across target devices and browsers

### Group Workshop Metrics:
- **Facilitator Adoption**: Workshop leaders can set up sessions in <2 minutes
- **Participation Rate**: >95% of session participants engage with the icebreaker
- **Discussion Quality**: Generated mood results lead to meaningful conversations
- **Session Flow**: Seamless integration into existing workshop structures
- **Retention**: Facilitators reuse the tool in multiple workshops

### Technical Performance Metrics:
- **Cross-Platform Reliability**: Consistent experience across mobile web browsers
- **Error Recovery**: <1% of sessions fail due to technical issues
- **Load Performance**: Initial app load <3 seconds on 3G connections
- **Offline Capability**: Basic functionality available without network connection
- **Accessibility Compliance**: WCAG 2.1 AA compliance for inclusive design

### Long-term Impact Metrics:
- **Workshop Enhancement**: Measurable improvement in team engagement scores
- **Scalability**: Supports workshops from 3-50 participants without performance degradation
- **Customization Adoption**: >50% of facilitators customize content for their context
- **Global Reach**: Multi-language support enables international workshop use