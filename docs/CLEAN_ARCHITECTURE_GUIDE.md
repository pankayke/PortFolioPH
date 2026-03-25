# Clean Architecture Structure - PortfolioPH

## 📁 Complete Folder Structure

```
lib/
├── main.dart                          # Entry point
│
├── core/                              # Business Logic & Declarations
│   ├── constants/
│   │   ├── app_constants.dart         # Global app constants
│   │   └── strings.dart               # String constants & localization
│   │
│   ├── exceptions/
│   │   └── custom_exceptions.dart     # Custom exception definitions
│   │
│   ├── router/
│   │   └── app_router.dart            # Route definitions & navigation
│   │
│   ├── theme/
│   │   └── app_theme.dart             # Theme, colors, typography
│   │
│   └── utils/
│       ├── validators.dart            # Validation utilities
│       ├── helpers.dart               # Helper functions
│       ├── date_formatter.dart        # Date formatting utilities
│       └── cache_manager.dart         # Caching logic
│
├── data/                              # Data Layer
│   ├── datasources/
│   │   ├── local_data_source.dart     # Local storage operations
│   │   └── remote_data_source.dart    # API calls & network ops
│   │
│   ├── models/
│   │   ├── app_setting_model.dart
│   │   ├── user_model.dart
│   │   ├── portfolio_model.dart
│   │   ├── project_model.dart
│   │   ├── skill_model.dart
│   │   ├── experience_model.dart
│   │   ├── education_model.dart
│   │   ├── certification_model.dart
│   │   ├── contact_model.dart
│   │   └── theme_setting_model.dart
│   │
│   ├── repositories/
│   │   ├── base_repository.dart       # Abstract base repository
│   │   ├── app_setting_repository.dart
│   │   ├── user_repository.dart
│   │   ├── portfolio_repository.dart
│   │   ├── project_repository.dart
│   │   ├── skill_repository.dart
│   │   ├── experience_repository.dart
│   │   ├── education_repository.dart
│   │   ├── certification_repository.dart
│   │   └── contact_repository.dart
│   │
│   └── services/
│       ├── api_service.dart           # HTTP client & API requests
│       ├── local_storage_service.dart # SharedPreferences operations
│       └── database_service.dart      # SQLite operations
│
└── presentation/                      # UI Layer
    ├── providers/
    │   └── app_providers.dart         # Riverpod state management
    │
    ├── screens/
    │   ├── splash/
    │   │   └── splash_screen.dart
    │   ├── auth/
    │   │   └── auth_screen.dart
    │   ├── dashboard/
    │   │   └── dashboard_screen.dart
    │   ├── portfolio/
    │   │   └── portfolio_screen.dart
    │   ├── profile/
    │   │   └── profile_screen.dart
    │   ├── skills/
    │   │   └── skills_screen.dart
    │   ├── resume/
    │   │   └── resume_screen.dart
    │   └── main_scaffold.dart
    │
    └── widgets/
        ├── index.dart                 # Widgets barrel export
        └── common/
            ├── index.dart             # Common widgets export
            ├── loading_widget.dart    # Loading indicator
            ├── error_widget.dart      # Error display widget
            ├── empty_state_widget.dart # Empty state UI
            └── custom_button.dart     # Reusable button widget
```

## 🏗️ Architecture Layers

### 1. **Data Layer** (`lib/data/`)
- **Datasources**: Local & Remote data operations
- **Models**: Data transfer objects (DTOs)
- **Repositories**: Abstraction between domain & data layers
- **Services**: Third-party service integrations

### 2. **Core Layer** (`lib/core/`)
- **Constants**: App-wide constants & strings
- **Exceptions**: Custom exception classes
- **Router**: Navigation & route management
- **Theme**: UI theme & styling
- **Utils**: Reusable utility functions

### 3. **Presentation Layer** (`lib/presentation/`)
- **Providers**: State management (Riverpod)
- **Screens**: Full-screen UI components
- **Widgets**: Reusable UI components

## 📋 File Statistics

- **Total Layers**: 3 (Data, Core, Presentation)
- **Total Directories**: 15+
- **Total Files Created**: 30+
- **Data Models**: 10
- **Repositories**: 9
- **Services**: 3
- **Screens**: 7
- **Widgets**: 5+

## ✅ Implementation Guidelines

### Best Practices:
1. **Separation of Concerns**: Each layer has distinct responsibility
2. **Dependency Injection**: Services injected through providers
3. **Error Handling**: Custom exceptions for better error management
4. **Code Reusability**: Common widgets & utilities for consistency
5. **State Management**: Riverpod for effective state handling

### Naming Conventions:
- `_repository.dart` for repository implementations
- `_service.dart` for service classes
- `_screen.dart` for full screens
- `_widget.dart` for UI components
- Abstract classes prefixed with base or abstract

### TODO Items:
- [ ] Implement LocalDataSource methods
- [ ] Implement RemoteDataSource methods
- [ ] Define repository methods
- [ ] Set up API service configuration
- [ ] Configure local storage service
- [ ] Implement database service
- [ ] Define app constants
- [ ] Setup state providers (Riverpod)
- [ ] Implement screen UIs
- [ ] Create widget implementations

---
**Status**: Clean Architecture Structure Complete ✓
**Folder Structure**: Ready for Development
**Created Date**: 2026-03-09
