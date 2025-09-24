import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/components/molecules/app_states.dart';
import '../../../core/themes/spacing_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isAnimationLoading = true;

  @override
  void initState() {
    super.initState();
    _populateDevCredentialsIfNeeded();
  }

  void _populateDevCredentialsIfNeeded() {
    const environment = String.fromEnvironment('ENVIRONMENT', defaultValue: '');
    if (environment == 'development') {
      const devEmail = String.fromEnvironment('DEV_AUTO_LOGIN_EMAIL', defaultValue: '');
      const devPassword = String.fromEnvironment('DEV_AUTO_LOGIN_PASSWORD', defaultValue: '');
      
      if (devEmail.isNotEmpty && devPassword.isNotEmpty) {
        _emailController.text = devEmail;
        _passwordController.text = devPassword;
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signIn(
        email: email,
        password: password,
      );

      if (mounted) {
        // Navigation will be handled by the auth state listener
        Navigator.of(context).pushReplacementNamed('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      resizeToAvoidBottomInset: true, // ✅ REQUIRED - Prevents keyboard from covering input fields
      body: SafeArea(
        // Standard SafeArea for Android compatibility
        minimum: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: _buildResponsiveLayout(constraints),
              ),
            );
          },
        ),
      ),
    );
  }


  Widget _buildResponsiveLayout(BoxConstraints constraints) {
    final width = constraints.maxWidth;

    // Material 3 breakpoint system with enhancement at 1200dp
    if (width < 600) return _buildCompactLayout(constraints);           // Compact: full width
    if (width < 840) return _constrainedLayout(600);                    // Medium: constrained
    if (width < 1200) return _buildTwoColumnLayout(constraints);        // Expanded: basic 2-column
    return _buildEnhancedTwoColumnLayout(constraints);                  // Enhanced: optimized 2-column
  }

  Widget _buildCompactLayout(BoxConstraints constraints) {
    return Padding(
      padding: context.pageEdgePadding,
      child: _buildFormContent(screenHeight: constraints.maxHeight),
    );
  }

  Widget _constrainedLayout(double maxWidth) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: context.pageEdgePadding,
          child: LayoutBuilder(
            builder: (context, constraints) => _buildFormContent(screenHeight: constraints.maxHeight),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent({required double screenHeight, bool isEnhanced = false}) {

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          SizedBox(height: _getTopSpacing(screenHeight)),

          // Bloom title with enhanced typography for larger screens
          Text(
            'Bloom',
            style: (isEnhanced 
              ? Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 64) 
              : Theme.of(context).textTheme.displayLarge)?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),

          SizedBox(height: isEnhanced ? context.spacing.xxl : context.spacing.xl),

          // Subtitle with enhanced typography
          Text(
            'Welcome back, facilitator',
            style: (isEnhanced ? Theme.of(context).textTheme.titleLarge : Theme.of(context).textTheme.bodyLarge)?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),

          SizedBox(height: isEnhanced 
            ? context.spacing.xxxl + context.spacing.xxxl
            : context.spacing.xxxl + context.spacing.xxl),


          // Email field
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            hintText: 'Enter your email',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),

          SizedBox(height: context.spacing.xl),

          // Password field
          _buildPasswordField(
            controller: _passwordController,
            label: 'Password',
            hintText: 'Enter your password',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              return null;
            },
          ),

          SizedBox(height: context.spacing.lg),

          // Forgot password link
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _showForgotPasswordDialog,
                child: const Text('Forgot password?'),
              ),
            ),

          SizedBox(height: context.spacing.xl),

          // Sign In button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isLoading ? null : _handleSignIn,
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    )
                  : const Text('Sign In'),
            ),
          ),

          SizedBox(height: context.spacing.lg),

          // Sign up link
          // Center(
          //   child: TextButton(
          //     onPressed: _isLoading ? null : () {
          //       Navigator.of(context).pushNamed('/signup');
          //     },
          //     child: const Text('Don\'t have an account? Create account'),
          //   ),
          // ),

          SizedBox(height: _getBottomSpacing(screenHeight)),
        ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainer,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.spacing.sm),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.spacing.sm),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.spacing.sm),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.spacing.sm),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.spacing.lg,
          vertical: context.spacing.lg,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: _obscurePassword,
      validator: validator,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainer,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.spacing.sm),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.spacing.sm),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.spacing.sm),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.spacing.sm),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.spacing.lg,
          vertical: context.spacing.lg,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
    );
  }

  double _getTopSpacing(double screenHeight) {
    return (screenHeight * 0.1).clamp(48.0, 64.0 + 16.0);
  }

  double _getBottomSpacing(double screenHeight) {
    return (screenHeight * 0.1).clamp(48.0, 64.0 + 16.0);
  }


  Widget _buildTwoColumnLayout(BoxConstraints constraints) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: context.pageEdgePadding,
          child: Row(
            children: [
              // Left side: Form content
              Expanded(
                flex: 2,
                child: _buildFormContent(screenHeight: constraints.maxHeight),
              ),
              
              SizedBox(width: context.spacing.xxxl + context.spacing.sm),
              
              // Right side: JSON container
              Expanded(
                flex: 3,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: _buildJsonContainer(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedTwoColumnLayout(BoxConstraints constraints) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1400), // Wider max width for enhanced layout
        child: Padding(
          padding: context.pageEdgePadding,
          child: Row(
            children: [
              // Left side: Form content with enhanced spacing
              Expanded(
                flex: 5, // Slightly wider form area
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.spacing.xl),
                  child: _buildFormContent(
                    screenHeight: constraints.maxHeight,
                    isEnhanced: true,
                  ),
                ),
              ),
              
              SizedBox(width: context.spacing.xxxl + context.spacing.lg), // More generous spacing
              
              // Right side: JSON container with better proportions
              Expanded(
                flex: 7, // More visual emphasis on the animation
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: _buildJsonContainer(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJsonContainer() {
    final colorScheme = Theme.of(context).colorScheme;


    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(context.spacing.xl),
      surfaceTintColor: colorScheme.surfaceTint,
      child: Container(
        width: double.infinity, // Fill available width
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(context.spacing.xl),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(context.spacing.xl),
          child: SizedBox.expand(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Lottie.asset(
                    'assets/lottie/shapes.json',
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
                // Skeleton loader overlay
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
          ),
        ),
      ),
    );
  }


  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (context) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (context, setState) {
            
            return AlertDialog(
              // Use theme colors instead of hardcoded values
              backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
              
              // Material Design 3 typography
              title: Text(
                'Reset Password',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              
              // Better content structure with form validation
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter your email address and we\'ll send you a link to reset your password.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: context.spacing.xl),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofocus: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email address';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                      // Use theme-based styling
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Email address',
                        hintText: 'your.email@example.com',
                        // Use theme colors for consistent styling
                        labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(context.spacing.md),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(context.spacing.md),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(context.spacing.md),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(context.spacing.md),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(context.spacing.md),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.error,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Material Design 3 button styling
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    
                    setState(() {
                      isLoading = true;
                    });
                    
                    final email = emailController.text.trim();
                    final navigator = Navigator.of(context);
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    final primaryColor = Theme.of(context).colorScheme.primary;
                    final errorColor = Theme.of(context).colorScheme.error;
                    
                    try {
                      await _authService.resetPassword(email: email);
                      if (mounted) {
                        navigator.pop();
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text('Password reset email sent to $email'),
                            backgroundColor: primaryColor,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 5),
                          ),
                        );
                      }
                    } catch (e) {
                      setState(() {
                        isLoading = false;
                      });
                      if (mounted) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text(e.toString().replaceFirst('Exception: ', '')),
                            backgroundColor: errorColor,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      }
                    }
                  },
                  child: isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        )
                      : const Text('Send Reset Email'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
