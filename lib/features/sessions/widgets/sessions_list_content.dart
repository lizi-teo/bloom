import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/session_service.dart';
import '../models/session_with_template.dart';
import '../../../core/components/molecules/session_list_card.dart';
import '../../../core/components/atoms/content_widget.dart';
import '../../../core/components/molecules/app_states.dart';
import '../../../core/providers/navigation_provider.dart';
import 'sessions_empty_state.dart';
import '../../../core/themes/spacing_theme.dart';
import '../../../core/utils/responsive_utils.dart';

class SessionsListContent extends ContentWidget {
  const SessionsListContent({super.key});

  @override
  String get title => 'Sessions';

  @override
  String get route => '/sessions_list';

  @override
  bool get showAppBar => false;

  @override
  Widget? get floatingActionButton => null; // Will be conditionally shown in _SessionsList

  @override
  Widget buildContent(BuildContext context) {
    return const _SessionsList();
  }
}

class _SessionsList extends StatefulWidget {
  const _SessionsList();

  @override
  State<_SessionsList> createState() => _SessionsListState();
}

class _SessionsListState extends State<_SessionsList> {
  final SessionService _sessionService = SessionService();
  List<SessionWithTemplate> _sessions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final sessions = await _sessionService.getSessionsWithTemplates();
      if (!mounted) return;

      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleDeleteSession(SessionWithTemplate sessionWithTemplate) async {
    final sessionId = sessionWithTemplate.session.sessionId;
    if (sessionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid session ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: context.spacing.lg,
                height: context.spacing.lg,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.onInverseSurface,
                  ),
                ),
              ),
              SizedBox(width: context.spacing.md),
              Text('Deleting ${sessionWithTemplate.sessionName}...'),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Delete the session
      await _sessionService.deleteSession(sessionId);

      // Clear any existing snackbars and show success message
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${sessionWithTemplate.sessionName} deleted successfully'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Refresh the sessions list
        await _loadSessions();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete session: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: _buildResponsiveLayout(constraints),
          floatingActionButton: _shouldShowFAB() ? _buildFloatingActionButton(context) : null,
        );
      },
    );
  }
  
  bool _shouldShowFAB() {
    return !_isLoading && _error == null && _sessions.isNotEmpty;
  }
  
  Widget _buildFloatingActionButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom +
                MediaQuery.of(context).padding.bottom,
      ),
      child: Semantics(
        label: 'Create new session',
        hint: 'Add a new feedback session',
        button: true,
        child: FloatingActionButton(
          onPressed: () {
            context.read<NavigationProvider>().navigateTo('/session_create');
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildResponsiveLayout(BoxConstraints constraints) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final width = constraints.maxWidth;
    
    return RefreshIndicator(
      onRefresh: _loadSessions,
      color: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surface,
      strokeWidth: 2.5,
      displacement: 40.0,
      child: SafeArea(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          semanticChildCount: _sessions.length,
          slivers: [
            // Content with responsive constraints
            SliverToBoxAdapter(
              child: _buildResponsiveContent(width, theme, colorScheme),
            ),
            // System UI bottom padding with responsive spacing
            SliverPadding(
              padding: EdgeInsets.only(
                bottom: _getBottomPadding(getScreenSize(context)) + MediaQuery.of(context).padding.bottom,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveContent(double width, ThemeData theme, ColorScheme colorScheme) {
    final screenSize = getScreenSize(context);

    Widget content = Padding(
      padding: _getPagePadding(screenSize),
      child: Column(
        children: [
          // Page title
          Padding(
            padding: _getTitlePadding(screenSize),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;

                // Use displayLarge for desktop (large text), headlineLarge for mobile
                final TextStyle baseStyle = screenWidth >= 600
                    ? theme.textTheme.displayLarge ?? const TextStyle()
                    : theme.textTheme.headlineLarge ?? const TextStyle();

                return Semantics(
                  label: 'Sessions, page heading',
                  header: true,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Sessions',
                      style: baseStyle.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Sessions content
          _buildSessionsContent(),
        ],
      ),
    );

    // Apply responsive constraints using ScreenSize enum pattern
    switch (screenSize) {
      case ScreenSize.compact:
        return content; // Full width for mobile
      case ScreenSize.medium:
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: content,
          ),
        ); // Constrained width for tablet
      case ScreenSize.expanded:
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: content,
          ),
        ); // Constrained width for desktop
    }
  }

  Widget _buildSessionsContent() {
    if (_isLoading) {
      return const SizedBox(
        height: 400,
        child: LoadingState(
          message: 'Loading sessions...',
        ),
      );
    }

    if (_error != null) {
      return SizedBox(
        height: 400,
        child: ErrorState(
          title: 'Unable to Load Sessions',
          message: _error,
          icon: Icons.folder_outlined,
          onRetry: _loadSessions,
          retryButtonText: 'Try Again',
        ),
      );
    }

    if (_sessions.isEmpty) {
      return const SizedBox(
        height: 400,
        child: SessionsEmptyState(),
      );
    }

    final screenSize = getScreenSize(context);

    return Column(
      children: _sessions.map((sessionWithTemplate) {
        return Padding(
          padding: EdgeInsets.only(bottom: _getSessionCardSpacing(screenSize)),
          child: _buildSessionCard(sessionWithTemplate),
        );
      }).toList(),
    );
  }


  // ✅ PRODUCTION STANDARD: ScreenSize enum pattern for page padding
  EdgeInsets _getPagePadding(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.compact:   // < 600dp
        return EdgeInsets.fromLTRB(context.spacing.lgPlus, context.spacing.xl, context.spacing.lgPlus, 0);
      case ScreenSize.medium:    // 600-959dp
        return EdgeInsets.fromLTRB(context.spacing.xl, context.spacing.xxl, context.spacing.xl, 0);
      case ScreenSize.expanded:  // >= 960dp
        return EdgeInsets.fromLTRB(context.spacing.xxl, context.spacing.xxl, context.spacing.xxl, 0);
    }
  }

  // Title spacing following #spacing patterns
  EdgeInsets _getTitlePadding(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.compact:
        return EdgeInsets.fromLTRB(0, 0, 0, context.spacing.xxl);
      case ScreenSize.medium:
        return EdgeInsets.fromLTRB(0, 0, 0, context.spacing.xxxl);
      case ScreenSize.expanded:
        return EdgeInsets.fromLTRB(0, 0, 0, context.spacing.xxxl);
    }
  }

  // Session card spacing following 8dp grid system
  double _getSessionCardSpacing(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.compact:
        return context.spacing.sm;  // 8dp
      case ScreenSize.medium:
        return context.spacing.md;  // 12dp
      case ScreenSize.expanded:
        return context.spacing.lg;  // 16dp
    }
  }

  // Bottom padding for better scroll experience
  double _getBottomPadding(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.compact:
        return context.spacing.xxxl;  // 48dp
      case ScreenSize.medium:
        return context.spacing.xxxl;  // 48dp
      case ScreenSize.expanded:
        return context.spacing.xxxl;  // 48dp
    }
  }

  Widget _buildSessionCard(SessionWithTemplate sessionWithTemplate) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final sessionId = sessionWithTemplate.session.sessionId;

    final submissionsText = sessionWithTemplate.resultsCount == 0 
        ? 'No submissions yet' 
        : '${sessionWithTemplate.resultsCount} ${sessionWithTemplate.resultsCount == 1 ? 'submission' : 'submissions'}';

    return SessionListCard(
      sessionName: sessionWithTemplate.sessionName,
      submissionsCount: submissionsText,
      template: sessionWithTemplate.templateName,
      imageUrl: sessionWithTemplate.imageUrl,
      imageBackgroundColor: colorScheme.primary,
      primaryActionLabel: 'Results',
      secondaryActionLabel: 'Share',
      showSecondaryAction: true,
      onPrimaryAction: () {
        if (sessionId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid session ID'),
            ),
          );
          return;
        }

        if (sessionWithTemplate.resultsCount > 0) {
          // Navigate to results page using NavigationProvider
          context.read<NavigationProvider>().navigateToResults(sessionId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No results available for this session yet'),
            ),
          );
        }
      },
      onSecondaryAction: () {
        if (sessionId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid session ID'),
            ),
          );
          return;
        }

        // Navigate to QR code page using NavigationProvider
        context.read<NavigationProvider>().navigateToQrCode(sessionId);
      },
      onDeleteAction: () => _handleDeleteSession(sessionWithTemplate),
    );
  }
}