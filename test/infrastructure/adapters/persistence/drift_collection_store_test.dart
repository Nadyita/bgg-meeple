import 'package:bgg_meeple/domain/entities/collection_item.dart' as domain;
import 'package:bgg_meeple/domain/value_objects/localized_name.dart';
import 'package:bgg_meeple/infrastructure/adapters/persistence/drift/app_database.dart'
    as drift;
import 'package:bgg_meeple/infrastructure/adapters/persistence/drift_collection_store.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DriftCollectionStore', () {
    late drift.AppDatabase db;
    late DriftCollectionStore store;

    setUp(() {
      db = drift.AppDatabase(NativeDatabase.memory());
      store = DriftCollectionStore(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('persists and restores collection item fields', () async {
      final items = [
        const domain.CollectionItem(
          thingId: 2719,
          collId: 146716083,
          names: [
            LocalizedName(value: '4 gewinnt', language: null, isPrimary: true),
          ],
          yearPublished: 2008,
          minPlayers: 2,
          maxPlayers: 2,
          minPlayTime: 10,
          maxPlayTime: 10,
          bayesAverage: 5.05634,
          geekRatingUserCount: 10552,
          bggRank: 30795,
        ),
      ];

      await store.saveAll(items);
      final loaded = await store.loadAll();

      expect(loaded.length, 1);
      final item = loaded.first;
      expect(item.displayName(preferredLanguage: 'de'), '4 gewinnt');
      expect(item.names.first.value, '4 gewinnt');
      expect(item.yearPublished, 2008);
      expect(item.minPlayers, 2);
      expect(item.bayesAverage, 5.05634);
      expect(item.geekRatingUserCount, 10552);
      expect(item.bggRank, 30795);
    });
  });
}
