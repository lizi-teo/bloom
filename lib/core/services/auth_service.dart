import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'user_service.dart';
import 'error_tracking_service.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final UserService _userService = UserService();

  User? get currentUser => _supabase.auth.currentUser;
  
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
  
  bool get isAuthenticated => currentUser != null;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: displayName != null ? {'display_name': displayName} : null,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Sign up request timed out. Please check your connection and try again.');
        },
      );
      
      if (response.user == null) {
        throw Exception('Failed to create account');
      }

      // Create user profile in our users table
      if (response.user != null) {
        try {
          await _userService.createUserProfile(
            authUserId: response.user!.id,
            email: email,
            fullName: displayName,
          );
        } catch (e) {
          // Log warning but don't fail signup if profile creation fails
          ErrorTrackingService().logWarning(
            'Failed to create user profile during signup: $e',
            context: 'AuthService.signUp',
            additionalData: {'email': email, 'displayName': displayName},
          );
        }
      }
      
      return response;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign up');
    }
  }

  Future<AuthResponse> signUpWithProfile({
    required String email,
    required String password,
    String? fullName,
    String? username,
    String? phone,
    String? organization,
    String? role,
    String? bio,
    String userType = 'facilitator',
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'display_name': fullName} : null,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Sign up request timed out. Please check your connection and try again.');
        },
      );
      
      if (response.user == null) {
        throw Exception('Failed to create account');
      }

      // Create comprehensive user profile in our users table
      if (response.user != null) {
        await _userService.createUserProfile(
          authUserId: response.user!.id,
          email: email,
          fullName: fullName,
          username: username,
          phone: phone,
          organization: organization,
          role: role,
          bio: bio,
          userType: userType,
        );
      }
      
      return response;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign up');
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Sign in request timed out. Please check your connection and try again.');
        },
      );
      
      if (response.user == null) {
        throw Exception('Failed to sign in');
      }

      // Update last login time
      if (response.user != null) {
        try {
          await _userService.updateLastLogin(response.user!.id);
        } catch (e) {
          // Log warning but don't fail signin if last login update fails
          ErrorTrackingService().logWarning(
            'Failed to update last login time: $e',
            context: 'AuthService.signIn',
            additionalData: {'userId': response.user!.id},
          );
        }
      }
      
      return response;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign in');
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Sign out request timed out. Please check your connection and try again.');
        },
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign out');
    }
  }

  Future<void> resetPassword({required String email}) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Password reset request timed out. Please check your connection and try again.');
        },
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred during password reset');
    }
  }


  String? getUserDisplayName() {
    final user = currentUser;
    if (user == null) return null;
    
    // Try to get display name from user metadata
    final displayName = user.userMetadata?['display_name'] as String?;
    if (displayName?.isNotEmpty == true) {
      return displayName;
    }
    
    // Fallback to email prefix
    return user.email?.split('@').first;
  }

  String? getUserEmail() {
    return currentUser?.email;
  }

  String? getUserId() {
    return currentUser?.id;
  }

  Future<UserModel?> getCurrentUserProfile() async {
    if (currentUser == null) return null;
    return await _userService.getUserProfile(currentUser!.id);
  }

  UserService get userService => _userService;

  Future<void> deleteAccount() async {
    if (currentUser == null) {
      throw Exception('No user is currently signed in');
    }

    try {
      final userId = currentUser!.id;
      
      // First delete the user profile from our users table
      await _userService.deleteUserProfile(userId);
      
      // Then delete the auth user (this will also handle cascade deletes due to foreign key constraints)
      // Note: In Supabase, user deletion from auth.users typically requires admin privileges
      // For a client-side implementation, you might want to mark the user as inactive instead
      await _supabase.rpc('delete_user');
      
    } catch (e) {
      // If the auth user deletion fails but profile deletion succeeded,
      // we should handle this gracefully
      throw Exception('Failed to delete account: $e');
    }
  }

  Future<void> deleteCurrentAccount() async {
    if (currentUser == null) {
      throw Exception('No user is currently signed in');
    }

    try {
      final userId = currentUser!.id;
      
      // Delete the user profile from our users table
      await _userService.deleteUserProfile(userId);
      
      // Sign out the user (since we can't delete auth users from client-side)
      await signOut();
      
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  Exception _handleAuthException(AuthException e) {
    switch (e.statusCode) {
      case '400':
        if (e.message.contains('Invalid login credentials')) {
          return Exception('Invalid email or password');
        }
        if (e.message.contains('Email not confirmed')) {
          return Exception('Please check your email and click the confirmation link');
        }
        return Exception(e.message);
      case '422':
        if (e.message.contains('User already registered')) {
          return Exception('An account with this email already exists');
        }
        if (e.message.contains('Password should be at least 6 characters')) {
          return Exception('Password must be at least 6 characters');
        }
        return Exception(e.message);
      case '429':
        return Exception('Too many attempts. Please try again later');
      default:
        return Exception(e.message.isNotEmpty ? e.message : 'Authentication error');
    }
  }
}