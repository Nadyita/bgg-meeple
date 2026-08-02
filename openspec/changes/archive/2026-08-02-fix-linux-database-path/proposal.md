# Fix: Linux database path

## Why

On Linux desktop the Drift database is currently stored at `~/databases/bgg_meeple_cache.sqlite` because `getApplicationDocumentsDirectory()` returns the user's home directory and the app appends a `databases` sub-folder. This is unexpected, pollutes the home directory, and is hard to discover for debugging. It should follow the XDG Base Directory specification and live under `~/.local/share/com.bggmeeple.bgg_meeple/databases/`.

## What Changes

- Change `_databaseDirectory()` in `app_database.dart` so that on Linux it uses the XDG data directory (`~/.local/share/<app-id>`) instead of `getApplicationDocumentsDirectory()`.
- Keep the existing behavior on other platforms.
- Ensure the chosen directory is created if it does not exist.

## Alternatives Considered

- Rename the app package and application ID in the same step. Rejected because it would break app upgrades on Android and requires regenerating release signing material and CI secrets.
- Move the database into a temporary directory. Rejected because cached data must persist across sessions.

## Impact

- [ ] Breaking changes
- [ ] Database migrations
- [ ] API changes
- [x] Behavior change (database file location on Linux desktop)
