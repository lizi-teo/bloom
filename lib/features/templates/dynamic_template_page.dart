import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/components/molecules/collapsing_header.dart';
import '../../core/components/molecules/slider_card.dart';
import '../../core/components/molecules/text_field_card.dart';
import '../../core/services/sentiment_service.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/themes/spacing_theme.dart';

// Text constants (in production, replace with proper i18n)
class _DynamicTemplateTexts {
  static const String loadingSessionData = 'Loading session data';
  static const String loadingTemplateData = 'Loading template data';
  static const String sessionNotFound = 'Session not found';
  static const String sessionCode = 'Session code';
  static const String failedToLoadTemplate = 'Failed to load template';
  static const String checkin = 'Check-in';
  static const String submitting = 'Submitting...';
  static const String submit = 'Submit';
  static const String submittingFeedback = 'Submitting feedback';
  static const String errorIcon = 'Error';
  static const String submitButton = 'Submit feedback';
  static const String submissionCompleted = 'completed successfully!';
  static const String failedToSubmitFeedback = 'Failed to submit feedback';
  static const String errorLoadingSession = 'Error loading session';
}

// Wrapper widget that looks up session ID by session code
class DynamicTemplatePageByCode extends StatefulWidget {
  final String sessionCode;

  const DynamicTemplatePageByCode({super.key, required this.sessionCode});

  @override
  State<DynamicTemplatePageByCode> createState() => _DynamicTemplatePageByCodeState();
}

