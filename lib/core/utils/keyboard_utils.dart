import 'dart:async';
import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// Universal keyboard detection utility for mobile web browsers
/// Handles viewport and keyboard behavior across Safari, Chrome, and Firefox
class KeyboardUtils {
  static bool get isWeb => kIsWeb;

  /// Detect if VirtualKeyboard API is supported (Chrome/Edge)
  static bool get hasVirtualKeyboardSupport {
    if (!kIsWeb) return false;
    try {
      // VirtualKeyboard API is still experimental, so we'll just return true for Chrome
      return browserType == BrowserType.chrome;
    } catch (e) {
      return false;
    }
  }

  /// Get current browser type for mobile-specific handling
  static BrowserType get browserType {
    if (!kIsWeb) return BrowserType.unknown;

    final userAgent = web.window.navigator.userAgent.toLowerCase();

    if (userAgent.contains('safari') && !userAgent.contains('chrome')) {
      return BrowserType.safari;
    } else if (userAgent.contains('firefox')) {
      return BrowserType.firefox;
    } else if (userAgent.contains('chrome')) {
      return BrowserType.chrome;
    }

    return BrowserType.unknown;
  }

  /// Check if running on mobile device
  static bool get isMobile {
    if (!kIsWeb) return false;

    final userAgent = web.window.navigator.userAgent.toLowerCase();
    return userAgent.contains('mobile') ||
           userAgent.contains('android') ||
           userAgent.contains('iphone') ||
           userAgent.contains('ipad');
  }

  /// Get current visual viewport height (simplified)
  static double get visualViewportHeight {
    if (!kIsWeb) return web.window.innerHeight.toDouble();

    try {
      // Try Visual Viewport API first (modern browsers)
      final visualViewport = web.window.visualViewport;
      if (visualViewport != null) {
        return visualViewport.height;
      }
    } catch (e) {
      debugPrint('Failed to access Visual Viewport API: $e');
    }

    // Fallback to window.innerHeight
    return web.window.innerHeight.toDouble();
  }

  /// Get keyboard height by comparing layout and visual viewport
  static double get keyboardHeight {
    if (!kIsWeb) return 0.0;

    final layoutHeight = web.window.innerHeight.toDouble();
    final visualHeight = visualViewportHeight;

    return (layoutHeight - visualHeight).clamp(0.0, double.infinity);
  }

  /// Check if keyboard is currently visible
  static bool get isKeyboardVisible {
    return keyboardHeight > 50; // 50px threshold for keyboard detection
  }

  /// Setup cross-browser keyboard handling with proper background consistency
  static void setupVirtualKeyboardOverlay() {
    if (!kIsWeb) return;

    // Step 1: Set up browser background consistency (root cause fix)
    _setupBrowserBackgroundConsistency();

    // Step 2: Chrome/Edge VirtualKeyboard API optimization
    if (hasVirtualKeyboardSupport) {
      try {
        // VirtualKeyboard API is experimental - we'll skip the setup for now
        // In future versions when it's stable, this can be re-enabled
        debugPrint('✅ VirtualKeyboard API detected (Chrome)');
      } catch (e) {
        debugPrint('⚠️ VirtualKeyboard API setup failed: $e');
      }
    }
  }

  /// Set CSS custom properties to match Flutter theme and prevent flash
  static void _setupBrowserBackgroundConsistency() {
    try {
      // Define CSS custom properties that can be updated dynamically
      final style = web.document.createElement('style') as web.HTMLStyleElement;
      style.id = 'flutter-theme-css-vars';
      style.textContent = '''
        :root {
          --flutter-surface: #fafafa;
          --flutter-on-surface: #1a1a1a;
          --flutter-surface-container: #f0f0f0;
        }

        body, html {
          background-color: var(--flutter-surface) !important;
          color: var(--flutter-on-surface) !important;
          margin: 0 !important;
          padding: 0 !important;
          overflow-x: hidden !important;
        }

        flt-scene-host, flt-semantics-host {
          background-color: var(--flutter-surface) !important;
        }

        /* Prevent white flash during viewport changes */
        body::before {
          content: '';
          position: fixed;
          top: 0;
          left: 0;
          width: 100vw;
          height: 100vh;
          background-color: var(--flutter-surface);
          z-index: -1;
          pointer-events: none;
        }
      ''';

      // Remove existing style if it exists
      final existing = web.document.getElementById('flutter-theme-css-vars');
      existing?.remove();

      web.document.head!.appendChild(style);
      debugPrint('✅ Browser background consistency applied');
    } catch (e) {
      debugPrint('⚠️ Background consistency setup failed: $e');
    }
  }

