// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $VersionsTable extends Versions with TableInfo<$VersionsTable, Version> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VersionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bggVersionIdMeta = const VerificationMeta(
    'bggVersionId',
  );
  @override
  late final GeneratedColumn<int> bggVersionId = GeneratedColumn<int>(
    'bgg_version_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, bggVersionId, name, year];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'versions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Version> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('bgg_version_id')) {
      context.handle(
        _bggVersionIdMeta,
        bggVersionId.isAcceptableOrUnknown(
          data['bgg_version_id']!,
          _bggVersionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bggVersionIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Version map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Version(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bggVersionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bgg_version_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      ),
    );
  }

  @override
  $VersionsTable createAlias(String alias) {
    return $VersionsTable(attachedDatabase, alias);
  }
}

class Version extends DataClass implements Insertable<Version> {
  final int id;
  final int bggVersionId;
  final String name;
  final int? year;
  const Version({
    required this.id,
    required this.bggVersionId,
    required this.name,
    this.year,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['bgg_version_id'] = Variable<int>(bggVersionId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    return map;
  }

  VersionsCompanion toCompanion(bool nullToAbsent) {
    return VersionsCompanion(
      id: Value(id),
      bggVersionId: Value(bggVersionId),
      name: Value(name),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
    );
  }

  factory Version.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Version(
      id: serializer.fromJson<int>(json['id']),
      bggVersionId: serializer.fromJson<int>(json['bggVersionId']),
      name: serializer.fromJson<String>(json['name']),
      year: serializer.fromJson<int?>(json['year']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bggVersionId': serializer.toJson<int>(bggVersionId),
      'name': serializer.toJson<String>(name),
      'year': serializer.toJson<int?>(year),
    };
  }

  Version copyWith({
    int? id,
    int? bggVersionId,
    String? name,
    Value<int?> year = const Value.absent(),
  }) => Version(
    id: id ?? this.id,
    bggVersionId: bggVersionId ?? this.bggVersionId,
    name: name ?? this.name,
    year: year.present ? year.value : this.year,
  );
  Version copyWithCompanion(VersionsCompanion data) {
    return Version(
      id: data.id.present ? data.id.value : this.id,
      bggVersionId: data.bggVersionId.present
          ? data.bggVersionId.value
          : this.bggVersionId,
      name: data.name.present ? data.name.value : this.name,
      year: data.year.present ? data.year.value : this.year,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Version(')
          ..write('id: $id, ')
          ..write('bggVersionId: $bggVersionId, ')
          ..write('name: $name, ')
          ..write('year: $year')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bggVersionId, name, year);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Version &&
          other.id == this.id &&
          other.bggVersionId == this.bggVersionId &&
          other.name == this.name &&
          other.year == this.year);
}

class VersionsCompanion extends UpdateCompanion<Version> {
  final Value<int> id;
  final Value<int> bggVersionId;
  final Value<String> name;
  final Value<int?> year;
  const VersionsCompanion({
    this.id = const Value.absent(),
    this.bggVersionId = const Value.absent(),
    this.name = const Value.absent(),
    this.year = const Value.absent(),
  });
  VersionsCompanion.insert({
    this.id = const Value.absent(),
    required int bggVersionId,
    required String name,
    this.year = const Value.absent(),
  }) : bggVersionId = Value(bggVersionId),
       name = Value(name);
  static Insertable<Version> custom({
    Expression<int>? id,
    Expression<int>? bggVersionId,
    Expression<String>? name,
    Expression<int>? year,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bggVersionId != null) 'bgg_version_id': bggVersionId,
      if (name != null) 'name': name,
      if (year != null) 'year': year,
    });
  }

  VersionsCompanion copyWith({
    Value<int>? id,
    Value<int>? bggVersionId,
    Value<String>? name,
    Value<int?>? year,
  }) {
    return VersionsCompanion(
      id: id ?? this.id,
      bggVersionId: bggVersionId ?? this.bggVersionId,
      name: name ?? this.name,
      year: year ?? this.year,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bggVersionId.present) {
      map['bgg_version_id'] = Variable<int>(bggVersionId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VersionsCompanion(')
          ..write('id: $id, ')
          ..write('bggVersionId: $bggVersionId, ')
          ..write('name: $name, ')
          ..write('year: $year')
          ..write(')'))
        .toString();
  }
}

class $CollectionItemsTable extends CollectionItems
    with TableInfo<$CollectionItemsTable, CollectionItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _thingIdMeta = const VerificationMeta(
    'thingId',
  );
  @override
  late final GeneratedColumn<int> thingId = GeneratedColumn<int>(
    'thing_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _collIdMeta = const VerificationMeta('collId');
  @override
  late final GeneratedColumn<int> collId = GeneratedColumn<int>(
    'coll_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _primaryNameMeta = const VerificationMeta(
    'primaryName',
  );
  @override
  late final GeneratedColumn<String> primaryName = GeneratedColumn<String>(
    'primary_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbnailLocalPathMeta =
      const VerificationMeta('thumbnailLocalPath');
  @override
  late final GeneratedColumn<String> thumbnailLocalPath =
      GeneratedColumn<String>(
        'thumbnail_local_path',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _customNameMeta = const VerificationMeta(
    'customName',
  );
  @override
  late final GeneratedColumn<String> customName = GeneratedColumn<String>(
    'custom_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customImageUrlMeta = const VerificationMeta(
    'customImageUrl',
  );
  @override
  late final GeneratedColumn<String> customImageUrl = GeneratedColumn<String>(
    'custom_image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbnailUrlMeta = const VerificationMeta(
    'thumbnailUrl',
  );
  @override
  late final GeneratedColumn<String> thumbnailUrl = GeneratedColumn<String>(
    'thumbnail_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yearPublishedMeta = const VerificationMeta(
    'yearPublished',
  );
  @override
  late final GeneratedColumn<int> yearPublished = GeneratedColumn<int>(
    'year_published',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minPlayersMeta = const VerificationMeta(
    'minPlayers',
  );
  @override
  late final GeneratedColumn<int> minPlayers = GeneratedColumn<int>(
    'min_players',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxPlayersMeta = const VerificationMeta(
    'maxPlayers',
  );
  @override
  late final GeneratedColumn<int> maxPlayers = GeneratedColumn<int>(
    'max_players',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minPlayTimeMeta = const VerificationMeta(
    'minPlayTime',
  );
  @override
  late final GeneratedColumn<int> minPlayTime = GeneratedColumn<int>(
    'min_play_time',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxPlayTimeMeta = const VerificationMeta(
    'maxPlayTime',
  );
  @override
  late final GeneratedColumn<int> maxPlayTime = GeneratedColumn<int>(
    'max_play_time',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minAgeMeta = const VerificationMeta('minAge');
  @override
  late final GeneratedColumn<int> minAge = GeneratedColumn<int>(
    'min_age',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bayesAverageMeta = const VerificationMeta(
    'bayesAverage',
  );
  @override
  late final GeneratedColumn<double> bayesAverage = GeneratedColumn<double>(
    'bayes_average',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ownRatingMeta = const VerificationMeta(
    'ownRating',
  );
  @override
  late final GeneratedColumn<double> ownRating = GeneratedColumn<double>(
    'own_rating',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _numPlaysMeta = const VerificationMeta(
    'numPlays',
  );
  @override
  late final GeneratedColumn<int> numPlays = GeneratedColumn<int>(
    'num_plays',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bggRankMeta = const VerificationMeta(
    'bggRank',
  );
  @override
  late final GeneratedColumn<int> bggRank = GeneratedColumn<int>(
    'bgg_rank',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _geekRatingUserCountMeta =
      const VerificationMeta('geekRatingUserCount');
  @override
  late final GeneratedColumn<int> geekRatingUserCount = GeneratedColumn<int>(
    'geek_rating_user_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isOwnedMeta = const VerificationMeta(
    'isOwned',
  );
  @override
  late final GeneratedColumn<bool> isOwned = GeneratedColumn<bool>(
    'is_owned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_owned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isPreorderedMeta = const VerificationMeta(
    'isPreordered',
  );
  @override
  late final GeneratedColumn<bool> isPreordered = GeneratedColumn<bool>(
    'is_preordered',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_preordered" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isWishlistedMeta = const VerificationMeta(
    'isWishlisted',
  );
  @override
  late final GeneratedColumn<bool> isWishlisted = GeneratedColumn<bool>(
    'is_wishlisted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_wishlisted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isWantToPlayMeta = const VerificationMeta(
    'isWantToPlay',
  );
  @override
  late final GeneratedColumn<bool> isWantToPlay = GeneratedColumn<bool>(
    'is_want_to_play',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_want_to_play" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isWantToBuyMeta = const VerificationMeta(
    'isWantToBuy',
  );
  @override
  late final GeneratedColumn<bool> isWantToBuy = GeneratedColumn<bool>(
    'is_want_to_buy',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_want_to_buy" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isPrevOwnedMeta = const VerificationMeta(
    'isPrevOwned',
  );
  @override
  late final GeneratedColumn<bool> isPrevOwned = GeneratedColumn<bool>(
    'is_prev_owned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_prev_owned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isPlayedMeta = const VerificationMeta(
    'isPlayed',
  );
  @override
  late final GeneratedColumn<bool> isPlayed = GeneratedColumn<bool>(
    'is_played',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_played" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isRatedMeta = const VerificationMeta(
    'isRated',
  );
  @override
  late final GeneratedColumn<bool> isRated = GeneratedColumn<bool>(
    'is_rated',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_rated" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isForTradeMeta = const VerificationMeta(
    'isForTrade',
  );
  @override
  late final GeneratedColumn<bool> isForTrade = GeneratedColumn<bool>(
    'is_for_trade',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_for_trade" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isWantInTradeMeta = const VerificationMeta(
    'isWantInTrade',
  );
  @override
  late final GeneratedColumn<bool> isWantInTrade = GeneratedColumn<bool>(
    'is_want_in_trade',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_want_in_trade" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hasCommentMeta = const VerificationMeta(
    'hasComment',
  );
  @override
  late final GeneratedColumn<bool> hasComment = GeneratedColumn<bool>(
    'has_comment',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_comment" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _versionIdMeta = const VerificationMeta(
    'versionId',
  );
  @override
  late final GeneratedColumn<int> versionId = GeneratedColumn<int>(
    'version_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES versions(id)',
  );
  @override
  List<GeneratedColumn> get $columns => [
    thingId,
    collId,
    primaryName,
    thumbnailLocalPath,
    customName,
    customImageUrl,
    thumbnailUrl,
    imageUrl,
    yearPublished,
    minPlayers,
    maxPlayers,
    minPlayTime,
    maxPlayTime,
    minAge,
    bayesAverage,
    ownRating,
    numPlays,
    bggRank,
    geekRatingUserCount,
    isOwned,
    isPreordered,
    isWishlisted,
    isWantToPlay,
    isWantToBuy,
    isPrevOwned,
    isPlayed,
    isRated,
    isForTrade,
    isWantInTrade,
    hasComment,
    versionId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collection_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<CollectionItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('thing_id')) {
      context.handle(
        _thingIdMeta,
        thingId.isAcceptableOrUnknown(data['thing_id']!, _thingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_thingIdMeta);
    }
    if (data.containsKey('coll_id')) {
      context.handle(
        _collIdMeta,
        collId.isAcceptableOrUnknown(data['coll_id']!, _collIdMeta),
      );
    } else if (isInserting) {
      context.missing(_collIdMeta);
    }
    if (data.containsKey('primary_name')) {
      context.handle(
        _primaryNameMeta,
        primaryName.isAcceptableOrUnknown(
          data['primary_name']!,
          _primaryNameMeta,
        ),
      );
    }
    if (data.containsKey('thumbnail_local_path')) {
      context.handle(
        _thumbnailLocalPathMeta,
        thumbnailLocalPath.isAcceptableOrUnknown(
          data['thumbnail_local_path']!,
          _thumbnailLocalPathMeta,
        ),
      );
    }
    if (data.containsKey('custom_name')) {
      context.handle(
        _customNameMeta,
        customName.isAcceptableOrUnknown(data['custom_name']!, _customNameMeta),
      );
    }
    if (data.containsKey('custom_image_url')) {
      context.handle(
        _customImageUrlMeta,
        customImageUrl.isAcceptableOrUnknown(
          data['custom_image_url']!,
          _customImageUrlMeta,
        ),
      );
    }
    if (data.containsKey('thumbnail_url')) {
      context.handle(
        _thumbnailUrlMeta,
        thumbnailUrl.isAcceptableOrUnknown(
          data['thumbnail_url']!,
          _thumbnailUrlMeta,
        ),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('year_published')) {
      context.handle(
        _yearPublishedMeta,
        yearPublished.isAcceptableOrUnknown(
          data['year_published']!,
          _yearPublishedMeta,
        ),
      );
    }
    if (data.containsKey('min_players')) {
      context.handle(
        _minPlayersMeta,
        minPlayers.isAcceptableOrUnknown(data['min_players']!, _minPlayersMeta),
      );
    }
    if (data.containsKey('max_players')) {
      context.handle(
        _maxPlayersMeta,
        maxPlayers.isAcceptableOrUnknown(data['max_players']!, _maxPlayersMeta),
      );
    }
    if (data.containsKey('min_play_time')) {
      context.handle(
        _minPlayTimeMeta,
        minPlayTime.isAcceptableOrUnknown(
          data['min_play_time']!,
          _minPlayTimeMeta,
        ),
      );
    }
    if (data.containsKey('max_play_time')) {
      context.handle(
        _maxPlayTimeMeta,
        maxPlayTime.isAcceptableOrUnknown(
          data['max_play_time']!,
          _maxPlayTimeMeta,
        ),
      );
    }
    if (data.containsKey('min_age')) {
      context.handle(
        _minAgeMeta,
        minAge.isAcceptableOrUnknown(data['min_age']!, _minAgeMeta),
      );
    }
    if (data.containsKey('bayes_average')) {
      context.handle(
        _bayesAverageMeta,
        bayesAverage.isAcceptableOrUnknown(
          data['bayes_average']!,
          _bayesAverageMeta,
        ),
      );
    }
    if (data.containsKey('own_rating')) {
      context.handle(
        _ownRatingMeta,
        ownRating.isAcceptableOrUnknown(data['own_rating']!, _ownRatingMeta),
      );
    }
    if (data.containsKey('num_plays')) {
      context.handle(
        _numPlaysMeta,
        numPlays.isAcceptableOrUnknown(data['num_plays']!, _numPlaysMeta),
      );
    }
    if (data.containsKey('bgg_rank')) {
      context.handle(
        _bggRankMeta,
        bggRank.isAcceptableOrUnknown(data['bgg_rank']!, _bggRankMeta),
      );
    }
    if (data.containsKey('geek_rating_user_count')) {
      context.handle(
        _geekRatingUserCountMeta,
        geekRatingUserCount.isAcceptableOrUnknown(
          data['geek_rating_user_count']!,
          _geekRatingUserCountMeta,
        ),
      );
    }
    if (data.containsKey('is_owned')) {
      context.handle(
        _isOwnedMeta,
        isOwned.isAcceptableOrUnknown(data['is_owned']!, _isOwnedMeta),
      );
    }
    if (data.containsKey('is_preordered')) {
      context.handle(
        _isPreorderedMeta,
        isPreordered.isAcceptableOrUnknown(
          data['is_preordered']!,
          _isPreorderedMeta,
        ),
      );
    }
    if (data.containsKey('is_wishlisted')) {
      context.handle(
        _isWishlistedMeta,
        isWishlisted.isAcceptableOrUnknown(
          data['is_wishlisted']!,
          _isWishlistedMeta,
        ),
      );
    }
    if (data.containsKey('is_want_to_play')) {
      context.handle(
        _isWantToPlayMeta,
        isWantToPlay.isAcceptableOrUnknown(
          data['is_want_to_play']!,
          _isWantToPlayMeta,
        ),
      );
    }
    if (data.containsKey('is_want_to_buy')) {
      context.handle(
        _isWantToBuyMeta,
        isWantToBuy.isAcceptableOrUnknown(
          data['is_want_to_buy']!,
          _isWantToBuyMeta,
        ),
      );
    }
    if (data.containsKey('is_prev_owned')) {
      context.handle(
        _isPrevOwnedMeta,
        isPrevOwned.isAcceptableOrUnknown(
          data['is_prev_owned']!,
          _isPrevOwnedMeta,
        ),
      );
    }
    if (data.containsKey('is_played')) {
      context.handle(
        _isPlayedMeta,
        isPlayed.isAcceptableOrUnknown(data['is_played']!, _isPlayedMeta),
      );
    }
    if (data.containsKey('is_rated')) {
      context.handle(
        _isRatedMeta,
        isRated.isAcceptableOrUnknown(data['is_rated']!, _isRatedMeta),
      );
    }
    if (data.containsKey('is_for_trade')) {
      context.handle(
        _isForTradeMeta,
        isForTrade.isAcceptableOrUnknown(
          data['is_for_trade']!,
          _isForTradeMeta,
        ),
      );
    }
    if (data.containsKey('is_want_in_trade')) {
      context.handle(
        _isWantInTradeMeta,
        isWantInTrade.isAcceptableOrUnknown(
          data['is_want_in_trade']!,
          _isWantInTradeMeta,
        ),
      );
    }
    if (data.containsKey('has_comment')) {
      context.handle(
        _hasCommentMeta,
        hasComment.isAcceptableOrUnknown(data['has_comment']!, _hasCommentMeta),
      );
    }
    if (data.containsKey('version_id')) {
      context.handle(
        _versionIdMeta,
        versionId.isAcceptableOrUnknown(data['version_id']!, _versionIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {thingId, collId};
  @override
  CollectionItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollectionItem(
      thingId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}thing_id'],
      )!,
      collId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}coll_id'],
      )!,
      primaryName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}primary_name'],
      ),
      thumbnailLocalPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_local_path'],
      ),
      customName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_name'],
      ),
      customImageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_image_url'],
      ),
      thumbnailUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_url'],
      ),
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      yearPublished: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year_published'],
      ),
      minPlayers: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_players'],
      ),
      maxPlayers: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_players'],
      ),
      minPlayTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_play_time'],
      ),
      maxPlayTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_play_time'],
      ),
      minAge: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_age'],
      ),
      bayesAverage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}bayes_average'],
      ),
      ownRating: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}own_rating'],
      ),
      numPlays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}num_plays'],
      ),
      bggRank: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bgg_rank'],
      ),
      geekRatingUserCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}geek_rating_user_count'],
      ),
      isOwned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_owned'],
      )!,
      isPreordered: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_preordered'],
      )!,
      isWishlisted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_wishlisted'],
      )!,
      isWantToPlay: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_want_to_play'],
      )!,
      isWantToBuy: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_want_to_buy'],
      )!,
      isPrevOwned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_prev_owned'],
      )!,
      isPlayed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_played'],
      )!,
      isRated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_rated'],
      )!,
      isForTrade: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_for_trade'],
      )!,
      isWantInTrade: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_want_in_trade'],
      )!,
      hasComment: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_comment'],
      )!,
      versionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version_id'],
      ),
    );
  }

  @override
  $CollectionItemsTable createAlias(String alias) {
    return $CollectionItemsTable(attachedDatabase, alias);
  }
}