class _DynamicTemplatePageByCodeState extends State<DynamicTemplatePageByCode> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  int? _sessionId;
  String? _error;

  // Error state spacing helper
  EdgeInsets _getErrorContentPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: context.pageEdgePadding.left,
      vertical: context.spacing.xl,
    );
  }

  @override
  void initState() {
    super.initState();
    _lookupSessionId();
  }

  Future<void> _lookupSessionId() async {
    try {
      debugPrint('🔍 Looking up session with code: ${widget.sessionCode}');

      // Fetch session with template data to ensure the template is available
      final response = await _supabase.from('sessions').select('session_id, template_id, session_name, created_at, templates!inner(template_name, image_url)').eq('session_code', widget.sessionCode).maybeSingle();

      debugPrint('📋 Session lookup response: $response');

      if (response != null) {
        debugPrint('✅ Found session ${response['session_id']} with template ${response['templates']['template_name']}');
        setState(() {
          _sessionId = response['session_id'];
          _isLoading = false;
        });
      } else {
        debugPrint('❌ Session not found for code: ${widget.sessionCode}');
        setState(() {
          _error = 'Session not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('💥 Error loading session: $e');
      setState(() {
        _error = 'Error loading session: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
              semanticsLabel: _DynamicTemplateTexts.loadingSessionData,
            ),
          ),
        ),
      );
    }

    if (_error != null || _sessionId == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: _getErrorContentPadding(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                    semanticLabel: _DynamicTemplateTexts.errorIcon,
                  ),
                  SizedBox(height: context.spacing.lg),
                  Text(
                    _error ?? _DynamicTemplateTexts.sessionNotFound,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.spacing.lg),
                  Text(
                    '${_DynamicTemplateTexts.sessionCode}: ${widget.sessionCode}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return DynamicTemplatePage(sessionId: _sessionId!);
  }
}

class DynamicTemplatePage extends StatefulWidget {
  final int sessionId;

  const DynamicTemplatePage({super.key, required this.sessionId});

  static const String routeName = '/session-template-get';

  @override
  State<DynamicTemplatePage> createState() => _DynamicTemplatePageState();
}

class _DynamicTemplatePageState extends State<DynamicTemplatePage> with TickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  final _scrollController = ScrollController();

  bool _isLoading = true;
  bool _isSubmitting = false;
  Map<String, dynamic>? _templateData;
  List<Map<String, dynamic>> _questions = [];
  final Map<int, dynamic> _answers = {}; // Changed to dynamic to handle different answer types

  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonAnimation;
  bool _showFloatingButton = false;

  @override
  void initState() {
    super.initState();
    _loadTemplateData();

    // Initialize animation controller for floating button
    _buttonAnimationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

    _buttonAnimation = CurvedAnimation(parent: _buttonAnimationController, curve: Curves.easeInOut);

    // Add scroll listener
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final scrollOffset = _scrollController.offset;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final scrollRatio = maxScroll > 0 ? scrollOffset / maxScroll : 0;

    // Show button when scrolled halfway down
    final shouldShow = scrollRatio >= 0.5;

    if (shouldShow != _showFloatingButton) {
      setState(() {
        _showFloatingButton = shouldShow;
      });

      if (shouldShow) {
        _buttonAnimationController.forward();
      } else {
        _buttonAnimationController.reverse();
      }
    }
  }

  Future<void> _loadTemplateData() async {
    try {
      // First, fetch session data to get the associated template_id
      final sessionResponse = await _supabase.from('sessions').select('session_id, template_id, session_name, created_at').eq('session_id', widget.sessionId).single();

      final templateId = sessionResponse['template_id'] as int?;
      if (templateId == null) {
        throw Exception('Session has no associated template');
      }

      // Fetch template data
      final templateResponse = await _supabase.from('templates').select().eq('template_id', templateId).single();

      // Fetch questions for this template with component type
      final questionsResponse = await _supabase.from('templates_questions').select('''
            questions (
              question_id,
              question,
              component_type_id,
              min_label,
              max_label,
              title,
              _component_type (
                name
              )
            )
          ''').eq('template_id', templateId);

      setState(() {
        _templateData = templateResponse;
        _questions = List<Map<String, dynamic>>.from(questionsResponse).map((item) => item['questions'] as Map<String, dynamic>).toList();

        // Initialize answers based on component type
        for (var question in _questions) {
          final questionId = question['question_id'] as int;
          final componentType = question['_component_type']?['name'];

          switch (componentType) {
            case 'slider':
              _answers[questionId] = 50; // Default slider value
              break;
            case 'text':
              _answers[questionId] = ''; // Default text value
              break;
          }
        }

        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading session/template data: $e');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_DynamicTemplateTexts.errorLoadingSession}: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _handleSubmit() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Step 1: Count existing submissions for this session
      final submissionCountResponse = await _supabase.from('results').select('results_id').eq('session_id', widget.sessionId);

      final submissionNumber = submissionCountResponse.length + 1;

      // Step 2: Insert into results table
      final resultsResponse = await _supabase
          .from('results')
          .insert({
            'session_id': widget.sessionId,
            'created_at': DateTime.now().toIso8601String().split('T')[0], // Date only
          })
          .select('results_id')
          .single();

      final resultsId = resultsResponse['results_id'] as int;

      // Step 3: Prepare and insert all answers
      final answersToInsert = <Map<String, dynamic>>[];

      for (final entry in _answers.entries) {
        // Only include answers that have been provided
        if (entry.value != null && entry.value != '') {
          String answerString;
          if (entry.value is int) {
            answerString = entry.value.toString();
          } else {
            answerString = entry.value as String;
          }
          answersToInsert.add({'results_id': resultsId, 'questions_id': entry.key, 'answer': answerString});
        }
      }

      // Step 4: Insert all answers in batch
      if (answersToInsert.isNotEmpty) {
        await _supabase.from('results_answers').insert(answersToInsert);
        
        // Step 5: Trigger individual sentiment analysis first, then session aggregation (async, don't wait)
        debugPrint('🔄 Triggering sentiment analysis for session ${widget.sessionId}...');
        // Run this async without waiting to avoid blocking the user experience
        
        // First analyze individual answers to populate feedback_sentiment table
        SentimentService.analyzeExistingAnswers(sessionId: widget.sessionId).then((_) {
          debugPrint('✅ Individual sentiment analysis completed for session ${widget.sessionId}');
          // Then aggregate into session summary
          return SentimentService.aggregateSessionSentiment(widget.sessionId);
        }).then((summary) {
          debugPrint('✅ Session sentiment aggregation completed for session ${widget.sessionId}');
        }).catchError((e) {
          debugPrint('⚠️  Sentiment analysis failed: $e');
        });
      }

      // Success feedback and navigation to results page
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission #$submissionNumber ${_DynamicTemplateTexts.submissionCompleted}'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate to results page after a short delay
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/session/results/${widget.sessionId}');
        }
      }
    } catch (e) {
      debugPrint('Error submitting feedback: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_DynamicTemplateTexts.failedToSubmitFeedback}: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Center(
            child: CircularProgressIndicator(
              color: colorScheme.primary,
              semanticsLabel: _DynamicTemplateTexts.loadingTemplateData,
            ),
          ),
        ),
      );
    }

    if (_templateData == null) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Center(
            child: Text(
              _DynamicTemplateTexts.failedToLoadTemplate,
              style: theme.textTheme.headlineMedium,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => _buildResponsiveLayout(constraints),
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom,
        ),
        child: AnimatedBuilder(
          animation: _buttonAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _buttonAnimation.value,
              child: Opacity(
                opacity: _buttonAnimation.value,
                child: FilledButton.icon(
                  onPressed: (_showFloatingButton && !_isSubmitting) ? _handleSubmit : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: _isSubmitting 
                        ? colorScheme.primary.withValues(alpha: 0.6) 
                        : null, // Let theme handle default color
                    elevation: 8,
                    shadowColor: colorScheme.shadow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    padding: _getFloatingButtonPadding(context),
                  ),
                  icon: _isSubmitting 
                      ? SizedBox(
                          width: 20, 
                          height: 20, 
                          child: CircularProgressIndicator(
                            strokeWidth: 2, 
                            color: colorScheme.onPrimary,
                            semanticsLabel: _DynamicTemplateTexts.submittingFeedback,
                          )
                        ) 
                      : const Icon(Icons.check, size: 20),
                  label: Text(
                    _isSubmitting ? _DynamicTemplateTexts.submitting : _DynamicTemplateTexts.submit,
                    semanticsLabel: _DynamicTemplateTexts.submitButton,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuestionWidget(Map<String, dynamic> question) {
    final questionId = question['question_id'] as int;
    final componentType = question['_component_type']?['name'];
    final questionTitle = question['title'] ?? '';
    final questionName = question['question'] ?? '';

    switch (componentType) {
      case 'slider':
        return SliderCard(
          questionTitle: questionTitle,
          questionName: questionName,
          minLabel: question['min_label'] ?? 'Min',
          maxLabel: question['max_label'] ?? 'Max',
          value: _answers[questionId] as int? ?? 50,
          onChanged: (value) {
            setState(() {
              _answers[questionId] = value;
            });
          },
          min: 0,
          max: 100,
        );

      case 'text':
        return TextFieldCard(
          questionTitle: questionTitle,
          questionName: questionName,
          initialValue: _answers[questionId] as String? ?? '',
          onChanged: (value) {
            setState(() {
              _answers[questionId] = value;
            });
          },
          hintText: 'Enter your response...',
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSliverContent(BoxConstraints constraints) {
    final screenSize = getScreenSize(context);
    final contentPadding = _getContentPadding(screenSize);
    final contentMaxWidth = _getContentMaxWidth(constraints.maxWidth);
    final questionSpacing = _getQuestionSpacing(screenSize);

    return SliverToBoxAdapter(
      child: Column(
        children: [
          // Content section with responsive breakpoints
          Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: contentMaxWidth),
              child: Padding(
                padding: contentPadding,
                child: Column(
                  children: [
                    // Questions list
                    ...List.generate(_questions.length * 2 - 1, (index) {
                      if (index.isOdd) {
                        // Separator with responsive spacing
                        return SizedBox(height: questionSpacing);
                      }

                      final questionIndex = index ~/ 2;
                      final question = _questions[questionIndex];

                      return _buildQuestionWidget(question);
                    }),
                  ],
                ),
              ),
            ),
          ),
          
          // Add extra spacing at bottom for floating button and system UI
          SizedBox(height: _getBottomContentSpacing(context)),
        ],
      ),
    );
  }

  // Responsive layout using Material 3 breakpoints
  Widget _buildResponsiveLayout(BoxConstraints constraints) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        // Header that scrolls away with content
        CollapsingHeader(
          title: _templateData?['template_name'] ?? _DynamicTemplateTexts.checkin,
          imageUrl: _templateData?['image_url'],
        ),

        // Scrollable content area
        _buildSliverContent(constraints),
      ],
    );
  }

  // Helper methods for responsive spacing using Material 3 breakpoints

  EdgeInsets _getContentPadding(ScreenSize screenSize) {
    return EdgeInsets.symmetric(
      horizontal: context.pageEdgePadding.left,
      vertical: context.spacing.lgPlus,
    );
  }

  double _getQuestionSpacing(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.compact:
        return context.spacing.xl;
      case ScreenSize.medium:
        return context.spacing.xl + context.spacing.xs;
      case ScreenSize.expanded:
        return context.spacing.xxl;
    }
  }

  // Floating button padding helper
  EdgeInsets _getFloatingButtonPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: context.spacing.lg + context.spacing.xs,
      vertical: context.spacing.lg,
    );
  }

  // Bottom spacing for scrollable content
  double _getBottomContentSpacing(BuildContext context) {
    return context.spacing.xxxl + MediaQuery.of(context).padding.bottom;
  }


  double _getContentMaxWidth(double width) {
    if (width < 600) return double.infinity;             // Compact: full width
    if (width < 960) return 600;                         // Medium: constrained (updated from 840 to 960)
    return 800;                                          // Expanded: wider constraint
  }
}
