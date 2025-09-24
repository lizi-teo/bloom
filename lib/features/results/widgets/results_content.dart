import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/components/molecules/simple_results_card.dart';
import '../../../core/components/molecules/decoration_tape.dart';
import '../../../core/components/molecules/collapsing_header.dart';
import '../../../core/components/molecules/app_states.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/themes/spacing_theme.dart';

class ResultsContent extends StatefulWidget {
  final int sessionId;
  final int? templateId;

  const ResultsContent({
    super.key,
    required this.sessionId,
    this.templateId,
  });

  @override
  State<ResultsContent> createState() => _ResultsContentState();
}

class _ResultsContentState extends State<ResultsContent> {
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
    try {
      final supabase = Supabase.instance.client;

      // Get template ID and template info from session
      int templateId = widget.templateId ?? 0;
      if (templateId == 0) {
        final sessionData = await supabase.from('sessions').select('template_id, templates(template_name, image_url)').eq('session_id', widget.sessionId).single();
        templateId = sessionData['template_id'];
        _templateTitle = sessionData['templates']['template_name'] ?? 'Results';
        _templateImageUrl = sessionData['templates']['image_url'];
      } else {
        // If template ID is provided, fetch template info
        final templateData = await supabase.from('templates').select('template_name, image_url').eq('template_id', templateId).single();
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

  Widget _buildResultsContent() {
    if (_isLoading) {
      return const LoadingState(
        message: 'Loading results...',
      );
    }

    if (_error != null) {
      return ErrorState(
        title: 'Unable to Load Results',
        message: _error,
        icon: Icons.analytics_outlined,
        onRetry: _checkQuestionTypes,
        retryButtonText: 'Try Again',
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

    return EmptyState(
      title: 'No Questions Found',
      subtitle: 'This session doesn\'t have any questions to analyze.',
      icon: Icons.quiz_outlined,
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

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Session results screen',
      hint: 'View feedback results and analytics for this session',
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: RefreshIndicator(
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
                    // Add spacing after header
                    SizedBox(height: context.spacing.xl),

                    // Content section with responsive breakpoints
                    Center(
                      child: Container(
                        constraints: BoxConstraints(maxWidth: _getContentMaxWidth(getScreenSize(context))),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: _getContentPadding(getScreenSize(context), context)),
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
      ),
    );
  }
}
