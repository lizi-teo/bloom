# BubbleCard - Shiny Water Bubble Component

## Overview
Create a new variant of the existing `icebreaker_card.dart` that looks like a shiny water bubble with realistic physics-based animations.

## Current State
- Existing component: `/lib/core/components/atoms/icebreaker_card.dart`
- Current design: Rounded rectangle with scale/rotation tap animations
- Well-structured with customizable size, image handling, and tap callbacks

## Goal
Create a circular, shiny water bubble container that maintains all functionality of the original card but with completely different aesthetics and animations.

## Implementation Plan

### 1. Create New Component
- **File**: `lib/core/components/atoms/bubble_card.dart`
- **Class Name**: `BubbleCard`
- **API Compatibility**: Same interface as original (imagePath, size, onTap)
- **Keep Original**: Leave existing `icebreaker_card.dart` unchanged

### 2. Visual Design - Shiny Water Bubble
- **Shape**: Perfect circle using `BorderRadius.circular(size/2)`
- **Multi-layer gradients**: Radial gradients for depth simulation
- **Shine effects**: Top-left highlight with moving glints
- **Glass transparency**: Semi-transparent overlays with different opacities
- **Surface tension border**: Dynamic rim with subtle thickness variations

### 3. Tap Animation Sequence (Combination Approach)
**Phase 1 - Initial Impact**
- Slight squish (vertical compression ~0.92x height)
- Surface tension breaking effect

**Phase 2 - Ripple Effects**
- Concentric circles emanating from tap point
- Fade out as they expand beyond bubble boundary
- Multiple ripples with slight delays for realism

**Phase 3 - Wobble Physics**
- Jelly-like oscillation with dampening
- Physics-based wobble that gradually settles

**Phase 4 - Elastic Recovery**
- Bounce back to perfect circle
- Elastic curve animation

**Throughout All Phases**
- Moving highlights and shimmer effects
- Image shifts slightly (internal liquid motion)

### 4. Enhancement Features

**Idle State Animations**
- Subtle pulsing "living" breathing effect (0.98x to 1.02x scale)
- Shimmer overlay: Diagonal light sweep every 3-4 seconds

**Interactive Effects**
- Surface tension border that responds to animations
- Internal liquid motion: Image shifts during wobble

### 5. Technical Implementation

**Animation Controllers**
- Multiple AnimationController instances for different effects
- Staggered timing for realistic physics
- Custom curves for elastic/damping effects

**Custom Painting**
- CustomPainter for ripple effects (concentric circles)
- Gradient overlays for shine and depth
- Clipping for perfect circular boundary

**Animation Curves**
- `Curves.elasticOut` for bounce-back
- `Curves.bounceOut` for wobble dampening
- Custom curves for ripple expansion

## Expected Result
A realistic water bubble that:
1. Squishes on initial tap
2. Shows ripple effects
3. Wobbles with physics dampening
4. Bounces back elastically to perfect circle
5. Has beautiful shine effects throughout
6. Maintains all original functionality

## Usage
Will be drop-in replacement for `IcebreakerCard` with same API:
```dart
BubbleCard(
  imagePath: 'path/to/image.png',
  size: 180,
  onTap: () => handleTap(),
)
```

## Notes
- Maintain error handling for images
- Keep accessibility features
- Ensure smooth 60fps animations
- Test on both light and dark themes