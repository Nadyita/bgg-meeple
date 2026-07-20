# project-foundation Specification

## Purpose

Establishes the base conventions and quality expectations for the BGG Meeple app: supported platforms and Flutter version, internationalization, language rules, emoji policy, hexagonal architecture, Clean Code principles, and test-first development.

## Requirements
### Requirement: Project uses current stable Flutter for Android and Linux Desktop
The project SHALL use the current stable Flutter SDK and SHALL support Android and Linux Desktop as primary build targets.

#### Scenario: Project builds and runs on supported platforms
- **WHEN** the project is built with `flutter run` or `flutter build` for Android or Linux Desktop
- **THEN** the build completes without errors and the app launches

### Requirement: All project artifacts are written in English
All source code, documentation, comments, issue content, commit messages, and other project artifacts SHALL be written in English to enable international collaboration.

#### Scenario: New code and docs are in English
- **WHEN** a contributor adds source code, comments, documentation, or commit messages
- **THEN** the text is in English

### Requirement: App UI supports German and English
The app UI SHALL support German and English through Flutter's recommended `flutter_localizations` approach with generated ARB-based `AppLocalizations`.

#### Scenario: UI follows system or selected language
- **WHEN** the device language is German or English, or the user selects one of those languages in the app
- **THEN** all user-facing strings appear in the selected language and all user-facing strings are externalized in ARB files

### Requirement: AI-generated emojis are prohibited
AI-generated emojis such as robot faces, sparkles, wands, stars, rockets, or bulbs SHALL NOT appear in any project artifact. Standard UI icons from Material Design or other icon sets are permitted when used for actual UI elements.

#### Scenario: Documentation and code are free of decorative emojis
- **WHEN** a project artifact is reviewed
- **THEN** no decorative AI-style emojis are present; only approved UI icon sets are used for interface elements

### Requirement: Project follows Clean Code and hexagonal architecture
The project SHALL follow Clean Code principles and SHALL use hexagonal architecture (ports and adapters) so that business logic is isolated from frameworks, external APIs, and persistence.

#### Scenario: UI, API, and persistence are adapters around domain logic
- **WHEN** inspecting the project structure
- **THEN** domain logic does not depend directly on Flutter UI code, BGG API client code, or persistence framework code

### Requirement: Business logic is developed test-first
Unit tests for business logic, data, and service layers SHALL be written before or alongside the implementation they verify.

#### Scenario: New business logic ships with tests
- **WHEN** a new use case, service, or data layer is added
- **THEN** corresponding unit tests are present and pass before the change is considered complete

