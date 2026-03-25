/// CV/Portfolio template mapping for PortFolioPH.
///
/// This file defines:
/// 1) Section order for student CV and portfolio views
/// 2) Mapping of UI sections to SQLite tables/columns
/// 3) Asset paths for default JSON templates
abstract final class TemplateSchemaMapping {
  // Template assets
  static const String studentCvTemplateAsset =
      'assets/templates/student_cv_template.json';
  static const String studentPortfolioTemplateAsset =
      'assets/templates/student_portfolio_template.json';

  // Recommended default section order (PH student/fresh-grad friendly)
  static const List<String> cvSectionOrder = [
    'header',
    'summary',
    'education',
    'experience',
    'projects',
    'skills',
    'certifications',
    'activities_awards',
    'references',
  ];

  static const List<String> portfolioSectionOrder = [
    'intro',
    'selected_works',
    'project_case_studies',
    'skills_tools',
    'contact_links',
  ];

  /// UI section -> DB table mapping.
  ///
  /// Notes:
  /// - Some sections are composites and read from multiple tables.
  /// - Column lists are intentionally explicit for predictable rendering.
  static const Map<String, Map<String, dynamic>> sectionToTable = {
    'header': {
      'table': 'users',
      'columns': [
        'full_name',
        'email',
        'phone_number',
        'location',
        'website_url',
        'avatar_path',
      ],
    },
    'summary': {
      'table': 'users',
      'columns': ['bio'],
    },
    'education': {
      'table': 'education',
      'columns': [
        'institution',
        'degree',
        'field_of_study',
        'description',
        'grade',
        'start_date',
        'end_date',
        'is_current',
        'sort_order',
      ],
      'orderBy': 'sort_order ASC, start_date DESC',
    },
    'experience': {
      'table': 'work_experience',
      'columns': [
        'company',
        'job_title',
        'employment_type',
        'location',
        'description',
        'start_date',
        'end_date',
        'is_current',
        'sort_order',
      ],
      'orderBy': 'sort_order ASC, start_date DESC',
    },
    'projects': {
      'table': 'projects',
      'columns': [
        'title',
        'description',
        'tech_stack',
        'repository_url',
        'live_demo_url',
        'thumbnail_path',
        'start_date',
        'end_date',
        'is_featured',
        'sort_order',
      ],
      'orderBy': 'is_featured DESC, sort_order ASC, created_at DESC',
    },
    'skills': {
      'table': 'skills',
      'columns': [
        'name',
        'category',
        'level',
        'years_of_experience',
        'sort_order',
      ],
      'orderBy': 'category ASC, sort_order ASC',
    },
    'certifications': {
      'table': 'certifications',
      'columns': [
        'name',
        'issuing_organization',
        'credential_id',
        'credential_url',
        'issue_date',
        'expiry_date',
        'does_expire',
        'image_path',
        'sort_order',
      ],
      'orderBy': 'sort_order ASC, issue_date DESC',
    },
    'activities_awards': {
      'table': 'app_settings',
      'columns': ['setting_key', 'setting_value'],
      'filterHint':
          'Use keys prefixed with activity_/award_ for student extras.',
    },
    'references': {
      'table': 'app_settings',
      'columns': ['setting_key', 'setting_value'],
      'filterHint': 'Use setting_key = references_policy.',
    },
    'contact_links': {
      'table': 'contacts',
      'columns': ['platform', 'url', 'display_label', 'sort_order'],
      'orderBy': 'sort_order ASC, platform ASC',
    },
    'theme': {
      'table': 'theme_settings',
      'columns': ['theme_mode', 'primary_color_hex', 'updated_at'],
    },
    'portfolio_meta': {
      'table': 'portfolios',
      'columns': ['title', 'summary', 'template_id', 'is_public', 'custom_url'],
    },
  };
}
