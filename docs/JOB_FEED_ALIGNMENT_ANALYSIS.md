# Job Feed & Profile Alignment Architecture Analysis

## Overview
This document maps the current job feed system, user profile data, and identifies implementation points for job-profile alignment filtering.

---

## 1. Job Feed Architecture

### File Paths
- **Model**: [lib/data/models/job_listing_model.dart](lib/data/models/job_listing_model.dart)
- **Provider**: [lib/presentation/providers/job_feed_provider.dart](lib/presentation/providers/job_feed_provider.dart)
- **Repository**: [lib/data/repositories/job_feed_repository.dart](lib/data/repositories/job_feed_repository.dart)
- **Database Layer**: [lib/data/datasources/local/database_service.dart](lib/data/datasources/local/database_service.dart) (jobs table)

### JobListingModel Data Structure
```dart
class JobListingModel {
  final int? id;
  final String title;           // e.g., "Virtual Assistant"
  final String company;          // e.g., "RemoteBoss PH"
  final String salary;           // e.g., "₱25k/mo"
  final String location;         // e.g., "Work from Home"
  final String description;      // e.g., "Handle CEO emails and schedules..."
  final String category;         // e.g., "Freelance", "Fresh Grad / OJT", "Creative"
  final bool isFeatured;         // Featured job flag
  final int sortOrder;           // Display order
  final String createdAt;        // ISO-8601 timestamp
  final String updatedAt;        // ISO-8601 timestamp
}
```

### Current Job Categories (Seeded)
- Freelance
- Creative
- Fresh Grad / OJT
- BPO / Support
- Sales
- Admin
- Gig Work

### JobFeedProvider State Management
```dart
class JobFeedProvider extends ChangeNotifier {
  List<JobListingModel> _jobs;        // All jobs from DB
  Set<int> _savedJobIds;              // Bookmarked job IDs (local)
  bool _isLoading;
  String? _errorMessage;

  // Current public API:
  Future<void> loadJobs()             // Fetch all jobs from repository
  Future<void> refresh()              // Reload jobs
  void toggleSave(int jobId)          // Add/remove from bookmarks
  bool isSaved(int jobId)             // Check if saved
}
```

### Current Filtering & Sorting Logic
**Location**: [lib/presentation/providers/job_feed_provider.dart](lib/presentation/providers/job_feed_provider.dart)

**Current Implementation**:
- **Sorting**: `orderBy: 'sort_order ASC, id ASC'` (database-level)
- **Filtering**: None – all jobs displayed
- **Search**: None – no search capability
- **Bookmarking**: In-memory set (not persistent)

**Current Usage** in Dashboard:
```dart
final previewJobs = jobsProvider.jobs.take(2).toList();  // Preview: 2 jobs
// Full list in _buildJobFeedSection()
```

---

## 2. User Profile Data Structure

### File Paths
- **UserModel**: [lib/data/models/user_model.dart](lib/data/models/user_model.dart)
- **AuthProvider**: [lib/presentation/providers/auth_provider.dart](lib/presentation/providers/auth_provider.dart)
- **ProfileService**: [lib/data/services/profile_service.dart](lib/data/services/profile_service.dart)

### UserModel Available Fields
```dart
class UserModel {
  final int? id;
  final String username;
  final String email;
  final String role;                 // "user" or "admin"
  final String? fullName;
  final String? bio;                 // Personal summary
  final String? avatarPath;
  final String? phoneNumber;
  final String? location;            // Home location (for proximity matching)
  final String? websiteUrl;
  final String createdAt;
  final String updatedAt;
}
```

### Associated User Data (Separate Tables)
The UserModel is connected to several other data models that collectively describe a user's profile:

#### Skills Data
**Files**:
- Model: [lib/data/models/skill_model.dart](lib/data/models/skill_model.dart)
- Provider: [lib/presentation/providers/skills_provider.dart](lib/presentation/providers/skills_provider.dart)
- Repository: [lib/data/repositories/skill_repository.dart](lib/data/repositories/skill_repository.dart)

**Structure**:
```dart
class SkillModel {
  final int? id;
  final int userId;
  final String name;                    // e.g., "JavaScript", "Project Management"
  final String category;                // e.g., "Frontend", "Backend", "Mobile"
  final SkillLevel level;               // enum: beginner, elementary, intermediate, advanced, expert
  final int yearsOfExperience;
  final int sortOrder;
  final String createdAt;
  final String updatedAt;
}

enum SkillLevel { beginner, elementary, intermediate, advanced, expert }
```

