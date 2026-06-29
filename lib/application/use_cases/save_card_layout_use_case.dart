import '../../domain/ports/card_layout_store.dart';
import '../../domain/value_objects/card_layout_config.dart';

/// Saves the user's collection card layout configuration.
class SaveCardLayoutUseCase {
  const SaveCardLayoutUseCase(this._store);

  final CardLayoutStore _store;

  Future<void> call(CardLayoutConfig config) => _store.save(config);
}
