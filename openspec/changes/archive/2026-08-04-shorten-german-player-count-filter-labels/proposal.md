# Proposal: Shorten German player count filter segmented button labels

## Problem

On Android, the three-segment `SegmentedButton` in the filter panel that selects the player-count source overflows/breaks when the device language is German. The current German labels are too wide for smaller screens:

- `Spieleranzahl` (publisher)
- `Empfohlen` (recommended)
- `Beste` (best)

## Affected capability

- `search-and-filter` – German localization of the player-count mode selector.

## Proposed change

Shorten only the German filter labels to:

- `Spieleranzahl` → `Spieler`
- `Empfohlen` → `Gut`
- `Beste` → `Beste` (already short enough)

These keys are used only by the filter panel's `SegmentedButton`. Other contexts such as detail-page labels (`detailRecommendedLabel`, `detailBestLabel`) and card labels (`cardPlayerCountRange`) must remain unchanged.

## Scope

- `lib/presentation/l10n/app_de.arb` – update three German strings and regenerate `app_localizations_de.dart`.

## Out of scope

- English labels stay as they are.
- No widget layout changes; the existing `SegmentedButton` layout remains unchanged.
