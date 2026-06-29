import 'package:bgg_meeple/domain/value_objects/card_field.dart';
import 'package:bgg_meeple/domain/value_objects/card_layout_config.dart';
import 'package:bgg_meeple/infrastructure/adapters/persistence/shared_preferences_card_layout_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

base class _FakeSharedPreferencesAsyncPlatform
    extends SharedPreferencesAsyncPlatform {
  final Map<String, Object> _storage = {};

  @override
  Future<String?> getString(
    String key,
    SharedPreferencesOptions options,
  ) async {
    return _storage[key] as String?;
  }

  @override
  Future<void> setString(
    String key,
    String value,
    SharedPreferencesOptions options,
  ) async {
    _storage[key] = value;
  }

  @override
  Future<void> clear(
    ClearPreferencesParameters parameters,
    SharedPreferencesOptions options,
  ) async {
    _storage.clear();
  }

  @override
  Future<Map<String, Object>> getPreferences(
    GetPreferencesParameters parameters,
    SharedPreferencesOptions options,
  ) async {
    return Map.unmodifiable(_storage);
  }

  @override
  Future<Set<String>> getKeys(
    GetPreferencesParameters parameters,
    SharedPreferencesOptions options,
  ) async {
    return _storage.keys.toSet();
  }

  @override
  Future<bool?> getBool(String key, SharedPreferencesOptions options) async =>
      null;

  @override
  Future<double?> getDouble(
    String key,
    SharedPreferencesOptions options,
  ) async => null;

  @override
  Future<int?> getInt(String key, SharedPreferencesOptions options) async =>
      null;

  @override
  Future<List<String>?> getStringList(
    String key,
    SharedPreferencesOptions options,
  ) async => null;

  @override
  Future<void> setBool(
    String key,
    bool value,
    SharedPreferencesOptions options,
  ) async {}

  @override
  Future<void> setDouble(
    String key,
    double value,
    SharedPreferencesOptions options,
  ) async {}

  @override
  Future<void> setInt(
    String key,
    int value,
    SharedPreferencesOptions options,
  ) async {}

  @override
  Future<void> setStringList(
    String key,
    List<String> value,
    SharedPreferencesOptions options,
  ) async {}
}

void main() {
  group('SharedPreferencesCardLayoutStore', () {
    late _FakeSharedPreferencesAsyncPlatform platform;
    late SharedPreferencesCardLayoutStore store;

    setUp(() {
      platform = _FakeSharedPreferencesAsyncPlatform();
      SharedPreferencesAsyncPlatform.instance = platform;
      store = SharedPreferencesCardLayoutStore();
    });

    tearDown(() {
      SharedPreferencesAsyncPlatform.instance = null;
    });

    test('returns default config when no data is stored', () async {
      final config = await store.load();
      expect(config, const CardLayoutConfig());
    });

    test('persists and restores custom layout', () async {
      const config = CardLayoutConfig(
        showThumbnail: false,
        showVersionSubtitle: false,
        enabledFields: [CardField.playerCount, CardField.ownRating],
        fieldOrder: [CardField.ownRating, CardField.playerCount],
        hidePlaysOnZero: false,
        showGeekRatingUserCount: true,
      );

      await store.save(config);
      final loaded = await store.load();

      expect(loaded, config);
    });

    test('returns default config when stored JSON is corrupt', () async {
      platform._storage['card_layout_config'] = 'not-json';

      final config = await store.load();
      expect(config, const CardLayoutConfig());
    });

    test('ignores unknown field indexes', () async {
      platform._storage['card_layout_config'] = '''
        {
          "enabledFields": [0, 1, 99],
          "fieldOrder": [0, -1, 1, 200]
        }
      ''';

      final config = await store.load();
      expect(config.enabledFields, [CardField.playerCount, CardField.playTime]);
      expect(config.fieldOrder, [CardField.playerCount, CardField.playTime]);
    });
  });
}
