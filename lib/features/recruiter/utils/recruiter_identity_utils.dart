import 'package:portfolioph/data/models/user_model.dart';

class RecruiterIdentityUtils {
  static String recruiterDisplayName(UserModel? user) {
    final fullName = _clean(user?.fullName);
    if (fullName != null) {
      if (fullName.contains(' - ')) {
        return fullName.split(' - ').first.trim();
      }
      return fullName;
    }

    final username = _clean(user?.username);
    if (username != null) return username;

    final email = _clean(user?.email);
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }

    return 'Recruiter';
  }

  static String companyDisplayName(UserModel? user) {
    final fullName = _clean(user?.fullName);
    if (fullName != null && fullName.contains(' - ')) {
      final parts = fullName.split(' - ');
      if (parts.length > 1) {
        final company = parts[1].trim();
        if (company.isNotEmpty) return company;
      }
    }

    final website = _clean(user?.websiteUrl);
    if (website != null) {
      final uri = Uri.tryParse(website);
      final host = uri?.host.trim();
      if (host != null && host.isNotEmpty) {
        return host.replaceFirst('www.', '');
      }
    }

    return 'PortfolioPH Hiring Desk';
  }

  static String companyLocation(UserModel? user) {
    return _clean(user?.location) ?? 'Philippines';
  }

  static String? _clean(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