**Provider API**:
```dart
Future<void> loadForUser(int userId)
List<SkillModel> get skills
Future<List<SkillModel>> findByCategory(int userId, String category)
```

#### StudentSkills (Alternative/Parallel System)
**Files**:
- Model: [lib/data/models/student_skills_model.dart](lib/data/models/student_skills_model.dart)
- Provider: [lib/presentation/providers/student_skills_provider.dart](lib/presentation/providers/student_skills_provider.dart)
- Repository: [lib/data/repositories/student_skills_repository.dart](lib/data/repositories/student_skills_repository.dart)

**Structure**:
```dart
class StudentSkillsModel {
  final int? id;
  final int studentId;
  final String skillName;               // e.g., "Public Speaking"
  final String category;                // e.g., "Communication"
  final int proficiency;                // 1-5 scale
  final String dateAdded;
  final int projectsLinked;             // Count of linked projects
  final String createdAt;
  final String updatedAt;
}
```

#### Education
**Files**:
- Model: [lib/data/models/education_model.dart](lib/data/models/education_model.dart)
- Provider: [lib/presentation/providers/education_provider.dart](lib/presentation/providers/education_provider.dart)

**Structure**:
```dart
class EducationModel {
  final int? id;
  final int userId;
  final String institution;             // e.g., "University of San Carlos"
  final String degree;                  // e.g., "Bachelor of Science"
  final String fieldOfStudy;            // e.g., "Computer Science"
  final String? description;
  final String? grade;
  final String? startDate;
  final String? endDate;
  final bool isCurrent;
  final int sortOrder;
  final String createdAt;
  final String updatedAt;
}
```

#### Work Experience
**Files**:
- Model: [lib/data/models/experience_model.dart](lib/data/models/experience_model.dart)
- Provider: [lib/presentation/providers/experience_provider.dart](lib/presentation/providers/experience_provider.dart)

**Structure**:
```dart
class ExperienceModel {
  final int? id;
  final int userId;
  final String company;                 // e.g., "RemoteBoss PH"
  final String jobTitle;                // e.g., "Virtual Assistant"
  final String? employmentType;         // "Full-time", "Part-time", "Freelance"
  final String? location;
  final String? description;
  final String? startDate;
  final String? endDate;
  final bool isCurrent;
  final int sortOrder;
  final String createdAt;
  final String updatedAt;
}
```

#### Certifications
**Files**:
- Model: [lib/data/models/certification_model.dart](lib/data/models/certification_model.dart)
- Provider: [lib/presentation/providers/certification_provider.dart](lib/presentation/providers/certification_provider.dart)

**Structure**:
```dart
class CertificationModel {
  final int? id;
  final int userId;
  final String name;                    // e.g., "Google Project Management"
  final String issuingOrganization;     // e.g., "Google"
  final String? credentialId;
  final String? credentialUrl;
  final String? issueDate;
  final String? expiryDate;
  final bool doesExpire;
  final String? imagePath;
  final int sortOrder;
  final String createdAt;
  final String updatedAt;
}
```

#### Portfolio Projects
**Files**:
- Model: [lib/data/models/project_model.dart](lib/data/models/project_model.dart)
- Provider: [lib/presentation/providers/portfolio_provider.dart](lib/presentation/providers/portfolio_provider.dart)

**Structure**:
```dart
class ProjectModel {
  final int? id;
  final int portfolioId;
  final int userId;
  final String title;                   // e.g., "E-commerce Platform"
  final String? description;
  final String? techStack;              // comma-separated: "Flutter,Firebase,Dart"
  final String? repositoryUrl;          // GitHub link
  final String? liveDemoUrl;
  final String? thumbnailPath;
  final List<String> imagePaths;
  final String? startDate;
  final String? endDate;
  final bool isFeatured;
  final int sortOrder;
  final String createdAt;
  final String updatedAt;

  // Method available:
  String? extractTechStackList()        // Parses comma-separated into List<String>
}
```

---

## 3. How Current Data Access Works

### Typical Dashboard Flow
```dart
// In DashboardScreen build():
final user = context.watch<AuthProvider>().currentUser;  // UserModel

// Access user's data via providers:
final skills = context.watch<SkillsProvider>().skills;
final certs = context.watch<CertificationProvider>().certifications;
final experience = context.watch<ExperienceProvider>().experience;
final education = context.watch<EducationProvider>().education;
final portfolios = context.watch<PortfolioProvider>().portfolios;
final projects = context.watch<PortfolioProvider>().projects;

// Jobs are separate:
final jobsProvider = context.watch<JobFeedProvider>();
final allJobs = jobsProvider.jobs;  // No filtering/ranking
```

