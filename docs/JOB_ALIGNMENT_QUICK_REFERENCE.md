# Quick Reference: Job-Profile Alignment Implementation

## Essential File Locations

### Core Job Feed System
```
Job Data Flow:
├─ lib/data/models/job_listing_model.dart           (Job structure)
├─ lib/data/repositories/job_feed_repository.dart   (DB access, findAll())
├─ lib/presentation/providers/job_feed_provider.dart (State mgmt)
└─ lib/presentation/screens/dashboard/dashboard_screen.dart (Usage)

Database Table: jobs
├─ Columns: id, title, company, salary, location, description, category, 
│           is_featured, sort_order, created_at, updated_at
└─ Seeded: 8 sample jobs (Virtual Assistant, Content Writer, etc.)
```

### User Profile System  
```
User Profile Data:
├─ UserModel                              (lib/data/models/user_model.dart)
│  └─ Fields: id, username, email, fullName, bio, location, websiteUrl
│
├─ SkillModel                             (lib/data/models/skill_model.dart)
│  └─ Fields: name, category, level, yearsOfExperience
│  └─ Provider: SkillsProvider.loadForUser(userId)
│
├─ ExperienceModel                        (lib/data/models/experience_model.dart)
│  └─ Fields: company, jobTitle, employmentType, location, isCurrent
│  └─ Provider: ExperienceProvider.loadForUser(userId)
│
├─ EducationModel                         (lib/data/models/education_model.dart)
│  └─ Fields: institution, degree, fieldOfStudy, isCurrent
│  └─ Provider: EducationProvider.loadForUser(userId)
│
├─ CertificationModel                     (lib/data/models/certification_model.dart)
│  └─ Fields: name, issuingOrganization, credentialUrl, expiryDate
│  └─ Provider: CertificationProvider.loadForUser(userId)
│
└─ ProjectModel                           (lib/data/models/project_model.dart)
   └─ Fields: title, techStack (comma-separated), description, isFeatured
   └─ Provider: PortfolioProvider.loadForUser(userId)
```

---

## Data Access Patterns

### Accessing Current User Profile
```dart
// In any widget with context:
final user = context.watch<AuthProvider>().currentUser;  // UserModel
final userId = user?.id;  // Required for loading related data

// Loading user's associated data (do in provider or service):
final skills = await SkillsRepository().findByUserId(userId);
final experience = await ExperienceRepository().findByUserId(userId);
final education = await EducationRepository().findByUserId(userId);
final certs = await CertificationRepository().findByUserId(userId);
final projects = await ProjectRepository().findByUserId(userId);
```

### Accessing Jobs
```dart
// Current implementation - just loads all jobs:
final jobsProvider = context.watch<JobFeedProvider>();
List<JobListingModel> allJobs = jobsProvider.jobs;  // No filtering

// To implement filtering, enhance JobFeedProvider with:
Future<void> loadJobsWithAlignment(int userId)  // Calculate scores
void setShowRecommendedOnly(bool value)         // Toggle filter
List<JobListingModel> get filteredJobs           // Return filtered
double getAlignmentScore(int jobId)              // Get score
```

---

## Filtering Strategy Examples

### 1. Skills-Based Matching
```dart
// Extract tech skills from job description
// Match against user's skills from SkillModel
List<String> _extractSkillsFromJob(JobListingModel job) {
  // Parse job.title + job.description for keywords
  final jobText = '${job.title} ${job.description}'.toLowerCase();
  final techKeywords = [
    'flutter', 'dart', 'react', 'javascript', 'python', 'java',
    'sql', 'firebase', 'aws', 'docker', 'git', 'project management'
  ];
  return techKeywords.where((tech) => jobText.contains(tech)).toList();
}

double _calculateSkillsMatch(JobListingModel job, List<SkillModel> userSkills) {
  final requiredSkills = _extractSkillsFromJob(job);
  if (requiredSkills.isEmpty) return 0.5;
  
  final userSkillNames = userSkills.map((s) => s.name.toLowerCase()).toSet();
  final matches = requiredSkills.where((skill) => 
    userSkillNames.any((userSkill) => userSkill.contains(skill))
  ).length;
  
  return matches / requiredSkills.length;
}
```

