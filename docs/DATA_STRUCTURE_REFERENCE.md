# Data Structure Reference & Relationships

## 1. Entity Relationship Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           DATA RELATIONSHIPS                                 │
└─────────────────────────────────────────────────────────────────────────────┘

                               ┌──────────────┐
                               │   UserModel  │
                               │   (users)    │
                               └──────┬───────┘
                                      │
                    ┌─────────────────┼─────────────────┐
                    │                 │                 │
                    ▼                 ▼                 ▼
          ┌──────────────────┐  ┌─────────────┐  ┌──────────────┐
          │  SkillModel      │  │Experience   │  │ Education    │
          │  (skills)        │  │ (work_exp)  │  │ (education)  │
          │                  │  │             │  │              │
          │ • name           │  │ • company   │  │ • degree     │
          │ • category       │  │ • jobTitle  │  │ • institution│
          │ • level          │  │ • location  │  │ • field      │
          │ • yearsOfExp     │  │ • isCurrent │  │ • isCurrent  │
          └──────────────────┘  └─────────────┘  └──────────────┘
                    │                 │                 │
                    └─────────────────┼─────────────────┘
                                      │
                    ┌─────────────────┼─────────────────┐
                    │                 │                 │
                    ▼                 ▼                 ▼
            ┌──────────────────┐  ┌──────────────┐  ┌─────────────┐
            │Certification     │  │ Portfolio    │  │ ProjectModel│
            │(certifications)  │  │ (portfolios) │  │ (projects)  │
            │                  │  │              │  │             │
            │ • name           │  │ • title      │  │ • title     │
            │ • org            │  │ • isPublic   │  │ • techStack │
            │ • credentialUrl  │  │ • customUrl  │  │ • github    │
            │ • expiryDate     │  │              │  │ • liveDemo  │
            └──────────────────┘  └──────────────┘  └─────────────┘


≈ ≈ ≈ ≈ ≈ ≈ ≈ ≈ ≈ ≈ ≈ ≈ ≈ ≈ ≈ ≈ ≈ ≈ ≈ ≈ ≈ ≈ ≈ ≈ ≈ ≈ ≈ ≈ ≈ ≈ ≈ ≈ ≈ ≈

                         ┌──────────────────┐
                         │ JobListingModel  │
                         │ (jobs table)     │
                         ├──────────────────┤
                         │ • title          │
                         │ • company        │
                         │ • description    │
                         │ • category       │
                         │ • location       │
                         │ • salary         │
                         │ • isFeatured     │
                         │ • sortOrder      │
                         └──────────────────┘

        ↑ MATCHES AGAINST ↓
        
    User's Profile Data (above)
    ├─ Skills
    ├─ Experience  
    ├─ Education
    ├─ Certifications
    ├─ Projects/Tech Stack
    └─ Location
```

---

## 2. File Structure & Relationships

### Layer 1: Data Models (Read-Only)
```
lib/data/models/
├── job_listing_model.dart          ← Job description (what to match)
├── user_model.dart                 ← User metadata
├── skill_model.dart                ← User's technical skills
├── experience_model.dart           ← User's work history
├── education_model.dart            ← User's education
├── certification_model.dart        ← User's certifications
└── project_model.dart              ← User's portfolio projects
```

### Layer 2: Repositories (Database I/O)
```
lib/data/repositories/
├── job_feed_repository.dart        ← findAll() → List<JobListingModel>
├── skill_repository.dart           ← findByUserId() → List<SkillModel>
├── experience_repository.dart      ← findByUserId() → List<ExperienceModel>
├── education_repository.dart       ← findByUserId() → List<EducationModel>
├── certification_repository.dart   ← findByUserId() → List<CertificationModel>
└── project_repository.dart         ← findByUserId() → List<ProjectModel>
```

### Layer 3: Services (Business Logic) 
```
lib/data/services/
├── auth_service.dart               ← Existing: login/register
├── profile_service.dart            ← Existing: profile CRUD
└── job_matching_service.dart       ← ★ NEW: Alignment scoring
    ├── calculateAlignmentScore()
    ├── rankJobsByScore()
    └── Helper methods: _extractSkillsFromJob(), _calculateLocationMatch(), etc.
```

### Layer 4: Providers (State Management)
```
lib/presentation/providers/
├── auth_provider.dart              ← currentUser: UserModel
├── job_feed_provider.dart          ← jobs, filteredJobs, alignmentScores
├── skills_provider.dart            ← skills: List<SkillModel>
├── experience_provider.dart        ← experience: List<ExperienceModel>
├── education_provider.dart         ← education: List<EducationModel>
├── certification_provider.dart     ← certifications: List<CertificationModel>
└── portfolio_provider.dart         ← projects: List<ProjectModel>
```

### Layer 5: Screens (UI Consumption)
```
lib/presentation/screens/
└── dashboard/dashboard_screen.dart
    ├── Reads: AuthProvider.currentUser
    ├── Reads: JobFeedProvider.filteredJobs (with alignment scores)
    ├── Calls: JobFeedProvider.loadJobsWithAlignment(userId, skills, exp, edu, certs, projects)
    ├── Displays: Job cards ranked by alignment
    └── Features: Filter by category, show recommended only, etc.
