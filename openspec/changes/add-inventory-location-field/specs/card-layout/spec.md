# card-layout delta spec

## Purpose

Adds `inventoryLocation` as a configurable metadata field on collection cards. The field is hidden when no value is present, matching the behavior of other conditionally shown fields.

## MODIFIED Requirements

### Requirement: Inventory location is a configurable card field

The card layout settings SHALL allow the user to toggle the display of `inventoryLocation` as a metadata field and reorder it together with the other configurable fields.

#### Scenario: Enable inventory location field

- **GIVEN** the user opens the card layout settings
- **WHEN** the user enables the `inventoryLocation` field
- **THEN** collection cards show the field when a value is present

#### Scenario: Reorder inventory location field

- **GIVEN** the user enables the `inventoryLocation` field
- **WHEN** the user drags it to a new position in the field order
- **THEN** the field appears in that position on collection cards

### Requirement: Inventory location field is hidden when empty

When the `inventoryLocation` field is enabled but a collection item has no inventory location value, the field SHALL be omitted from that card.

#### Scenario: Card with inventory location shows the value

- **GIVEN** the `inventoryLocation` field is enabled
- **AND** a collection item has `inventoryLocation` set to `"Eva"`
- **WHEN** the card is rendered
- **THEN** the card displays the inventory location

#### Scenario: Card without inventory location hides the field

- **GIVEN** the `inventoryLocation` field is enabled
- **AND** a collection item has `inventoryLocation` set to `null`
- **WHEN** the card is rendered
- **THEN** the card does not reserve space or show a placeholder for the field
