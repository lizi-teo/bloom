import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';
import 'package:web/web.dart' as web;
import '../../../core/components/molecules/session_qr_code_card.dart';
import '../../../core/components/molecules/app_states.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/themes/spacing_theme.dart';

class QrCodeShareContent extends StatefulWidget {
  final int sessionId;

  const QrCodeShareContent({super.key, required this.sessionId});

  @override
  State<QrCodeShareContent> createState() => _QrCodeShareContentState();
}

class _QrCodeShareContentState extends State<QrCodeShareContent> {
  final _supabase = Supabase.instance.client;
  final _scrollController = ScrollController();

  bool _isLoading = true;
  bool _isAnimationLoading = true;
  Map<String, dynamic>? _sessionData;
  String _participantAccessUrl = '';
  String _participantAccessPath = '';
  String _sessionCode = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrGenerateSessionData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _generateSessionCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  Future<void> _loadOrGenerateSessionData() async {
    try {
      // First, fetch existing session data
      final sessionResponse = await _supabase
          .from('sessions')
          .select('session_id, session_name, template_id, session_code, participant_access_url, created_at, templates!inner(template_name, image_url)')
          .eq('session_id', widget.sessionId)
          .single();

      setState(() {
        _sessionData = sessionResponse;
      });

      // Check if session_code already exists
      if (sessionResponse['session_code'] != null && sessionResponse['participant_access_url'] != null) {
        _sessionCode = sessionResponse['session_code'];
        _participantAccessPath = sessionResponse['participant_access_url'];
        
        // Handle legacy URLs that still contain full URLs
        if (_participantAccessPath.startsWith('http')) {
          // Extract path from full URL
          final uri = Uri.parse(_participantAccessPath);
          _participantAccessPath = uri.fragment.isNotEmpty ? '#${uri.fragment}' : uri.path;
          
          // Update database with cleaned path
          await _supabase.from('sessions').update({
            'participant_access_url': _participantAccessPath,
          }).eq('session_id', widget.sessionId);
        }
        
        // Construct full URL with current environment's base URL
        final baseUrl = _getCurrentBaseUrl();
        _participantAccessUrl = '$baseUrl$_participantAccessPath';
      } else {
        // Fallback: Generate new session code and URL for existing sessions
        await _generateAndSaveSessionCode();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading session data: $e');
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _generateAndSaveSessionCode() async {
    const maxAttempts = 10;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        _sessionCode = _generateSessionCode();
        _participantAccessPath = '/#/session/$_sessionCode';
        
        // Construct full URL with current environment's base URL for display
        final baseUrl = _getCurrentBaseUrl();
        _participantAccessUrl = '$baseUrl$_participantAccessPath';

        // Update the session with the new code and path (not full URL)
        await _supabase.from('sessions').update({
          'session_code': _sessionCode,
          'participant_access_url': _participantAccessPath, // Store only the path
        }).eq('session_id', widget.sessionId);

        // Success - break out of loop
        break;
      } catch (e) {
        // If unique constraint violation, try again with a new code
        if (e.toString().contains('duplicate') || e.toString().contains('unique')) {
          attempts++;
          if (attempts >= maxAttempts) {
            throw Exception('Could not generate unique session code after $maxAttempts attempts');
          }
        } else {
          // Some other error - rethrow it
          rethrow;
        }
      }
    }
  }

  String _getCurrentBaseUrl() {
    // For web platform, get the current URL dynamically
    try {
      final uri = Uri.parse(web.window.location.href);
      final baseUrl = '${uri.scheme}://${uri.host}:${uri.port}';
      debugPrint('🔗 Dynamic base URL detected: $baseUrl');
      return baseUrl;
    } catch (e) {
      // Fallback to environment variable for non-web platforms
      debugPrint('⚠️ Failed to detect dynamic URL, using fallback: $e');
      return const String.fromEnvironment('APP_BASE_URL', defaultValue: 'https://bloom-e0901.web.app');
    }
  }


  // Helper methods for responsive sizing (optimized for mobile)
  EdgeInsets _getContentPadding() {
    return context.pageEdgePadding;
  }

  double _getContentMaxWidth(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.compact:
        return double.infinity;
      case ScreenSize.medium:
        return 900; // Match Create Sessions
      case ScreenSize.expanded:
        return 1200; // Match Create Sessions
    }
  }

