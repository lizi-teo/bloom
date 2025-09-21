class UserModel {
  final String id;
  final String? fullName;
  final String? username;
  final String? avatarUrl;
  final String? bio;
  final String email;
  final String? phone;
  final String? organization;
  final String? role;
  final String userType;
  final bool isActive;
  final bool emailVerified;
  final DateTime? lastLogin;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    this.fullName,
    this.username,
    this.avatarUrl,
    this.bio,
    required this.email,
    this.phone,
    this.organization,
    this.role,
    this.userType = 'facilitator',
    this.isActive = true,
    this.emailVerified = false,
    this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      username: json['username'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      organization: json['organization'] as String?,
      role: json['role'] as String?,
      userType: json['user_type'] as String? ?? 'facilitator',
      isActive: json['is_active'] as bool? ?? true,
      emailVerified: json['email_verified'] as bool? ?? false,
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'username': username,
      'avatar_url': avatarUrl,
      'bio': bio,
      'email': email,
      'phone': phone,
      'organization': organization,
      'role': role,
      'user_type': userType,
      'is_active': isActive,
      'email_verified': emailVerified,
      'last_login': lastLogin?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? username,
    String? avatarUrl,
    String? bio,
    String? email,
    String? phone,
    String? organization,
    String? role,
    String? userType,
    bool? isActive,
    bool? emailVerified,
    DateTime? lastLogin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      organization: organization ?? this.organization,
      role: role ?? this.role,
      userType: userType ?? this.userType,
      isActive: isActive ?? this.isActive,
      emailVerified: emailVerified ?? this.emailVerified,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, fullName: $fullName, email: $email, userType: $userType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}