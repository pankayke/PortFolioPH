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
  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    id: map['id'] as int?,
    username: map['username'] as String,
    email: map['email'] as String,
    role: map['role'] as String? ?? 'user',
    passwordHash: map['password_hash'] as String,
    fullName: map['full_name'] as String?,
    bio: map['bio'] as String?,
    avatarPath: map['avatar_path'] as String?,
    phoneNumber: map['phone_number'] as String?,
    location: map['location'] as String?,
    websiteUrl: map['website_url'] as String?,
    createdAt: map['created_at'] as String,
    updatedAt: map['updated_at'] as String,
  );

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
