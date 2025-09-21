import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../models/template.dart';
import '../../../core/services/session_service.dart';
import '../../../core/components/molecules/app_states.dart';
import '../../../core/providers/navigation_provider.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/themes/spacing_theme.dart';
import '../../../core/themes/app_theme.dart';

class SessionCreateContent extends StatefulWidget {
  final bool isEnhanced;
  
  const SessionCreateContent({super.key, this.isEnhanced = false});

  @override
  State<SessionCreateContent> createState() => _SessionCreateContentState();
}

class _SessionCreateContentState extends State<SessionCreateContent> {
  final _sessionService = SessionService();
  final _sessionNameController = TextEditingController();
  final _scrollController = ScrollController();

  Template? _selectedTemplate;
  List<Template> _templates = [];
  bool _isLoading = false;
  bool _isLoadingTemplates = false;
  bool _isAnimationLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
    
    // Add listener to session name controller for contextual animation
    _sessionNameController.addListener(_onFormStateChanged);
  }

  void _onFormStateChanged() {
    // Trigger rebuild to update animation state
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadTemplates() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingTemplates = true;
    });

    try {
      final templates = await _sessionService.getTemplates();
      if (!mounted) return;
      
      setState(() {
        _templates = templates;
        _isLoadingTemplates = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoadingTemplates = false;
      });
      
      if (mounted) {
        _showErrorMessage(
          context,
          message: 'Failed to load templates. Please check your connection and try again.',
          actionLabel: 'Retry',
          onAction: _loadTemplates,
        );
      }
    }
  }

  Future<void> _createSession() async {
    if (_sessionNameController.text.trim().isEmpty) {
      _showErrorMessage(context, message: 'Please enter a session name');
      return;
    }

    if (_selectedTemplate == null) {
      _showErrorMessage(context, message: 'Please select a template');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _sessionService.createSession(
        sessionName: _sessionNameController.text.trim(),
        templateId: _selectedTemplate!.templateId!,
      );

      if (mounted) {
        _showSuccessMessage('Session created successfully!');

        // Navigate back to sessions list using NavigationProvider
        context.read<NavigationProvider>().navigateTo('/sessions_list');
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage(
          context,
          message: 'Failed to create session. Please try again.',
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _sessionNameController.removeListener(_onFormStateChanged);
    _sessionNameController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildContent(context);
  }

  Widget _buildContent(BuildContext context) {
    if (_isLoadingTemplates) {
      return const Center(
        child: LoadingState(
          message: 'Loading templates...',
        ),
      );
    }

    if (_templates.isEmpty) {
      return _buildEmptyState(context);
    }

    return Semantics(
      label: 'Create session screen',
      hint: 'Create a new feedback session',
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        child: Column(
          children: [
            SizedBox(height: context.spacing.xxl),
            
            // Content section with responsive breakpoints (now includes header)
            _buildResponsiveContent(context),
            
            // System UI bottom padding as per #mobile requirements
            SizedBox(
              height: context.spacing.xxxl + MediaQuery.of(context).padding.bottom,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.spacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: context.spacing.lg),
            Text(
              'No Templates Available',
              style: theme.textTheme.headlineSmall!.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.spacing.sm),
            Text(
              'Templates are required to create a session. Please contact your administrator.',
              style: theme.textTheme.bodyMedium!.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.spacing.xl),
            FilledButton.icon(
              onPressed: _loadTemplates,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }




  Widget _buildFormContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Page title with enhanced typography for larger screens
        Text(
          'Create session',
          style: (widget.isEnhanced 
            ? theme.textTheme.displaySmall! 
            : _getTitleTextStyle(context)).copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        
        SizedBox(height: widget.isEnhanced ? context.spacing.xxl : context.spacing.xl),
        
        // Subtitle with enhanced typography
        Text(
          'Create a new feedback session for your team',
          style: (widget.isEnhanced ? theme.textTheme.titleLarge! : theme.textTheme.bodyLarge!).copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        
        SizedBox(height: widget.isEnhanced 
          ? context.spacing.xxxl + context.spacing.lg + context.spacing.lg 
          : context.spacing.xxxl + context.spacing.lg),
        
        _buildTextField(
          context: context,
          controller: _sessionNameController,
          label: 'Session Name',
          hintText: 'e.g., Sprint Review Q4 2024',
        ),

        SizedBox(height: widget.isEnhanced ? context.spacing.xxxl + context.spacing.lg : context.spacing.xxxl),

        _buildTemplateDropdown(context),

        SizedBox(height: widget.isEnhanced ? context.spacing.xxxl + context.spacing.lg + context.spacing.xxl : context.spacing.xxxl + context.spacing.lg),

        SizedBox(
          width: double.infinity,
          child: Semantics(
            label: 'Create session button',
            hint: 'Creates a new session with the entered details',
            button: true,
            child: FilledButton(
              onPressed: _isLoading ? null : _createSession,
              child: _isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : const Text('Create Session'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hintText,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Semantics(
      label: '$label field',
      hint: hintText,
      textField: true,
      child: TextFormField(
        controller: controller,
        style: theme.textTheme.bodyMedium!.copyWith(
          color: colorScheme.onSurface,
        ),
        decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: theme.textTheme.bodySmall!.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        hintStyle: theme.textTheme.bodyMedium!.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainer,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.spacing.sm),
          borderSide: BorderSide(
            color: colorScheme.outline,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.spacing.sm),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.spacing.sm),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.spacing.sm),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.spacing.lg,
          vertical: context.spacing.lg,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      ),
    );
  }

  Widget _buildTemplateDropdown(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    if (_isLoadingTemplates) {
      return LoadingState(
        message: 'Loading templates...',
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(context.spacing.sm),
            border: Border.all(color: colorScheme.outline),
          ),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
          ),
        ),
      );
    }

    return Semantics(
      label: 'Template selection',
      hint: 'Choose a feedback template for your session',
      child: DropdownButtonFormField<Template>(
      initialValue: _selectedTemplate,
      style: theme.textTheme.bodyMedium!.copyWith(
        color: colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: 'Template',
        hintText: 'Select a template',
        labelStyle: theme.textTheme.bodySmall!.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        hintStyle: theme.textTheme.bodyMedium!.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainer,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.spacing.sm),
          borderSide: BorderSide(
            color: colorScheme.outline,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.spacing.sm),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.spacing.sm),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.spacing.sm),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.spacing.lg,
          vertical: context.spacing.lg,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      dropdownColor: colorScheme.surfaceContainer,
      icon: Icon(
        Icons.keyboard_arrow_down,
        color: colorScheme.onSurfaceVariant,
      ),
      items: _templates.map((template) {
        return DropdownMenuItem<Template>(
          value: template,
          child: Text(
            template.templateName ?? 'Unknown Template',
            style: theme.textTheme.bodyMedium!.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        );
      }).toList(),
      onChanged: (Template? value) {
        setState(() {
          _selectedTemplate = value;
        });
        // Trigger animation state change
        _onFormStateChanged();
      },
    ),
    );
  }

  void _showErrorMessage(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: theme.textTheme.bodyMedium!.copyWith(
            color: colorScheme.onError,
          ),
        ),
        backgroundColor: colorScheme.error,
        behavior: SnackBarBehavior.floating,
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: colorScheme.onError,
                onPressed: onAction,
              )
            : null,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: theme.textTheme.bodyMedium!.copyWith(
            color: colorScheme.onSuccessContainer,
          ),
        ),
        backgroundColor: colorScheme.successContainer,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
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
            padding: EdgeInsets.symmetric(horizontal: _getContentPadding(screenSize)),
            child: _buildFormContent(context),
          ),
        ),
      );
    } else {
      // Tablet/Desktop: two column layout with enhanced spacing for large screens
      return Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: _getContentMaxWidth(screenSize)),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: _getContentPadding(screenSize)),
            child: Row(
              children: [
                // Left side: Form content with enhanced spacing
                Expanded(
                  flex: widget.isEnhanced ? 5 : 2, // Slightly wider form area when enhanced
                  child: Padding(
                    padding: widget.isEnhanced 
                      ? EdgeInsets.symmetric(horizontal: context.spacing.xl)
                      : EdgeInsets.zero,
                    child: _buildFormContent(context),
                  ),
                ),
                
                SizedBox(width: context.spacing.xxxl + context.spacing.lg),
                
                // Right side: Lottie animation container with better proportions
                Expanded(
                  flex: widget.isEnhanced ? 7 : 3, // More visual emphasis on animation when enhanced
                  child: _buildAnimationContainer(context),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildAnimationContainer(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = kToolbarHeight;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final colorScheme = Theme.of(context).colorScheme;
    
    // Calculate available height (screen minus app bar and system UI)
    final availableHeight = screenHeight - appBarHeight - statusBarHeight - bottomPadding - (context.spacing.xxxl + context.spacing.lg);
    
    return SizedBox(
      width: double.infinity,
      height: availableHeight,
      child: Stack(
        children: [
          // Lottie animation
          Positioned.fill(
            child: Lottie.asset(
              'assets/lottie/paper-plane-heart.json',
              fit: BoxFit.contain,
              repeat: _shouldAnimationRepeat(),
              animate: _shouldAnimationAnimate(),
              onLoaded: (composition) {
                if (mounted) {
                  setState(() {
                    _isAnimationLoading = false;
                  });
                }
              },
            ),
          ),
          
          // Skeleton loader overlay when loading
          if (_isAnimationLoading)
            Positioned.fill(
              child: SkeletonLoader(
                isLoading: true,
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(context.spacing.xl),
                  ),
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
              ),
            ),
        ],
      ),
    );
  }

  // Contextual animation control methods
  bool _shouldAnimationAnimate() {
    // Animate when loading or when user has interacted with form
    // Paper Plane Heart animation represents sending love/feedback
    return _isLoading || 
           _sessionNameController.text.isNotEmpty || 
           _selectedTemplate != null;
  }

  bool _shouldAnimationRepeat() {
    // Repeat animation during loading or when user is actively creating
    // The heart sends continuously while form is being filled
    return _isLoading || 
           _sessionNameController.text.isNotEmpty ||
           _selectedTemplate != null;
  }

  // Helper method for responsive title text style
  TextStyle _getTitleTextStyle(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.compact:
        return theme.textTheme.headlineLarge ?? theme.textTheme.headlineLarge!;
      case ScreenSize.medium:
        return theme.textTheme.displaySmall ?? theme.textTheme.headlineLarge!;
      case ScreenSize.expanded:
        return theme.textTheme.displayLarge ?? theme.textTheme.headlineLarge!;
    }
  }

  // Helper methods for responsive sizing
  double _getContentPadding(ScreenSize screenSize) {
    return context.pageEdgePadding.left;
  }

  double _getContentMaxWidth(ScreenSize screenSize) {
    if (widget.isEnhanced) {
      return 1400; // Enhanced layout uses wider containers
    }
    switch (screenSize) {
      case ScreenSize.compact:
        return double.infinity;
      case ScreenSize.medium:
        return 900; // Wider to accommodate larger animation
      case ScreenSize.expanded:
        return 1200; // Much wider for desktop to showcase animation
    }
  }
}