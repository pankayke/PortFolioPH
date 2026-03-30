// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seeker_application_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SeekerApplication _$SeekerApplicationFromJson(Map<String, dynamic> json) =>
    SeekerApplication(
      id: (json['id'] as num).toInt(),
      jobId: (json['jobId'] as num).toInt(),
      jobTitle: json['jobTitle'] as String,
      recruiterName: json['recruiterName'] as String,
      recruiterLogo: json['recruiterLogo'] as String,
      jobLocation: json['jobLocation'] as String?,
      salaryMin: (json['salaryMin'] as num?)?.toDouble(),
      salaryMax: (json['salaryMax'] as num?)?.toDouble(),
      status: json['status'] as String,
      notes: json['notes'] as String?,
      interviewDate: json['interviewDate'] == null
          ? null
          : DateTime.parse(json['interviewDate'] as String),
      interviewLocation: json['interviewLocation'] as String?,
      videoInterviewLink: json['videoInterviewLink'] as String?,
      appliedAt: DateTime.parse(json['appliedAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SeekerApplicationToJson(SeekerApplication instance) =>
    <String, dynamic>{
      'id': instance.id,
      'jobId': instance.jobId,
      'jobTitle': instance.jobTitle,
      'recruiterName': instance.recruiterName,
      'recruiterLogo': instance.recruiterLogo,
      'jobLocation': instance.jobLocation,
      'salaryMin': instance.salaryMin,
      'salaryMax': instance.salaryMax,
      'status': instance.status,
      'notes': instance.notes,
      'interviewDate': instance.interviewDate?.toIso8601String(),
      'interviewLocation': instance.interviewLocation,
      'videoInterviewLink': instance.videoInterviewLink,
      'appliedAt': instance.appliedAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
