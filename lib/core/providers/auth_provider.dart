import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  StreamSubscription<AuthState>? _authSubscription;
  
  User? _currentUser;
  bool _isLoading = true;
  
  AuthProvider() {
    _init();
  }

  /// Current authenticated user, null if not authenticated
  User? get currentUser => _currentUser;
  
  /// Whether a user is currently authenticated
  bool get isAuthenticated => _currentUser != null;
  
  /// Whether auth state is currently loading
  bool get isLoading => _isLoading;
  
  /// Current user's display name
  String? get userDisplayName => _authService.getUserDisplayName();
  
  /// Current user's email
  String? get userEmail => _authService.getUserEmail();
  
  /// Current user's ID
  String? get userId => _authService.getUserId();

  void _init() {
    // Get initial auth state
    _currentUser = _authService.currentUser;
    _isLoading = false;
    
    // Listen to auth state changes
    _authSubscription = _authService.authStateChanges.listen(
      _onAuthStateChanged,
      onError: (error) {
        debugPrint('Auth state error: $error');
        _isLoading = false;
        notifyListeners();
      },
    );
    
    notifyListeners();
  }

  void _onAuthStateChanged(AuthState authState) {
    final newUser = authState.session?.user;
    
    if (_currentUser?.id != newUser?.id) {
      _currentUser = newUser;
      _isLoading = false;
      
      debugPrint('Auth state changed: ${newUser != null ? 'signed in' : 'signed out'}');
      
      notifyListeners();
    }
  }

  /// Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _authService.signIn(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// Reset password for the given email
  Future<void> resetPassword({required String email}) async {
    try {
      await _authService.resetPassword(email: email);
    } catch (e) {
      rethrow;
    }
  }


  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}