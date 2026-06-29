import '../../domain/ports/card_layout_store.dart';
import '../../domain/value_objects/card_layout_config.dart';

/// Loads the user's collection card layout configuration.
class LoadCardLayoutUseCase {
  const LoadCardLayoutUseCase(this._store);

  final CardLayoutStore _store;

  Future<CardLayoutConfig> call() => _store.load();
}
