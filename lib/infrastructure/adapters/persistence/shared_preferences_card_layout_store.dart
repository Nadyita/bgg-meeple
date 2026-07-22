import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/ports/card_layout_store.dart';
import '../../../domain/value_objects/card_field.dart';
import '../../../domain/value_objects/card_layout_config.dart';

/// Stores the card layout configuration in shared preferences.
class SharedPreferencesCardLayoutStore implements CardLayoutStore {
  SharedPreferencesCardLayoutStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _key = 'card_layout_config';

  final SharedPreferencesAsync _preferences;

  @override
  Future<CardLayoutConfig> load() async {
    final jsonString = await _preferences.getString(_key);
    if (jsonString == null || jsonString.isEmpty) {
      return const CardLayoutConfig();
    }

    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return _fromJson(map);
    } on FormatException {
      return const CardLayoutConfig();
    }
  }

  @override
  Future<void> save(CardLayoutConfig config) async {
    final map = _toJson(config);
    await _preferences.setString(_key, jsonEncode(map));
  }

  Map<String, dynamic> _toJson(CardLayoutConfig config) {
    return {
      'showThumbnail': config.showThumbnail,
      'showVersionSubtitle': config.showVersionSubtitle,
      'enabledFields': config.enabledFields.map((f) => f.index).toList(),
      'fieldOrder': config.fieldOrder.map((f) => f.index).toList(),
      'hidePlaysOnZero': config.hidePlaysOnZero,
      'showGeekRatingUserCount': config.showGeekRatingUserCount,
      'showPlayerNamesOnPlays': config.showPlayerNamesOnPlays,
    };
  }

  CardLayoutConfig _fromJson(Map<String, dynamic> map) {
    final enabledIndexes =
        (map['enabledFields'] as List<dynamic>?)?.whereType<int>().toList() ??
        [];
    final orderIndexes =
        (map['fieldOrder'] as List<dynamic>?)?.whereType<int>().toList() ?? [];

    final enabledFields = enabledIndexes
        .where((i) => i >= 0 && i < CardField.values.length)
        .map((i) => CardField.values[i])
        .toList();

    final fieldOrder = orderIndexes
        .where((i) => i >= 0 && i < CardField.values.length)
        .map((i) => CardField.values[i])
        .toList();

    return CardLayoutConfig(
      showThumbnail: map['showThumbnail'] as bool? ?? true,
      showVersionSubtitle: map['showVersionSubtitle'] as bool? ?? true,
      enabledFields: enabledFields,
      fieldOrder: fieldOrder.isNotEmpty ? fieldOrder : CardField.values,
      hidePlaysOnZero: map['hidePlaysOnZero'] as bool? ?? true,
      showGeekRatingUserCount: map['showGeekRatingUserCount'] as bool? ?? false,
      showPlayerNamesOnPlays: map['showPlayerNamesOnPlays'] as bool? ?? false,
    );
  }
}