---

## 4. Implementation Points for Job-Profile Alignment

### 4.1 Recommended Service Layer for Matching
**Create New File**: `lib/data/services/job_matching_service.dart`

**Purpose**: Encapsulate all job-profile alignment logic separately from providers/repositories

**Responsibilities**:
- Calculate alignment score between job and user profile
- Implement filtering rules (skills, location, experience level, certifications)
- Rank jobs by relevance
- Handle threshold filtering

**Key Methods to Implement**:
```dart
class JobMatchingService {
  // Score calculation
  double calculateAlignmentScore(
    JobListingModel job,
    UserModel user,
    List<SkillModel> userSkills,
    List<ExperienceModel> userExperience,
    List<EducationModel> userEducation,
    List<CertificationModel> userCerts,
    List<ProjectModel> userProjects,
  ) → double (0.0 - 1.0)

  // Filtering
  bool matchesLocationPreference(JobListingModel job, UserModel user) → bool
  bool matchesSkillRequirements(JobListingModel job, List<SkillModel> skills) → bool
  bool matchesExperienceLevel(JobListingModel job, List<ExperienceModel> experience) → bool
  bool matchesCertifications(JobListingModel job, List<CertificationModel> certs) → bool

  // Ranking/Sorting
  List<JobListingModel> rankJobsByRelevance(
    List<JobListingModel> jobs,
    UserModel user,
    UserProfileData profileData,
  ) → List<JobListingModel>

  // Category matching
  bool jobCategoryMatchesUserProfile(String jobCategory, UserModel user) → bool
  SkillMatchResult analyzeSkillMatch(JobListingModel job, List<SkillModel> skills)
}

class SkillMatchResult {
  final List<String> matchedSkills;
  final List<String> missingSkills;
  final double matchPercentage;
}

class UserProfileData {
  final UserModel user;
  final List<SkillModel> skills;
  final List<ExperienceModel> experience;
  final List<EducationModel> education;
  final List<CertificationModel> certifications;
  final List<ProjectModel> projects;
}
```

### 4.2 Enhanced JobFeedProvider
**Location**: [lib/presentation/providers/job_feed_provider.dart](lib/presentation/providers/job_feed_provider.dart)

**Add Methods**:
```dart
class JobFeedProvider extends ChangeNotifier {
  final JobFeedRepository _repository;
  final JobMatchingService _matchingService;  // Inject

  // Existing:
  List<JobListingModel> _jobs = [];
  Set<int> _savedJobIds = {};

  // Add new state:
  List<JobListingModel> _filteredJobs = [];
  Map<int, double> _alignmentScores = {};
  String _filterCategory = '';
  double _minAlignmentThreshold = 0.5;
  bool _showRecommendedOnly = false;

  // Public API additions:
  Future<void> loadJobsWithAlignment(int userId) async {
    // Load jobs + calculate alignment scores
    _isLoading = true;
    notifyListeners();

    try {
      _jobs = await _repository.findAll();
      await _calculateAlignmentForUser(userId);
      _applyCurrentFilters();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _calculateAlignmentForUser(int userId) async {
    final user = /* fetch from UserRepository */;
    final skills = /* fetch all skills for user */;
    final experience = /* fetch */;
    final education = /* fetch */;
    final certs = /* fetch */;
    final projects = /* fetch */;

    final profileData = UserProfileData(
      user: user,
      skills: skills,
      experience: experience,
      education: education,
      certifications: certs,
      projects: projects,
    );

    for (final job in _jobs) {
      final score = _matchingService.calculateAlignmentScore(job, profileData);
      _alignmentScores[job.id ?? -1] = score;
    }
  }

  // Filtering methods:
  void setCategoryFilter(String category) {
    _filterCategory = category;
    _applyCurrentFilters();
    notifyListeners();
  }

  void setShowRecommendedOnly(bool value) {
    _showRecommendedOnly = value;
    _applyCurrentFilters();
    notifyListeners();
  }

  void setAlignmentThreshold(double threshold) {
    _minAlignmentThreshold = threshold;
    _applyCurrentFilters();
    notifyListeners();
  }

  void _applyCurrentFilters() {
    _filteredJobs = _jobs.where((job) {
      if (_filterCategory.isNotEmpty && job.category != _filterCategory) {
        return false;
      }
      if (_showRecommendedOnly) {
        final score = _alignmentScores[job.id ?? -1] ?? 0.0;
        return score >= _minAlignmentThreshold;
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

  // Getters:
  List<JobListingModel> get filteredJobs => List.unmodifiable(_filteredJobs);
  double getAlignmentScore(int jobId) => _alignmentScores[jobId] ?? 0.0;
  List<String> getRecommendationReason(int jobId) {
    // Return why job is recommended
  }
}
```

