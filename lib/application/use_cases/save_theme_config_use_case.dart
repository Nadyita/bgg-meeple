import '../../domain/ports/theme_store.dart';
import '../../domain/value_objects/theme_config.dart';

/// Persists the theme configuration.
class SaveThemeConfigUseCase {
  const SaveThemeConfigUseCase(this._store);

  final ThemeStore _store;

  Future<void> call(ThemeConfig config) => _store.save(config);
}
