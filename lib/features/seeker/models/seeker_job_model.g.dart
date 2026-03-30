// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seeker_job_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SeekerJob _$SeekerJobFromJson(Map<String, dynamic> json) => SeekerJob(
  id: (json['id'] as num).toInt(),
  recruiterId: (json['recruiterId'] as num).toInt(),
  recruiterName: json['recruiterName'] as String,
  recruiterLogo: json['recruiterLogo'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  category: json['category'] as String,
  location: json['location'] as String,
  salaryMin: (json['salaryMin'] as num?)?.toDouble(),
  salaryMax: (json['salaryMax'] as num?)?.toDouble(),
  employmentType: json['employmentType'] as String,
  experienceLevel: json['experienceLevel'] as String,
  requiredSkills: (json['requiredSkills'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  requiredQualifications: json['requiredQualifications'] as String?,
  deadline: DateTime.parse(json['deadline'] as String),
  totalApplications: (json['totalApplications'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  applicationStatus: json['applicationStatus'] as String? ?? 'none',
  isSaved: json['isSaved'] as bool? ?? false,
);

Map<String, dynamic> _$SeekerJobToJson(SeekerJob instance) => <String, dynamic>{
  'id': instance.id,
  'recruiterId': instance.recruiterId,
  'recruiterName': instance.recruiterName,
  'recruiterLogo': instance.recruiterLogo,
  'title': instance.title,
  'description': instance.description,
  'category': instance.category,
  'location': instance.location,
  'salaryMin': instance.salaryMin,
  'salaryMax': instance.salaryMax,
  'employmentType': instance.employmentType,
  'experienceLevel': instance.experienceLevel,
  'requiredSkills': instance.requiredSkills,
  'requiredQualifications': instance.requiredQualifications,
  'deadline': instance.deadline.toIso8601String(),
  'totalApplications': instance.totalApplications,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'applicationStatus': instance.applicationStatus,
  'isSaved': instance.isSaved,
};
