import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/components/molecules/simple_results_card.dart';
import '../../core/components/molecules/decoration_tape.dart';
import '../../core/components/molecules/collapsing_header.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/themes/spacing_theme.dart';

class DynamicResultsPage extends StatefulWidget {
  final int sessionId;
  final int? templateId;

  const DynamicResultsPage({
    super.key,
    required this.sessionId,
    this.templateId,
  });

  @override
  State<DynamicResultsPage> createState() => _DynamicResultsPageState();
}

class _DynamicResultsPageState extends State<DynamicResultsPage> with TickerProviderStateMixin {
  final _scrollController = ScrollController();
  
  bool _isLoading = true;
  bool _hasTextQuestions = false;
  bool _hasNonTextQuestions = false;
  String? _error;
  String? _templateTitle;
  String? _templateImageUrl;
  

  @override
  void initState() {
    super.initState();
    _checkQuestionTypes();
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  

  Future<void> _checkQuestionTypes() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final supabase = Supabase.instance.client;

      // Get template ID and template info from session
      int templateId = widget.templateId ?? 0;
      if (templateId == 0) {
        final sessionData = await supabase.from('sessions')
            .select('template_id, templates(template_name, image_url)')
            .eq('session_id', widget.sessionId)
            .single();
        templateId = sessionData['template_id'];
        _templateTitle = sessionData['templates']['template_name'] ?? 'Results';
        _templateImageUrl = sessionData['templates']['image_url'];
      } else {
        // If template ID is provided, fetch template info
        final templateData = await supabase.from('templates')
            .select('template_name, image_url')
            .eq('template_id', templateId)
            .single();
        _templateTitle = templateData['template_name'] ?? 'Results';
        _templateImageUrl = templateData['image_url'];
      }

      // Get all questions for this template with their component types
      final questionsData = await supabase.from('templates_questions').select('questions!inner(component_type_id)').eq('template_id', templateId);

      bool hasText = false;
      bool hasNonText = false;

      for (final questionJunction in questionsData) {
        final question = questionJunction['questions'] as Map<String, dynamic>;
        final componentTypeId = question['component_type_id'] as int;

        if (componentTypeId == 2) {
          // Text component type
          hasText = true;
        } else {
          // Slider (1) or Button (3) component types
          hasNonText = true;
        }

        // Early break if we found both types
        if (hasText && hasNonText) break;
      }

      if (mounted) {
        setState(() {
          _hasTextQuestions = hasText;
          _hasNonTextQuestions = hasNonText;
          _isLoading = false;
        });
        debugPrint('DEBUG Results Page: Session ${widget.sessionId} - hasText: $hasText, hasNonText: $hasNonText');
        debugPrint('DEBUG Results Page: Should show SentimentAnswersCard: ${hasText || hasNonText}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _checkQuestionTypes,
            color: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).colorScheme.surface,
            strokeWidth: 2.5,
            displacement: context.spacing.xxxl + context.spacing.sm,
            child: SafeArea(
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
              // Collapsing header as first sliver
              CollapsingHeader(
                title: _templateTitle ?? 'Results',
                imageUrl: _templateImageUrl,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                iconBackgroundColor: const Color(0xFFF8E503),
              ),
              // Main content
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Content section with responsive breakpoints
                    Center(
                      child: Container(
                        constraints: BoxConstraints(maxWidth: _getContentMaxWidth(getScreenSize(context))),
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: _getContentPadding(getScreenSize(context), context),
                            right: _getContentPadding(getScreenSize(context), context),
                            top: context.spacing.xl, // Add top spacing to prevent overlap with collapsing header
                          ),
                          child: Column(
                            children: [
                              _buildResultsContent(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: context.spacing.xxxl),
                    
                    // Decoration tape fills entire width with fallback to template image
                    DecorationTape(
                      imageUrl: _templateImageUrl,
                      sectionId: widget.sessionId,
                      templateId: widget.templateId,
                      itemSize: context.spacing.xxxl,
                      spacing: context.spacing.sm,
                    ),
                  ],
                ),
              ),
            ],
              ),
            ),
          ),
          // Positioned back button with safe area consideration (only for authenticated facilitators)
          if (Supabase.instance.client.auth.currentUser != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + context.spacing.lg,
              left: context.spacing.lg,
              child: SafeArea(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(context.spacing.xl),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }


  Widget _buildResultsContent() {
    if (_isLoading) {
      return Padding(
        padding: EdgeInsets.all(context.spacing.xl),
        child: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    if (_error != null) {
      return Container(
        height: 400,
        padding: EdgeInsets.all(context.spacing.xl),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              SizedBox(height: context.spacing.lg),
              Text(
                'Unable to Load Results',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.spacing.sm),
              Text(
                _error!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.spacing.xl),
              ElevatedButton(
                onPressed: _checkQuestionTypes,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    // Show unified results and sentiment card for all question types
    if (_hasTextQuestions || _hasNonTextQuestions) {
      debugPrint('DEBUG: Showing SimpleResultsCard');
      return SimpleResultsCard(
        key: ValueKey('simple_results_${widget.sessionId}'),
        sessionId: widget.sessionId,
      );
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.spacing.xl),
        child: Text(
          'No questions found for this session',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // Helper methods for responsive sizing - using standardized page edge padding
  double _getContentPadding(ScreenSize screenSize, BuildContext context) {
    return context.pageEdgePadding.left;
  }

  double _getContentMaxWidth(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.compact:
        return double.infinity;
      case ScreenSize.medium:
        return 600;
      case ScreenSize.expanded:
        return 840;
    }
  }

}