### 2. Location-Based Matching
```dart
bool _isLocationMatch(JobListingModel job, UserModel user) {
  if (job.location.toLowerCase().contains('remote') ||
      job.location.toLowerCase().contains('work from home')) {
    return true;
  }
  
  final userLocation = user.location?.toLowerCase() ?? '';
  return job.location.toLowerCase().contains(userLocation);
}
```

### 3. Category-Based Matching
```dart
bool _isCategoryMatch(JobListingModel job, UserModel user, 
    List<ExperienceModel> experience) {
  // If user has "Fresh Grad" as only experience, prefer fresh grad roles
  if (experience.isEmpty) {
    return job.category.contains('Fresh Grad') || 
           job.category.contains('OJT') ||
           job.category == 'Internship';
  }
  
  // Check if user's experience matches job category
  final userJobTitles = experience.map((e) => e.jobTitle.toLowerCase()).join(' ');
  
  final categoryMatches = {
    'Freelance': ['freelancer', 'contractor', 'independent'],
    'Creative': ['designer', 'writer', 'artist', 'content'],
    'Sales': ['sales', 'account executive', 'business development'],
    'Admin': ['assistant', 'clerk', 'coordinator'],
    'BPO': ['support', 'representative', 'customer service'],
    'Gig Work': ['delivery', 'driver', 'rideshare'],
  };
  
  return categoryMatches[job.category]?.any((keyword) =>
    userJobTitles.contains(keyword)) ?? false;
}
```

### 4. Experience Level Matching
```dart
bool _meetsExperienceRequirement(JobListingModel job, 
    List<ExperienceModel> userExperience) {
  final isFreshGradRole = job.category.contains('Fresh Grad') || 
                          job.category.contains('OJT') ||
                          job.category == 'Internship';
  
  // Fresh grad roles: no experience OR less than 1 year
  if (isFreshGradRole) {
    if (userExperience.isEmpty) return true;
    
    final recentExperience = userExperience
      .where((e) => e.isCurrent || e.endDate == null)
      .toList();
    return recentExperience.isNotEmpty;
  }
  
  // For other roles: must have relevant experience
  return userExperience.isNotEmpty;
}
```

### 5. Certification/Education Matching
```dart
bool _meetsEducationRequirement(JobListingModel job,
    List<EducationModel> userEducation) {
  // If job mentions "degree" in description, prefer users with degree
  if (job.description.toLowerCase().contains('degree') ||
      job.description.toLowerCase().contains('bachelor')) {
    return userEducation.any((e) => !e.isCurrent);
  }
  
  return true;
}

bool _hasRelevantCertifications(JobListingModel job,
    List<CertificationModel> userCerts) {
  // Parse job description for cert keywords
  final jobText = '${job.title} ${job.description}'.toLowerCase();
  
  final relevantCertKeywords = [
    'google', 'microsoft', 'aws', 'azure', 'salesforce',
    'pmp', 'capm', 'scrum', 'certified'
  ];
  
  if (!relevantCertKeywords.any((keyword) => jobText.contains(keyword))) {
    return true; // No specific cert required
  }
  
  return userCerts.isNotEmpty;
}
```

### 6. Portfolio/Project Tech Stack Matching
```dart
double _calculateTechStackMatch(JobListingModel job,
    List<ProjectModel> userProjects) {
  final requiredTechs = _extractSkillsFromJob(job);
  if (requiredTechs.isEmpty || userProjects.isEmpty) return 0.5;
  
  final allUserTechs = userProjects
    .map((p) => p.techStack?.split(',').map((s) => s.trim()).toList() ?? [])
    .expand((techs) => techs)
    .map((tech) => tech.toLowerCase())
    .toSet();
  
  final matches = requiredTechs.where((tech) =>
    allUserTechs.any((userTech) => userTech.contains(tech))
  ).length;
  
  return matches / requiredTechs.length;
}
```

