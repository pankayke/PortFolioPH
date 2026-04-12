// lib/data/models/user_model.dart
// Table: users
// ─────────────────────────────────────────────────────────────────────────────

class UserModel {
  final int? id;
  final String username;
  final String email;
  final String role;
  final String passwordHash;
  final String? fullName;
  final String? bio;
  final String? avatarPath;
  final String? phoneNumber;
  final String? location;
  final String? websiteUrl;
  final String createdAt;
  final String updatedAt;

  const UserModel({
    this.id,
    required this.username,
    required this.email,
    this.role = 'user',
    required this.passwordHash,
    this.fullName,
    this.bio,
    this.avatarPath,
    this.phoneNumber,
    this.location,
    this.websiteUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  // ── Serialisation ─────────────────────────────────────────────────────────────
  factory UserModel.fromMap(Map<String, dynamic> map) {
    final email = _asString(map['email']);
    final name = _asString(map['name']);
    final username = _asString(map['username']);

    // Auth endpoints may return a minimal user payload (id/name/email/role only).
    // Keep parsing resilient by falling back to available identity fields.
    final resolvedUsername = username.isNotEmpty
        ? username
        : (name.isNotEmpty ? name : email);

    return UserModel(
      id: map['id'] as int?,
      username: resolvedUsername,
      email: email,
      role: _asString(map['role']).isNotEmpty ? _asString(map['role']) : 'user',
      passwordHash: _asString(map['password_hash']),
      fullName:
          _asNullableString(map['full_name']) ?? _asNullableString(map['name']),
      bio: _asNullableString(map['bio']),
      avatarPath: _asNullableString(map['avatar_path']),
      phoneNumber: _asNullableString(map['phone_number']),
      location: _asNullableString(map['location']),
      websiteUrl: _asNullableString(map['website_url']),
      createdAt: _asString(map['created_at']),
      updatedAt: _asString(map['updated_at']),
    );
  }

  static String _asString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static String? _asNullableString(dynamic value) {
    if (value == null) return null;
    final result = value.toString();
    return result.isEmpty ? null : result;
  }

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'username': username,
    'email': email,
    'role': role,
    'password_hash': passwordHash,
    'full_name': fullName,
    'bio': bio,
    'avatar_path': avatarPath,
    'phone_number': phoneNumber,
    'location': location,
    'website_url': websiteUrl,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  /// Creates a copy with specified fields replaced.
  /// To explicitly set a nullable field to null, use the named parameter.
  /// Fields not provided will retain their current values.
  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? role,
    String? passwordHash,
    String? fullName,
    bool clearFullName = false,
    String? bio,
    bool clearBio = false,
    String? avatarPath,
    bool clearAvatarPath = false,
    String? phoneNumber,
    bool clearPhoneNumber = false,
    String? location,
    bool clearLocation = false,
    String? websiteUrl,
    bool clearWebsiteUrl = false,
    String? createdAt,
    String? updatedAt,
  }) => UserModel(
    id: id ?? this.id,
    username: username ?? this.username,
    email: email ?? this.email,
    role: role ?? this.role,
    passwordHash: passwordHash ?? this.passwordHash,
    fullName: clearFullName ? null : (fullName ?? this.fullName),
    bio: clearBio ? null : (bio ?? this.bio),
    avatarPath: clearAvatarPath ? null : (avatarPath ?? this.avatarPath),
    phoneNumber: clearPhoneNumber ? null : (phoneNumber ?? this.phoneNumber),
    location: clearLocation ? null : (location ?? this.location),
    websiteUrl: clearWebsiteUrl ? null : (websiteUrl ?? this.websiteUrl),
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  String toString() =>
      'UserModel(id: $id, username: $username, email: $email, role: $role)';
}