### 4.3 Repository Layer for User Data
**Existing**: [lib/data/repositories/](lib/data/repositories/)

**Suggested Addition**: Create query methods in existing repositories:
```dart
// In SkillRepository:
Future<List<SkillModel>> findByUserId(int userId)
Future<List<SkillModel>> findByCategory(int userId, String category)

// In ExperienceRepository:
Future<List<ExperienceModel>> findByUserId(int userId)
Future<int> getYearsOfExperienceInRole(int userId, String jobTitle)

// In EducationRepository:
Future<List<EducationModel>> findByUserId(int userId)
Future<String?> getHighestEducationLevel(int userId)

// In ProjectRepository:
Future<List<ProjectModel>> findByUserId(int userId)
Future<List<String>> getAllTechStacksForUser(int userId)
```

### 4.4 UI Layer Integration Point
**Location**: [lib/presentation/screens/dashboard/dashboard_screen.dart](lib/presentation/screens/dashboard/dashboard_screen.dart)

**Current**:
```dart
_buildJobFeedSection(
  jobsProvider,
  isDark,
  colorScheme,
)
```

**Enhanced**:
```dart
void _loadJobsWithAlignment(int userId) async {
  await context.read<JobFeedProvider>().loadJobsWithAlignment(userId);
}

// In build():
if (shouldShowAlignmentUI) {
  _buildJobAlignmentFilters()  // Category, threshold, etc.
}

// Display aligned jobs:
ListView(
  children: jobsProvider.filteredJobs.map((job) {
    final score = jobsProvider.getAlignmentScore(job.id ?? -1);
    return JobAlignmentCard(
      job: job,
      alignmentScore: score,
      reasons: jobsProvider.getRecommendationReason(job.id ?? -1),
    );
  }).toList(),
)
```

---

## 5. Alignment Scoring Algorithm (Recommended)

### Score Components
1. **Skills Match** (40% weight)
   - Extract required skills from job.title + job.description
   - Calculate skill overlap with user.skills
   - Boost for advanced/expert level matches

2. **Experience Level** (25% weight)
   - Analyze job category vs user's ExperienceModel entries
   - Years of experience in similar roles
   - Current employment status consideration

3. **Location** (15% weight)
   - Exact location match: +0.15
   - Remote-friendly: +0.10
   - User location set: +0.05

4. **Education** (10% weight)
   - Degree requirements (if any in description)
   - Fresh grad opportunities get special boost

5. **Projects/Portfolio** (10% weight)
   - Relevant project tech stack match
   - GitHub links demonstrate ability

### Example Scoring Logic
```dart
double calculateAlignmentScore(JobListingModel job, UserProfileData profile) {
  double score = 0.0;

  // 1. Skills (40%)
  final skillsMatch = _analyzeSkillMatch(job, profile.skills);
  score += skillsMatch.matchPercentage * 0.40;

  // 2. Experience (25%)
  final experienceMatch = _analyzeExperienceMatch(job, profile.experience);
  score += experienceMatch * 0.25;

  // 3. Location (15%)
  final locationMatch = _analyzeLocationMatch(job, profile.user);
  score += locationMatch * 0.15;

  // 4. Education (10%)
  final educationMatch = _analyzeEducationMatch(job, profile.education);
  score += educationMatch * 0.10;

  // 5. Portfolio (10%)
  final portfolioMatch = _analyzePortfolioMatch(job, profile.projects);
  score += portfolioMatch * 0.10;

  return score.clamp(0.0, 1.0);
}
```

---

## 6. Database Schema Considerations

### Jobs Table (Current)
```sql
CREATE TABLE jobs (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  title       TEXT    NOT NULL,
  company     TEXT    NOT NULL,
  salary      TEXT    NOT NULL,
  location    TEXT    NOT NULL,
  description TEXT    NOT NULL,
  category    TEXT    NOT NULL,
  is_featured INTEGER NOT NULL DEFAULT 0,
  sort_order  INTEGER NOT NULL DEFAULT 0,
  created_at  TEXT    NOT NULL,
  updated_at  TEXT    NOT NULL
)
```

