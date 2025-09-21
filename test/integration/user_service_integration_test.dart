import 'package:flutter_test/flutter_test.dart';
import 'package:bloom_app/core/models/user_model.dart';

void main() {
  group('User Model Tests', () {

    test('UserModel should serialize and deserialize correctly', () {
      final now = DateTime.now();
      final userData = {
        'id': 'test-uuid-123',
        'email': 'test@example.com',
        'full_name': 'Test User',
        'username': 'testuser',
        'phone': '+1234567890',
        'organization': 'Test Org',
        'role': 'Facilitator',
        'bio': 'Test bio',
        'user_type': 'facilitator',
        'is_active': true,
        'email_verified': false,
        'last_login': null,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      // Test fromJson
      final user = UserModel.fromJson(userData);
      expect(user.id, 'test-uuid-123');
      expect(user.email, 'test@example.com');
      expect(user.fullName, 'Test User');
      expect(user.username, 'testuser');
      expect(user.phone, '+1234567890');
      expect(user.organization, 'Test Org');
      expect(user.role, 'Facilitator');
      expect(user.bio, 'Test bio');
      expect(user.userType, 'facilitator');
      expect(user.isActive, true);
      expect(user.emailVerified, false);
      expect(user.lastLogin, null);
      expect(user.createdAt, now);

      // Test toJson
      final json = user.toJson();
      expect(json['id'], 'test-uuid-123');
      expect(json['email'], 'test@example.com');
      expect(json['full_name'], 'Test User');
      expect(json['username'], 'testuser');
      expect(json['user_type'], 'facilitator');
      expect(json['is_active'], true);
      expect(json['email_verified'], false);
    });

    test('UserModel copyWith should work correctly', () {
      final now = DateTime.now();
      final user = UserModel(
        id: 'test-id',
        email: 'test@example.com',
        createdAt: now,
        updatedAt: now,
      );

      final updatedUser = user.copyWith(
        fullName: 'Updated Name',
        username: 'updateduser',
        isActive: false,
      );

      expect(updatedUser.id, 'test-id'); // unchanged
      expect(updatedUser.email, 'test@example.com'); // unchanged
      expect(updatedUser.fullName, 'Updated Name'); // changed
      expect(updatedUser.username, 'updateduser'); // changed
      expect(updatedUser.isActive, false); // changed
      expect(updatedUser.createdAt, now); // unchanged
    });

    test('UserModel equality should work correctly', () {
      final now = DateTime.now();
      final user1 = UserModel(
        id: 'test-id',
        email: 'test@example.com',
        createdAt: now,
        updatedAt: now,
      );

      final user2 = UserModel(
        id: 'test-id',
        email: 'different@example.com',
        createdAt: now,
        updatedAt: now,
      );

      final user3 = UserModel(
        id: 'different-id',
        email: 'test@example.com',
        createdAt: now,
        updatedAt: now,
      );

      expect(user1, equals(user2)); // same ID
      expect(user1, isNot(equals(user3))); // different ID
      expect(user1.hashCode, equals(user2.hashCode)); // same hash
    });
  });
}