# app-database delta spec

## Purpose

Extends the `CollectionItems` table with nullable columns for the BGG-recommended and BGG-best player count ranges so they can be cached together with each collection item.

## MODIFIED Requirements

### Requirement: CollectionItems table stores best and recommended player counts

The `CollectionItems` table SHALL include nullable columns for `bestPlayerCount` (text), `bestPlayerCountMin` (integer), `bestPlayerCountMax` (integer), `recommendedPlayerCount` (text), `recommendedPlayerCountMin` (integer), and `recommendedPlayerCountMax` (integer).

#### Scenario: New columns exist after migration

- **GIVEN** the app is upgraded to the schema version that includes this change
- **WHEN** the `CollectionItems` table is inspected
- **THEN** the six new nullable columns are present

### Requirement: Migration preserves existing collection data

The schema migration SHALL add the new columns without deleting existing `CollectionItems` rows. Existing rows SHALL have null values in the new columns after the migration.

#### Scenario: Existing rows survive migration

- **GIVEN** the cache contains collection items from a previous schema version
- **WHEN** the app starts with the new schema version
- **THEN** all existing collection items are still present
- **AND** their new player count columns are null

### Requirement: Schema version is bumped

The database schema version SHALL be incremented to reflect the new columns, and the `onUpgrade` migration path SHALL handle upgrades from the previous version.

#### Scenario: Upgrade from previous version

- **GIVEN** the cache is on the previous schema version
- **WHEN** the app opens the database
- **THEN** the migration runs and the schema version is updated