```

---

## 3. Data Flow Diagram

### Initialization Flow
```
DashboardScreen.build()
    │
    ├─→ Get user from context.watch<AuthProvider>().currentUser
    │
    ├─→ didChangeDependencies() calls _loadJobsWithAlignment()
    │    │
    │    ├─→ Gather user profile data:
    │    │   ├─ skills: context.read<SkillsProvider>().skills
    │    │   ├─ experience: context.read<ExperienceProvider>().experience
    │    │   ├─ education: context.read<EducationProvider>().education
    │    │   ├─ certs: context.read<CertificationProvider>().certifications
    │    │   └─ projects: context.read<PortfolioProvider>().projects
    │    │
    │    └─→ Call JobFeedProvider.loadJobsWithAlignment(
    │           userId, user, skills, experience, education, certs, projects
    │        )
    │           │
    │           ├─→ JobFeedRepository.findAll()
    │           │    └─→ From DB: SELECT * FROM jobs
    │           │
    │           ├─→ For each job:
    │           │    └─→ JobMatchingService.calculateAlignmentScore(
    │           │         job, user, skills, experience, education, certs, projects
    │           │       )
    │           │        Returns: double (0.0 - 1.0)
    │           │
    │           └─→ Store scores in _alignmentScores[jobId] = score
    │
    └─→ Watch JobFeedProvider.filteredJobs
        └─→ Display jobs sorted by alignment score (descending)
```

### Matching Calculation Flow
```
JobMatchingService.calculateAlignmentScore(
    job: "Virtual Assistant - ₱25k/mo",
    user: UserModel(location: "Cebu"),
    skills: [
        SkillModel(name: "Communication", level: advanced),
        SkillModel(name: "Organization", level: intermediate),
    ],
    experience: [
        ExperienceModel(company: "TechCorp", isCurrent: true),
    ],
    education: [
        EducationModel(degree: "Bachelor", isCurrent: false),
    ],
    certifications: [
        CertificationModel(name: "Project Management"),
    ],
    projects: [
        ProjectModel(title: "App", techStack: "Flutter,Firebase"),
    ],
)
    │
    ├─→ _calculateSkillMatch()
    │    ├─ Extract keywords from job: "assistant", "email", "schedule"
    │    ├─ Match against ["Communication", "Organization"]
    │    └─ Return: 0.6 (60% match) × 40% weight = 0.24
    │
    ├─→ _calculateExperienceMatch()
    │    ├─ User has recent experience (isCurrent: true)
    │    └─ Return: 1.0 × 25% weight = 0.25
    │
    ├─→ _calculateLocationMatch()
    │    ├─ Job has "Work from Home"
    │    ├─ User location is "Cebu" (not required)
    │    └─ Return: 1.0 (remote) × 15% weight = 0.15
    │
    ├─→ _calculateEducationMatch()
    │    ├─ Job doesn't mention degree requirement
    │    └─ Return: 0.8 × 10% weight = 0.08
    │
    └─→ _calculateCertificationMatch()
         ├─ User has certifications (bonus)
         └─ Return: 1.0 × 10% weight = 0.10

    TOTAL ALIGNMENT SCORE: 0.24 + 0.25 + 0.15 + 0.08 + 0.10 = 0.82
    (82% match - EXCELLENT)
```

---

## 4. Quick Lookup: What Data to Access When

### For Skill-Based Filtering
**From**: `SkillsProvider.skills` or `SkillRepository.findByUserId(userId)`
**Uses**: Filter jobs requiring specific skills/languages
**Example**:
```dart
if (job.description.contains("Flutter")) {
  bool hasFlutter = userSkills.any((s) => s.name.contains("Flutter"));
}
```

### For Experience Level Filtering
**From**: `ExperienceProvider.experience` or `ExperienceRepository.findByUserId(userId)`
**Uses**: Determine if user qualifies for role (fresh grad vs senior)
**Example**:
```dart
bool isFreshGrad = userExperience.isEmpty;
bool isSuitable = isFreshGrad 
  ? job.category.contains("Fresh Grad") 
  : userExperience.length > 0;
```

### For Education Level Filtering
**From**: `EducationProvider.education` or `EducationRepository.findByUserId(userId)`
**Uses**: Match degree requirements
**Example**:
```dart
bool hasDegree = userEducation.any((e) => 
  e.degree.contains("Bachelor") || e.degree.contains("Degree"));
```

### For Location Filtering
**From**: `UserModel.location` (from `AuthProvider.currentUser`)
**Uses**: Match job location preferences
**Example**:
```dart
bool isRemote = job.location.toLowerCase().contains("remote") ||
                job.location.toLowerCase().contains("work from home");
