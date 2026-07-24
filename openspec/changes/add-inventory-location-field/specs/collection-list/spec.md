# collection-list delta spec

## Purpose

Ensures that collection cards can render an inventory location value when one is present and that the value is visually consistent with the rest of the card metadata.

## MODIFIED Requirements

### Requirement: Collection cards render inventory location

When a collection item has a non-empty `inventoryLocation` value and the field is enabled in the card layout, the card SHALL display the value as a metadata line with an appropriate icon.

#### Scenario: Inventory location line renders

- **GIVEN** a collection item has `inventoryLocation` set to `"Keller"`
- **AND** the field is enabled in the card layout
- **WHEN** the collection card is rendered
- **THEN** a metadata line with the inventory location icon and the text `"Keller"` is visible

#### Scenario: Inventory location line is absent when empty

- **GIVEN** a collection item has `inventoryLocation` set to `null`
- **AND** the field is enabled in the card layout
- **WHEN** the collection card is rendered
- **THEN** no inventory location metadata line is visible
