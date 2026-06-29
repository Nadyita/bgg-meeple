import '../value_objects/theme_config.dart';

/// Persistence adapter for the app's theme configuration.
abstract class ThemeStore {
  Future<ThemeConfig> load();
  Future<void> save(ThemeConfig config);
}