bool isLocalMatch = job.location.contains(user.location);
```

### For Technical Skills (Tech Stack)
**From**: `PortfolioProvider.projects` → `ProjectModel.techStack`
**Uses**: Confirm technical capabilities beyond just skill list
**Example**:
```dart
List<String> userTechs = userProjects
  .map((p) => p.techStack?.split(",").map((s) => s.trim()).toList() ?? [])
  .expand((list) => list)
  .toList();
  
bool hasTech = userTechs.any((tech) => job.description.contains(tech));
```

### For Recent Achievements
**From**: `CertificationProvider.certifications`
**Uses**: Boost score for recent certifications
**Example**:
```dart
bool hasRecentCert = userCerts.any((c) => 
  c.issueDate != null && 
  DateTime.parse(c.issueDate!).year >= DateTime.now().year - 1
);
```

---

## 5. Scoring Weight Breakdown (Recommended)

```
TOTAL ALIGNMENT SCORE = 100%

Skills Match ..................... 40%
├─ Exact skill matches ........... 25%
├─ Skill category matching ....... 10%
└─ Years of experience bonus ..... 5%

Experience Level ................. 25%
├─ Recent work experience ........ 15%
├─ Similar job titles ............ 8%
└─ Employment status ............. 2%

Location Preference .............. 15%
├─ Exact location match .......... 8%
├─ Remote-friendly job ........... 5%
└─ Region/province match ......... 2%

Education Level .................. 10%
├─ Degree requirement match ...... 6%
├─ Field of study relevance ...... 3%
└─ Currently studying bonus ...... 1%

Certifications/Credentials ........ 10%
├─ Relevant certifications ....... 7%
├─ Industry-recognized certs ..... 2%
└─ Recent renewal bonus .......... 1%

────────────────────────────────────
TOTAL ........................... 100%
```

**Interpretation**:
- 0.75 - 1.00 = "Excellent Match" ✅
- 0.50 - 0.74 = "Good Match" 👍
- 0.25 - 0.49 = "Possible Fit" ⚠️
- 0.00 - 0.24 = "Not Recommended" ❌

---

## 6. Current Status Matrix

| Feature | Status | Location | Notes |
|---------|--------|----------|-------|
| Job Model | ✅ Complete | `job_listing_model.dart` | 11 fields, fully structured |
| Job Provider | ⚠️ Partial | `job_feed_provider.dart` | Loads all jobs, no filtering |
| Job Repository | ✅ Complete | `job_feed_repository.dart` | Fetches from DB, includes seeding |
| User Model | ✅ Complete | `user_model.dart` | Full profile metadata |
| Skills System | ✅ Complete | `skill_model.dart, provider` | Full CRUD capability |
| Experience System | ✅ Complete | `experience_model.dart, provider` | Full CRUD capability |
| Education System | ✅ Complete | `education_model.dart, provider` | Full CRUD capability |
| Certification System | ✅ Complete | `certification_model.dart, provider` | Full CRUD capability |
| Portfolio System | ✅ Complete | `project_model.dart, provider` | Full CRUD capability |
| **Job Matching** | ❌ TODO | `job_matching_service.dart` | **TO BE CREATED** |
| **Alignment Filtering** | ❌ TODO | `job_feed_provider.dart` | **NEEDS ENHANCEMENT** |
| **UI Display** | ⚠️ Partial | `dashboard_screen.dart` | Shows jobs, needs score display |

---

## 7. Implementation Checklist

```
PHASE 1: SERVICE LAYER
┌─ [ ] Create lib/data/services/job_matching_service.dart
├─ [ ] Implement calculateAlignmentScore()
├─ [ ] Implement _calculateSkillMatch()
├─ [ ] Implement _calculateExperienceMatch()
├─ [ ] Implement _calculateLocationMatch()
├─ [ ] Implement _calculateEducationMatch()
├─ [ ] Implement _calculateCertificationMatch()
├─ [ ] Implement _extractSkillsFromJob()
└─ [ ] Add unit tests for scoring logic

PHASE 2: PROVIDER ENHANCEMENT
├─ [ ] Inject JobMatchingService into JobFeedProvider
├─ [ ] Add _filteredJobs, _alignmentScores state
├─ [ ] Implement loadJobsWithAlignment()
├─ [ ] Implement setCategoryFilter()
├─ [ ] Implement setAlignmentThreshold()
├─ [ ] Implement setShowRecommendedOnly()
├─ [ ] Implement getAlignmentScore()
└─ [ ] Add integration tests

PHASE 3: UI INTEGRATION
├─ [ ] Enhance dashboard_screen.dart didChangeDependencies()
├─ [ ] Call loadJobsWithAlignment() with profile data
├─ [ ] Display filteredJobs instead of all jobs
├─ [ ] Add alignment score badge to job card
├─ [ ] Add filter UI controls
└─ [ ] Test with real user data

PHASE 4: REFINEMENT
├─ [ ] Calibrate scoring weights based on feedback
├─ [ ] Add "Why recommended?" explanations
├─ [ ] Optimize performance for large job sets
├─ [ ] Add user preference settings
└─ [ ] Document scoring algorithm
```