### Optional Future Enhancement: Job Requirements Table
```sql
CREATE TABLE job_requirements (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  job_id      INTEGER NOT NULL,
  skill_name  TEXT    NOT NULL,
  skill_level TEXT,            -- beginner, intermediate, expert, etc.
  required    INTEGER DEFAULT 1,
  years_exp   INTEGER,
  created_at  TEXT    NOT NULL,
  FOREIGN KEY(job_id) REFERENCES jobs(id) ON DELETE CASCADE
)
```

---

## 7. Implementation Roadmap

### Phase 1: Foundation (Service Layer)
1. Create `JobMatchingService` with basic scoring
2. Add `UserProfileData` DTO
3. Implement location matching
4. Implement skill matching

### Phase 2: Provider Enhancement
1. Update `JobFeedProvider` with filtering state
2. Add alignment calculation methods
3. Implement threshold filtering
4. Add recommendation reasons

### Phase 3: UI Integration
1. Add alignment score display to JobFeedCard
2. Create filter UI controls
3. Add user preference settings
4. Show "Why recommended?" explanations

### Phase 4: Persistence
1. Store alignment scores in local cache
2. Store user job preferences
3. Track click-through rates

### Phase 5: Advanced Features
1. ML-based recommendation refinement
2. Saved job matching
3. Notification for new aligned opportunities
4. Job application tracking

---

## 8. Summary of Key Files

| Purpose | File Path |
|---------|-----------|
| Job Model | `lib/data/models/job_listing_model.dart` |
| Job Provider | `lib/presentation/providers/job_feed_provider.dart` |
| Job Repository | `lib/data/repositories/job_feed_repository.dart` |
| User Model | `lib/data/models/user_model.dart` |
| Skills Model | `lib/data/models/skill_model.dart` |
| Skills Provider | `lib/presentation/providers/skills_provider.dart` |
| Experience Model | `lib/data/models/experience_model.dart` |
| Experience Provider | `lib/presentation/providers/experience_provider.dart` |
| Education Model | `lib/data/models/education_model.dart` |
| Education Provider | `lib/presentation/providers/education_provider.dart` |
| Certifications Model | `lib/data/models/certification_model.dart` |
| Certifications Provider | `lib/presentation/providers/certification_provider.dart` |
| Projects Model | `lib/data/models/project_model.dart` |
| Portfolio Provider | `lib/presentation/providers/portfolio_provider.dart` |
| Dashboard (Usage) | `lib/presentation/screens/dashboard/dashboard_screen.dart` |
| **[NEW]** Job Matching Service | `lib/data/services/job_matching_service.dart` ← **To Create** |

---

## 9. Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                      DashboardScreen                             │
│  Watches: AuthProvider, JobFeedProvider, SkillsProvider, etc.   │
└────────┬────────────────────────────────────────────────────────┘
         │
         ├─→ Get User: AuthProvider.currentUser (UserModel)
         │
         └─→ Get Jobs: JobFeedProvider
              │
              ├─→ loadJobsWithAlignment(userId)
              │    │
              │    └─→ JobFeedProvider._calculateAlignmentForUser()
              │         │
              │         ├─→ Fetch Skills (SkillsProvider)
              │         ├─→ Fetch Experience (ExperienceProvider)
              │         ├─→ Fetch Education (EducationProvider)
              │         ├─→ Fetch Certifications (CertificationProvider)
              │         ├─→ Fetch Projects (PortfolioProvider)
              │         │
              │         └─→ JobMatchingService.calculateAlignmentScore()
              │              (for each job in collection)
              │
              ├─→ setShowRecommendedOnly(true)
              │    └─→ _applyCurrentFilters() + sort by score
              │
              └─→ Display: filteredJobs with alignment scores

```

---

## 10. Current Gaps & Opportunities

| Gap | Current State | Recommendation |
|-----|---------------|-----------------|
| Job Filtering | None | Implement JobMatchingService |
| Job Search | None | Add full-text search in repository |
| Skill Matching | Not implemented | Extract from description + match |
| Location Matching | Not implemented | Parse job location vs user location |
| Experience Validation | Manual | Auto-detect experience level |
| Bookmarking Persistence | In-memory only | Persist to database |
| Category Filtering | None | Filter by user-selected categories |
| Alignment Scoring | None | Implement weighted scoring |
| Recommendations | Just sort order | Rank by relevance to profile |
| Explanation | None | Show why job recommended |

