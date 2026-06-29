import '../value_objects/card_layout_config.dart';

/// Port for persisting the user's collection card layout preferences.
abstract class CardLayoutStore {
  Future<CardLayoutConfig> load();
  Future<void> save(CardLayoutConfig config);
}
