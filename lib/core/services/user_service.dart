import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class UserService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<UserModel> createUserProfile({
    required String authUserId,
    required String email,
    String? fullName,
    String? username,
    String? phone,
    String? organization,
    String? role,
    String? bio,
    String userType = 'facilitator',
  }) async {
    try {
      final now = DateTime.now();
      final userData = {
        'id': authUserId,
        'email': email,
        'full_name': fullName,
        'username': username,
        'phone': phone,
        'organization': organization,
        'role': role,
        'bio': bio,
        'user_type': userType,
        'is_active': true,
        'email_verified': false,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final response = await _supabase
          .from('users')
          .insert(userData)
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      if (e is PostgrestException) {
        if (e.code == '23505') {
          if (e.message.contains('username')) {
            throw Exception('Username already exists');
          } else if (e.message.contains('email')) {
            throw Exception('Email already exists');
          }
        }
        throw Exception('Failed to create user profile: ${e.message}');
      }
      throw Exception('Failed to create user profile: $e');
    }
  }

  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  Future<UserModel> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    try {
      final updatedData = {
        ...updates,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('users')
          .update(updatedData)
          .eq('id', userId)
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      if (e is PostgrestException) {
        if (e.code == '23505') {
          if (e.message.contains('username')) {
            throw Exception('Username already exists');
          } else if (e.message.contains('email')) {
            throw Exception('Email already exists');
          }
        }
        throw Exception('Failed to update user profile: ${e.message}');
      }
      throw Exception('Failed to update user profile: $e');
    }
  }

  Future<void> updateLastLogin(String userId) async {
    try {
      await _supabase
          .from('users')
          .update({
            'last_login': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      // Don't throw here as this is not critical
      // TODO: Implement proper logging framework
    }
  }

  Future<void> verifyUserEmail(String userId) async {
    try {
      await _supabase
          .from('users')
          .update({
            'email_verified': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      throw Exception('Failed to verify user email: $e');
    }
  }

  Future<void> deactivateUser(String userId) async {
    try {
      await _supabase
          .from('users')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      throw Exception('Failed to deactivate user: $e');
    }
  }

  Future<void> reactivateUser(String userId) async {
    try {
      await _supabase
          .from('users')
          .update({
            'is_active': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      throw Exception('Failed to reactivate user: $e');
    }
  }

  Future<bool> isUsernameAvailable(String username, {String? excludeUserId}) async {
    try {
      var query = _supabase
          .from('users')
          .select('id')
          .eq('username', username);

      if (excludeUserId != null) {
        query = query.neq('id', excludeUserId);
      }

      final response = await query.maybeSingle();
      return response == null;
    } catch (e) {
      throw Exception('Failed to check username availability: $e');
    }
  }

  Future<bool> isEmailAvailable(String email, {String? excludeUserId}) async {
    try {
      var query = _supabase
          .from('users')
          .select('id')
          .eq('email', email);

      if (excludeUserId != null) {
        query = query.neq('id', excludeUserId);
      }

      final response = await query.maybeSingle();
      return response == null;
    } catch (e) {
      throw Exception('Failed to check email availability: $e');
    }
  }

  Future<List<UserModel>> searchUsers({
    String? searchTerm,
    String? userType,
    bool? isActive,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      var query = _supabase.from('users').select();

      if (searchTerm != null && searchTerm.isNotEmpty) {
        query = query.or('full_name.ilike.%$searchTerm%,username.ilike.%$searchTerm%,email.ilike.%$searchTerm%,organization.ilike.%$searchTerm%');
      }

      if (userType != null) {
        query = query.eq('user_type', userType);
      }

      if (isActive != null) {
        query = query.eq('is_active', isActive);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response.map<UserModel>((user) => UserModel.fromJson(user)).toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  Future<void> deleteUserProfile(String userId) async {
    try {
      await _supabase
          .from('users')
          .delete()
          .eq('id', userId);
    } catch (e) {
      throw Exception('Failed to delete user profile: $e');
    }
  }
}