---

## Complete Scoring Algorithm Implementation

### File: `lib/data/services/job_matching_service.dart` (TO CREATE)

```dart
import 'package:portfolioph/data/models/certification_model.dart';
import 'package:portfolioph/data/models/education_model.dart';
import 'package:portfolioph/data/models/experience_model.dart';
import 'package:portfolioph/data/models/job_listing_model.dart';
import 'package:portfolioph/data/models/project_model.dart';
import 'package:portfolioph/data/models/skill_model.dart';
import 'package:portfolioph/data/models/user_model.dart';

class JobMatchingService {
  /// Comprehensive alignment score (0.0 - 1.0)
  double calculateAlignmentScore({
    required JobListingModel job,
    required UserModel user,
    required List<SkillModel> skills,
    required List<ExperienceModel> experience,
    required List<EducationModel> education,
    required List<CertificationModel> certifications,
    required List<ProjectModel> projects,
  }) {
    double score = 0.0;
    
    // 1. Skills match (40%)
    final skillsScore = _calculateSkillMatch(job, skills, projects);
    score += skillsScore * 0.40;
    
    // 2. Experience match (25%)
    final experienceScore = _calculateExperienceMatch(job, experience);
    score += experienceScore * 0.25;
    
    // 3. Location match (15%)
    final locationScore = _calculateLocationMatch(job, user) ? 1.0 : 0.3;
    score += locationScore * 0.15;
    
    // 4. Education match (10%)
    final educationScore = _calculateEducationMatch(job, education);
    score += educationScore * 0.10;
    
    // 5. Certifications/credentials (10%)
    final certScore = _calculateCertificationMatch(job, certifications);
    score += certScore * 0.10;
    
    return score.clamp(0.0, 1.0);
  }

  double _calculateSkillMatch(
    JobListingModel job,
    List<SkillModel> skills,
    List<ProjectModel> projects,
  ) {
    final requiredSkills = _extractSkillsFromJob(job);
    if (requiredSkills.isEmpty) return 0.6;
    
    // Check skills
    final userSkillNames = skills
      .map((s) => s.name.toLowerCase())
      .toSet();
    
    // Check project tech stacks
    final userTechs = projects
      .map((p) => p.techStack?.split(',').map((s) => s.trim().toLowerCase()).toList() ?? [])
      .expand((techs) => techs)
      .toSet();
    
    final allUserSkills = {...userSkillNames, ...userTechs};
    
    final matches = requiredSkills.where((skill) =>
      allUserSkills.any((userSkill) =>
        userSkill.contains(skill) || skill.contains(userSkill))
    ).length;
    
    return matches / requiredSkills.length;
  }

  double _calculateExperienceMatch(
    JobListingModel job,
    List<ExperienceModel> experience,
  ) {
    if (experience.isEmpty) {
      return job.category.contains('Fresh Grad') ? 1.0 : 0.4;
    }
    
    final hasRecentExperience = experience.any((e) => 
      e.isCurrent || (e.endDate == null));
    
    return hasRecentExperience ? 1.0 : 0.7;
  }

  bool _calculateLocationMatch(HomeListingModel job, UserModel user) {
    if (job.location.toLowerCase().contains('remote') ||
        job.location.toLowerCase().contains('work from home')) {
      return true;
    }
    
    if (user.location == null || user.location!.isEmpty) {
      return false;
    }
    
    return job.location.toLowerCase().contains(
      user.location!.toLowerCase()
    );
  }

  double _calculateEducationMatch(
    JobListingModel job,
    List<EducationModel> education,
  ) {
    if (education.isEmpty) return 0.5;
    
    final jobRequiresDegree = job.description.toLowerCase().contains('degree') ||
                              job.description.toLowerCase().contains('bachelor') ||
                              job.description.toLowerCase().contains('diploma');
    
    if (!jobRequiresDegree) return 0.8;
    
    return education.isNotEmpty ? 1.0 : 0.4;
  }

  double _calculateCertificationMatch(
    JobListingModel job,
    List<CertificationModel> certifications,
  ) {
    if (certifications.isEmpty) return 0.6;
    
    final jobMentionsCert = job.description.toLowerCase().contains('certif') ||
                            job.description.toLowerCase().contains('credential');
    
    if (!jobMentionsCert) return 0.7;
    
    return certifications.isNotEmpty ? 1.0 : 0.5;
  }

  List<String> _extractSkillsFromJob(JobListingModel job) {
    final commonSkills = [
      'flutter', 'dart', 'react', 'angular', 'vue', 'javascript', 'typescript',
      'python', 'java', 'c#', 'kotlin', 'sql', 'firebase', 'aws', 'azure',
      'docker', 'kubernetes', 'git', 'react native', 'nodejs', 'express',
      'graphql', 'rest', 'api', 'database', 'html', 'css', 'design',
      'project management', 'communication', 'leadership', 'sales', 'marketing',
      'content writing', 'graphic design', 'ui/ux', 'data analysis'
    ];
    
    final jobText = '${job.title} ${job.description} ${job.category}'
      .toLowerCase();
    
    return commonSkills
      .where((skill) => jobText.contains(skill))
      .toList();
  }

  List<JobListingModel> rankJobsByScore(
    List<JobListingModel> jobs,
    Map<int, double> scores,
  ) {
    final jobsWithScores = jobs.map((job) {
      final jobId = job.id ?? -1;
      return (job: job, score: scores[jobId] ?? 0.0);
    }).toList();
    
    jobsWithScores.sort((a, b) => b.score.compareTo(a.score));
    
    return jobsWithScores.map((item) => item.job).toList();
  }
}
```

