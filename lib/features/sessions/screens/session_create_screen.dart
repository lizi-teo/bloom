import 'package:flutter/material.dart';
import '../widgets/session_create_content.dart';
import '../../../core/themes/spacing_theme.dart';

class SessionCreateScreen extends StatelessWidget {
  static const String routeName = '/create-session';
  
  const SessionCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,  // #mobile requirement for text input pages
      appBar: AppBar(
        centerTitle: false,
      ),
      body: SafeArea(
        // Standard SafeArea for Android compatibility
        minimum: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) => _buildResponsiveLayout(constraints, context),
        ),
      ),
    );
  }

  Widget _buildResponsiveLayout(BoxConstraints constraints, BuildContext context) {
    final width = constraints.maxWidth;

    // Material 3 breakpoint system with enhancement at 1200dp
    if (width < 600) return _buildCompactLayout(constraints, context);           // Compact: full width
    if (width < 840) return _constrainedLayout(600, context);                    // Medium: constrained
    if (width < 1200) return _buildExpandedLayout(constraints, context);         // Expanded: 2-column
    return _buildEnhancedLayout(constraints, context);                          // Enhanced: optimized 2-column
  }

  Widget _buildCompactLayout(BoxConstraints constraints, BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.spacing.lg),
      child: const SessionCreateContent(),
    );
  }

  Widget _constrainedLayout(double maxWidth, BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: maxWidth > 600 ? context.spacing.xxl : context.spacing.xl),
          child: const SessionCreateContent(),
        ),
      ),
    );
  }

  Widget _buildExpandedLayout(BoxConstraints constraints, BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.spacing.xxl),
          child: const SessionCreateContent(isEnhanced: false),
        ),
      ),
    );
  }

  Widget _buildEnhancedLayout(BoxConstraints constraints, BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1400), // Wider max width for enhanced layout
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth >= 1400 
              ? context.spacing.xs * 1.51
              : context.spacing.xs,
          ),
          child: const SessionCreateContent(isEnhanced: true),
        ),
      ),
    );
  }
}