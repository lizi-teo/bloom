import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../utils/responsive_utils.dart';

class SessionQrCodeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String instructionText;
  final String participantAccessUrl;
  final VoidCallback? onTap;
  final VoidCallback? onUrlCopied;

  const SessionQrCodeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.instructionText,
    required this.participantAccessUrl,
    this.onTap,
    this.onUrlCopied,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = getScreenSize(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      color: colorScheme.surfaceContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0), // 20dp to match Figma
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.0),
        child: Padding(
          padding: EdgeInsets.all(_getCardPadding(screenSize)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title.isNotEmpty) ...[
                _buildTitle(context),
                SizedBox(height: _getSpacing(screenSize)),
              ],
              if (subtitle.isNotEmpty) ...[
                _buildSubtitle(context),
                SizedBox(height: _getSpacing(screenSize)),
              ],
              if (instructionText.isNotEmpty) ...[
                _buildInstructionText(context),
                SizedBox(height: _getSpacing(screenSize)),
              ],
              _buildQrCodeSection(context, screenSize),
              SizedBox(height: _getSpacing(screenSize)),
              _buildShareableLink(context, screenSize),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Text(
      title,
      style: theme.textTheme.headlineLarge!.copyWith(
        color: colorScheme.onSurface,
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Text(
      subtitle,
      style: _bodyText(context).copyWith(
        color: colorScheme.onSurface,
      ),
    );
  }

  Widget _buildInstructionText(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Text(
      instructionText,
      style: _bodyText(context).copyWith(
        color: colorScheme.onSurface,
      ),
    );
  }

  Widget _buildQrCodeSection(BuildContext context, ScreenSize screenSize) {
    return Center(
      child: Container(
        width: _getQrCodeSize(screenSize),
        height: _getQrCodeSize(screenSize),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: Colors.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: participantAccessUrl.isNotEmpty
              ? QrImageView(
                  data: participantAccessUrl,
                  version: QrVersions.auto,
                  size: _getQrCodeSize(screenSize),
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.all(16.0),
                )
              : Container(
                  width: _getQrCodeSize(screenSize),
                  height: _getQrCodeSize(screenSize),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Icon(
                    Icons.qr_code,
                    size: _getQrCodeSize(screenSize) * 0.5,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildShareableLink(BuildContext context, ScreenSize screenSize) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.link,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Shareable Link',
                  style: _labelText(context).copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      participantAccessUrl.isNotEmpty ? participantAccessUrl : 'No URL available',
                      style: _bodyMediumText(context).copyWith(
                        color: participantAccessUrl.isNotEmpty ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (participantAccessUrl.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _copyToClipboard(context),
                      borderRadius: BorderRadius.circular(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.copy,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context) async {
    if (participantAccessUrl.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: participantAccessUrl));

    // Trigger animation callback if provided
    onUrlCopied?.call();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Link copied to clipboard'),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      );
    }
  }

  double _getCardPadding(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.compact:
        return 12.0; // 12dp for mobile - optimized for smaller screens
      case ScreenSize.medium:
        return 20.0; // 20dp for tablet - balanced spacing
      case ScreenSize.expanded:
        return 28.0; // 28dp for desktop - comfortable but not excessive
    }
  }

  double _getSpacing(ScreenSize screenSize) {
    return 24.0; // 24dp spacing between elements - matches Figma
  }

  double _getQrCodeSize(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.compact:
        return 180.0; // Smaller for mobile with reduced padding
      case ScreenSize.medium:
        return 220.0; // Medium size for tablets
      case ScreenSize.expanded:
        return 260.0; // Good size for desktop two-column layout
    }
  }

  // Responsive typography utility following Material Design 3 standards
  static TextStyle _getResponsiveStyle(
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
  
  // Typography helpers for consistent responsive text
  static TextStyle _bodyText(BuildContext context) {
    return _getResponsiveStyle(context, Theme.of(context).textTheme.bodyLarge!);
  }
  
  static TextStyle _labelText(BuildContext context) {
    return _getResponsiveStyle(context, Theme.of(context).textTheme.labelLarge!);
  }
  
  static TextStyle _bodyMediumText(BuildContext context) {
    return _getResponsiveStyle(context, Theme.of(context).textTheme.bodyMedium!);
  }
}