---

## Integration Into JobFeedProvider

### File: `lib/presentation/providers/job_feed_provider.dart` (ENHANCE)

```dart
class JobFeedProvider extends ChangeNotifier {
  final JobFeedRepository _repository;
  final JobMatchingService _matchingService;  // Add injection

  List<JobListingModel> _jobs = [];
  List<JobListingModel> _filteredJobs = [];
  Map<int, double> _alignmentScores = {};
  Set<int> _savedJobIds = {};
  bool _isLoading = false;
  String? _errorMessage;
  String _filterCategory = '';
  double _alignmentThreshold = 0.0;
  bool _showRecommendedOnly = false;

  JobFeedProvider({
    JobFeedRepository? repository,
    JobMatchingService? matchingService,
  })  : _repository = repository ?? JobFeedRepository(),
        _matchingService = matchingService ?? JobMatchingService();

  // ── Getters ──────────────────────────────────────────────────────────────
  List<JobListingModel> get jobs => List.unmodifiable(_jobs);
  List<JobListingModel> get filteredJobs => List.unmodifiable(_filteredJobs);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Set<int> get savedJobIds => Set.unmodifiable(_savedJobIds);
  
  double getAlignmentScore(int? jobId) {
    if (jobId == null || jobId <= 0) return 0.0;
    return _alignmentScores[jobId] ?? 0.0;
  }

  // ── Load Jobs with Alignment ─────────────────────────────────────────────
  Future<void> loadJobsWithAlignment({
    required int userId,
    required UserModel user,
    required List<SkillModel> skills,
    required List<ExperienceModel> experience,
    required List<EducationModel> education,
    required List<CertificationModel> certifications,
    required List<ProjectModel> projects,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Load all jobs
      _jobs = await _repository.findAll();

      // 2. Calculate alignment scores
      for (final job in _jobs) {
        final score = _matchingService.calculateAlignmentScore(
          job: job,
          user: user,
          skills: skills,
          experience: experience,
          education: education,
          certifications: certifications,
          projects: projects,
        );
        _alignmentScores[job.id ?? -1] = score;
      }

      // 3. Apply current filters
      _applyFilters();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Filtering Methods ────────────────────────────────────────────────────
  void setCategoryFilter(String category) {
    _filterCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void setAlignmentThreshold(double threshold) {
    _alignmentThreshold = threshold;
    _applyFilters();
    notifyListeners();
  }

  void setShowRecommendedOnly(bool show) {
    _showRecommendedOnly = show;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredJobs = _jobs.where((job) {
      // Category filter
      if (_filterCategory.isNotEmpty && job.category != _filterCategory) {
        return false;
      }

      // Alignment threshold filter
      if (_showRecommendedOnly) {
        final score = _alignmentScores[job.id ?? -1] ?? 0.0;
        return score >= _alignmentThreshold;
      }

      return true;
    }).toList();

    // Sort by alignment score (descending)
    _filteredJobs.sort((a, b) {
      final scoreA = _alignmentScores[a.id ?? -1] ?? 0.0;
      final scoreB = _alignmentScores[b.id ?? -1] ?? 0.0;
      return scoreB.compareTo(scoreA);
    });
  }

  // ── Save/Bookmark Management ─────────────────────────────────────────────
  void toggleSave(int jobId) {
    if (_savedJobIds.contains(jobId)) {
      _savedJobIds.remove(jobId);
    } else {
      _savedJobIds.add(jobId);
    }
    notifyListeners();
  }

  bool isSaved(int jobId) => _savedJobIds.contains(jobId);

  // ── Existing Methods ───────────────────────────────────────────────────
  Future<void> loadJobs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _jobs = await _repository.findAll();
      _filteredJobs = List.from(_jobs);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadJobs();
}
```

