import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';

/// Widget that wraps routes requiring authentication
/// 
/// Shows the child widget if user is authenticated,
/// otherwise shows the login screen
class AuthWrapper extends StatelessWidget {
  final Widget child;
  
  const AuthWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Show loading screen while checking auth state
        if (authProvider.isLoading) {
          return _buildLoadingScreen();
        }
        
        // Show child if authenticated, otherwise show login
        if (authProvider.isAuthenticated) {
          return child;
        } else {
          return const LoginScreen();
        }
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF141218), // Dark background from Figma
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bloom title
            Text(
              'Bloom',
              style: TextStyle(
                fontFamily: 'Questrial',
                fontSize: 57,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFE6E0E9),
                letterSpacing: -0.25,
                height: 64 / 57,
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Loading indicator
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFF9E8AEF),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Loading text
            Text(
              'Loading...',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFC6C6C6),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Utility function to check if a route requires authentication
/// 
/// Returns true if the route should be protected (facilitator routes)
/// Returns false for participant routes (/session/*) and public routes
bool requiresAuth(String? routeName) {
  if (routeName == null) return true;
  
  // Participant routes - no auth required
  if (routeName.startsWith('/session/')) {
    return false;
  }
  
  // Public routes - no auth required  
  const publicRoutes = [
    '/login',
    '/signup',
  ];
  
  if (publicRoutes.contains(routeName)) {
    return false;
  }
  
  // All other routes require auth (facilitator routes)
  return true;
}

/// Widget that conditionally applies authentication based on route
/// 
/// Use this in route builders to automatically apply auth protection
/// to facilitator routes while leaving participant routes open
class ConditionalAuthWrapper extends StatelessWidget {
  final Widget child;
  final String? routeName;
  
  const ConditionalAuthWrapper({
    super.key,
    required this.child,
    this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    // Get route name from context if not provided
    final String? currentRoute = routeName ?? ModalRoute.of(context)?.settings.name;
    
    // Apply auth wrapper only if route requires authentication
    if (requiresAuth(currentRoute)) {
      return AuthWrapper(child: child);
    } else {
      return child;
    }
  }
}