  double _getTopPadding(BuildContext context) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.compact:
        return context.spacing.xxxl + context.spacing.lg;
      case ScreenSize.medium:
        return context.spacing.xxl;
      case ScreenSize.expanded:
        return context.spacing.xl;
    }
  }

  // Responsive typography utility following Material Design 3 standards
  static TextStyle getResponsiveStyle(
    BuildContext context,
    TextStyle baseStyle, {
    double? customMobileScale,
    double? customTabletScale,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = baseStyle.fontSize ?? 16.0;
    
    // Material Design 3 responsive scaling factors
    const double mobileScaleFactor = 0.875;  // 12.5% smaller
    const double tabletScaleFactor = 0.95;   // 5% smaller
    
    double responsiveFontSize;
    
    if (screenWidth < 600) {
      responsiveFontSize = fontSize * (customMobileScale ?? mobileScaleFactor);
    } else if (screenWidth < 1024) {
      responsiveFontSize = fontSize * (customTabletScale ?? tabletScaleFactor);
    } else {
      responsiveFontSize = fontSize; // Desktop baseline
    }
    
    return baseStyle.copyWith(fontSize: responsiveFontSize);
  }
  
  
  // Body text optimized for different screen sizes
  static TextStyle bodyText(BuildContext context) {
    return getResponsiveStyle(context, Theme.of(context).textTheme.bodyLarge!);
  }
  
  // Helper method for responsive title text style (matching Create Session)
  static TextStyle getTitleTextStyle(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 600) {
      return theme.textTheme.headlineLarge!;
    } else if (screenWidth < 1024) {
      return theme.textTheme.displaySmall!;
    } else {
      return theme.textTheme.displayLarge!;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingState(
        message: 'Loading QR code...',
      );
    }

    if (_error != null || _sessionData == null) {
      return ErrorState(
        title: 'Unable to Load QR Code',
        message: _error ?? 'Session data could not be loaded',
        icon: Icons.qr_code_2,
        onRetry: _loadOrGenerateSessionData,
        retryButtonText: 'Try Again',
      );
    }

    return Semantics(
      label: 'QR code sharing screen',
      hint: 'Share this QR code for participants to join your session',
      child: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Column(
            children: [
              SizedBox(height: _getTopPadding(context)),

              // Content section with responsive breakpoints
              _buildResponsiveContent(context),
              
              SizedBox(
                height: context.spacing.xxxl + MediaQuery.of(context).padding.bottom,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveContent(BuildContext context) {
    final screenSize = getScreenSize(context);
    
    if (screenSize == ScreenSize.compact) {
      // Mobile: single column layout
      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: double.infinity),
          child: Padding(
            padding: _getContentPadding(),
            child: _buildQrContent(context),
          ),
        ),
      );
    } else {
      // Tablet/Desktop: two column layout with animation
      return Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: _getContentMaxWidth(screenSize)),
          child: Padding(
            padding: _getContentPadding(),
            child: Row(
              children: [
                // Left side: QR content (5/12 ratio)
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.spacing.lg),
                    child: _buildQrContent(context),
                  ),
                ),
                
                SizedBox(width: context.spacing.xxxl + context.spacing.lg),
                
                // Right side: Animation container (7/12 ratio) - aligned to top
                Expanded(
                  flex: 7,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: _buildAnimationContainer(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildQrContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Page title with responsive typography (matching Create Session)
        Text(
          'Share session',
          style: getTitleTextStyle(context).copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        
        SizedBox(height: context.spacing.xl),
        
        // Subtitle with responsive typography
        Text(
          'Scan QR or copy link below',
          style: bodyText(context).copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        
        SizedBox(height: context.spacing.xxl),
        
        // QR Code Card
        Semantics(
          label: 'Session QR code',
          hint: 'QR code and link for participants to join session',
          child: SessionQrCodeCard(
            title: '',
            subtitle: '',
            instructionText: '',
            participantAccessUrl: _participantAccessUrl,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimationContainer(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Fixed height to match QR code section
    const containerHeight = 400.0;
    
    return SizedBox(
      width: double.infinity,
      height: containerHeight,
      child: Stack(
        children: [
          // Lottie animation (always visible)
          Positioned.fill(
            child: Lottie.asset(
              'assets/lottie/paper-plane-heart.json',
              fit: BoxFit.contain,
              repeat: true,
              animate: true,
              onLoaded: (composition) {
                if (mounted) {
                  setState(() {
                    _isAnimationLoading = false;
                  });
                }
              },
            ),
          ),
          
          // Loading overlay when animation is loading
          if (_isAnimationLoading)
            Positioned.fill(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.animation,
                      size: 64,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    ),
                    SizedBox(height: context.spacing.lg),
                    Text(
                      'Loading animation...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}