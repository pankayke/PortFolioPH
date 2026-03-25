| Task No. | Description | Duration (hours) | Assignee | Prerequisite |
|---|---|---|---|---|
| Sprint 1: Foundation & Architecture |  |  |  |  |
| PFPH-1 | Flutter project init, pubspec.yaml, all package setup | 4 hrs. | Tom Kyle B. Caballegan | None |
| PFPH-2 | Enforce folder structure — create ALL placeholder .dart files | 3 hrs. | Tom Kyle B. Caballegan | PFPH-1 |
| PFPH-3 | SQLite schema design — all 10 tables, ERD sign-off | 8 hrs. | Mark Leannie Gacutno | None |
| PFPH-4 | DatabaseService singleton: open(), close(), getDatabase(), migrations | 6 hrs. | Mark Leannie Gacutno | PFPH-3 |
| PFPH-5 | AppRouter (GoRouter) — define ALL named routes upfront | 5 hrs. | Rex Bernard G. Gabor | PFPH-1 |
| PFPH-6 | Bottom navigation scaffold + 5 placeholder tab screens | 6 hrs. | Rex Bernard G. Gabor | PFPH-5 |
| PFPH-7 | Splash screen: logo + loading + session check → redirect | 4 hrs. | Tom Kyle B. Caballegan | PFPH-1 |
| PFPH-8 | AppConstants: colors, font sizes, padding, DB name, version | 3 hrs. | Mark Leannie Gacutno | PFPH-1 |
| PFPH-9 | AppTheme: Material 3, brand colors, dark/light modes | 5 hrs. | Rex Bernard G. Gabor | PFPH-8 |
| PFPH-10 | Git repo setup, branching strategy, README.md | 4 hrs. | Tom Kyle B. Caballegan, Mark Leannie Gacutno, Rex Bernard G. Gabor | None |
| PFPH-11 | Android manifest: runtime permissions (storage, camera) | 3 hrs. | Tom Kyle B. Caballegan | PFPH-1 |
| PFPH-12 | Sprint 1 internal demo + full retrospective | 3 hrs. | Tom Kyle B. Caballegan, Mark Leannie Gacutno, Rex Bernard G. Gabor | Sprint 1 tasks complete |
| PFPH-13 | BUFFER — 10% | 9.6 hrs. | Tom Kyle B. Caballegan, Mark Leannie Gacutno, Rex Bernard G. Gabor | Sprint 1 in progress |
| Sprint 2: Authentication + Dashboard |  |  |  |  |
| PFPH-14 | UserModel: fromMap(), toMap(), copyWith() | 3 hrs. | Mark Leannie Gacutno | Sprint 1 complete |
| PFPH-15 | AuthService: register(), login(), logout(), getCurrentUser() | 8 hrs. | Mark Leannie Gacutno | PFPH-13 |
| PFPH-16 | Login screen UI (email, password, form validation) | 5 hrs. | Rex Bernard G. Gabor | PFPH-14 |
| PFPH-17 | Register screen UI (name, email, password, confirm) | 5 hrs. | Rex Bernard G. Gabor | PFPH-14 |
| PFPH-18 | Forgot password screen (security question local reset) | 4 hrs. | Tom Kyle B. Caballegan | PFPH-14 |
| PFPH-19 | AuthProvider (ChangeNotifier): authState, currentUser, errorMessage | 5 hrs. | Tom Kyle B. Caballegan | PFPH-14, PFPH-15, PFPH-16, PFPH-17 |
| PFPH-20 | Student Dashboard: greeting, stats, recent entries, quick-add FAB | 8 hrs. | Rex Bernard G. Gabor | PFPH-15, PFPH-18 |
| PFPH-21 | Profile setup screen: avatar (image_picker), bio, school, course | 6 hrs. | Tom Kyle B. Caballegan | PFPH-14 |
| PFPH-22 | ProfileService: getProfile(), updateProfile() | 5 hrs. | Mark Leannie Gacutno | PFPH-20 |
| PFPH-23 | Session persistence: auto-login from SharedPreferences | 4 hrs. | Tom Kyle B. Caballegan | PFPH-14 |
| PFPH-24 | Unit tests: AuthService register/login/logout | 4 hrs. | Mark Leannie Gacutno | PFPH-14 |
| PFPH-25 | Sprint 2 demo + retrospective | 3 hrs. | Tom Kyle B. Caballegan, Mark Leannie Gacutno, Rex Bernard G. Gabor | Sprint 2 tasks complete |
| PFPH-26 | BUFFER — 10% | 9.6 hrs. | Tom Kyle B. Caballegan, Mark Leannie Gacutno, Rex Bernard G. Gabor | Sprint 2 in progress |
| Sprint 3: Portfolio CRUD I — Projects & Achievements |  |  |  |  |
| PFPH-27 | ProjectModel: id, userId, title, desc, techStack, dates, tags | 3 hrs. | Mark Leannie Gacutno | Sprint 2 complete |
| PFPH-28 | ProjectService: create, getAll, getById, update, delete, search | 8 hrs. | Mark Leannie Gacutno | PFPH-26 |
| PFPH-29 | ProjectsListScreen: ListView.builder + search bar + filter chips | 7 hrs. | Rex Bernard G. Gabor | PFPH-27 |
| PFPH-30 | AddEditProjectScreen: title, desc, tags, dates, tech stack, images | 8 hrs. | Rex Bernard G. Gabor | PFPH-26, PFPH-27 |
| PFPH-31 | ImageStorageService: saveImage(), deleteImage(), compressImage() | 7 hrs. | Tom Kyle B. Caballegan | Sprint 1 complete |
| PFPH-32 | ProjectDetailScreen: full view + image carousel + edit/delete | 6 hrs. | Tom Kyle B. Caballegan | PFPH-28, PFPH-29 |
| PFPH-33 | AchievementModel: id, userId, title, desc, date, type, imagePath | 2 hrs. | Mark Leannie Gacutno | Sprint 2 complete |
| PFPH-34 | AchievementService: full CRUD + searchByTitle() | 5 hrs. | Mark Leannie Gacutno | PFPH-32 |
| PFPH-35 | AchievementsListScreen + AddEditAchievementScreen | 6 hrs. | Rex Bernard G. Gabor | PFPH-33 |
| PFPH-36 | ProjectProvider + AchievementProvider (ChangeNotifier) | 5 hrs. | Tom Kyle B. Caballegan | PFPH-28, PFPH-32 |
| PFPH-37 | Reusable widgets: PortfolioCard, EmptyStateWidget, LoadingWidget, TagChip | 4 hrs. | Tom Kyle B. Caballegan | PFPH-28 |
| PFPH-38 | Sprint 3 demo + retrospective | 3 hrs. | Tom Kyle B. Caballegan, Mark Leannie Gacutno, Rex Bernard G. Gabor | Sprint 3 tasks complete |
| PFPH-39 | BUFFER — 10% | 9.6 hrs. | Tom Kyle B. Caballegan, Mark Leannie Gacutno, Rex Bernard G. Gabor | Sprint 3 in progress |
| Sprint 4: Portfolio CRUD II — Certificates, Reflections & Skills |  |  |  |  |
| PFPH-40 | CertificateModel: id, userId, title, issuer, dates, filePath, type | 3 hrs. | Mark Leannie Gacutno | Sprint 3 complete |
| PFPH-41 | CertificateService: full CRUD + filterByType() + search | 6 hrs. | Mark Leannie Gacutno | PFPH-39 |
| PFPH-42 | CertificatesListScreen + AddEditCertificateScreen | 7 hrs. | Rex Bernard G. Gabor | PFPH-40 |
| PFPH-43 | Document upload for certificates (image_picker + file_picker) | 5 hrs. | Tom Kyle B. Caballegan | PFPH-1, PFPH-11 |
| PFPH-44 | ReflectionModel: id, userId, title, body, mood, tags, isPrivate, date | 2 hrs. | Mark Leannie Gacutno | Sprint 2 complete |
| PFPH-45 | ReflectionService: full CRUD + searchByBody() (SQLite LIKE or FTS5) | 5 hrs. | Mark Leannie Gacutno | PFPH-43 |
| PFPH-46 | ReflectionsListScreen + ReflectionEditorScreen | 7 hrs. | Rex Bernard G. Gabor | PFPH-44 |
| PFPH-47 | SkillModel: id, userId, name, category, rating 1-5, lastUsed | 3 hrs. | Tom Kyle B. Caballegan | Sprint 2 complete |
| PFPH-48 | SkillService: full CRUD + sortByRating() + suggestSkillNames() | 4 hrs. | Tom Kyle B. Caballegan | PFPH-46 |
| PFPH-49 | SkillsTrackerScreen: categorized list + rating stars + add/edit modal | 7 hrs. | Tom Kyle B. Caballegan | PFPH-47 |
| PFPH-50 | CertificateProvider + ReflectionProvider + SkillProvider | 5 hrs. | Tom Kyle B. Caballegan | PFPH-40, PFPH-44, PFPH-47 |
| PFPH-51 | PortfolioOverview tab: aggregate all 4 modules with counts + recent | 7 hrs. | Rex Bernard G. Gabor | PFPH-41, PFPH-45, PFPH-48 |
| PFPH-52 | Sprint 4 demo + retrospective | 3 hrs. | Tom Kyle B. Caballegan, Mark Leannie Gacutno, Rex Bernard G. Gabor | Sprint 4 tasks complete |
| PFPH-53 | BUFFER — 10% | 9.6 hrs. | Tom Kyle B. Caballegan, Mark Leannie Gacutno, Rex Bernard G. Gabor | Sprint 4 in progress |
| Sprint 5: Resume / CV Builder |  |  |  |  |
| PFPH-54 | ResumeModel: id, userId, templateId, customSections JSON, isDefault | 3 hrs. | Mark Leannie Gacutno | Sprint 4 complete |
| PFPH-55 | Design 3 PH resume templates (paper/Figma before coding) | 4 hrs. | Tom Kyle B. Caballegan, Mark Leannie Gacutno, Rex Bernard G. Gabor | Sprint 4 complete |
| PFPH-56 | ResumeTemplateSimple widget — government/academic style | 8 hrs. | Rex Bernard G. Gabor | PFPH-53, PFPH-54 |
| PFPH-57 | ResumeTemplateProfessional widget — corporate PH style | 7 hrs. | Rex Bernard G. Gabor | PFPH-53, PFPH-54 |
| PFPH-58 | ResumeTemplateModern widget — fresh grad tech style | 7 hrs. | Tom Kyle B. Caballegan | PFPH-53, PFPH-54 |
| PFPH-59 | ResumeDataService: mapPortfolioToResumeData(userId) | 8 hrs. | Mark Leannie Gacutno | PFPH-52, Sprint 4 complete |
| PFPH-60 | TemplateSelectionScreen: 3 template preview cards + select CTA | 5 hrs. | Tom Kyle B. Caballegan | PFPH-53 |
| PFPH-61 | ResumeBuilderScreen: live preview + section toggles + field overrides | 8 hrs. | Tom Kyle B. Caballegan, Rex Bernard G. Gabor | PFPH-54, PFPH-55, PFPH-56, PFPH-57 |
| PFPH-62 | ResumeProvider: selectedTemplate, resumeData, dirtyState | 5 hrs. | Mark Leannie Gacutno | PFPH-52, PFPH-58 |
| PFPH-63 | Photo slot: pick from gallery or use profile photo + 2×2 crop | 4 hrs. | Mark Leannie Gacutno | PFPH-52 |
| PFPH-64 | Unit tests: ResumeDataService field mapping accuracy | 4 hrs. | Tom Kyle B. Caballegan | PFPH-57, PFPH-58 |
| PFPH-65 | Sprint 5 demo + retrospective | 3 hrs. | Tom Kyle B. Caballegan, Mark Leannie Gacutno, Rex Bernard G. Gabor | Sprint 5 tasks complete |
| PFPH-66 | BUFFER — 10% | 9.6 hrs. | Tom Kyle B. Caballegan, Mark Leannie Gacutno, Rex Bernard G. Gabor | Sprint 5 in progress |
| Sprint 6: PDF Export + UI Polish |  |  |  |  |
| PFPH-67 | PdfService: generateResumePdf(resumeData, templateId) — pdf package | 10 hrs. | Mark Leannie Gacutno | Sprint 5 complete |
| PFPH-68 | PDF layout for Template I (Simple) — mirror Flutter widget layout | 7 hrs. | Mark Leannie Gacutno | PFPH-66 |
| PFPH-69 | PDF layout for Template II (Professional) | 7 hrs. | Rex Bernard G. Gabor | PFPH-66 |
| PFPH-70 | PDF layout for Template III (Modern) | 6 hrs. | Rex Bernard G. Gabor | PFPH-66 |
| PFPH-71 | PdfExportScreen: preview (printing pkg) + save to Downloads | 6 hrs. | Tom Kyle B. Caballegan | PFPH-67, PFPH-68, PFPH-69 |
| PFPH-72 | Share PDF via Android share sheet (share_plus) | 3 hrs. | Tom Kyle B. Caballegan | PFPH-70 |
| PFPH-73 | Portfolio PDF export (all entries as structured PDF document) | 6 hrs. | Mark Leannie Gacutno | PFPH-66, Sprint 4 complete |
| PFPH-74 | ExportHistoryService: log exports to audit table | 3 hrs. | Tom Kyle B. Caballegan | PFPH-70 |
| PFPH-75 | UI Polish pass: spacing, loading skeletons, error states all screens | 7 hrs. | Rex Bernard G. Gabor | Sprint 5 complete |
| PFPH-76 | Micro-animations: page transitions, FAB, card tap feedback | 4 hrs. | Tom Kyle B. Caballegan | PFPH-74 |
| PFPH-77 | Empty state illustrations for all list screens | 4 hrs. | Rex Bernard G. Gabor | PFPH-73 |
| PFPH-78 | Accessibility pass: semantics labels, contrast, font scaling | 3 hrs. | Mark Leannie Gacutno | PFPH-73 |
| PFPH-79 | Sprint 6 demo + retrospective | 3 hrs. | Tom Kyle B. Caballegan, Mark Leannie Gacutno, Rex Bernard G. Gabor | Sprint 6 tasks complete |
| PFPH-80 | BUFFER — 10% | 9.6 hrs. | Tom Kyle B. Caballegan, Mark Leannie Gacutno, Rex Bernard G. Gabor | Sprint 6 in progress |
| Sprint 7: Admin Panel + Security |  |  |  |  |
| PFPH-81 | Admin seeding: setup wizard on first launch (or hardcoded seed admin) | 3 hrs. | Mark Leannie Gacutno | Sprint 6 complete |
| PFPH-82 | Admin login screen (separate PIN/password + admin badge UI) | 4 hrs. | Rex Bernard G. Gabor | PFPH-80 |
| PFPH-83 | AdminDashboard: total users, portfolios, exports, storage used | 7 hrs. | Rex Bernard G. Gabor | PFPH-80, PFPH-81 |
| PFPH-84 | AdminUserListScreen: all students + portfolio counts + search | 6 hrs. | Tom Kyle B. Caballegan | PFPH-82 |
| PFPH-85 | AdminPortfolioViewScreen: read-only view of any student's portfolio | 5 hrs. | Tom Kyle B. Caballegan | PFPH-83 |
| PFPH-86 | AdminDataManagementScreen: delete user, export all data, wipe DB | 6 hrs. | Mark Leannie Gacutno | PFPH-83 |
| PFPH-87 | BackupService: export full SQLite DB as .db file to Downloads | 5 hrs. | Mark Leannie Gacutno | PFPH-86 |
| PFPH-88 | RestoreService: import .db backup (schema version validation) | 5 hrs. | Mark Leannie Gacutno | PFPH-86 |
| PFPH-89 | App PIN lock screen: 4-digit PIN, auto-lock after 5 min idle | 5 hrs. | Tom Kyle B. Caballegan | Sprint 2 complete |
| PFPH-90 | BiometricService: optional fingerprint auth (local_auth pkg) | 5 hrs. | Tom Kyle B. Caballegan | PFPH-88 |
| PFPH-91 | Input sanitization audit: review all SQL queries in all services | 4 hrs. | Rex Bernard G. Gabor | Sprint 1-6 services complete |
| PFPH-92 | Audit log: track login attempts, failed PINs, admin actions | 4 hrs. | Rex Bernard G. Gabor | PFPH-85, PFPH-90 |
| PFPH-93 | Sprint 7 demo + retrospective | 3 hrs. | Tom Kyle B. Caballegan, Mark Leannie Gacutno, Rex Bernard G. Gabor | Sprint 7 tasks complete |
| PFPH-94 | BUFFER — 10% | 9.6 hrs. | Tom Kyle B. Caballegan, Mark Leannie Gacutno, Rex Bernard G. Gabor | Sprint 7 in progress |
| Sprint 8: QA, Bug Fixes & APK Release |  |  |  |  |
| PFPH-95 | Full regression test pass (manual end-to-end all user flows) | 12 hrs. | Tom Kyle B. Caballegan, Mark Leannie Gacutno, Rex Bernard G. Gabor | Sprint 7 complete |
| PFPH-96 | Unit tests for all Services (target ≥80% service layer coverage) | 8 hrs. | Mark Leannie Gacutno | Sprint 7 complete |
| PFPH-97 | Widget tests: Login, Dashboard, ResumeBuilderScreen | 6 hrs. | Tom Kyle B. Caballegan | Sprint 7 complete |
| PFPH-98 | Bug fix sprint: Critical → High → Medium (skip Low) | 10 hrs. | Tom Kyle B. Caballegan, Mark Leannie Gacutno, Rex Bernard G. Gabor | PFPH-95 |
| PFPH-99 | Performance profiling: Flutter DevTools (fps, memory, DB query times) | 4 hrs. | Rex Bernard G. Gabor | PFPH-95 |
| PFPH-100 | Fix performance regressions from profiling | 4 hrs. | Tom Kyle B. Caballegan | PFPH-99 |
| PFPH-101 | Final UI pass: typography, spacing, icon sizes — all screens | 5 hrs. | Rex Bernard G. Gabor | PFPH-98, PFPH-100 |
| PFPH-102 | Keystore generation + app signing config | 3 hrs. | Tom Kyle B. Caballegan | Sprint 7 complete |
| PFPH-103 | flutter build apk --release --split-per-abi | 2 hrs. | Tom Kyle B. Caballegan | PFPH-102 |
| PFPH-104 | Install + test release APK on 2 physical Android devices | 4 hrs. | Tom Kyle B. Caballegan, Rex Bernard G. Gabor | PFPH-103 |
| PFPH-105 | Documentation: README, 1-page user manual, DB schema diagram | 6 hrs. | Mark Leannie Gacutno | Sprint 1-7 complete |
| PFPH-106 | Capstone presentation slides + demo script + Q&A rehearsal | 6 hrs. | Tom Kyle B. Caballegan, Mark Leannie Gacutno, Rex Bernard G. Gabor | PFPH-95, PFPH-105 |
| PFPH-107 | Final retrospective: lessons learned, what to keep, future roadmap | 3 hrs. | Tom Kyle B. Caballegan, Mark Leannie Gacutno, Rex Bernard G. Gabor | Sprint 8 tasks complete |
| PFPH-108 | BUFFER — 10% | 9.6 hrs. | Tom Kyle B. Caballegan, Mark Leannie Gacutno, Rex Bernard G. Gabor | Sprint 8 in progress |
|  | SPRINT TOTAL | Sprint 1: 63.6 hrs.; Sprint 2: 69.6 hrs.; Sprint 3: 73.6 hrs.; Sprint 4: 73.6 hrs.; Sprint 5: 75.6 hrs.; Sprint 6: 78.6 hrs.; Sprint 7: 71.6 hrs.; Sprint 8: 82.6 hrs. | Tom Kyle B. Caballegan, Mark Leannie Gacutno, Rex Bernard G. Gabor | All sprint tasks complete |
|  | GRAND TOTAL | 588.8 hrs. | Tom Kyle B. Caballegan, Mark Leannie Gacutno, Rex Bernard G. Gabor | Sprint 1-8 complete |
CHECK: last task=108, grand=588.8