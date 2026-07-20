## ADDED Requirements

### Requirement: User can enter and save BGG credentials
The app SHALL provide a dedicated settings screen where the user can enter and save a BGG username and password. The credentials SHALL be persisted using platform-appropriate secure storage and SHALL be used to obtain a BGG session.

#### Scenario: Save credentials on settings screen
- **WHEN** the user enters a BGG username and password on the settings screen and saves them
- **THEN** the credentials are stored securely and can be retrieved for subsequent BGG logins

### Requirement: BGG session is managed and reused
The app SHALL log into BGG with the stored credentials, obtain and store the session cookies (including `bggusername`, `bggpassword`, and `SessionID`), and reuse the session cookie for authenticated API calls. The session SHALL be refreshed as needed.

#### Scenario: Authenticated collection fetch uses stored session
- **WHEN** the app needs to access a private BGG collection
- **THEN** the stored BGG session cookies are attached to the request and the collection is returned

#### Scenario: Missing session triggers re-login
- **WHEN** the stored session is absent or invalid
- **THEN** the app re-authenticates with the stored username and password before making authenticated requests

### Requirement: Manual BGG API token can be stored and used
The settings screen SHALL allow the user to enter a manual BGG API bearer token. The token SHALL be stored securely alongside the BGG credentials and SHALL be merged into the BGG session for `/xmlapi2/thing` requests when the login response does not provide a token.

#### Scenario: Thing endpoint uses manual token when login response lacks one
- **WHEN** the login response does not contain an API token and a manual token is configured
- **THEN** the app sends `Authorization: Bearer <manual-token>` for `/xmlapi2/thing` requests
