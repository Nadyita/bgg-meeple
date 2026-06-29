import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/ports/collection_view_store.dart';
import '../../../domain/value_objects/collection_view.dart';

/// Stores the collection view state in shared preferences.
class SharedPreferencesCollectionViewStore implements CollectionViewStore {
  SharedPreferencesCollectionViewStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _key = 'collection_view';

  final SharedPreferencesAsync _preferences;

  @override
  Future<CollectionView> load() async {
    final jsonString = await _preferences.getString(_key);
    if (jsonString == null || jsonString.isEmpty) {
      return const CollectionView();
    }

    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return CollectionView.fromJson(map);
    } on FormatException {
      return const CollectionView();
    }
  }

  @override
  Future<void> save(CollectionView view) async {
    final map = view.toJson();
    await _preferences.setString(_key, jsonEncode(map));
  }
}