class CollectionItem extends DataClass implements Insertable<CollectionItem> {
  final int thingId;
  final int collId;
  final String? primaryName;
  final String? thumbnailLocalPath;
  final String? customName;
  final String? customImageUrl;
  final String? thumbnailUrl;
  final String? imageUrl;
  final int? yearPublished;
  final int? minPlayers;
  final int? maxPlayers;
  final int? minPlayTime;
  final int? maxPlayTime;
  final int? minAge;
  final double? bayesAverage;
  final double? ownRating;
  final int? numPlays;
  final int? bggRank;
  final int? geekRatingUserCount;
  final bool isOwned;
  final bool isPreordered;
  final bool isWishlisted;
  final bool isWantToPlay;
  final bool isWantToBuy;
  final bool isPrevOwned;
  final bool isPlayed;
  final bool isRated;
  final bool isForTrade;
  final bool isWantInTrade;
  final bool hasComment;
  final int? versionId;
  const CollectionItem({
    required this.thingId,
    required this.collId,
    this.primaryName,
    this.thumbnailLocalPath,
    this.customName,
    this.customImageUrl,
    this.thumbnailUrl,
    this.imageUrl,
    this.yearPublished,
    this.minPlayers,
    this.maxPlayers,
    this.minPlayTime,
    this.maxPlayTime,
    this.minAge,
    this.bayesAverage,
    this.ownRating,
    this.numPlays,
    this.bggRank,
    this.geekRatingUserCount,
    required this.isOwned,
    required this.isPreordered,
    required this.isWishlisted,
    required this.isWantToPlay,
    required this.isWantToBuy,
    required this.isPrevOwned,
    required this.isPlayed,
    required this.isRated,
    required this.isForTrade,
    required this.isWantInTrade,
    required this.hasComment,
    this.versionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['thing_id'] = Variable<int>(thingId);
    map['coll_id'] = Variable<int>(collId);
    if (!nullToAbsent || primaryName != null) {
      map['primary_name'] = Variable<String>(primaryName);
    }
    if (!nullToAbsent || thumbnailLocalPath != null) {
      map['thumbnail_local_path'] = Variable<String>(thumbnailLocalPath);
    }
    if (!nullToAbsent || customName != null) {
      map['custom_name'] = Variable<String>(customName);
    }
    if (!nullToAbsent || customImageUrl != null) {
      map['custom_image_url'] = Variable<String>(customImageUrl);
    }
    if (!nullToAbsent || thumbnailUrl != null) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || yearPublished != null) {
      map['year_published'] = Variable<int>(yearPublished);
    }
    if (!nullToAbsent || minPlayers != null) {
      map['min_players'] = Variable<int>(minPlayers);
    }
    if (!nullToAbsent || maxPlayers != null) {
      map['max_players'] = Variable<int>(maxPlayers);
    }
    if (!nullToAbsent || minPlayTime != null) {
      map['min_play_time'] = Variable<int>(minPlayTime);
    }
    if (!nullToAbsent || maxPlayTime != null) {
      map['max_play_time'] = Variable<int>(maxPlayTime);
    }
    if (!nullToAbsent || minAge != null) {
      map['min_age'] = Variable<int>(minAge);
    }
    if (!nullToAbsent || bayesAverage != null) {
      map['bayes_average'] = Variable<double>(bayesAverage);
    }
    if (!nullToAbsent || ownRating != null) {
      map['own_rating'] = Variable<double>(ownRating);
    }
    if (!nullToAbsent || numPlays != null) {
      map['num_plays'] = Variable<int>(numPlays);
    }
    if (!nullToAbsent || bggRank != null) {
      map['bgg_rank'] = Variable<int>(bggRank);
    }
    if (!nullToAbsent || geekRatingUserCount != null) {
      map['geek_rating_user_count'] = Variable<int>(geekRatingUserCount);
    }
    map['is_owned'] = Variable<bool>(isOwned);
    map['is_preordered'] = Variable<bool>(isPreordered);
    map['is_wishlisted'] = Variable<bool>(isWishlisted);
    map['is_want_to_play'] = Variable<bool>(isWantToPlay);
    map['is_want_to_buy'] = Variable<bool>(isWantToBuy);
    map['is_prev_owned'] = Variable<bool>(isPrevOwned);
    map['is_played'] = Variable<bool>(isPlayed);
    map['is_rated'] = Variable<bool>(isRated);
    map['is_for_trade'] = Variable<bool>(isForTrade);
    map['is_want_in_trade'] = Variable<bool>(isWantInTrade);
    map['has_comment'] = Variable<bool>(hasComment);
    if (!nullToAbsent || versionId != null) {
      map['version_id'] = Variable<int>(versionId);
    }
    return map;
  }

