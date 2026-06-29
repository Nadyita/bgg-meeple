import '../../domain/ports/theme_store.dart';
import '../../domain/value_objects/theme_config.dart';

/// Loads the persisted theme configuration.
class LoadThemeConfigUseCase {
  const LoadThemeConfigUseCase(this._store);

  final ThemeStore _store;

  Future<ThemeConfig> call() => _store.load();
}
