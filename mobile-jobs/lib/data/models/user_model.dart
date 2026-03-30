class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final bool isApproved;
  final String? companyName;
  final String? companyWebsite;
  final String? phone;
  final String? bio;
  final String? profileImageUrl;
  final String? resumeUrl;
  final List<String>? skills;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isApproved,
    this.companyName,
    this.companyWebsite,
    this.phone,
    this.bio,
    this.profileImageUrl,
    this.resumeUrl,
    this.skills,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      isApproved: json['is_approved'] ?? false,
      companyName: json['company_name'],
      companyWebsite: json['company_website'],
      phone: json['phone'],
      bio: json['bio'],
      profileImageUrl: json['profile_image_url'],
      resumeUrl: json['resume_url'],
      skills: List<String>.from(json['skills'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
    'is_approved': isApproved,
    'company_name': companyName,
    'company_website': companyWebsite,
    'phone': phone,
    'bio': bio,
    'profile_image_url': profileImageUrl,
    'resume_url': resumeUrl,
    'skills': skills,
  };

  bool get isRecruiter => role == 'recruiter';
  bool get isJobSeeker => role == 'job_seeker';
  bool get isAdmin => role == 'admin';
}
