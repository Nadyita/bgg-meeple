# bgg-sync delta spec

## Purpose

Extends the BGG collection synchronization so that private collection information is requested and the `inventorylocation` attribute is parsed, trimmed, and made available on each collection item.

## MODIFIED Requirements

### Requirement: Collection request requests private information

The BGG collection request SHALL include the parameter `showprivate=1` so that `<privateinfo>` elements are returned for items with private data.

#### Scenario: Private info is requested

- **GIVEN** a BGG account is configured
- **WHEN** the app fetches `/xmlapi2/collection` for the user
- **THEN** the request URL contains `showprivate=1`

### Requirement: Inventory location is parsed from private info

For each collection item that contains a `<privateinfo>` element, the app SHALL read the `inventorylocation` attribute and expose it as a nullable string on the parsed `CollectionItem`.

#### Scenario: Item with inventory location

- **GIVEN** the BGG response contains an item with `<privateinfo inventorylocation="Eva ">`
- **WHEN** the collection is parsed
- **THEN** the resulting `CollectionItem` has an `inventoryLocation` value of `"Eva"`

#### Scenario: Item without private info

- **GIVEN** the BGG response contains an item without a `<privateinfo>` element
- **WHEN** the collection is parsed
- **THEN** the resulting `CollectionItem` has `inventoryLocation` set to `null`

#### Scenario: Item with empty inventory location

- **GIVEN** the BGG response contains an item with `<privateinfo inventorylocation="">`
- **WHEN** the collection is parsed
- **THEN** the resulting `CollectionItem` has `inventoryLocation` set to `null`