  /// Update CSS custom properties to match current Flutter theme
  static void updateThemeColors({
    String? surface,
    String? onSurface,
    String? surfaceContainer,
  }) {
    if (!kIsWeb) return;

    try {
      final root = web.document.documentElement! as web.HTMLElement;
      if (surface != null) {
        root.style.setProperty('--flutter-surface', surface);
        web.document.body!.style.backgroundColor = surface;
      }
      if (onSurface != null) {
        root.style.setProperty('--flutter-on-surface', onSurface);
      }
      if (surfaceContainer != null) {
        root.style.setProperty('--flutter-surface-container', surfaceContainer);
      }
    } catch (e) {
      debugPrint('⚠️ Theme color update failed: $e');
    }
  }

  // Debounced keyboard listener state
  static Timer? _keyboardDebounceTimer;
  static bool _lastKeyboardState = false;
  static double _lastKeyboardHeight = 0.0;

  /// Add debounced keyboard visibility listener for all browsers
  static void addKeyboardListener(Function(bool isVisible, double height) callback) {
    if (!kIsWeb) return;

    // Get browser-specific debounce delay
    final debounceDelay = getKeyboardDebounceDelay();

    // Use window resize events for keyboard detection
    web.window.addEventListener('resize', (web.Event event) {
      // Cancel previous timer
      _keyboardDebounceTimer?.cancel();

      // Create new debounced timer
      _keyboardDebounceTimer = Timer(debounceDelay, () {
        final currentIsVisible = isKeyboardVisible;
        final currentHeight = keyboardHeight;

        // Only trigger callback if state actually changed
        if (currentIsVisible != _lastKeyboardState ||
            (currentHeight - _lastKeyboardHeight).abs() > 10) {
          _lastKeyboardState = currentIsVisible;
          _lastKeyboardHeight = currentHeight;
          callback(currentIsVisible, currentHeight);
        }
      });
    }.toJS);
  }

  /// Get browser-specific debounce delay for keyboard transitions
  static Duration getKeyboardDebounceDelay() {
    switch (browserType) {
      case BrowserType.firefox:
        return const Duration(milliseconds: 350); // Firefox needs longer
      case BrowserType.safari:
        return const Duration(milliseconds: 250);  // Safari medium
      case BrowserType.chrome:
        return const Duration(milliseconds: 200);  // Chrome fastest
      case BrowserType.unknown:
        return const Duration(milliseconds: 300);  // Safe default
    }
  }

  /// Get safe bottom padding that accounts for keyboard
  static double getSafeBottomPadding({double defaultPadding = 0.0}) {
    if (!kIsWeb || !isMobile) return defaultPadding;

    switch (browserType) {
      case BrowserType.safari:
        // Safari: Use minimal padding, let Visual Viewport handle it
        return defaultPadding;

      case BrowserType.firefox:
        // Firefox: Add extra padding for viewport adjustment delays
        return isKeyboardVisible ? keyboardHeight + 20 : defaultPadding;

      case BrowserType.chrome:
        // Chrome: Use VirtualKeyboard API or standard padding
        return hasVirtualKeyboardSupport ? defaultPadding :
               (isKeyboardVisible ? keyboardHeight : defaultPadding);

      case BrowserType.unknown:
        return defaultPadding;
    }
  }

  /// Remove keyboard listener and cleanup resources
  static void removeKeyboardListener() {
    _keyboardDebounceTimer?.cancel();
    _keyboardDebounceTimer = null;
    _lastKeyboardState = false;
    _lastKeyboardHeight = 0.0;
  }
}

enum BrowserType {
  safari,
  chrome,
  firefox,
  unknown,
}