  CollectionItemsCompanion toCompanion(bool nullToAbsent) {
    return CollectionItemsCompanion(
      thingId: Value(thingId),
      collId: Value(collId),
      primaryName: primaryName == null && nullToAbsent
          ? const Value.absent()
          : Value(primaryName),
      thumbnailLocalPath: thumbnailLocalPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailLocalPath),
      customName: customName == null && nullToAbsent
          ? const Value.absent()
          : Value(customName),
      customImageUrl: customImageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(customImageUrl),
      thumbnailUrl: thumbnailUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailUrl),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      yearPublished: yearPublished == null && nullToAbsent
          ? const Value.absent()
          : Value(yearPublished),
      minPlayers: minPlayers == null && nullToAbsent
          ? const Value.absent()
          : Value(minPlayers),
      maxPlayers: maxPlayers == null && nullToAbsent
          ? const Value.absent()
          : Value(maxPlayers),
      minPlayTime: minPlayTime == null && nullToAbsent
          ? const Value.absent()
          : Value(minPlayTime),
      maxPlayTime: maxPlayTime == null && nullToAbsent
          ? const Value.absent()
          : Value(maxPlayTime),
      minAge: minAge == null && nullToAbsent
          ? const Value.absent()
          : Value(minAge),
      bayesAverage: bayesAverage == null && nullToAbsent
          ? const Value.absent()
          : Value(bayesAverage),
      ownRating: ownRating == null && nullToAbsent
          ? const Value.absent()
          : Value(ownRating),
      numPlays: numPlays == null && nullToAbsent
          ? const Value.absent()
          : Value(numPlays),
      bggRank: bggRank == null && nullToAbsent
          ? const Value.absent()
          : Value(bggRank),
      geekRatingUserCount: geekRatingUserCount == null && nullToAbsent
          ? const Value.absent()
          : Value(geekRatingUserCount),
      isOwned: Value(isOwned),
      isPreordered: Value(isPreordered),
      isWishlisted: Value(isWishlisted),
      isWantToPlay: Value(isWantToPlay),
      isWantToBuy: Value(isWantToBuy),
      isPrevOwned: Value(isPrevOwned),
      isPlayed: Value(isPlayed),
      isRated: Value(isRated),
      isForTrade: Value(isForTrade),
      isWantInTrade: Value(isWantInTrade),
      hasComment: Value(hasComment),
      versionId: versionId == null && nullToAbsent
          ? const Value.absent()
          : Value(versionId),
    );
  }

  factory CollectionItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollectionItem(
      thingId: serializer.fromJson<int>(json['thingId']),
      collId: serializer.fromJson<int>(json['collId']),
      primaryName: serializer.fromJson<String?>(json['primaryName']),
      thumbnailLocalPath: serializer.fromJson<String?>(
        json['thumbnailLocalPath'],
      ),
      customName: serializer.fromJson<String?>(json['customName']),
      customImageUrl: serializer.fromJson<String?>(json['customImageUrl']),
      thumbnailUrl: serializer.fromJson<String?>(json['thumbnailUrl']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      yearPublished: serializer.fromJson<int?>(json['yearPublished']),
      minPlayers: serializer.fromJson<int?>(json['minPlayers']),
      maxPlayers: serializer.fromJson<int?>(json['maxPlayers']),
      minPlayTime: serializer.fromJson<int?>(json['minPlayTime']),
      maxPlayTime: serializer.fromJson<int?>(json['maxPlayTime']),
      minAge: serializer.fromJson<int?>(json['minAge']),
      bayesAverage: serializer.fromJson<double?>(json['bayesAverage']),
      ownRating: serializer.fromJson<double?>(json['ownRating']),
      numPlays: serializer.fromJson<int?>(json['numPlays']),
      bggRank: serializer.fromJson<int?>(json['bggRank']),
      geekRatingUserCount: serializer.fromJson<int?>(
        json['geekRatingUserCount'],
      ),
      isOwned: serializer.fromJson<bool>(json['isOwned']),
      isPreordered: serializer.fromJson<bool>(json['isPreordered']),
      isWishlisted: serializer.fromJson<bool>(json['isWishlisted']),
      isWantToPlay: serializer.fromJson<bool>(json['isWantToPlay']),
      isWantToBuy: serializer.fromJson<bool>(json['isWantToBuy']),
      isPrevOwned: serializer.fromJson<bool>(json['isPrevOwned']),
      isPlayed: serializer.fromJson<bool>(json['isPlayed']),
      isRated: serializer.fromJson<bool>(json['isRated']),
      isForTrade: serializer.fromJson<bool>(json['isForTrade']),
      isWantInTrade: serializer.fromJson<bool>(json['isWantInTrade']),
      hasComment: serializer.fromJson<bool>(json['hasComment']),
      versionId: serializer.fromJson<int?>(json['versionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'thingId': serializer.toJson<int>(thingId),
      'collId': serializer.toJson<int>(collId),
      'primaryName': serializer.toJson<String?>(primaryName),
      'thumbnailLocalPath': serializer.toJson<String?>(thumbnailLocalPath),
      'customName': serializer.toJson<String?>(customName),
      'customImageUrl': serializer.toJson<String?>(customImageUrl),
      'thumbnailUrl': serializer.toJson<String?>(thumbnailUrl),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'yearPublished': serializer.toJson<int?>(yearPublished),
      'minPlayers': serializer.toJson<int?>(minPlayers),
      'maxPlayers': serializer.toJson<int?>(maxPlayers),
      'minPlayTime': serializer.toJson<int?>(minPlayTime),
      'maxPlayTime': serializer.toJson<int?>(maxPlayTime),
      'minAge': serializer.toJson<int?>(minAge),
      'bayesAverage': serializer.toJson<double?>(bayesAverage),
      'ownRating': serializer.toJson<double?>(ownRating),
      'numPlays': serializer.toJson<int?>(numPlays),
      'bggRank': serializer.toJson<int?>(bggRank),
      'geekRatingUserCount': serializer.toJson<int?>(geekRatingUserCount),
      'isOwned': serializer.toJson<bool>(isOwned),
      'isPreordered': serializer.toJson<bool>(isPreordered),
      'isWishlisted': serializer.toJson<bool>(isWishlisted),
      'isWantToPlay': serializer.toJson<bool>(isWantToPlay),
      'isWantToBuy': serializer.toJson<bool>(isWantToBuy),
      'isPrevOwned': serializer.toJson<bool>(isPrevOwned),
      'isPlayed': serializer.toJson<bool>(isPlayed),
      'isRated': serializer.toJson<bool>(isRated),
      'isForTrade': serializer.toJson<bool>(isForTrade),
      'isWantInTrade': serializer.toJson<bool>(isWantInTrade),
      'hasComment': serializer.toJson<bool>(hasComment),
      'versionId': serializer.toJson<int?>(versionId),
    };
  }

  CollectionItem copyWith({
    int? thingId,
    int? collId,
    Value<String?> primaryName = const Value.absent(),
    Value<String?> thumbnailLocalPath = const Value.absent(),
    Value<String?> customName = const Value.absent(),
    Value<String?> customImageUrl = const Value.absent(),
    Value<String?> thumbnailUrl = const Value.absent(),
    Value<String?> imageUrl = const Value.absent(),
    Value<int?> yearPublished = const Value.absent(),
    Value<int?> minPlayers = const Value.absent(),
    Value<int?> maxPlayers = const Value.absent(),
    Value<int?> minPlayTime = const Value.absent(),
    Value<int?> maxPlayTime = const Value.absent(),
    Value<int?> minAge = const Value.absent(),
    Value<double?> bayesAverage = const Value.absent(),
    Value<double?> ownRating = const Value.absent(),
    Value<int?> numPlays = const Value.absent(),
    Value<int?> bggRank = const Value.absent(),
    Value<int?> geekRatingUserCount = const Value.absent(),
    bool? isOwned,
    bool? isPreordered,
    bool? isWishlisted,
    bool? isWantToPlay,
    bool? isWantToBuy,
    bool? isPrevOwned,
    bool? isPlayed,
    bool? isRated,
    bool? isForTrade,
    bool? isWantInTrade,
    bool? hasComment,
    Value<int?> versionId = const Value.absent(),
  }) => CollectionItem(
    thingId: thingId ?? this.thingId,
    collId: collId ?? this.collId,
    primaryName: primaryName.present ? primaryName.value : this.primaryName,
    thumbnailLocalPath: thumbnailLocalPath.present
        ? thumbnailLocalPath.value
        : this.thumbnailLocalPath,
    customName: customName.present ? customName.value : this.customName,
    customImageUrl: customImageUrl.present
        ? customImageUrl.value
        : this.customImageUrl,
    thumbnailUrl: thumbnailUrl.present ? thumbnailUrl.value : this.thumbnailUrl,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    yearPublished: yearPublished.present
        ? yearPublished.value
        : this.yearPublished,
    minPlayers: minPlayers.present ? minPlayers.value : this.minPlayers,
    maxPlayers: maxPlayers.present ? maxPlayers.value : this.maxPlayers,
    minPlayTime: minPlayTime.present ? minPlayTime.value : this.minPlayTime,
    maxPlayTime: maxPlayTime.present ? maxPlayTime.value : this.maxPlayTime,
    minAge: minAge.present ? minAge.value : this.minAge,
    bayesAverage: bayesAverage.present ? bayesAverage.value : this.bayesAverage,
    ownRating: ownRating.present ? ownRating.value : this.ownRating,
    numPlays: numPlays.present ? numPlays.value : this.numPlays,
    bggRank: bggRank.present ? bggRank.value : this.bggRank,
    geekRatingUserCount: geekRatingUserCount.present
        ? geekRatingUserCount.value
        : this.geekRatingUserCount,
    isOwned: isOwned ?? this.isOwned,
    isPreordered: isPreordered ?? this.isPreordered,
    isWishlisted: isWishlisted ?? this.isWishlisted,
    isWantToPlay: isWantToPlay ?? this.isWantToPlay,
    isWantToBuy: isWantToBuy ?? this.isWantToBuy,
    isPrevOwned: isPrevOwned ?? this.isPrevOwned,
    isPlayed: isPlayed ?? this.isPlayed,
    isRated: isRated ?? this.isRated,
    isForTrade: isForTrade ?? this.isForTrade,
    isWantInTrade: isWantInTrade ?? this.isWantInTrade,
    hasComment: hasComment ?? this.hasComment,
    versionId: versionId.present ? versionId.value : this.versionId,
  );
  CollectionItem copyWithCompanion(CollectionItemsCompanion data) {
    return CollectionItem(
      thingId: data.thingId.present ? data.thingId.value : this.thingId,
      collId: data.collId.present ? data.collId.value : this.collId,
      primaryName: data.primaryName.present
          ? data.primaryName.value
          : this.primaryName,
      thumbnailLocalPath: data.thumbnailLocalPath.present
          ? data.thumbnailLocalPath.value
          : this.thumbnailLocalPath,
      customName: data.customName.present
          ? data.customName.value
          : this.customName,
      customImageUrl: data.customImageUrl.present
          ? data.customImageUrl.value
          : this.customImageUrl,
      thumbnailUrl: data.thumbnailUrl.present
          ? data.thumbnailUrl.value
          : this.thumbnailUrl,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      yearPublished: data.yearPublished.present
          ? data.yearPublished.value
          : this.yearPublished,
      minPlayers: data.minPlayers.present
          ? data.minPlayers.value
          : this.minPlayers,
      maxPlayers: data.maxPlayers.present
          ? data.maxPlayers.value
          : this.maxPlayers,
      minPlayTime: data.minPlayTime.present
          ? data.minPlayTime.value
          : this.minPlayTime,
      maxPlayTime: data.maxPlayTime.present
          ? data.maxPlayTime.value
          : this.maxPlayTime,
      minAge: data.minAge.present ? data.minAge.value : this.minAge,
      bayesAverage: data.bayesAverage.present
          ? data.bayesAverage.value
          : this.bayesAverage,
      ownRating: data.ownRating.present ? data.ownRating.value : this.ownRating,
      numPlays: data.numPlays.present ? data.numPlays.value : this.numPlays,
      bggRank: data.bggRank.present ? data.bggRank.value : this.bggRank,
      geekRatingUserCount: data.geekRatingUserCount.present
          ? data.geekRatingUserCount.value
          : this.geekRatingUserCount,
      isOwned: data.isOwned.present ? data.isOwned.value : this.isOwned,
      isPreordered: data.isPreordered.present
          ? data.isPreordered.value
          : this.isPreordered,
      isWishlisted: data.isWishlisted.present
          ? data.isWishlisted.value
          : this.isWishlisted,
      isWantToPlay: data.isWantToPlay.present
          ? data.isWantToPlay.value
          : this.isWantToPlay,
      isWantToBuy: data.isWantToBuy.present
          ? data.isWantToBuy.value
          : this.isWantToBuy,
      isPrevOwned: data.isPrevOwned.present
          ? data.isPrevOwned.value
          : this.isPrevOwned,
      isPlayed: data.isPlayed.present ? data.isPlayed.value : this.isPlayed,
      isRated: data.isRated.present ? data.isRated.value : this.isRated,
      isForTrade: data.isForTrade.present
          ? data.isForTrade.value
          : this.isForTrade,
      isWantInTrade: data.isWantInTrade.present
          ? data.isWantInTrade.value
          : this.isWantInTrade,
      hasComment: data.hasComment.present
          ? data.hasComment.value
          : this.hasComment,
      versionId: data.versionId.present ? data.versionId.value : this.versionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollectionItem(')
          ..write('thingId: $thingId, ')
          ..write('collId: $collId, ')
          ..write('primaryName: $primaryName, ')
          ..write('thumbnailLocalPath: $thumbnailLocalPath, ')
          ..write('customName: $customName, ')
          ..write('customImageUrl: $customImageUrl, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('yearPublished: $yearPublished, ')
          ..write('minPlayers: $minPlayers, ')
          ..write('maxPlayers: $maxPlayers, ')
          ..write('minPlayTime: $minPlayTime, ')
          ..write('maxPlayTime: $maxPlayTime, ')
          ..write('minAge: $minAge, ')
          ..write('bayesAverage: $bayesAverage, ')
          ..write('ownRating: $ownRating, ')
          ..write('numPlays: $numPlays, ')
          ..write('bggRank: $bggRank, ')
          ..write('geekRatingUserCount: $geekRatingUserCount, ')
          ..write('isOwned: $isOwned, ')
          ..write('isPreordered: $isPreordered, ')
          ..write('isWishlisted: $isWishlisted, ')
          ..write('isWantToPlay: $isWantToPlay, ')
          ..write('isWantToBuy: $isWantToBuy, ')
          ..write('isPrevOwned: $isPrevOwned, ')
          ..write('isPlayed: $isPlayed, ')
          ..write('isRated: $isRated, ')
          ..write('isForTrade: $isForTrade, ')
          ..write('isWantInTrade: $isWantInTrade, ')
          ..write('hasComment: $hasComment, ')
          ..write('versionId: $versionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    thingId,
    collId,
    primaryName,
    thumbnailLocalPath,
    customName,
    customImageUrl,
    thumbnailUrl,
    imageUrl,
    yearPublished,
    minPlayers,
    maxPlayers,
    minPlayTime,
    maxPlayTime,
    minAge,
    bayesAverage,
    ownRating,
    numPlays,
    bggRank,
    geekRatingUserCount,
    isOwned,
    isPreordered,
    isWishlisted,
    isWantToPlay,
    isWantToBuy,
    isPrevOwned,
    isPlayed,
    isRated,
    isForTrade,
    isWantInTrade,
    hasComment,
    versionId,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollectionItem &&
          other.thingId == this.thingId &&
          other.collId == this.collId &&
          other.primaryName == this.primaryName &&
          other.thumbnailLocalPath == this.thumbnailLocalPath &&
          other.customName == this.customName &&
          other.customImageUrl == this.customImageUrl &&
          other.thumbnailUrl == this.thumbnailUrl &&
          other.imageUrl == this.imageUrl &&
          other.yearPublished == this.yearPublished &&
          other.minPlayers == this.minPlayers &&
          other.maxPlayers == this.maxPlayers &&
          other.minPlayTime == this.minPlayTime &&
          other.maxPlayTime == this.maxPlayTime &&
          other.minAge == this.minAge &&
          other.bayesAverage == this.bayesAverage &&
          other.ownRating == this.ownRating &&
          other.numPlays == this.numPlays &&
          other.bggRank == this.bggRank &&
          other.geekRatingUserCount == this.geekRatingUserCount &&
          other.isOwned == this.isOwned &&
          other.isPreordered == this.isPreordered &&
          other.isWishlisted == this.isWishlisted &&
          other.isWantToPlay == this.isWantToPlay &&
          other.isWantToBuy == this.isWantToBuy &&
          other.isPrevOwned == this.isPrevOwned &&
          other.isPlayed == this.isPlayed &&
          other.isRated == this.isRated &&
          other.isForTrade == this.isForTrade &&
          other.isWantInTrade == this.isWantInTrade &&
          other.hasComment == this.hasComment &&
          other.versionId == this.versionId);
}

class CollectionItemsCompanion extends UpdateCompanion<CollectionItem> {
  final Value<int> thingId;
  final Value<int> collId;
  final Value<String?> primaryName;
  final Value<String?> thumbnailLocalPath;
  final Value<String?> customName;
  final Value<String?> customImageUrl;
  final Value<String?> thumbnailUrl;
  final Value<String?> imageUrl;
  final Value<int?> yearPublished;
  final Value<int?> minPlayers;
  final Value<int?> maxPlayers;
  final Value<int?> minPlayTime;
  final Value<int?> maxPlayTime;
  final Value<int?> minAge;
  final Value<double?> bayesAverage;
  final Value<double?> ownRating;
  final Value<int?> numPlays;
  final Value<int?> bggRank;
  final Value<int?> geekRatingUserCount;
  final Value<bool> isOwned;
  final Value<bool> isPreordered;
  final Value<bool> isWishlisted;
  final Value<bool> isWantToPlay;
  final Value<bool> isWantToBuy;
  final Value<bool> isPrevOwned;
  final Value<bool> isPlayed;
  final Value<bool> isRated;
  final Value<bool> isForTrade;
  final Value<bool> isWantInTrade;
  final Value<bool> hasComment;
  final Value<int?> versionId;
  final Value<int> rowid;
  const CollectionItemsCompanion({
    this.thingId = const Value.absent(),
    this.collId = const Value.absent(),
    this.primaryName = const Value.absent(),
    this.thumbnailLocalPath = const Value.absent(),
    this.customName = const Value.absent(),
    this.customImageUrl = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.yearPublished = const Value.absent(),
    this.minPlayers = const Value.absent(),
    this.maxPlayers = const Value.absent(),
    this.minPlayTime = const Value.absent(),
    this.maxPlayTime = const Value.absent(),
    this.minAge = const Value.absent(),
    this.bayesAverage = const Value.absent(),
    this.ownRating = const Value.absent(),
    this.numPlays = const Value.absent(),
    this.bggRank = const Value.absent(),
    this.geekRatingUserCount = const Value.absent(),
    this.isOwned = const Value.absent(),
    this.isPreordered = const Value.absent(),
    this.isWishlisted = const Value.absent(),
    this.isWantToPlay = const Value.absent(),
    this.isWantToBuy = const Value.absent(),
    this.isPrevOwned = const Value.absent(),
    this.isPlayed = const Value.absent(),
    this.isRated = const Value.absent(),
    this.isForTrade = const Value.absent(),
    this.isWantInTrade = const Value.absent(),
    this.hasComment = const Value.absent(),
    this.versionId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollectionItemsCompanion.insert({
    required int thingId,
    required int collId,
    this.primaryName = const Value.absent(),
    this.thumbnailLocalPath = const Value.absent(),
    this.customName = const Value.absent(),
    this.customImageUrl = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.yearPublished = const Value.absent(),
    this.minPlayers = const Value.absent(),
    this.maxPlayers = const Value.absent(),
    this.minPlayTime = const Value.absent(),
    this.maxPlayTime = const Value.absent(),
    this.minAge = const Value.absent(),
    this.bayesAverage = const Value.absent(),
    this.ownRating = const Value.absent(),
    this.numPlays = const Value.absent(),
    this.bggRank = const Value.absent(),
    this.geekRatingUserCount = const Value.absent(),
    this.isOwned = const Value.absent(),
    this.isPreordered = const Value.absent(),
    this.isWishlisted = const Value.absent(),
    this.isWantToPlay = const Value.absent(),
    this.isWantToBuy = const Value.absent(),
    this.isPrevOwned = const Value.absent(),
    this.isPlayed = const Value.absent(),
    this.isRated = const Value.absent(),
    this.isForTrade = const Value.absent(),
    this.isWantInTrade = const Value.absent(),
    this.hasComment = const Value.absent(),
    this.versionId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : thingId = Value(thingId),
       collId = Value(collId);
  static Insertable<CollectionItem> custom({
    Expression<int>? thingId,
    Expression<int>? collId,
    Expression<String>? primaryName,
    Expression<String>? thumbnailLocalPath,
    Expression<String>? customName,
    Expression<String>? customImageUrl,
    Expression<String>? thumbnailUrl,
    Expression<String>? imageUrl,
    Expression<int>? yearPublished,
    Expression<int>? minPlayers,
    Expression<int>? maxPlayers,
    Expression<int>? minPlayTime,
    Expression<int>? maxPlayTime,
    Expression<int>? minAge,
    Expression<double>? bayesAverage,
    Expression<double>? ownRating,
    Expression<int>? numPlays,
    Expression<int>? bggRank,
    Expression<int>? geekRatingUserCount,
    Expression<bool>? isOwned,
    Expression<bool>? isPreordered,
    Expression<bool>? isWishlisted,
    Expression<bool>? isWantToPlay,
    Expression<bool>? isWantToBuy,
    Expression<bool>? isPrevOwned,
    Expression<bool>? isPlayed,
    Expression<bool>? isRated,
    Expression<bool>? isForTrade,
    Expression<bool>? isWantInTrade,
    Expression<bool>? hasComment,
    Expression<int>? versionId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (thingId != null) 'thing_id': thingId,
      if (collId != null) 'coll_id': collId,
      if (primaryName != null) 'primary_name': primaryName,
      if (thumbnailLocalPath != null)
        'thumbnail_local_path': thumbnailLocalPath,
      if (customName != null) 'custom_name': customName,
      if (customImageUrl != null) 'custom_image_url': customImageUrl,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (imageUrl != null) 'image_url': imageUrl,
      if (yearPublished != null) 'year_published': yearPublished,
      if (minPlayers != null) 'min_players': minPlayers,
      if (maxPlayers != null) 'max_players': maxPlayers,
      if (minPlayTime != null) 'min_play_time': minPlayTime,
      if (maxPlayTime != null) 'max_play_time': maxPlayTime,
      if (minAge != null) 'min_age': minAge,
      if (bayesAverage != null) 'bayes_average': bayesAverage,
      if (ownRating != null) 'own_rating': ownRating,
      if (numPlays != null) 'num_plays': numPlays,
      if (bggRank != null) 'bgg_rank': bggRank,
      if (geekRatingUserCount != null)
        'geek_rating_user_count': geekRatingUserCount,
      if (isOwned != null) 'is_owned': isOwned,
      if (isPreordered != null) 'is_preordered': isPreordered,
      if (isWishlisted != null) 'is_wishlisted': isWishlisted,
      if (isWantToPlay != null) 'is_want_to_play': isWantToPlay,
      if (isWantToBuy != null) 'is_want_to_buy': isWantToBuy,
      if (isPrevOwned != null) 'is_prev_owned': isPrevOwned,
      if (isPlayed != null) 'is_played': isPlayed,
      if (isRated != null) 'is_rated': isRated,
      if (isForTrade != null) 'is_for_trade': isForTrade,
      if (isWantInTrade != null) 'is_want_in_trade': isWantInTrade,
      if (hasComment != null) 'has_comment': hasComment,
      if (versionId != null) 'version_id': versionId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollectionItemsCompanion copyWith({
    Value<int>? thingId,
    Value<int>? collId,
    Value<String?>? primaryName,
    Value<String?>? thumbnailLocalPath,
    Value<String?>? customName,
    Value<String?>? customImageUrl,
    Value<String?>? thumbnailUrl,
    Value<String?>? imageUrl,
    Value<int?>? yearPublished,
    Value<int?>? minPlayers,
    Value<int?>? maxPlayers,
    Value<int?>? minPlayTime,
    Value<int?>? maxPlayTime,
    Value<int?>? minAge,
    Value<double?>? bayesAverage,
    Value<double?>? ownRating,
    Value<int?>? numPlays,
    Value<int?>? bggRank,
    Value<int?>? geekRatingUserCount,
    Value<bool>? isOwned,
    Value<bool>? isPreordered,
    Value<bool>? isWishlisted,
    Value<bool>? isWantToPlay,
    Value<bool>? isWantToBuy,
    Value<bool>? isPrevOwned,
    Value<bool>? isPlayed,
    Value<bool>? isRated,
    Value<bool>? isForTrade,
    Value<bool>? isWantInTrade,
    Value<bool>? hasComment,
    Value<int?>? versionId,
    Value<int>? rowid,
  }) {
    return CollectionItemsCompanion(
      thingId: thingId ?? this.thingId,
      collId: collId ?? this.collId,
      primaryName: primaryName ?? this.primaryName,
      thumbnailLocalPath: thumbnailLocalPath ?? this.thumbnailLocalPath,
      customName: customName ?? this.customName,
      customImageUrl: customImageUrl ?? this.customImageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      yearPublished: yearPublished ?? this.yearPublished,
      minPlayers: minPlayers ?? this.minPlayers,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      minPlayTime: minPlayTime ?? this.minPlayTime,
      maxPlayTime: maxPlayTime ?? this.maxPlayTime,
      minAge: minAge ?? this.minAge,
      bayesAverage: bayesAverage ?? this.bayesAverage,
      ownRating: ownRating ?? this.ownRating,
      numPlays: numPlays ?? this.numPlays,
      bggRank: bggRank ?? this.bggRank,
      geekRatingUserCount: geekRatingUserCount ?? this.geekRatingUserCount,
      isOwned: isOwned ?? this.isOwned,
      isPreordered: isPreordered ?? this.isPreordered,
      isWishlisted: isWishlisted ?? this.isWishlisted,
      isWantToPlay: isWantToPlay ?? this.isWantToPlay,
      isWantToBuy: isWantToBuy ?? this.isWantToBuy,
      isPrevOwned: isPrevOwned ?? this.isPrevOwned,
      isPlayed: isPlayed ?? this.isPlayed,
      isRated: isRated ?? this.isRated,
      isForTrade: isForTrade ?? this.isForTrade,
      isWantInTrade: isWantInTrade ?? this.isWantInTrade,
      hasComment: hasComment ?? this.hasComment,
      versionId: versionId ?? this.versionId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (thingId.present) {
      map['thing_id'] = Variable<int>(thingId.value);
    }
    if (collId.present) {
      map['coll_id'] = Variable<int>(collId.value);
    }
    if (primaryName.present) {
      map['primary_name'] = Variable<String>(primaryName.value);
    }
    if (thumbnailLocalPath.present) {
      map['thumbnail_local_path'] = Variable<String>(thumbnailLocalPath.value);
    }
    if (customName.present) {
      map['custom_name'] = Variable<String>(customName.value);
    }
    if (customImageUrl.present) {
      map['custom_image_url'] = Variable<String>(customImageUrl.value);
    }
    if (thumbnailUrl.present) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (yearPublished.present) {
      map['year_published'] = Variable<int>(yearPublished.value);
    }
    if (minPlayers.present) {
      map['min_players'] = Variable<int>(minPlayers.value);
    }
    if (maxPlayers.present) {
      map['max_players'] = Variable<int>(maxPlayers.value);
    }
    if (minPlayTime.present) {
      map['min_play_time'] = Variable<int>(minPlayTime.value);
    }
    if (maxPlayTime.present) {
      map['max_play_time'] = Variable<int>(maxPlayTime.value);
    }
    if (minAge.present) {
      map['min_age'] = Variable<int>(minAge.value);
    }
    if (bayesAverage.present) {
      map['bayes_average'] = Variable<double>(bayesAverage.value);
    }
    if (ownRating.present) {
      map['own_rating'] = Variable<double>(ownRating.value);
    }
    if (numPlays.present) {
      map['num_plays'] = Variable<int>(numPlays.value);
    }
    if (bggRank.present) {
      map['bgg_rank'] = Variable<int>(bggRank.value);
    }
    if (geekRatingUserCount.present) {
      map['geek_rating_user_count'] = Variable<int>(geekRatingUserCount.value);
    }
    if (isOwned.present) {
      map['is_owned'] = Variable<bool>(isOwned.value);
    }
    if (isPreordered.present) {
      map['is_preordered'] = Variable<bool>(isPreordered.value);
    }
    if (isWishlisted.present) {
      map['is_wishlisted'] = Variable<bool>(isWishlisted.value);
    }
    if (isWantToPlay.present) {
      map['is_want_to_play'] = Variable<bool>(isWantToPlay.value);
    }
    if (isWantToBuy.present) {
      map['is_want_to_buy'] = Variable<bool>(isWantToBuy.value);
    }
    if (isPrevOwned.present) {
      map['is_prev_owned'] = Variable<bool>(isPrevOwned.value);
    }
    if (isPlayed.present) {
      map['is_played'] = Variable<bool>(isPlayed.value);
    }
    if (isRated.present) {
      map['is_rated'] = Variable<bool>(isRated.value);
    }
    if (isForTrade.present) {
      map['is_for_trade'] = Variable<bool>(isForTrade.value);
    }
    if (isWantInTrade.present) {
      map['is_want_in_trade'] = Variable<bool>(isWantInTrade.value);
    }
    if (hasComment.present) {
      map['has_comment'] = Variable<bool>(hasComment.value);
    }
    if (versionId.present) {
      map['version_id'] = Variable<int>(versionId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionItemsCompanion(')
          ..write('thingId: $thingId, ')
          ..write('collId: $collId, ')
          ..write('primaryName: $primaryName, ')
          ..write('thumbnailLocalPath: $thumbnailLocalPath, ')
          ..write('customName: $customName, ')
          ..write('customImageUrl: $customImageUrl, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('yearPublished: $yearPublished, ')
          ..write('minPlayers: $minPlayers, ')
          ..write('maxPlayers: $maxPlayers, ')
          ..write('minPlayTime: $minPlayTime, ')
          ..write('maxPlayTime: $maxPlayTime, ')
          ..write('minAge: $minAge, ')
          ..write('bayesAverage: $bayesAverage, ')
          ..write('ownRating: $ownRating, ')
          ..write('numPlays: $numPlays, ')
          ..write('bggRank: $bggRank, ')
          ..write('geekRatingUserCount: $geekRatingUserCount, ')
          ..write('isOwned: $isOwned, ')
          ..write('isPreordered: $isPreordered, ')
          ..write('isWishlisted: $isWishlisted, ')
          ..write('isWantToPlay: $isWantToPlay, ')
          ..write('isWantToBuy: $isWantToBuy, ')
          ..write('isPrevOwned: $isPrevOwned, ')
          ..write('isPlayed: $isPlayed, ')
          ..write('isRated: $isRated, ')
          ..write('isForTrade: $isForTrade, ')
          ..write('isWantInTrade: $isWantInTrade, ')
          ..write('hasComment: $hasComment, ')
          ..write('versionId: $versionId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BoardGamesTable extends BoardGames
    with TableInfo<$BoardGamesTable, BoardGame> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BoardGamesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbnailUrlMeta = const VerificationMeta(
    'thumbnailUrl',
  );
  @override
  late final GeneratedColumn<String> thumbnailUrl = GeneratedColumn<String>(
    'thumbnail_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yearPublishedMeta = const VerificationMeta(
    'yearPublished',
  );
  @override
  late final GeneratedColumn<int> yearPublished = GeneratedColumn<int>(
    'year_published',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minPlayersMeta = const VerificationMeta(
    'minPlayers',
  );
  @override
  late final GeneratedColumn<int> minPlayers = GeneratedColumn<int>(
    'min_players',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxPlayersMeta = const VerificationMeta(
    'maxPlayers',
  );
  @override
  late final GeneratedColumn<int> maxPlayers = GeneratedColumn<int>(
    'max_players',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minPlayTimeMeta = const VerificationMeta(
    'minPlayTime',
  );
  @override
  late final GeneratedColumn<int> minPlayTime = GeneratedColumn<int>(
    'min_play_time',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxPlayTimeMeta = const VerificationMeta(
    'maxPlayTime',
  );
  @override
  late final GeneratedColumn<int> maxPlayTime = GeneratedColumn<int>(
    'max_play_time',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minAgeMeta = const VerificationMeta('minAge');
  @override
  late final GeneratedColumn<int> minAge = GeneratedColumn<int>(
    'min_age',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bayesAverageMeta = const VerificationMeta(
    'bayesAverage',
  );
  @override
  late final GeneratedColumn<double> bayesAverage = GeneratedColumn<double>(
    'bayes_average',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    imageUrl,
    thumbnailUrl,
    yearPublished,
    minPlayers,
    maxPlayers,
    minPlayTime,
    maxPlayTime,
    minAge,
    bayesAverage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'board_games';
  @override
  VerificationContext validateIntegrity(
    Insertable<BoardGame> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('thumbnail_url')) {
      context.handle(
        _thumbnailUrlMeta,
        thumbnailUrl.isAcceptableOrUnknown(
          data['thumbnail_url']!,
          _thumbnailUrlMeta,
        ),
      );
    }
    if (data.containsKey('year_published')) {
      context.handle(
        _yearPublishedMeta,
        yearPublished.isAcceptableOrUnknown(
          data['year_published']!,
          _yearPublishedMeta,
        ),
      );
    }
    if (data.containsKey('min_players')) {
      context.handle(
        _minPlayersMeta,
        minPlayers.isAcceptableOrUnknown(data['min_players']!, _minPlayersMeta),
      );
    }
    if (data.containsKey('max_players')) {
      context.handle(
        _maxPlayersMeta,
        maxPlayers.isAcceptableOrUnknown(data['max_players']!, _maxPlayersMeta),
      );
    }
    if (data.containsKey('min_play_time')) {
      context.handle(
        _minPlayTimeMeta,
        minPlayTime.isAcceptableOrUnknown(
          data['min_play_time']!,
          _minPlayTimeMeta,
        ),
      );
    }
    if (data.containsKey('max_play_time')) {
      context.handle(
        _maxPlayTimeMeta,
        maxPlayTime.isAcceptableOrUnknown(
          data['max_play_time']!,
          _maxPlayTimeMeta,
        ),
      );
    }
    if (data.containsKey('min_age')) {
      context.handle(
        _minAgeMeta,
        minAge.isAcceptableOrUnknown(data['min_age']!, _minAgeMeta),
      );
    }
    if (data.containsKey('bayes_average')) {
      context.handle(
        _bayesAverageMeta,
        bayesAverage.isAcceptableOrUnknown(
          data['bayes_average']!,
          _bayesAverageMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BoardGame map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BoardGame(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      thumbnailUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_url'],
      ),
      yearPublished: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year_published'],
      ),
      minPlayers: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_players'],
      ),
      maxPlayers: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_players'],
      ),
      minPlayTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_play_time'],
      ),
      maxPlayTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_play_time'],
      ),
      minAge: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_age'],
      ),
      bayesAverage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}bayes_average'],
      ),
    );
  }

  @override
  $BoardGamesTable createAlias(String alias) {
    return $BoardGamesTable(attachedDatabase, alias);
  }
}

class BoardGame extends DataClass implements Insertable<BoardGame> {
  final int id;
  final String? imageUrl;
  final String? thumbnailUrl;
  final int? yearPublished;
  final int? minPlayers;
  final int? maxPlayers;
  final int? minPlayTime;
  final int? maxPlayTime;
  final int? minAge;
  final double? bayesAverage;
  const BoardGame({
    required this.id,
    this.imageUrl,
    this.thumbnailUrl,
    this.yearPublished,
    this.minPlayers,
    this.maxPlayers,
    this.minPlayTime,
    this.maxPlayTime,
    this.minAge,
    this.bayesAverage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || thumbnailUrl != null) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl);
    }
    if (!nullToAbsent || yearPublished != null) {
      map['year_published'] = Variable<int>(yearPublished);
    }
    if (!nullToAbsent || minPlayers != null) {
      map['min_players'] = Variable<int>(minPlayers);
    }
    if (!nullToAbsent || maxPlayers != null) {
      map['max_players'] = Variable<int>(maxPlayers);
    }
    if (!nullToAbsent || minPlayTime != null) {
      map['min_play_time'] = Variable<int>(minPlayTime);
    }
    if (!nullToAbsent || maxPlayTime != null) {
      map['max_play_time'] = Variable<int>(maxPlayTime);
    }
    if (!nullToAbsent || minAge != null) {
      map['min_age'] = Variable<int>(minAge);
    }
    if (!nullToAbsent || bayesAverage != null) {
      map['bayes_average'] = Variable<double>(bayesAverage);
    }
    return map;
  }

  BoardGamesCompanion toCompanion(bool nullToAbsent) {
    return BoardGamesCompanion(
      id: Value(id),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      thumbnailUrl: thumbnailUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailUrl),
      yearPublished: yearPublished == null && nullToAbsent
          ? const Value.absent()
          : Value(yearPublished),
      minPlayers: minPlayers == null && nullToAbsent
          ? const Value.absent()
          : Value(minPlayers),
      maxPlayers: maxPlayers == null && nullToAbsent
          ? const Value.absent()
          : Value(maxPlayers),
      minPlayTime: minPlayTime == null && nullToAbsent
          ? const Value.absent()
          : Value(minPlayTime),
      maxPlayTime: maxPlayTime == null && nullToAbsent
          ? const Value.absent()
          : Value(maxPlayTime),
      minAge: minAge == null && nullToAbsent
          ? const Value.absent()
          : Value(minAge),
      bayesAverage: bayesAverage == null && nullToAbsent
          ? const Value.absent()
          : Value(bayesAverage),
    );
  }

  factory BoardGame.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BoardGame(
      id: serializer.fromJson<int>(json['id']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      thumbnailUrl: serializer.fromJson<String?>(json['thumbnailUrl']),
      yearPublished: serializer.fromJson<int?>(json['yearPublished']),
      minPlayers: serializer.fromJson<int?>(json['minPlayers']),
      maxPlayers: serializer.fromJson<int?>(json['maxPlayers']),
      minPlayTime: serializer.fromJson<int?>(json['minPlayTime']),
      maxPlayTime: serializer.fromJson<int?>(json['maxPlayTime']),
      minAge: serializer.fromJson<int?>(json['minAge']),
      bayesAverage: serializer.fromJson<double?>(json['bayesAverage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'thumbnailUrl': serializer.toJson<String?>(thumbnailUrl),
      'yearPublished': serializer.toJson<int?>(yearPublished),
      'minPlayers': serializer.toJson<int?>(minPlayers),
      'maxPlayers': serializer.toJson<int?>(maxPlayers),
      'minPlayTime': serializer.toJson<int?>(minPlayTime),
      'maxPlayTime': serializer.toJson<int?>(maxPlayTime),
      'minAge': serializer.toJson<int?>(minAge),
      'bayesAverage': serializer.toJson<double?>(bayesAverage),
    };
  }

  BoardGame copyWith({
    int? id,
    Value<String?> imageUrl = const Value.absent(),
    Value<String?> thumbnailUrl = const Value.absent(),
    Value<int?> yearPublished = const Value.absent(),
    Value<int?> minPlayers = const Value.absent(),
    Value<int?> maxPlayers = const Value.absent(),
    Value<int?> minPlayTime = const Value.absent(),
    Value<int?> maxPlayTime = const Value.absent(),
    Value<int?> minAge = const Value.absent(),
    Value<double?> bayesAverage = const Value.absent(),
  }) => BoardGame(
    id: id ?? this.id,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    thumbnailUrl: thumbnailUrl.present ? thumbnailUrl.value : this.thumbnailUrl,
    yearPublished: yearPublished.present
        ? yearPublished.value
        : this.yearPublished,
    minPlayers: minPlayers.present ? minPlayers.value : this.minPlayers,
    maxPlayers: maxPlayers.present ? maxPlayers.value : this.maxPlayers,
    minPlayTime: minPlayTime.present ? minPlayTime.value : this.minPlayTime,
    maxPlayTime: maxPlayTime.present ? maxPlayTime.value : this.maxPlayTime,
    minAge: minAge.present ? minAge.value : this.minAge,
    bayesAverage: bayesAverage.present ? bayesAverage.value : this.bayesAverage,
  );
  BoardGame copyWithCompanion(BoardGamesCompanion data) {
    return BoardGame(
      id: data.id.present ? data.id.value : this.id,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      thumbnailUrl: data.thumbnailUrl.present
          ? data.thumbnailUrl.value
          : this.thumbnailUrl,
      yearPublished: data.yearPublished.present
          ? data.yearPublished.value
          : this.yearPublished,
      minPlayers: data.minPlayers.present
          ? data.minPlayers.value
          : this.minPlayers,
      maxPlayers: data.maxPlayers.present
          ? data.maxPlayers.value
          : this.maxPlayers,
      minPlayTime: data.minPlayTime.present
          ? data.minPlayTime.value
          : this.minPlayTime,
      maxPlayTime: data.maxPlayTime.present
          ? data.maxPlayTime.value
          : this.maxPlayTime,
      minAge: data.minAge.present ? data.minAge.value : this.minAge,
      bayesAverage: data.bayesAverage.present
          ? data.bayesAverage.value
          : this.bayesAverage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BoardGame(')
          ..write('id: $id, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('yearPublished: $yearPublished, ')
          ..write('minPlayers: $minPlayers, ')
          ..write('maxPlayers: $maxPlayers, ')
          ..write('minPlayTime: $minPlayTime, ')
          ..write('maxPlayTime: $maxPlayTime, ')
          ..write('minAge: $minAge, ')
          ..write('bayesAverage: $bayesAverage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    imageUrl,
    thumbnailUrl,
    yearPublished,
    minPlayers,
    maxPlayers,
    minPlayTime,
    maxPlayTime,
    minAge,
    bayesAverage,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BoardGame &&
          other.id == this.id &&
          other.imageUrl == this.imageUrl &&
          other.thumbnailUrl == this.thumbnailUrl &&
          other.yearPublished == this.yearPublished &&
          other.minPlayers == this.minPlayers &&
          other.maxPlayers == this.maxPlayers &&
          other.minPlayTime == this.minPlayTime &&
          other.maxPlayTime == this.maxPlayTime &&
          other.minAge == this.minAge &&
          other.bayesAverage == this.bayesAverage);
}

class BoardGamesCompanion extends UpdateCompanion<BoardGame> {
  final Value<int> id;
  final Value<String?> imageUrl;
  final Value<String?> thumbnailUrl;
  final Value<int?> yearPublished;
  final Value<int?> minPlayers;
  final Value<int?> maxPlayers;
  final Value<int?> minPlayTime;
  final Value<int?> maxPlayTime;
  final Value<int?> minAge;
  final Value<double?> bayesAverage;
  const BoardGamesCompanion({
    this.id = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.yearPublished = const Value.absent(),
    this.minPlayers = const Value.absent(),
    this.maxPlayers = const Value.absent(),
    this.minPlayTime = const Value.absent(),
    this.maxPlayTime = const Value.absent(),
    this.minAge = const Value.absent(),
    this.bayesAverage = const Value.absent(),
  });
  BoardGamesCompanion.insert({
    this.id = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.yearPublished = const Value.absent(),
    this.minPlayers = const Value.absent(),
    this.maxPlayers = const Value.absent(),
    this.minPlayTime = const Value.absent(),
    this.maxPlayTime = const Value.absent(),
    this.minAge = const Value.absent(),
    this.bayesAverage = const Value.absent(),
  });
  static Insertable<BoardGame> custom({
    Expression<int>? id,
    Expression<String>? imageUrl,
    Expression<String>? thumbnailUrl,
    Expression<int>? yearPublished,
    Expression<int>? minPlayers,
    Expression<int>? maxPlayers,
    Expression<int>? minPlayTime,
    Expression<int>? maxPlayTime,
    Expression<int>? minAge,
    Expression<double>? bayesAverage,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (imageUrl != null) 'image_url': imageUrl,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (yearPublished != null) 'year_published': yearPublished,
      if (minPlayers != null) 'min_players': minPlayers,
      if (maxPlayers != null) 'max_players': maxPlayers,
      if (minPlayTime != null) 'min_play_time': minPlayTime,
      if (maxPlayTime != null) 'max_play_time': maxPlayTime,
      if (minAge != null) 'min_age': minAge,
      if (bayesAverage != null) 'bayes_average': bayesAverage,
    });
  }

  BoardGamesCompanion copyWith({
    Value<int>? id,
    Value<String?>? imageUrl,
    Value<String?>? thumbnailUrl,
    Value<int?>? yearPublished,
    Value<int?>? minPlayers,
    Value<int?>? maxPlayers,
    Value<int?>? minPlayTime,
    Value<int?>? maxPlayTime,
    Value<int?>? minAge,
    Value<double?>? bayesAverage,
  }) {
    return BoardGamesCompanion(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      yearPublished: yearPublished ?? this.yearPublished,
      minPlayers: minPlayers ?? this.minPlayers,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      minPlayTime: minPlayTime ?? this.minPlayTime,
      maxPlayTime: maxPlayTime ?? this.maxPlayTime,
      minAge: minAge ?? this.minAge,
      bayesAverage: bayesAverage ?? this.bayesAverage,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (thumbnailUrl.present) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl.value);
    }
    if (yearPublished.present) {
      map['year_published'] = Variable<int>(yearPublished.value);
    }
    if (minPlayers.present) {
      map['min_players'] = Variable<int>(minPlayers.value);
    }
    if (maxPlayers.present) {
      map['max_players'] = Variable<int>(maxPlayers.value);
    }
    if (minPlayTime.present) {
      map['min_play_time'] = Variable<int>(minPlayTime.value);
    }
    if (maxPlayTime.present) {
      map['max_play_time'] = Variable<int>(maxPlayTime.value);
    }
    if (minAge.present) {
      map['min_age'] = Variable<int>(minAge.value);
    }
    if (bayesAverage.present) {
      map['bayes_average'] = Variable<double>(bayesAverage.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BoardGamesCompanion(')
          ..write('id: $id, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('yearPublished: $yearPublished, ')
          ..write('minPlayers: $minPlayers, ')
          ..write('maxPlayers: $maxPlayers, ')
          ..write('minPlayTime: $minPlayTime, ')
          ..write('maxPlayTime: $maxPlayTime, ')
          ..write('minAge: $minAge, ')
          ..write('bayesAverage: $bayesAverage')
          ..write(')'))
        .toString();
  }
}

class $LocalizedNamesTable extends LocalizedNames
    with TableInfo<$LocalizedNamesTable, LocalizedName> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalizedNamesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _boardGameIdMeta = const VerificationMeta(
    'boardGameId',
  );
  @override
  late final GeneratedColumn<int> boardGameId = GeneratedColumn<int>(
    'board_game_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES board_games(id)',
  );
  static const VerificationMeta _versionIdMeta = const VerificationMeta(
    'versionId',
  );
  @override
  late final GeneratedColumn<int> versionId = GeneratedColumn<int>(
    'version_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES versions(id)',
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPrimaryMeta = const VerificationMeta(
    'isPrimary',
  );
  @override
  late final GeneratedColumn<bool> isPrimary = GeneratedColumn<bool>(
    'is_primary',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_primary" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    boardGameId,
    versionId,
    value,
    language,
    isPrimary,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'localized_names';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalizedName> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('board_game_id')) {
      context.handle(
        _boardGameIdMeta,
        boardGameId.isAcceptableOrUnknown(
          data['board_game_id']!,
          _boardGameIdMeta,
        ),
      );
    }
    if (data.containsKey('version_id')) {
      context.handle(
        _versionIdMeta,
        versionId.isAcceptableOrUnknown(data['version_id']!, _versionIdMeta),
      );
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    if (data.containsKey('is_primary')) {
      context.handle(
        _isPrimaryMeta,
        isPrimary.isAcceptableOrUnknown(data['is_primary']!, _isPrimaryMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalizedName map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalizedName(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      boardGameId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}board_game_id'],
      ),
      versionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version_id'],
      ),
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      ),
      isPrimary: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_primary'],
      )!,
    );
  }

  @override
  $LocalizedNamesTable createAlias(String alias) {
    return $LocalizedNamesTable(attachedDatabase, alias);
  }
}

class LocalizedName extends DataClass implements Insertable<LocalizedName> {
  final int id;
  final int? boardGameId;
  final int? versionId;
  final String value;
  final String? language;
  final bool isPrimary;
  const LocalizedName({
    required this.id,
    this.boardGameId,
    this.versionId,
    required this.value,
    this.language,
    required this.isPrimary,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || boardGameId != null) {
      map['board_game_id'] = Variable<int>(boardGameId);
    }
    if (!nullToAbsent || versionId != null) {
      map['version_id'] = Variable<int>(versionId);
    }
    map['value'] = Variable<String>(value);
    if (!nullToAbsent || language != null) {
      map['language'] = Variable<String>(language);
    }
    map['is_primary'] = Variable<bool>(isPrimary);
    return map;
  }

  LocalizedNamesCompanion toCompanion(bool nullToAbsent) {
    return LocalizedNamesCompanion(
      id: Value(id),
      boardGameId: boardGameId == null && nullToAbsent
          ? const Value.absent()
          : Value(boardGameId),
      versionId: versionId == null && nullToAbsent
          ? const Value.absent()
          : Value(versionId),
      value: Value(value),
      language: language == null && nullToAbsent
          ? const Value.absent()
          : Value(language),
      isPrimary: Value(isPrimary),
    );
  }

  factory LocalizedName.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalizedName(
      id: serializer.fromJson<int>(json['id']),
      boardGameId: serializer.fromJson<int?>(json['boardGameId']),
      versionId: serializer.fromJson<int?>(json['versionId']),
      value: serializer.fromJson<String>(json['value']),
      language: serializer.fromJson<String?>(json['language']),
      isPrimary: serializer.fromJson<bool>(json['isPrimary']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'boardGameId': serializer.toJson<int?>(boardGameId),
      'versionId': serializer.toJson<int?>(versionId),
      'value': serializer.toJson<String>(value),
      'language': serializer.toJson<String?>(language),
      'isPrimary': serializer.toJson<bool>(isPrimary),
    };
  }

  LocalizedName copyWith({
    int? id,
    Value<int?> boardGameId = const Value.absent(),
    Value<int?> versionId = const Value.absent(),
    String? value,
    Value<String?> language = const Value.absent(),
    bool? isPrimary,
  }) => LocalizedName(
    id: id ?? this.id,
    boardGameId: boardGameId.present ? boardGameId.value : this.boardGameId,
    versionId: versionId.present ? versionId.value : this.versionId,
    value: value ?? this.value,
    language: language.present ? language.value : this.language,
    isPrimary: isPrimary ?? this.isPrimary,
  );
  LocalizedName copyWithCompanion(LocalizedNamesCompanion data) {
    return LocalizedName(
      id: data.id.present ? data.id.value : this.id,
      boardGameId: data.boardGameId.present
          ? data.boardGameId.value
          : this.boardGameId,
      versionId: data.versionId.present ? data.versionId.value : this.versionId,
      value: data.value.present ? data.value.value : this.value,
      language: data.language.present ? data.language.value : this.language,
      isPrimary: data.isPrimary.present ? data.isPrimary.value : this.isPrimary,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalizedName(')
          ..write('id: $id, ')
          ..write('boardGameId: $boardGameId, ')
          ..write('versionId: $versionId, ')
          ..write('value: $value, ')
          ..write('language: $language, ')
          ..write('isPrimary: $isPrimary')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, boardGameId, versionId, value, language, isPrimary);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalizedName &&
          other.id == this.id &&
          other.boardGameId == this.boardGameId &&
          other.versionId == this.versionId &&
          other.value == this.value &&
          other.language == this.language &&
          other.isPrimary == this.isPrimary);
}

class LocalizedNamesCompanion extends UpdateCompanion<LocalizedName> {
  final Value<int> id;
  final Value<int?> boardGameId;
  final Value<int?> versionId;
  final Value<String> value;
  final Value<String?> language;
  final Value<bool> isPrimary;
  const LocalizedNamesCompanion({
    this.id = const Value.absent(),
    this.boardGameId = const Value.absent(),
    this.versionId = const Value.absent(),
    this.value = const Value.absent(),
    this.language = const Value.absent(),
    this.isPrimary = const Value.absent(),
  });
  LocalizedNamesCompanion.insert({
    this.id = const Value.absent(),
    this.boardGameId = const Value.absent(),
    this.versionId = const Value.absent(),
    required String value,
    this.language = const Value.absent(),
    this.isPrimary = const Value.absent(),
  }) : value = Value(value);
  static Insertable<LocalizedName> custom({
    Expression<int>? id,
    Expression<int>? boardGameId,
    Expression<int>? versionId,
    Expression<String>? value,
    Expression<String>? language,
    Expression<bool>? isPrimary,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (boardGameId != null) 'board_game_id': boardGameId,
      if (versionId != null) 'version_id': versionId,
      if (value != null) 'value': value,
      if (language != null) 'language': language,
      if (isPrimary != null) 'is_primary': isPrimary,
    });
  }

  LocalizedNamesCompanion copyWith({
    Value<int>? id,
    Value<int?>? boardGameId,
    Value<int?>? versionId,
    Value<String>? value,
    Value<String?>? language,
    Value<bool>? isPrimary,
  }) {
    return LocalizedNamesCompanion(
      id: id ?? this.id,
      boardGameId: boardGameId ?? this.boardGameId,
      versionId: versionId ?? this.versionId,
      value: value ?? this.value,
      language: language ?? this.language,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (boardGameId.present) {
      map['board_game_id'] = Variable<int>(boardGameId.value);
    }
    if (versionId.present) {
      map['version_id'] = Variable<int>(versionId.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (isPrimary.present) {
      map['is_primary'] = Variable<bool>(isPrimary.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalizedNamesCompanion(')
          ..write('id: $id, ')
          ..write('boardGameId: $boardGameId, ')
          ..write('versionId: $versionId, ')
          ..write('value: $value, ')
          ..write('language: $language, ')
          ..write('isPrimary: $isPrimary')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VersionsTable versions = $VersionsTable(this);
  late final $CollectionItemsTable collectionItems = $CollectionItemsTable(
    this,
  );
  late final $BoardGamesTable boardGames = $BoardGamesTable(this);
  late final $LocalizedNamesTable localizedNames = $LocalizedNamesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    versions,
    collectionItems,
    boardGames,
    localizedNames,
  ];
}

typedef $$VersionsTableCreateCompanionBuilder =
    VersionsCompanion Function({
      Value<int> id,
      required int bggVersionId,
      required String name,
      Value<int?> year,
    });
typedef $$VersionsTableUpdateCompanionBuilder =
    VersionsCompanion Function({
      Value<int> id,
      Value<int> bggVersionId,
      Value<String> name,
      Value<int?> year,
    });

final class $$VersionsTableReferences
    extends BaseReferences<_$AppDatabase, $VersionsTable, Version> {
  $$VersionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CollectionItemsTable, List<CollectionItem>>
  _collectionItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.collectionItems,
    aliasName: $_aliasNameGenerator(
      db.versions.id,
      db.collectionItems.versionId,
    ),
  );

  $$CollectionItemsTableProcessedTableManager get collectionItemsRefs {
    final manager = $$CollectionItemsTableTableManager(
      $_db,
      $_db.collectionItems,
    ).filter((f) => f.versionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _collectionItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LocalizedNamesTable, List<LocalizedName>>
  _localizedNamesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.localizedNames,
    aliasName: $_aliasNameGenerator(
      db.versions.id,
      db.localizedNames.versionId,
    ),
  );

  $$LocalizedNamesTableProcessedTableManager get localizedNamesRefs {
    final manager = $$LocalizedNamesTableTableManager(
      $_db,
      $_db.localizedNames,
    ).filter((f) => f.versionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_localizedNamesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VersionsTableFilterComposer
    extends Composer<_$AppDatabase, $VersionsTable> {
  $$VersionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bggVersionId => $composableBuilder(
    column: $table.bggVersionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> collectionItemsRefs(
    Expression<bool> Function($$CollectionItemsTableFilterComposer f) f,
  ) {
    final $$CollectionItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.collectionItems,
      getReferencedColumn: (t) => t.versionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionItemsTableFilterComposer(
            $db: $db,
            $table: $db.collectionItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> localizedNamesRefs(
    Expression<bool> Function($$LocalizedNamesTableFilterComposer f) f,
  ) {
    final $$LocalizedNamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localizedNames,
      getReferencedColumn: (t) => t.versionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalizedNamesTableFilterComposer(
            $db: $db,
            $table: $db.localizedNames,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VersionsTableOrderingComposer
    extends Composer<_$AppDatabase, $VersionsTable> {
  $$VersionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bggVersionId => $composableBuilder(
    column: $table.bggVersionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VersionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VersionsTable> {
  $$VersionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get bggVersionId => $composableBuilder(
    column: $table.bggVersionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  Expression<T> collectionItemsRefs<T extends Object>(
    Expression<T> Function($$CollectionItemsTableAnnotationComposer a) f,
  ) {
    final $$CollectionItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.collectionItems,
      getReferencedColumn: (t) => t.versionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.collectionItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> localizedNamesRefs<T extends Object>(
    Expression<T> Function($$LocalizedNamesTableAnnotationComposer a) f,
  ) {
    final $$LocalizedNamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localizedNames,
      getReferencedColumn: (t) => t.versionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalizedNamesTableAnnotationComposer(
            $db: $db,
            $table: $db.localizedNames,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VersionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VersionsTable,
          Version,
          $$VersionsTableFilterComposer,
          $$VersionsTableOrderingComposer,
          $$VersionsTableAnnotationComposer,
          $$VersionsTableCreateCompanionBuilder,
          $$VersionsTableUpdateCompanionBuilder,
          (Version, $$VersionsTableReferences),
          Version,
          PrefetchHooks Function({
            bool collectionItemsRefs,
            bool localizedNamesRefs,
          })
        > {
  $$VersionsTableTableManager(_$AppDatabase db, $VersionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VersionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VersionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VersionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> bggVersionId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> year = const Value.absent(),
              }) => VersionsCompanion(
                id: id,
                bggVersionId: bggVersionId,
                name: name,
                year: year,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int bggVersionId,
                required String name,
                Value<int?> year = const Value.absent(),
              }) => VersionsCompanion.insert(
                id: id,
                bggVersionId: bggVersionId,
                name: name,
                year: year,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VersionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({collectionItemsRefs = false, localizedNamesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (collectionItemsRefs) db.collectionItems,
                    if (localizedNamesRefs) db.localizedNames,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (collectionItemsRefs)
                        await $_getPrefetchedData<
                          Version,
                          $VersionsTable,
                          CollectionItem
                        >(
                          currentTable: table,
                          referencedTable: $$VersionsTableReferences
                              ._collectionItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VersionsTableReferences(
                                db,
                                table,
                                p0,
                              ).collectionItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.versionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (localizedNamesRefs)
                        await $_getPrefetchedData<
                          Version,
                          $VersionsTable,
                          LocalizedName
                        >(
                          currentTable: table,
                          referencedTable: $$VersionsTableReferences
                              ._localizedNamesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VersionsTableReferences(
                                db,
                                table,
                                p0,
                              ).localizedNamesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.versionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$VersionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VersionsTable,
      Version,
      $$VersionsTableFilterComposer,
      $$VersionsTableOrderingComposer,
      $$VersionsTableAnnotationComposer,
      $$VersionsTableCreateCompanionBuilder,
      $$VersionsTableUpdateCompanionBuilder,
      (Version, $$VersionsTableReferences),
      Version,
      PrefetchHooks Function({
        bool collectionItemsRefs,
        bool localizedNamesRefs,
      })
    >;
typedef $$CollectionItemsTableCreateCompanionBuilder =
    CollectionItemsCompanion Function({
      required int thingId,
      required int collId,
      Value<String?> primaryName,
      Value<String?> thumbnailLocalPath,
      Value<String?> customName,
      Value<String?> customImageUrl,
      Value<String?> thumbnailUrl,
      Value<String?> imageUrl,
      Value<int?> yearPublished,
      Value<int?> minPlayers,
      Value<int?> maxPlayers,
      Value<int?> minPlayTime,
      Value<int?> maxPlayTime,
      Value<int?> minAge,
      Value<double?> bayesAverage,
      Value<double?> ownRating,
      Value<int?> numPlays,
      Value<int?> bggRank,
      Value<int?> geekRatingUserCount,
      Value<bool> isOwned,
      Value<bool> isPreordered,
      Value<bool> isWishlisted,
      Value<bool> isWantToPlay,
      Value<bool> isWantToBuy,
      Value<bool> isPrevOwned,
      Value<bool> isPlayed,
      Value<bool> isRated,
      Value<bool> isForTrade,
      Value<bool> isWantInTrade,
      Value<bool> hasComment,
      Value<int?> versionId,
      Value<int> rowid,
    });
typedef $$CollectionItemsTableUpdateCompanionBuilder =
    CollectionItemsCompanion Function({
      Value<int> thingId,
      Value<int> collId,
      Value<String?> primaryName,
      Value<String?> thumbnailLocalPath,
      Value<String?> customName,
      Value<String?> customImageUrl,
      Value<String?> thumbnailUrl,
      Value<String?> imageUrl,
      Value<int?> yearPublished,
      Value<int?> minPlayers,
      Value<int?> maxPlayers,
      Value<int?> minPlayTime,
      Value<int?> maxPlayTime,
      Value<int?> minAge,
      Value<double?> bayesAverage,
      Value<double?> ownRating,
      Value<int?> numPlays,
      Value<int?> bggRank,
      Value<int?> geekRatingUserCount,
      Value<bool> isOwned,
      Value<bool> isPreordered,
      Value<bool> isWishlisted,
      Value<bool> isWantToPlay,
      Value<bool> isWantToBuy,
      Value<bool> isPrevOwned,
      Value<bool> isPlayed,
      Value<bool> isRated,
      Value<bool> isForTrade,
      Value<bool> isWantInTrade,
      Value<bool> hasComment,
      Value<int?> versionId,
      Value<int> rowid,
    });

final class $$CollectionItemsTableReferences
    extends
        BaseReferences<_$AppDatabase, $CollectionItemsTable, CollectionItem> {
  $$CollectionItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $VersionsTable _versionIdTable(_$AppDatabase db) =>
      db.versions.createAlias(
        $_aliasNameGenerator(db.collectionItems.versionId, db.versions.id),
      );

  $$VersionsTableProcessedTableManager? get versionId {
    final $_column = $_itemColumn<int>('version_id');
    if ($_column == null) return null;
    final manager = $$VersionsTableTableManager(
      $_db,
      $_db.versions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_versionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CollectionItemsTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionItemsTable> {
  $$CollectionItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get thingId => $composableBuilder(
    column: $table.thingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get collId => $composableBuilder(
    column: $table.collId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get primaryName => $composableBuilder(
    column: $table.primaryName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailLocalPath => $composableBuilder(
    column: $table.thumbnailLocalPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customImageUrl => $composableBuilder(
    column: $table.customImageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get yearPublished => $composableBuilder(
    column: $table.yearPublished,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minPlayers => $composableBuilder(
    column: $table.minPlayers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxPlayers => $composableBuilder(
    column: $table.maxPlayers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minPlayTime => $composableBuilder(
    column: $table.minPlayTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxPlayTime => $composableBuilder(
    column: $table.maxPlayTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minAge => $composableBuilder(
    column: $table.minAge,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bayesAverage => $composableBuilder(
    column: $table.bayesAverage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ownRating => $composableBuilder(
    column: $table.ownRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get numPlays => $composableBuilder(
    column: $table.numPlays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bggRank => $composableBuilder(
    column: $table.bggRank,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get geekRatingUserCount => $composableBuilder(
    column: $table.geekRatingUserCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOwned => $composableBuilder(
    column: $table.isOwned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPreordered => $composableBuilder(
    column: $table.isPreordered,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isWishlisted => $composableBuilder(
    column: $table.isWishlisted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isWantToPlay => $composableBuilder(
    column: $table.isWantToPlay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isWantToBuy => $composableBuilder(
    column: $table.isWantToBuy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPrevOwned => $composableBuilder(
    column: $table.isPrevOwned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPlayed => $composableBuilder(
    column: $table.isPlayed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRated => $composableBuilder(
    column: $table.isRated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isForTrade => $composableBuilder(
    column: $table.isForTrade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isWantInTrade => $composableBuilder(
    column: $table.isWantInTrade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasComment => $composableBuilder(
    column: $table.hasComment,
    builder: (column) => ColumnFilters(column),
  );

  $$VersionsTableFilterComposer get versionId {
    final $$VersionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.versionId,
      referencedTable: $db.versions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VersionsTableFilterComposer(
            $db: $db,
            $table: $db.versions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CollectionItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionItemsTable> {
  $$CollectionItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get thingId => $composableBuilder(
    column: $table.thingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get collId => $composableBuilder(
    column: $table.collId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryName => $composableBuilder(
    column: $table.primaryName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailLocalPath => $composableBuilder(
    column: $table.thumbnailLocalPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customImageUrl => $composableBuilder(
    column: $table.customImageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get yearPublished => $composableBuilder(
    column: $table.yearPublished,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minPlayers => $composableBuilder(
    column: $table.minPlayers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxPlayers => $composableBuilder(
    column: $table.maxPlayers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minPlayTime => $composableBuilder(
    column: $table.minPlayTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxPlayTime => $composableBuilder(
    column: $table.maxPlayTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minAge => $composableBuilder(
    column: $table.minAge,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bayesAverage => $composableBuilder(
    column: $table.bayesAverage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ownRating => $composableBuilder(
    column: $table.ownRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get numPlays => $composableBuilder(
    column: $table.numPlays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bggRank => $composableBuilder(
    column: $table.bggRank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get geekRatingUserCount => $composableBuilder(
    column: $table.geekRatingUserCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOwned => $composableBuilder(
    column: $table.isOwned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPreordered => $composableBuilder(
    column: $table.isPreordered,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isWishlisted => $composableBuilder(
    column: $table.isWishlisted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isWantToPlay => $composableBuilder(
    column: $table.isWantToPlay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isWantToBuy => $composableBuilder(
    column: $table.isWantToBuy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPrevOwned => $composableBuilder(
    column: $table.isPrevOwned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPlayed => $composableBuilder(
    column: $table.isPlayed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRated => $composableBuilder(
    column: $table.isRated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isForTrade => $composableBuilder(
    column: $table.isForTrade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isWantInTrade => $composableBuilder(
    column: $table.isWantInTrade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasComment => $composableBuilder(
    column: $table.hasComment,
    builder: (column) => ColumnOrderings(column),
  );

  $$VersionsTableOrderingComposer get versionId {
    final $$VersionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.versionId,
      referencedTable: $db.versions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VersionsTableOrderingComposer(
            $db: $db,
            $table: $db.versions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CollectionItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionItemsTable> {
  $$CollectionItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get thingId =>
      $composableBuilder(column: $table.thingId, builder: (column) => column);

  GeneratedColumn<int> get collId =>
      $composableBuilder(column: $table.collId, builder: (column) => column);

  GeneratedColumn<String> get primaryName => $composableBuilder(
    column: $table.primaryName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get thumbnailLocalPath => $composableBuilder(
    column: $table.thumbnailLocalPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customImageUrl => $composableBuilder(
    column: $table.customImageUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<int> get yearPublished => $composableBuilder(
    column: $table.yearPublished,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minPlayers => $composableBuilder(
    column: $table.minPlayers,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxPlayers => $composableBuilder(
    column: $table.maxPlayers,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minPlayTime => $composableBuilder(
    column: $table.minPlayTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxPlayTime => $composableBuilder(
    column: $table.maxPlayTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minAge =>
      $composableBuilder(column: $table.minAge, builder: (column) => column);

  GeneratedColumn<double> get bayesAverage => $composableBuilder(
    column: $table.bayesAverage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ownRating =>
      $composableBuilder(column: $table.ownRating, builder: (column) => column);

  GeneratedColumn<int> get numPlays =>
      $composableBuilder(column: $table.numPlays, builder: (column) => column);

  GeneratedColumn<int> get bggRank =>
      $composableBuilder(column: $table.bggRank, builder: (column) => column);

  GeneratedColumn<int> get geekRatingUserCount => $composableBuilder(
    column: $table.geekRatingUserCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isOwned =>
      $composableBuilder(column: $table.isOwned, builder: (column) => column);

  GeneratedColumn<bool> get isPreordered => $composableBuilder(
    column: $table.isPreordered,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isWishlisted => $composableBuilder(
    column: $table.isWishlisted,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isWantToPlay => $composableBuilder(
    column: $table.isWantToPlay,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isWantToBuy => $composableBuilder(
    column: $table.isWantToBuy,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPrevOwned => $composableBuilder(
    column: $table.isPrevOwned,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPlayed =>
      $composableBuilder(column: $table.isPlayed, builder: (column) => column);

  GeneratedColumn<bool> get isRated =>
      $composableBuilder(column: $table.isRated, builder: (column) => column);

  GeneratedColumn<bool> get isForTrade => $composableBuilder(
    column: $table.isForTrade,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isWantInTrade => $composableBuilder(
    column: $table.isWantInTrade,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasComment => $composableBuilder(
    column: $table.hasComment,
    builder: (column) => column,
  );

  $$VersionsTableAnnotationComposer get versionId {
    final $$VersionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.versionId,
      referencedTable: $db.versions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VersionsTableAnnotationComposer(
            $db: $db,
            $table: $db.versions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CollectionItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollectionItemsTable,
          CollectionItem,
          $$CollectionItemsTableFilterComposer,
          $$CollectionItemsTableOrderingComposer,
          $$CollectionItemsTableAnnotationComposer,
          $$CollectionItemsTableCreateCompanionBuilder,
          $$CollectionItemsTableUpdateCompanionBuilder,
          (CollectionItem, $$CollectionItemsTableReferences),
          CollectionItem,
          PrefetchHooks Function({bool versionId})
        > {
  $$CollectionItemsTableTableManager(
    _$AppDatabase db,
    $CollectionItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> thingId = const Value.absent(),
                Value<int> collId = const Value.absent(),
                Value<String?> primaryName = const Value.absent(),
                Value<String?> thumbnailLocalPath = const Value.absent(),
                Value<String?> customName = const Value.absent(),
                Value<String?> customImageUrl = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<int?> yearPublished = const Value.absent(),
                Value<int?> minPlayers = const Value.absent(),
                Value<int?> maxPlayers = const Value.absent(),
                Value<int?> minPlayTime = const Value.absent(),
                Value<int?> maxPlayTime = const Value.absent(),
                Value<int?> minAge = const Value.absent(),
                Value<double?> bayesAverage = const Value.absent(),
                Value<double?> ownRating = const Value.absent(),
                Value<int?> numPlays = const Value.absent(),
                Value<int?> bggRank = const Value.absent(),
                Value<int?> geekRatingUserCount = const Value.absent(),
                Value<bool> isOwned = const Value.absent(),
                Value<bool> isPreordered = const Value.absent(),
                Value<bool> isWishlisted = const Value.absent(),
                Value<bool> isWantToPlay = const Value.absent(),
                Value<bool> isWantToBuy = const Value.absent(),
                Value<bool> isPrevOwned = const Value.absent(),
                Value<bool> isPlayed = const Value.absent(),
                Value<bool> isRated = const Value.absent(),
                Value<bool> isForTrade = const Value.absent(),
                Value<bool> isWantInTrade = const Value.absent(),
                Value<bool> hasComment = const Value.absent(),
                Value<int?> versionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionItemsCompanion(
                thingId: thingId,
                collId: collId,
                primaryName: primaryName,
                thumbnailLocalPath: thumbnailLocalPath,
                customName: customName,
                customImageUrl: customImageUrl,
                thumbnailUrl: thumbnailUrl,
                imageUrl: imageUrl,
                yearPublished: yearPublished,
                minPlayers: minPlayers,
                maxPlayers: maxPlayers,
                minPlayTime: minPlayTime,
                maxPlayTime: maxPlayTime,
                minAge: minAge,
                bayesAverage: bayesAverage,
                ownRating: ownRating,
                numPlays: numPlays,
                bggRank: bggRank,
                geekRatingUserCount: geekRatingUserCount,
                isOwned: isOwned,
                isPreordered: isPreordered,
                isWishlisted: isWishlisted,
                isWantToPlay: isWantToPlay,
                isWantToBuy: isWantToBuy,
                isPrevOwned: isPrevOwned,
                isPlayed: isPlayed,
                isRated: isRated,
                isForTrade: isForTrade,
                isWantInTrade: isWantInTrade,
                hasComment: hasComment,
                versionId: versionId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int thingId,
                required int collId,
                Value<String?> primaryName = const Value.absent(),
                Value<String?> thumbnailLocalPath = const Value.absent(),
                Value<String?> customName = const Value.absent(),
                Value<String?> customImageUrl = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<int?> yearPublished = const Value.absent(),
                Value<int?> minPlayers = const Value.absent(),
                Value<int?> maxPlayers = const Value.absent(),
                Value<int?> minPlayTime = const Value.absent(),
                Value<int?> maxPlayTime = const Value.absent(),
                Value<int?> minAge = const Value.absent(),
                Value<double?> bayesAverage = const Value.absent(),
                Value<double?> ownRating = const Value.absent(),
                Value<int?> numPlays = const Value.absent(),
                Value<int?> bggRank = const Value.absent(),
                Value<int?> geekRatingUserCount = const Value.absent(),
                Value<bool> isOwned = const Value.absent(),
                Value<bool> isPreordered = const Value.absent(),
                Value<bool> isWishlisted = const Value.absent(),
                Value<bool> isWantToPlay = const Value.absent(),
                Value<bool> isWantToBuy = const Value.absent(),
                Value<bool> isPrevOwned = const Value.absent(),
                Value<bool> isPlayed = const Value.absent(),
                Value<bool> isRated = const Value.absent(),
                Value<bool> isForTrade = const Value.absent(),
                Value<bool> isWantInTrade = const Value.absent(),
                Value<bool> hasComment = const Value.absent(),
                Value<int?> versionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionItemsCompanion.insert(
                thingId: thingId,
                collId: collId,
                primaryName: primaryName,
                thumbnailLocalPath: thumbnailLocalPath,
                customName: customName,
                customImageUrl: customImageUrl,
                thumbnailUrl: thumbnailUrl,
                imageUrl: imageUrl,
                yearPublished: yearPublished,
                minPlayers: minPlayers,
                maxPlayers: maxPlayers,
                minPlayTime: minPlayTime,
                maxPlayTime: maxPlayTime,
                minAge: minAge,
                bayesAverage: bayesAverage,
                ownRating: ownRating,
                numPlays: numPlays,
                bggRank: bggRank,
                geekRatingUserCount: geekRatingUserCount,
                isOwned: isOwned,
                isPreordered: isPreordered,
                isWishlisted: isWishlisted,
                isWantToPlay: isWantToPlay,
                isWantToBuy: isWantToBuy,
                isPrevOwned: isPrevOwned,
                isPlayed: isPlayed,
                isRated: isRated,
                isForTrade: isForTrade,
                isWantInTrade: isWantInTrade,
                hasComment: hasComment,
                versionId: versionId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CollectionItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({versionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (versionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.versionId,
                                referencedTable:
                                    $$CollectionItemsTableReferences
                                        ._versionIdTable(db),
                                referencedColumn:
                                    $$CollectionItemsTableReferences
                                        ._versionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CollectionItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollectionItemsTable,
      CollectionItem,
      $$CollectionItemsTableFilterComposer,
      $$CollectionItemsTableOrderingComposer,
      $$CollectionItemsTableAnnotationComposer,
      $$CollectionItemsTableCreateCompanionBuilder,
      $$CollectionItemsTableUpdateCompanionBuilder,
      (CollectionItem, $$CollectionItemsTableReferences),
      CollectionItem,
      PrefetchHooks Function({bool versionId})
    >;
typedef $$BoardGamesTableCreateCompanionBuilder =
    BoardGamesCompanion Function({
      Value<int> id,
      Value<String?> imageUrl,
      Value<String?> thumbnailUrl,
      Value<int?> yearPublished,
      Value<int?> minPlayers,
      Value<int?> maxPlayers,
      Value<int?> minPlayTime,
      Value<int?> maxPlayTime,
      Value<int?> minAge,
      Value<double?> bayesAverage,
    });
typedef $$BoardGamesTableUpdateCompanionBuilder =
    BoardGamesCompanion Function({
      Value<int> id,
      Value<String?> imageUrl,
      Value<String?> thumbnailUrl,
      Value<int?> yearPublished,
      Value<int?> minPlayers,
      Value<int?> maxPlayers,
      Value<int?> minPlayTime,
      Value<int?> maxPlayTime,
      Value<int?> minAge,
      Value<double?> bayesAverage,
    });

final class $$BoardGamesTableReferences
    extends BaseReferences<_$AppDatabase, $BoardGamesTable, BoardGame> {
  $$BoardGamesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LocalizedNamesTable, List<LocalizedName>>
  _localizedNamesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.localizedNames,
    aliasName: $_aliasNameGenerator(
      db.boardGames.id,
      db.localizedNames.boardGameId,
    ),
  );

  $$LocalizedNamesTableProcessedTableManager get localizedNamesRefs {
    final manager = $$LocalizedNamesTableTableManager(
      $_db,
      $_db.localizedNames,
    ).filter((f) => f.boardGameId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_localizedNamesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BoardGamesTableFilterComposer
    extends Composer<_$AppDatabase, $BoardGamesTable> {
  $$BoardGamesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get yearPublished => $composableBuilder(
    column: $table.yearPublished,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minPlayers => $composableBuilder(
    column: $table.minPlayers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxPlayers => $composableBuilder(
    column: $table.maxPlayers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minPlayTime => $composableBuilder(
    column: $table.minPlayTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxPlayTime => $composableBuilder(
    column: $table.maxPlayTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minAge => $composableBuilder(
    column: $table.minAge,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bayesAverage => $composableBuilder(
    column: $table.bayesAverage,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> localizedNamesRefs(
    Expression<bool> Function($$LocalizedNamesTableFilterComposer f) f,
  ) {
    final $$LocalizedNamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localizedNames,
      getReferencedColumn: (t) => t.boardGameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalizedNamesTableFilterComposer(
            $db: $db,
            $table: $db.localizedNames,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BoardGamesTableOrderingComposer
    extends Composer<_$AppDatabase, $BoardGamesTable> {
  $$BoardGamesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get yearPublished => $composableBuilder(
    column: $table.yearPublished,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minPlayers => $composableBuilder(
    column: $table.minPlayers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxPlayers => $composableBuilder(
    column: $table.maxPlayers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minPlayTime => $composableBuilder(
    column: $table.minPlayTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxPlayTime => $composableBuilder(
    column: $table.maxPlayTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minAge => $composableBuilder(
    column: $table.minAge,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bayesAverage => $composableBuilder(
    column: $table.bayesAverage,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BoardGamesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BoardGamesTable> {
  $$BoardGamesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => column,
  );

  GeneratedColumn<int> get yearPublished => $composableBuilder(
    column: $table.yearPublished,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minPlayers => $composableBuilder(
    column: $table.minPlayers,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxPlayers => $composableBuilder(
    column: $table.maxPlayers,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minPlayTime => $composableBuilder(
    column: $table.minPlayTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxPlayTime => $composableBuilder(
    column: $table.maxPlayTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minAge =>
      $composableBuilder(column: $table.minAge, builder: (column) => column);

  GeneratedColumn<double> get bayesAverage => $composableBuilder(
    column: $table.bayesAverage,
    builder: (column) => column,
  );

  Expression<T> localizedNamesRefs<T extends Object>(
    Expression<T> Function($$LocalizedNamesTableAnnotationComposer a) f,
  ) {
    final $$LocalizedNamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localizedNames,
      getReferencedColumn: (t) => t.boardGameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalizedNamesTableAnnotationComposer(
            $db: $db,
            $table: $db.localizedNames,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BoardGamesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BoardGamesTable,
          BoardGame,
          $$BoardGamesTableFilterComposer,
          $$BoardGamesTableOrderingComposer,
          $$BoardGamesTableAnnotationComposer,
          $$BoardGamesTableCreateCompanionBuilder,
          $$BoardGamesTableUpdateCompanionBuilder,
          (BoardGame, $$BoardGamesTableReferences),
          BoardGame,
          PrefetchHooks Function({bool localizedNamesRefs})
        > {
  $$BoardGamesTableTableManager(_$AppDatabase db, $BoardGamesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BoardGamesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BoardGamesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BoardGamesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<int?> yearPublished = const Value.absent(),
                Value<int?> minPlayers = const Value.absent(),
                Value<int?> maxPlayers = const Value.absent(),
                Value<int?> minPlayTime = const Value.absent(),
                Value<int?> maxPlayTime = const Value.absent(),
                Value<int?> minAge = const Value.absent(),
                Value<double?> bayesAverage = const Value.absent(),
              }) => BoardGamesCompanion(
                id: id,
                imageUrl: imageUrl,
                thumbnailUrl: thumbnailUrl,
                yearPublished: yearPublished,
                minPlayers: minPlayers,
                maxPlayers: maxPlayers,
                minPlayTime: minPlayTime,
                maxPlayTime: maxPlayTime,
                minAge: minAge,
                bayesAverage: bayesAverage,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<int?> yearPublished = const Value.absent(),
                Value<int?> minPlayers = const Value.absent(),
                Value<int?> maxPlayers = const Value.absent(),
                Value<int?> minPlayTime = const Value.absent(),
                Value<int?> maxPlayTime = const Value.absent(),
                Value<int?> minAge = const Value.absent(),
                Value<double?> bayesAverage = const Value.absent(),
              }) => BoardGamesCompanion.insert(
                id: id,
                imageUrl: imageUrl,
                thumbnailUrl: thumbnailUrl,
                yearPublished: yearPublished,
                minPlayers: minPlayers,
                maxPlayers: maxPlayers,
                minPlayTime: minPlayTime,
                maxPlayTime: maxPlayTime,
                minAge: minAge,
                bayesAverage: bayesAverage,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BoardGamesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({localizedNamesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (localizedNamesRefs) db.localizedNames,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (localizedNamesRefs)
                    await $_getPrefetchedData<
                      BoardGame,
                      $BoardGamesTable,
                      LocalizedName
                    >(
                      currentTable: table,
                      referencedTable: $$BoardGamesTableReferences
                          ._localizedNamesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$BoardGamesTableReferences(
                            db,
                            table,
                            p0,
                          ).localizedNamesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.boardGameId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$BoardGamesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BoardGamesTable,
      BoardGame,
      $$BoardGamesTableFilterComposer,
      $$BoardGamesTableOrderingComposer,
      $$BoardGamesTableAnnotationComposer,
      $$BoardGamesTableCreateCompanionBuilder,
      $$BoardGamesTableUpdateCompanionBuilder,
      (BoardGame, $$BoardGamesTableReferences),
      BoardGame,
      PrefetchHooks Function({bool localizedNamesRefs})
    >;
typedef $$LocalizedNamesTableCreateCompanionBuilder =
    LocalizedNamesCompanion Function({
      Value<int> id,
      Value<int?> boardGameId,
      Value<int?> versionId,
      required String value,
      Value<String?> language,
      Value<bool> isPrimary,
    });
typedef $$LocalizedNamesTableUpdateCompanionBuilder =
    LocalizedNamesCompanion Function({
      Value<int> id,
      Value<int?> boardGameId,
      Value<int?> versionId,
      Value<String> value,
      Value<String?> language,
      Value<bool> isPrimary,
    });

final class $$LocalizedNamesTableReferences
    extends BaseReferences<_$AppDatabase, $LocalizedNamesTable, LocalizedName> {
  $$LocalizedNamesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BoardGamesTable _boardGameIdTable(_$AppDatabase db) =>
      db.boardGames.createAlias(
        $_aliasNameGenerator(db.localizedNames.boardGameId, db.boardGames.id),
      );

  $$BoardGamesTableProcessedTableManager? get boardGameId {
    final $_column = $_itemColumn<int>('board_game_id');
    if ($_column == null) return null;
    final manager = $$BoardGamesTableTableManager(
      $_db,
      $_db.boardGames,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_boardGameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $VersionsTable _versionIdTable(_$AppDatabase db) =>
      db.versions.createAlias(
        $_aliasNameGenerator(db.localizedNames.versionId, db.versions.id),
      );

  $$VersionsTableProcessedTableManager? get versionId {
    final $_column = $_itemColumn<int>('version_id');
    if ($_column == null) return null;
    final manager = $$VersionsTableTableManager(
      $_db,
      $_db.versions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_versionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LocalizedNamesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalizedNamesTable> {
  $$LocalizedNamesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnFilters(column),
  );

  $$BoardGamesTableFilterComposer get boardGameId {
    final $$BoardGamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.boardGameId,
      referencedTable: $db.boardGames,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BoardGamesTableFilterComposer(
            $db: $db,
            $table: $db.boardGames,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VersionsTableFilterComposer get versionId {
    final $$VersionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.versionId,
      referencedTable: $db.versions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VersionsTableFilterComposer(
            $db: $db,
            $table: $db.versions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalizedNamesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalizedNamesTable> {
  $$LocalizedNamesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnOrderings(column),
  );

  $$BoardGamesTableOrderingComposer get boardGameId {
    final $$BoardGamesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.boardGameId,
      referencedTable: $db.boardGames,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BoardGamesTableOrderingComposer(
            $db: $db,
            $table: $db.boardGames,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VersionsTableOrderingComposer get versionId {
    final $$VersionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.versionId,
      referencedTable: $db.versions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VersionsTableOrderingComposer(
            $db: $db,
            $table: $db.versions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalizedNamesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalizedNamesTable> {
  $$LocalizedNamesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<bool> get isPrimary =>
      $composableBuilder(column: $table.isPrimary, builder: (column) => column);

  $$BoardGamesTableAnnotationComposer get boardGameId {
    final $$BoardGamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.boardGameId,
      referencedTable: $db.boardGames,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BoardGamesTableAnnotationComposer(
            $db: $db,
            $table: $db.boardGames,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VersionsTableAnnotationComposer get versionId {
    final $$VersionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.versionId,
      referencedTable: $db.versions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VersionsTableAnnotationComposer(
            $db: $db,
            $table: $db.versions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalizedNamesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalizedNamesTable,
          LocalizedName,
          $$LocalizedNamesTableFilterComposer,
          $$LocalizedNamesTableOrderingComposer,
          $$LocalizedNamesTableAnnotationComposer,
          $$LocalizedNamesTableCreateCompanionBuilder,
          $$LocalizedNamesTableUpdateCompanionBuilder,
          (LocalizedName, $$LocalizedNamesTableReferences),
          LocalizedName,
          PrefetchHooks Function({bool boardGameId, bool versionId})
        > {
  $$LocalizedNamesTableTableManager(
    _$AppDatabase db,
    $LocalizedNamesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalizedNamesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalizedNamesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalizedNamesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> boardGameId = const Value.absent(),
                Value<int?> versionId = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<String?> language = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
              }) => LocalizedNamesCompanion(
                id: id,
                boardGameId: boardGameId,
                versionId: versionId,
                value: value,
                language: language,
                isPrimary: isPrimary,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> boardGameId = const Value.absent(),
                Value<int?> versionId = const Value.absent(),
                required String value,
                Value<String?> language = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
              }) => LocalizedNamesCompanion.insert(
                id: id,
                boardGameId: boardGameId,
                versionId: versionId,
                value: value,
                language: language,
                isPrimary: isPrimary,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LocalizedNamesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({boardGameId = false, versionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (boardGameId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.boardGameId,
                                referencedTable: $$LocalizedNamesTableReferences
                                    ._boardGameIdTable(db),
                                referencedColumn:
                                    $$LocalizedNamesTableReferences
                                        ._boardGameIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (versionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.versionId,
                                referencedTable: $$LocalizedNamesTableReferences
                                    ._versionIdTable(db),
                                referencedColumn:
                                    $$LocalizedNamesTableReferences
                                        ._versionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LocalizedNamesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalizedNamesTable,
      LocalizedName,
      $$LocalizedNamesTableFilterComposer,
      $$LocalizedNamesTableOrderingComposer,
      $$LocalizedNamesTableAnnotationComposer,
      $$LocalizedNamesTableCreateCompanionBuilder,
      $$LocalizedNamesTableUpdateCompanionBuilder,
      (LocalizedName, $$LocalizedNamesTableReferences),
      LocalizedName,
      PrefetchHooks Function({bool boardGameId, bool versionId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VersionsTableTableManager get versions =>
      $$VersionsTableTableManager(_db, _db.versions);
  $$CollectionItemsTableTableManager get collectionItems =>
      $$CollectionItemsTableTableManager(_db, _db.collectionItems);
  $$BoardGamesTableTableManager get boardGames =>
      $$BoardGamesTableTableManager(_db, _db.boardGames);
  $$LocalizedNamesTableTableManager get localizedNames =>
      $$LocalizedNamesTableTableManager(_db, _db.localizedNames);
}
