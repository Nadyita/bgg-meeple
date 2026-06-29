import 'package:drift/drift.dart';

import '../../../domain/entities/collection_item.dart' as domain;
import '../../../domain/ports/collection_store.dart';
import '../../../domain/value_objects/localized_name.dart';
import '../../../domain/value_objects/version_info.dart';
import 'drift/app_database.dart' as drift;

/// Drift-backed adapter for [CollectionStore].
class DriftCollectionStore implements CollectionStore {
  DriftCollectionStore(this._db);

  final drift.AppDatabase _db;

  @override
  Future<void> saveAll(List<domain.CollectionItem> items) async {
    await _db.transaction(() async {
      await _db.delete(_db.collectionItems).go();
      await _db.delete(_db.versions).go();

      for (final item in items) {
        final versionCompanion = item.version != null
            ? _toVersionCompanion(item.version!)
            : null;

        final versionId = versionCompanion != null
            ? await _db
                  .into(_db.versions)
                  .insert(
                    versionCompanion,
                    onConflict: DoUpdate((_) => versionCompanion),
                  )
            : null;

        final collectionCompanion = _toCollectionCompanion(item, versionId);
        await _db
            .into(_db.collectionItems)
            .insert(
              collectionCompanion,
              onConflict: DoUpdate((_) => collectionCompanion),
            );
      }
    });
  }

  @override
  Future<List<domain.CollectionItem>> loadAll() async {
    final rows = await _db.select(_db.collectionItems).get();
    return Future.wait(rows.map(_toEntity));
  }

  @override
  Future<void> clear() async {
    await _db.delete(_db.collectionItems).go();
    await _db.delete(_db.versions).go();
  }

  drift.VersionsCompanion _toVersionCompanion(VersionInfo version) {
    return drift.VersionsCompanion.insert(
      bggVersionId: version.id,
      name: version.name,
      year: Value(version.year),
    );
  }

  drift.CollectionItemsCompanion _toCollectionCompanion(
    domain.CollectionItem item,
    int? versionId,
  ) {
    return drift.CollectionItemsCompanion(
      thingId: Value(item.thingId),
      collId: Value(item.collId ?? item.thingId),
      primaryName: Value(_primaryName(item)),
      customName: Value(item.customName),
      customImageUrl: Value(item.customImageUrl),
      thumbnailUrl: Value(item.thumbnailUrl),
      thumbnailLocalPath: Value(item.thumbnailLocalPath),
      imageUrl: Value(item.imageUrl),
      yearPublished: Value(item.yearPublished),
      minPlayers: Value(item.minPlayers),
      maxPlayers: Value(item.maxPlayers),
      minPlayTime: Value(item.minPlayTime),
      maxPlayTime: Value(item.maxPlayTime),
      minAge: Value(item.minAge),
      bayesAverage: Value(item.bayesAverage),
      geekRatingUserCount: Value(item.geekRatingUserCount),
      ownRating: Value(item.ownRating),
      numPlays: Value(item.numPlays),
      bggRank: Value(item.bggRank),
      isOwned: Value(item.isOwned),
      isPreordered: Value(item.isPreordered),
      isWishlisted: Value(item.isWishlisted),
      isWantToPlay: Value(item.isWantToPlay),
      isWantToBuy: Value(item.isWantToBuy),
      isPrevOwned: Value(item.isPrevOwned),
      isPlayed: Value(item.isPlayed),
      isRated: Value(item.isRated),
      isForTrade: Value(item.isForTrade),
      isWantInTrade: Value(item.isWantInTrade),
      hasComment: Value(item.hasComment),
      versionId: Value(versionId),
    );
  }

  Future<domain.CollectionItem> _toEntity(drift.CollectionItem row) async {
    final version = row.versionId != null
        ? await (_db.select(
            _db.versions,
          )..where((v) => v.id.equals(row.versionId!))).getSingleOrNull()
        : null;

    return domain.CollectionItem(
      thingId: row.thingId,
      version: version != null
          ? VersionInfo(
              id: version.bggVersionId,
              name: version.name,
              year: version.year,
            )
          : null,
      customName: row.customName,
      customImageUrl: row.customImageUrl,
      thumbnailUrl: row.thumbnailUrl,
      thumbnailLocalPath: row.thumbnailLocalPath,
      imageUrl: row.imageUrl,
      names: _toNames(row.primaryName),
      yearPublished: row.yearPublished,
      minPlayers: row.minPlayers,
      maxPlayers: row.maxPlayers,
      minPlayTime: row.minPlayTime,
      maxPlayTime: row.maxPlayTime,
      minAge: row.minAge,
      bayesAverage: row.bayesAverage,
      geekRatingUserCount: row.geekRatingUserCount,
      ownRating: row.ownRating,
      numPlays: row.numPlays,
      bggRank: row.bggRank,
      isOwned: row.isOwned,
      isPreordered: row.isPreordered,
      isWishlisted: row.isWishlisted,
      isWantToPlay: row.isWantToPlay,
      isWantToBuy: row.isWantToBuy,
      isPrevOwned: row.isPrevOwned,
      isPlayed: row.isPlayed,
      isRated: row.isRated,
      isForTrade: row.isForTrade,
      isWantInTrade: row.isWantInTrade,
      hasComment: row.hasComment,
    );
  }

  List<LocalizedName> _toNames(String? primaryName) {
    if (primaryName == null || primaryName.isEmpty) {
      return const [];
    }
    return [LocalizedName(value: primaryName, language: null, isPrimary: true)];
  }

  String? _primaryName(domain.CollectionItem item) {
    final primary = item.names.where((n) => n.isPrimary).firstOrNull;
    if (primary != null && primary.value.isNotEmpty) {
      return primary.value;
    }
    if (item.names.isNotEmpty && item.names.first.value.isNotEmpty) {
      return item.names.first.value;
    }
    return item.customName;
  }
}
