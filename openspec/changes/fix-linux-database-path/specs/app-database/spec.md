# app-database delta spec

## Purpose

Change the Linux desktop database directory from the user's home directory to the XDG data directory so the SQLite file is stored in a conventional, discoverable location.

## MODIFIED Requirements

### Requirement: Store the Linux desktop database under XDG data directory
The app SHALL store the Drift SQLite database on Linux desktop under `~/.local/share/com.bggmeeple.bgg_meeple/databases/` instead of `~/databases/`.

#### Scenario: Database path follows XDG on Linux
- **GIVEN** the app runs on Linux desktop
- **WHEN** Drift opens the database connection
- **THEN** the parent directory is `~/.local/share/com.bggmeeple.bgg_meeple/databases/`

#### Scenario: Database directory is created when missing
- **GIVEN** the XDG data directory does not yet contain the app-specific database folder
- **WHEN** the app starts
- **THEN** the directory is created automatically and the database file can be written

### Requirement: Keep existing database behavior on non-Linux platforms
The app SHALL continue to use `getApplicationDocumentsDirectory()` as the base path on Android, iOS, macOS, and Windows.

#### Scenario: Non-Linux platforms are unaffected
- **GIVEN** the app runs on Android, iOS, macOS, or Windows
- **WHEN** Drift opens the database connection
- **THEN** the database directory is derived from the platform's documents directory as before
