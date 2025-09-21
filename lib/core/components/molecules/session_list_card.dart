import 'package:flutter/material.dart';
import '../../themes/spacing_theme.dart';

class SessionListCard extends StatelessWidget {
  final String sessionName;
  final String submissionsCount;
  final String? template;
  final String? imageUrl;
  final Color? imageBackgroundColor;
  final Widget? imageWidget;
  final VoidCallback? onPrimaryAction;
  final VoidCallback? onSecondaryAction;
  final String? primaryActionLabel;
  final String? secondaryActionLabel;
  final bool showSecondaryAction;
  final VoidCallback? onDeleteAction;

  const SessionListCard({
    super.key,
    required this.sessionName,
    required this.submissionsCount,
    this.template,
    this.imageUrl,
    this.imageBackgroundColor,
    this.imageWidget,
    this.onPrimaryAction,
    this.onSecondaryAction,
    this.primaryActionLabel,
    this.secondaryActionLabel,
    this.showSecondaryAction = true,
    this.onDeleteAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      color: colorScheme.surfaceContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.spacing.sm),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.spacing.lg,
        context.spacing.md, // Responsive padding using theme
        context.spacing.xs, // Allow space for IconButton (which has its own padding)
        context.spacing.md, // Responsive padding using theme
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align to top for proper positioning
        children: [
          Padding(
            padding: EdgeInsets.only(top: context.spacing.xs), // Align image with text baseline
            child: _buildImage(context),
          ),
          SizedBox(width: context.spacing.lg),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: context.spacing.xs), // Align text with image
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sessionName,
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (template != null) ...[
                    SizedBox(height: context.spacing.xs),
                    Text(
                      template!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: context.spacing.sm), // More space above icon and count
                    _buildSubmissionCount(context),
                  ],
                ],
              ),
            ),
          ),
          if (onDeleteAction != null) _buildMenuButton(context),
        ],
      ),
    );
  }


  Widget _buildImage(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = imageBackgroundColor ?? colorScheme.primary;

    final imageSize = _getImageSize(context); // Responsive image sizing

    return Container(
      width: imageSize,
      height: imageSize,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4.0), // Corner radius 4 as requested
      ),
      clipBehavior: Clip.antiAlias,
      child: imageWidget ??
          (imageUrl != null
              ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  width: imageSize,
                  height: imageSize,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.image_outlined,
                        color: colorScheme.onPrimary,
                        size: context.spacing.xxl,
                      ),
                    );
                  },
                )
              : Center(
                  child: Icon(
                    Icons.favorite,
                    color: colorScheme.onPrimary,
                    size: context.spacing.xxl,
                  ),
                )),
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopupMenuButton<String>(
      onSelected: (String result) {
        if (result == 'delete' && onDeleteAction != null) {
          _showDeleteConfirmationDialog(context);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'delete',
          padding: EdgeInsets.symmetric(
            horizontal: context.spacing.md,
            vertical: 0, // Remove vertical padding completely
          ),
          height: 32, // Much smaller height for compact menu
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.delete_outline,
                size: 16, // Even smaller icon
                color: colorScheme.error,
              ),
              SizedBox(width: context.spacing.xs * 1.5), // Even tighter spacing
              Text(
                'Delete',
                style: theme.textTheme.labelSmall?.copyWith( // Use labelSmall for more compact text
                  color: colorScheme.error,
                  fontWeight: FontWeight.w500, // Slightly bolder for readability
                ),
              ),
            ],
          ),
        ),
      ],
      // Simple icon for PopupMenuButton
      icon: Icon(
        Icons.more_vert,
        color: colorScheme.onSurfaceVariant,
        size: 24,
      ),
      iconSize: 24,
      padding: EdgeInsets.all(context.spacing.sm),
      constraints: const BoxConstraints(
        minWidth: 40,
        minHeight: 40,
      ),
      tooltip: 'More options',
      // Add corner radius to popup menu (Material Design 3)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.spacing.xs),
      ),
      color: colorScheme.surfaceContainerHighest,
      elevation: 3, // MD3 elevation for menus
      shadowColor: colorScheme.shadow,
      surfaceTintColor: colorScheme.surfaceTint,
      // MD3: Proper positioning from edge
      offset: Offset(0, context.spacing.sm),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.spacing.lg), // MD3: 28dp radius
          ),
          backgroundColor: colorScheme.surfaceContainerHigh,
          surfaceTintColor: colorScheme.surfaceTint,
          elevation: 6, // MD3 elevation for dialogs
          shadowColor: colorScheme.shadow,
          title: Text(
            'Delete Session',
            style: textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "$sessionName"? This action cannot be undone.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
                overlayColor: colorScheme.primary.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.spacing.lg),
                ),
              ),
              child: Text(
                'Cancel',
                style: textTheme.labelLarge,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDeleteAction?.call();
              },
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.error,
                overlayColor: colorScheme.error.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.spacing.lg),
                ),
              ),
              child: Text(
                'Delete',
                style: textTheme.labelLarge,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActions(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive button sizing based on screen width
    final isSmallScreen = screenWidth < 600;

    // Material Design 3 compliant button sizing
    final buttonPadding = EdgeInsets.symmetric(
      horizontal: isSmallScreen ? context.spacing.lg : context.spacing.xl,
      vertical: context.spacing.sm, // Consistent vertical padding
    );

    final buttonHeight = isSmallScreen
        ? 40.0 // Material Design 3 minimum button height
        : 48.0; // Larger touch target for desktop

    final buttonSpacing = 8.0; // Material Design 3 standard button spacing

    // Material Design 3 button text styles
    final buttonTextStyle = theme.textTheme.labelLarge; // Consistent text style for all buttons

    return Padding(
      padding: EdgeInsets.all(context.spacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end, // Align buttons to the right
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showSecondaryAction && onSecondaryAction != null) ...[
            Flexible(
              child: OutlinedButton(
                onPressed: onSecondaryAction,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(colorScheme.surface.withValues(alpha: 0.0)),
                  foregroundColor: WidgetStateProperty.all(colorScheme.onSurfaceVariant),
                  padding: WidgetStateProperty.all(buttonPadding),
                  minimumSize: WidgetStateProperty.all(Size(0, buttonHeight)),
                  elevation: WidgetStateProperty.all(0),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // Material Design 3 button rounding
                  ),
                  side: WidgetStateProperty.all(
                    BorderSide(color: colorScheme.outline),
                  ),
                ),
                child: Text(
                  secondaryActionLabel ?? '',
                  style: buttonTextStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            SizedBox(width: buttonSpacing),
          ],
          if (onPrimaryAction != null)
            Flexible(
              child: FilledButton(
                onPressed: onPrimaryAction,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(colorScheme.primary),
                  foregroundColor: WidgetStateProperty.all(colorScheme.onPrimary),
                  padding: WidgetStateProperty.all(buttonPadding),
                  minimumSize: WidgetStateProperty.all(Size(0, buttonHeight)),
                  elevation: WidgetStateProperty.all(0),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // Material Design 3 button rounding
                  ),
                ),
                child: Text(
                  primaryActionLabel ?? '',
                  style: buttonTextStyle?.copyWith(
                    color: colorScheme.onPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        ],
      ),
    );
  }


  double _getImageSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth < 600 ? 64.0 : 90.0; // Compact: 64x64, Medium/Expanded: 90x90
  }

  Widget _buildSubmissionCount(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Extract number from submissions text
    final match = RegExp(r'(\d+)').firstMatch(submissionsCount);
    final count = match?.group(1) ?? '0';
    final isEmptyState = submissionsCount.toLowerCase().contains('no submissions') ||
                        submissionsCount.toLowerCase().contains('0 submissions');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.face_outlined, // Face outlined icon - lighter weight, perfect for feedback submissions
          size: 24.0, // Fixed 24x24 size
          color: colorScheme.onSurfaceVariant, // Neutral color for informational icon
        ),
        SizedBox(width: context.spacing.xs), // Increased spacing between icon and counter
        Text(
          isEmptyState ? '0' : count,
          style: theme.textTheme.labelLarge?.copyWith(
            color: isEmptyState ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
