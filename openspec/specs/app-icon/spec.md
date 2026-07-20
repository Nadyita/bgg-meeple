# app-icon Specification

## Purpose

Defines how the BGG Meeple app presents its launcher icon across supported platforms, ensuring a consistent, reproducible brand asset.

## Requirements

### Requirement: App has a branded launcher icon on Android

The app SHALL provide a custom launcher icon for Android that replaces the default Flutter icon and reflects the BGG Meeple brand.

#### Scenario: Android launcher shows the BGG Meeple icon

- **WHEN** the app is installed on an Android device
- **THEN** the home screen / app drawer displays the BGG Meeple icon instead of the default Flutter icon

### Requirement: App has a branded launcher icon on Linux Desktop

The app SHALL provide a custom application icon for Linux Desktop builds that replaces the default Flutter icon and reflects the BGG Meeple brand.

#### Scenario: Linux launcher shows the BGG Meeple icon

- **WHEN** the app is built for Linux Desktop
- **THEN** the desktop entry / launcher displays the BGG Meeple icon instead of the default Flutter icon

### Requirement: Icons are generated from a single source asset

All platform-specific launcher icons SHALL be generated from a single source image to guarantee consistency across densities and platforms.

#### Scenario: Source icon drives all generated icons

- **WHEN** the source icon asset is updated
- **THEN** running the icon generator reproduces all Android and Linux launcher icons from that single source

### Requirement: Icon generation is reproducible via project tooling

The project SHALL declare a dev dependency and configuration for generating launcher icons so that any contributor can regenerate them with a documented command.

#### Scenario: Contributor regenerates icons

- **WHEN** a contributor runs the documented icon generation command
- **THEN** all platform launcher icons are regenerated deterministically without manual image editing

## Notes

- The source icon should be a square, high-resolution raster image (PNG) or a scalable vector image (SVG) suitable for down-scaling to launcher sizes.
- Decorative AI-generated emojis are prohibited per `project-foundation`.