---

## Usage in Dashboard

### Integration Point: `dashboard_screen.dart`

```dart
class DashboardScreen extends StatefulWidget { /* ... */ }

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadJobsWithAlignment();
  }

  Future<void> _loadJobsWithAlignment() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user?.id == null) return;

    final userId = user!.id!;
    final skills = context.read<SkillsProvider>().skills;
    final experience = context.read<ExperienceProvider>().experience;
    final education = context.read<EducationProvider>().education;
    final certs = context.read<CertificationProvider>().certifications;
    final projects = context.read<PortfolioProvider>().projects;

    await context.read<JobFeedProvider>().loadJobsWithAlignment(
      userId: userId,
      user: user,
      skills: skills,
      experience: experience,
      education: education,
      certifications: certs,
      projects: projects,
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobsProvider = context.watch<JobFeedProvider>();

    return Column(
      children: [
        // Optional: Filter controls
        _buildFilterControls(jobsProvider),

        // Job list (now aligned/ranked)
        if (jobsProvider.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (jobsProvider.filteredJobs.isEmpty)
          const Center(child: Text('No jobs match your profile'))
        else
          ListView.builder(
            itemCount: jobsProvider.filteredJobs.length,
            itemBuilder: (context, index) {
              final job = jobsProvider.filteredJobs[index];
              final score = jobsProvider.getAlignmentScore(job.id);
              
              return JobFeedCard(
                job: job,
                alignmentScore: score,
                // ... other props
              );
            },
          ),
      ],
    );
  }

  Widget _buildFilterControls(JobFeedProvider provider) {
    return Row(
      children: [
        DropdownButton<String>(
          hint: const Text('Category'),
          onChanged: (value) {
            if (value != null) {
              provider.setCategoryFilter(value);
            }
          },
          items: ['Freelance', 'Creative', 'Fresh Grad / OJT', 'Sales', 'Admin']
            .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
            .toList(),
        ),
        Checkbox(
          value: provider.showRecommendedOnly,
          onChanged: (value) {
            provider.setShowRecommendedOnly(value ?? false);
          },
          label: const Text('Recommended Only'),
        ),
      ],
    );
  }
}
```

---

## Next Steps Checklist

- [ ] Create `lib/data/services/job_matching_service.dart`
- [ ] Inject `JobMatchingService` into `JobFeedProvider`
- [ ] Add alignment state variables to `JobFeedProvider`
- [ ] Implement `loadJobsWithAlignment()` method
- [ ] Add filter/threshold methods to provider
- [ ] Create `JobAlignmentCard` widget showing score
- [ ] Integrate into `DashboardScreen`
- [ ] Test with sample data
- [ ] Add alignment score display UI
- [ ] Performance test with large job sets

