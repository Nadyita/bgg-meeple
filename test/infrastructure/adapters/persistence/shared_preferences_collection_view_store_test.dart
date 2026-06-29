import 'package:bgg_meeple/domain/value_objects/collection_filter.dart';
import 'package:bgg_meeple/domain/value_objects/collection_sort.dart';
import 'package:bgg_meeple/domain/value_objects/collection_sub_type.dart';
import 'package:bgg_meeple/domain/value_objects/collection_view.dart';
import 'package:bgg_meeple/infrastructure/adapters/persistence/shared_preferences_collection_view_store.dart';
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
  group('SharedPreferencesCollectionViewStore', () {
    late _FakeSharedPreferencesAsyncPlatform platform;
    late SharedPreferencesCollectionViewStore store;

    setUp(() {
      platform = _FakeSharedPreferencesAsyncPlatform();
      SharedPreferencesAsyncPlatform.instance = platform;
      store = SharedPreferencesCollectionViewStore();
    });

    tearDown(() {
      SharedPreferencesAsyncPlatform.instance = null;
    });

    test('returns default view when no data is stored', () async {
      final view = await store.load();
      expect(view, const CollectionView());
    });

    test('persists and restores view state', () async {
      const view = CollectionView(
        searchText: 'catan',
        filter: CollectionFilter(
          selectedSubTypes: [CollectionSubType.owned],
          minPlayers: 2,
          maxPlayers: 4,
          minPlayTime: 30,
          maxPlayTime: 120,
          minRating: 7.0,
          maxRating: 9.5,
        ),
        sort: CollectionSort(sortBy: SortBy.bggRating, ascending: false),
      );

      await store.save(view);
      final loaded = await store.load();

      expect(loaded, view);
    });

    test('returns default view when stored JSON is corrupt', () async {
      platform._storage['collection_view'] = 'not-json';

      final view = await store.load();
      expect(view, const CollectionView());
    });
  });
}
