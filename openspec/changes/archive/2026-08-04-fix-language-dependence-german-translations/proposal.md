# Proposal: Fix German language dependence labels to match spec

## Problem

The German translations for `detailLanguageDependenceLevel1` through `detailLanguageDependenceLevel5` in `app_de.arb` deviate from the authoritative mapping defined in the `game-detail` spec.

Current values vs. spec:

| Level | Spec | Current ARB |
|-------|------|-------------|
| 1 | "Kein Text im Spiel" | "Kein notwendiger Spieltext" |
| 2 | "Wenig Text im Spiel - leicht zu merken oder kleine Spickzettel" | "Wenig notwendiger Text - leicht zu merken oder kleine Spickzettel" |
| 3 | "Moderate Menge Text im Spiel - Spickzettel oder Ergänzungen nötig" | "Mittlerer Spieltext - Spickzettel oder Ergänzungen nötig" |
| 4 | "Umfangreicher Text im Spiel - große Anpassungen nötig, um spielbar zu sein" | "Umfangreicher Text - große Anpassungen nötig, um spielbar zu sein" |
| 5 | "In anderen Sprachen unspielbar" | "In anderer Sprache unspielbar" |

## Affected capability

- `game-detail` language-dependence label localization.

## Proposed fix

Update the five German localization strings in `lib/presentation/l10n/app_de.arb` to match the spec text exactly. Update the widget test that checks the German level 1 label so it expects the new string.

## Scope

- `lib/presentation/l10n/app_de.arb`
- `test/presentation/pages/game_detail_page_test.dart`

## Out of scope

- English strings already match the spec.
- No logic changes in `_DetailFields._languageDependenceLabel`.
