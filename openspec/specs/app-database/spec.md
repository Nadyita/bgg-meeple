# app-database Specification

## Purpose

Defines how the local Drift SQLite database is opened, where it is stored on each supported platform, and how schema migrations are handled.

## Requirements

### Requirement: Store the Linux desktop database under XDG data directory
The app SHALL store the Drift SQLite database on Linux desktop under `~/.local/share/com.bggmeeple.bgg_meeple/databases/`.

#### Scenario: Database path follows XDG on Linux
- **GIVEN** the app runs on Linux desktop
- **WHEN** Drift opens the database connection
- **THEN** the parent directory is `~/.local/share/com.bggmeeple.bgg_meeple/databases/`

#### Scenario: Database directory is created when missing
- **GIVEN** the XDG data directory does not yet contain the app-specific database folder
- **WHEN** the app starts
- **THEN** the directory is created automatically and the database file can be written

### Requirement: Store the database in the platform documents directory on non-Linux platforms
The app SHALL continue to use the platform's application documents directory as the base path on Android, iOS, macOS, and Windows.

#### Scenario: Non-Linux platforms are unaffected
- **GIVEN** the app runs on Android, iOS, macOS, or Windows
- **WHEN** Drift opens the database connection
- **THEN** the database directory is derived from the platform's documents directory

### Requirement: Keep cached data across schema updates
The app SHALL use additive migrations that preserve existing cached data whenever possible. Destructive migrations are only acceptable when required by a major schema redesign and SHALL be documented in the change.

#### Scenario: Existing cache survives a minor schema bump
- **GIVEN** the user has synced games and plays into a previous schema version
- **WHEN** the app upgrades to a new minor schema version
- **THEN** the existing collection, games, and play data remain available
