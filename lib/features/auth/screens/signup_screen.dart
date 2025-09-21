import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/components/molecules/app_states.dart';
import '../../../core/themes/spacing_theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  static const String routeName = '/signup';

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  bool _isAnimationLoading = true;
  
  double _passwordStrength = 0.0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please accept the Terms and Conditions to continue'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Account created! Please check your email and click the confirmation link.'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 5),
          ),
        );

        // Navigate to login screen
        Navigator.of(context).pushReplacementNamed('/login');
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

  void _calculatePasswordStrength(String password) {
    double strength = 0.0;
    
    if (password.length >= 8) strength += 0.25;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.25;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.25;
    
    setState(() {
      _passwordStrength = strength;
    });
  }

  Color _getPasswordStrengthColor() {
    if (_passwordStrength <= 0.25) return Theme.of(context).colorScheme.error;
    if (_passwordStrength <= 0.5) return Colors.orange;
    if (_passwordStrength <= 0.75) return Colors.yellow.shade700;
    return Colors.green;
  }

  String _getPasswordStrengthText() {
    if (_passwordStrength <= 0.25) return 'Weak';
    if (_passwordStrength <= 0.5) return 'Fair';
    if (_passwordStrength <= 0.75) return 'Good';
    return 'Strong';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
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

    // Material 3 breakpoint system
    if (width < 600) return _buildCompactLayout(constraints);
    if (width < 840) return _constrainedLayout(600);
    if (width < 1200) return _buildTwoColumnLayout(constraints);
    return _buildEnhancedTwoColumnLayout(constraints);
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
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: _getTopSpacing(screenHeight)),

          // Bloom title
          Text(
            'Bloom',
            style: (isEnhanced 
              ? Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 64) 
              : Theme.of(context).textTheme.displayLarge)?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),

          SizedBox(height: isEnhanced ? context.spacing.xxl : context.spacing.xl),

          // Create account subtitle
          Text(
            'Create your facilitator account',
            style: (isEnhanced 
              ? Theme.of(context).textTheme.titleLarge 
              : Theme.of(context).textTheme.bodyLarge)?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),

          SizedBox(height: isEnhanced ? context.spacing.xxxl + context.spacing.xxxl : context.spacing.xxxl + context.spacing.xxl),

          // Email field
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            hintText: 'Enter your email address',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),

          SizedBox(height: context.spacing.xl),

          // Password field
          _buildPasswordField(
            controller: _passwordController,
            label: 'Password',
            hintText: 'Create a secure password',
            obscureText: _obscurePassword,
            onToggleVisibility: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
            onChanged: _calculatePasswordStrength,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters long';
              }
              return null;
            },
          ),

          SizedBox(height: context.spacing.lg),

          // Password strength indicator
          if (_passwordController.text.isNotEmpty) ...[
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: _passwordStrength,
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(_getPasswordStrengthColor()),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: context.spacing.md),
                Text(
                  _getPasswordStrengthText(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getPasswordStrengthColor(),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.spacing.sm),
          ],

          SizedBox(height: context.spacing.lg),

          // Confirm password field
          _buildPasswordField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            hintText: 'Re-enter your password',
            obscureText: _obscureConfirmPassword,
            onToggleVisibility: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),

          SizedBox(height: context.spacing.xl),

          // Terms and conditions checkbox
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _agreedToTerms,
                onChanged: (value) {
                  setState(() {
                    _agreedToTerms = value ?? false;
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.spacing.xs),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _agreedToTerms = !_agreedToTerms;
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.only(top: context.spacing.md),
                    child: Text(
                      'I agree to the Terms and Conditions and Privacy Policy',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: context.spacing.xl),

          // Create Account button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isLoading ? null : _handleSignUp,
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    )
                  : const Text('Create account'),
            ),
          ),

          SizedBox(height: context.spacing.lg),

          // Already have account link
          Center(
            child: TextButton(
              onPressed: _isLoading ? null : () {
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: const Text('Already have an account? Sign in'),
            ),
          ),

          SizedBox(height: _getBottomSpacing(screenHeight)),
        ],
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
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
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
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          onPressed: onToggleVisibility,
        ),
      ),
    );
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
              
              // Right side: Animation container
              Expanded(
                flex: 3,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: _buildAnimationContainer(),
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
        constraints: const BoxConstraints(maxWidth: 1400),
        child: Padding(
          padding: context.pageEdgePadding,
          child: Row(
            children: [
              // Left side: Form content with enhanced spacing
              Expanded(
                flex: 5,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.spacing.xl),
                  child: _buildFormContent(
                    screenHeight: constraints.maxHeight,
                    isEnhanced: true,
                  ),
                ),
              ),
              
              SizedBox(width: context.spacing.xxxl + context.spacing.lg),
              
              // Right side: Animation container
              Expanded(
                flex: 7,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: _buildAnimationContainer(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimationContainer() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(context.spacing.xl),
      surfaceTintColor: colorScheme.surfaceTint,
      child: Container(
        width: double.infinity,
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
                    'assets/lottie/abstract-shape.json',
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

  double _getTopSpacing(double screenHeight) {
    return (screenHeight * 0.1).clamp(48.0, 64.0 + 16.0);
  }

  double _getBottomSpacing(double screenHeight) {
    return (screenHeight * 0.1).clamp(48.0, 64.0 + 16.0);
  }
}