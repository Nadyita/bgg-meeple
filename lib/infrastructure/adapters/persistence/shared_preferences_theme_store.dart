import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/ports/theme_store.dart';
import '../../../domain/value_objects/theme_config.dart';

/// Shared preferences adapter for [ThemeStore].
class SharedPreferencesThemeStore implements ThemeStore {
  SharedPreferencesThemeStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _key = 'theme_config';

  final SharedPreferencesAsync _preferences;

  @override
  Future<ThemeConfig> load() async {
    final jsonString = await _preferences.getString(_key);
    if (jsonString == null || jsonString.isEmpty) {
      return const ThemeConfig();
    }
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return ThemeConfig.fromJson(map);
    } on FormatException {
      return const ThemeConfig();
    }
  }

  @override
  Future<void> save(ThemeConfig config) async {
    final map = config.toJson();
    await _preferences.setString(_key, jsonEncode(map));
  }
}
