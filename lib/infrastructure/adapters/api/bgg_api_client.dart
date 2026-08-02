import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import '../../../domain/entities/board_game.dart';
import '../../../domain/entities/bgg_credentials.dart';
import '../../../domain/entities/bgg_session.dart';
import '../../../domain/entities/collection_item.dart';
import '../../../domain/entities/play.dart';
import '../../../domain/entities/play_player.dart';
import '../../../domain/ports/authentication_service.dart';
import '../../../domain/ports/bgg_api.dart';
import '../../../domain/ports/session_store.dart';
import '../../../domain/value_objects/game_link.dart';
import '../../../domain/value_objects/localized_name.dart';
import '../../../domain/value_objects/version_info.dart';

/// Thrown when a BGG API request returns 401 or 403, indicating that the
/// current session cookies are missing or no longer valid.
class BggSessionExpiredException implements Exception {
  const BggSessionExpiredException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Concrete BGG XML API2 client.
///
/// Handles authentication, session cookies, rate limiting and HTTP 202 retries.
/// This adapter implements both [BggApi] and [AuthenticationService] so that the
/// same instance owns the authenticated session and shares it across login tests
/// and sync calls.
class _PlayerCountRange {
  const _PlayerCountRange({this.min, this.max, this.display});

  final int? min;
  final int? max;

  /// Original textual value from the BGG summary, normalized to a consistent
  /// dash character, e.g. "4, 6-10, 12" or "6, 8".
  final String? display;
}

class BggApiClient implements BggApi, AuthenticationService {
  BggApiClient({
    http.Client? httpClient,
    this.retryDelay = _defaultRetryDelay,
    this._sessionStore,
  }) : _client = httpClient ?? http.Client();

  static const _defaultRetryDelay = Duration(seconds: 5);
  static const _maxRetries = 10;
  static const _baseUrl = 'https://boardgamegeek.com';
  static const _loginPath = '/login/api/v1';
  static const _collectionPath = '/xmlapi2/collection';
  static const _thingPath = '/xmlapi2/thing';
  static const _maxThingIdsPerRequest = 20;

  final http.Client _client;
  final SessionStore? _sessionStore;
  final Duration retryDelay;

  BggSession? _session;

  @override
  Future<BggSession> authenticate(BggCredentials credentials) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl$_loginPath'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'credentials': {
          'username': credentials.username,
          'password': credentials.password,
        },
      }),
    );

    if (response.statusCode == 400) {
      final message = _extractLoginError(response.body);
      throw Exception('BGG authentication failed: $message');
    }

    if (response.statusCode >= 400) {
      throw Exception(
        'BGG authentication failed with status ${response.statusCode}',
      );
    }

    final cookies = _extractCookies(response.headers['set-cookie']);
    final token = _extractApiToken(response.body);
    _session = BggSession(
      sessionCookies: cookies.sessionCookies,
      apiToken: token,
    );
    await _sessionStore?.save(_session!);
    return _session!;
  }

  @override
  Future<List<CollectionItem>> fetchCollection(String username) async {
    await _ensureSessionLoaded();

    final params = {
      'username': username,
      'version': '1',
      'stats': '1',
      'showprivate': '1',
    };

    final response = await _getWithRetry(
      Uri.parse('$_baseUrl$_collectionPath').replace(queryParameters: params),
    );

    final root = _parseXml(response.body);
    final items = root.getElement('items')?.findElements('item').toList() ?? [];
    return items.map(_parseCollectionItem).toList();
  }

  static const _playsPath = '/xmlapi2/plays';

  @override
  Future<List<Play>> fetchPlays(String username) async {
    await _ensureSessionLoaded();

    final plays = <Play>[];
    var page = 1;
    var total = 0;

    do {
      final params = {
        'username': username,
        'subtype': 'boardgame',
        'page': page.toString(),
      };

      final response = await _getWithRetry(
        Uri.parse('$_baseUrl$_playsPath').replace(queryParameters: params),
      );

      final root = _parseXml(response.body);
      final playsElement = root.getElement('plays');
      final playElements = playsElement?.findElements('play').toList() ?? [];

      if (total == 0) {
        total = int.parse(playsElement?.getAttribute('total') ?? '0');
      }

      plays.addAll(playElements.map(_parsePlay));
      page++;
    } while (plays.length < total);

    return plays;
  }

  Play _parsePlay(XmlElement play) {
    final item = play.getElement('item');
    final players = play.getElement('players');

    return Play(
      id: int.parse(play.getAttribute('id') ?? '0'),
      thingId: int.parse(item?.getAttribute('objectid') ?? '0'),
      gameName: item?.getAttribute('name') ?? '',
      date: play.getAttribute('date') ?? '',
      quantity: int.parse(play.getAttribute('quantity') ?? '1'),
      length: int.parse(play.getAttribute('length') ?? '0'),
      incomplete: _parseBoolAttribute(play.getAttribute('incomplete')),
      noWinStats: _parseBoolAttribute(play.getAttribute('nowinstats')),
      location: _nullIfEmpty(play.getAttribute('location')),
      comments: _nullIfEmpty(_childText(play, 'comments')),
      subtypes: _parseSubtypes(item?.getElement('subtypes')),
      players:
          players?.findElements('player').map(_parsePlayPlayer).toList() ?? [],
    );
  }

  PlayPlayer _parsePlayPlayer(XmlElement player) {
    return PlayPlayer(
      username: _nullIfEmpty(player.getAttribute('username')),
      userId: int.tryParse(player.getAttribute('userid') ?? '0'),
      name: _nullIfEmpty(player.getAttribute('name')),
      startPosition: _nullIfEmpty(player.getAttribute('startposition')),
      color: _nullIfEmpty(player.getAttribute('color')),
      score: _nullIfEmpty(player.getAttribute('score')),
      newPlayer: _parseBoolAttribute(player.getAttribute('new')),
      rating: _parseDouble(player.getAttribute('rating')),
      win: _parseBoolAttribute(player.getAttribute('win')),
    );
  }

  List<String> _parseSubtypes(XmlElement? subtypes) {
    if (subtypes == null) return const [];
    return subtypes
        .findElements('subtype')
        .map((e) => e.getAttribute('value'))
        .whereType<String>()
        .toList();
  }

  String? _nullIfEmpty(String? value) {
    if (value == null || value.isEmpty) return null;
    return value;
  }

  double? _parseDouble(String? value) {
    if (value == null || value.isEmpty) return null;
    return double.tryParse(value);
  }

  bool _parseBoolAttribute(String? value) => value == '1';

  @override
  Future<List<BoardGame>> fetchGames(List<int> ids) async {
    await _ensureSessionLoaded();

    if (ids.isEmpty) return [];

    final session = _session;

    if (session == null || !session.hasApiToken) {
      return [];
    }

    final games = <BoardGame>[];
    for (var i = 0; i < ids.length; i += _maxThingIdsPerRequest) {
      final batch = ids.skip(i).take(_maxThingIdsPerRequest).toList();
      final uri = Uri.parse(
        '$_baseUrl$_thingPath',
      ).replace(queryParameters: {'id': batch.join(','), 'stats': '1'});

      final response = await _getWithRetry(uri, useToken: true);

      final root = _parseXml(response.body);
      final items =
          root.getElement('items')?.findElements('item').toList() ?? [];
      games.addAll(items.map(_parseBoardGame));
    }

    return games;
  }

  Future<void> _ensureSessionLoaded() async {
    if (_session != null && _session!.isValid) {
      return;
    }

    final stored = await _sessionStore?.load();
    if (stored != null && stored.isValid) {
      _session = stored;
    }
  }

  Future<http.Response> _getWithRetry(Uri uri, {bool useToken = false}) async {
    for (var attempt = 0; attempt < _maxRetries; attempt++) {
      final response = await _client.get(
        uri,
        headers: useToken ? _tokenHeaders : _authHeaders,
      );

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw BggSessionExpiredException(
          'BGG API request failed with status ${response.statusCode}. '
          'Session cookies may be missing or expired.',
        );
      }

      if (response.statusCode != 202) {
        if (response.statusCode >= 400) {
          throw Exception(
            'BGG API request failed with status ${response.statusCode}',
          );
        }
        return response;
      }

      await Future.delayed(retryDelay);
    }

    throw Exception('BGG API request timed out after $_maxRetries retries');
  }

  Map<String, String> get _authHeaders {
    final session = _session;
    if (session == null || !session.isValid) {
      return {};
    }
    return {'Cookie': session.sessionCookies};
  }

  Map<String, String> get _tokenHeaders {
    final session = _session;
    if (session == null || !session.hasApiToken) {
      return {};
    }
    return {'Authorization': 'Bearer ${session.apiToken}'};
  }

  String _extractLoginError(String body) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final errors = decoded['errors'] as Map<String, dynamic>?;
      final message = errors?['message'] as String?;
      if (message != null && message.isNotEmpty) {
        return message;
      }
    } on FormatException {
      // Fall through to default message.
    } on TypeError {
      // Fall through to default message.
    }
    return 'invalid username or password';
  }

  /// Returns the BGG authentication cookies needed for XML API calls.
  ///
  /// Includes bggusername, bggpassword, and SessionID.
  BggSession? get currentSession {
    if (_session != null && _session!.isValid) {
      return _session;
    }
    return null;
  }

  /// Parses cookies from a `set-cookie` header value and returns a session.
  ///
  /// Keeps all cookie name/value pairs (including bggusername, bggpassword,
  /// and SessionID) separated by `; `.
  BggSession _extractCookies(String? setCookieHeader) {
    if (setCookieHeader == null || setCookieHeader.isEmpty) {
      throw Exception('BGG authentication failed: no session cookies received');
    }

    final cookieMap = _extractBggCookieValues(setCookieHeader);

    final entries = cookieMap.entries
        .where((e) => e.value.isNotEmpty && e.value != 'deleted')
        .map((e) => '${e.key}=${e.value}')
        .toList();

    if (entries.isEmpty) {
      throw Exception('BGG authentication failed: no session cookies received');
    }

    return BggSession(sessionCookies: entries.join('; '));
  }

  /// Extracts an API bearer token from the JSON login response, if present.
  String? _extractApiToken(String body) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final token = decoded['token'] as String?;
      if (token != null && token.trim().isNotEmpty) {
        return token.trim();
      }
    } on FormatException {
      // Not a JSON body - no token available.
    } on TypeError {
      // Unexpected JSON structure.
    }
    return null;
  }

  /// Extracts BGG-specific cookie values from a possibly combined
  /// `set-cookie` header.
  ///
  /// This method is tolerant of commas inside `Expires` attributes, which are
  /// common in `Set-Cookie` headers. It only looks for the three cookie names
  /// BGG uses for authenticated XML API requests.
  Map<String, String> _extractBggCookieValues(String header) {
    const cookieNames = ['bggusername', 'bggpassword', 'SessionID'];
    final result = <String, String>{};

    for (final name in cookieNames) {
      final prefix = '$name=';
      final start = header.indexOf(prefix);
      if (start == -1) continue;

      final valueStart = start + prefix.length;
      var valueEnd = header.indexOf(';', valueStart);
      if (valueEnd == -1) {
        valueEnd = header.length;
      }

      // Combined Set-Cookie headers separate cookies with ", ". Make sure we
      // don't run into the next cookie's name.
      final commaIndex = header.indexOf(',', valueStart);
      if (commaIndex != -1 && commaIndex < valueEnd) {
        valueEnd = commaIndex;
      }

      result[name] = header.substring(valueStart, valueEnd).trim();
    }

    return result;
  }

  XmlDocument _parseXml(String body) {
    try {
      return XmlDocument.parse(body);
    } on XmlParserException catch (e) {
      throw Exception('Failed to parse BGG XML response: ${e.message}');
    }
  }

  CollectionItem _parseCollectionItem(XmlElement item) {
    final thingId = int.parse(item.getAttribute('objectid') ?? '0');
    final collId = int.parse(item.getAttribute('collid') ?? '0');

    final stats = item.getElement('stats');

    final name = _childText(item, 'name');
    final originalName = _childText(item, 'originalname');
    final yearPublished = _childInt(item, 'yearpublished');
    final ownRating = _parseOwnRating(stats);
    final numPlays = _childInt(item, 'numplays');
    final minPlayers = _statsInt(stats, 'minplayers');
    final maxPlayers = _statsInt(stats, 'maxplayers');
    final minPlayTime = _statsInt(stats, 'minplaytime');
    final maxPlayTime = _statsInt(stats, 'maxplaytime');
    final minAge = _statsInt(stats, 'minage');
    final bayesAverage = _statsBayesAverage(stats);
    final geekRatingUserCount = _statsUsersRated(stats);
    final bggRank = _statsBoardGameRank(stats);

    final status = item.findElements('status').firstOrNull;
    final versionElement = item.findElements('version').firstOrNull;
    final inventoryLocation = _inventoryLocation(item);

    return CollectionItem(
      thingId: thingId,
      collId: collId,
      version: versionElement != null ? _parseVersion(versionElement) : null,
      customName: _isCustomName(item) ? name : null,
      customImageUrl: _childText(item, 'image'),
      thumbnailUrl: _childText(item, 'thumbnail'),
      imageUrl: _childText(item, 'image'),
      names: _buildNames(name, originalName),
      yearPublished: yearPublished,
      minPlayers: minPlayers,
      maxPlayers: maxPlayers,
      minPlayTime: minPlayTime,
      maxPlayTime: maxPlayTime,
      minAge: minAge,
      bayesAverage: bayesAverage,
      geekRatingUserCount: geekRatingUserCount,
      ownRating: ownRating,
      numPlays: numPlays,
      bggRank: bggRank,
      inventoryLocation: inventoryLocation,
      isOwned: _parseBool(status, 'own'),
      isPreordered: _parseBool(status, 'preordered'),
      isWishlisted: _parseBool(status, 'wishlist'),
      isWantToPlay: _parseBool(status, 'wanttoplay'),
      isWantToBuy: _parseBool(status, 'wanttobuy'),
      isPrevOwned: _parseBool(status, 'prevowned'),
      isPlayed: _parseBool(status, 'played'),
      isRated: _parseBool(status, 'rated'),
      isForTrade: _parseBool(status, 'fortrade'),
      isWantInTrade: _parseBool(status, 'want'),
      hasComment: _childText(item, 'comment')?.trim().isNotEmpty ?? false,
    );
  }

  String? _inventoryLocation(XmlElement item) {
    final privateInfo = item.findElements('privateinfo').firstOrNull;
    final value = privateInfo?.getAttribute('inventorylocation');
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  VersionInfo? _parseVersion(XmlElement version) {
    final item = version.findElements('item').firstOrNull;
    if (item == null) return null;

    final id = int.parse(item.getAttribute('id') ?? '0');
    final name = _versionName(item);
    final year = _firstIntInSubtree(item, 'yearpublished');

    return VersionInfo(id: id, name: name ?? '', year: year);
  }

  List<LocalizedName> _buildNames(String? primary, String? original) {
    final names = <LocalizedName>[];
    if (primary != null && primary.isNotEmpty) {
      names.add(LocalizedName(value: primary, language: null, isPrimary: true));
    }
    if (original != null && original.isNotEmpty && original != primary) {
      names.add(
        LocalizedName(value: original, language: null, isPrimary: false),
      );
    }
    return names;
  }

  String? _versionName(XmlElement? versionItem) {
    if (versionItem == null) return null;
    final nameElement = versionItem.findElements('name').firstOrNull;
    return nameElement?.getAttribute('value') ?? nameElement?.innerText;
  }

  int? _firstIntInSubtree(XmlElement? parent, String tag) {
    if (parent == null) return null;
    return int.tryParse(_firstValueDeep(parent, tag) ?? '');
  }

  String? _firstValueDeep(XmlElement parent, String tag) {
    final element = parent.findAllElements(tag).firstOrNull;
    if (element == null) return null;
    return element.getAttribute('value') ?? element.innerText;
  }

  bool _isCustomName(XmlElement item) {
    // BGG does not reliably distinguish a user-defined custom name from the
    // primary game name in the /collection response. Returning false keeps the
    // name in the primary-name slot and avoids misidentifying the canonical
    // title as a custom override.
    return false;
  }

  double? _parseOwnRating(XmlElement? stats) {
    if (stats == null) return null;
    final rating = stats.getElement('rating');
    if (rating == null) return null;
    final value = rating.getAttribute('value');
    if (value == null ||
        value.toUpperCase() == 'N/A' ||
        value.toUpperCase() == 'NOT RANKED') {
      return null;
    }
    return double.tryParse(value);
  }

  double? _statsBayesAverage(XmlElement? stats) {
    if (stats == null) return null;
    final rating = stats.getElement('rating');
    if (rating == null) return null;
    final element = rating.getElement('bayesaverage');
    if (element == null) return null;
    final value = element.getAttribute('value');
    if (value == null ||
        value.isEmpty ||
        value.toUpperCase() == 'N/A' ||
        value.toUpperCase() == 'NOT RANKED') {
      return null;
    }
    final parsed = double.tryParse(value);
    if (parsed == null || parsed == 0.0) {
      return null;
    }
    return parsed;
  }

  int? _statsUsersRated(XmlElement? stats) {
    if (stats == null) return null;
    final rating = stats.getElement('rating');
    if (rating == null) return null;
    final element = rating.getElement('usersrated');
    if (element == null) return null;
    final value = element.getAttribute('value');
    if (value == null || value.isEmpty) {
      return null;
    }
    return int.tryParse(value);
  }

  int? _statsBoardGameRank(XmlElement? stats) {
    if (stats == null) return null;
    final rating = stats.getElement('rating');
    if (rating == null) return null;
    final ranks = rating.getElement('ranks');
    if (ranks == null) return null;
    XmlElement? rank;
    for (final r in ranks.findElements('rank')) {
      if (r.getAttribute('type') == 'subtype' &&
          r.getAttribute('id') == '1' &&
          r.getAttribute('name') == 'boardgame') {
        rank = r;
        break;
      }
    }
    if (rank == null) return null;
    final value = rank.getAttribute('value');
    if (value == null ||
        value.isEmpty ||
        value.toUpperCase() == 'N/A' ||
        value.toUpperCase() == 'NOT RANKED') {
      return null;
    }
    return int.tryParse(value);
  }

  BoardGame _parseBoardGame(XmlElement item) {
    final id = int.parse(item.getAttribute('id') ?? '0');
    final names = _parseThingNames(item);

    final stats = item.getElement('statistics');
    final ratings = stats?.getElement('ratings');

    final description = _childText(item, 'description');
    final minPlayers = _childInt(item, 'minplayers');
    final maxPlayers = _childInt(item, 'maxplayers');
    final minPlayTime = _childInt(item, 'minplaytime');

    final bestRange = _bestPlayerCountRange(item);
    final recommendedRange = _recommendedPlayerCountRange(item);
    final maxPlayTime = _childInt(item, 'maxplaytime');
    final playingTime = _childInt(item, 'playingtime');
    final minAge = _childInt(item, 'minage');
    final yearPublished = _childInt(item, 'yearpublished');

    return BoardGame(
      id: id,
      names: names,
      imageUrl: _childText(item, 'image'),
      thumbnailUrl: _childText(item, 'thumbnail'),
      yearPublished: yearPublished,
      minPlayers: minPlayers,
      maxPlayers: maxPlayers,
      minPlayTime: minPlayTime,
      maxPlayTime: maxPlayTime,
      playingTime: playingTime,
      minAge: minAge,
      bayesAverage: _ratingValue(ratings, 'bayesaverage'),
      averageRating: _ratingValue(ratings, 'average'),
      userCount: _ratingInt(ratings, 'usersrated'),
      numOwned: _ratingInt(ratings, 'owned'),
      numTrading: _ratingInt(ratings, 'trading'),
      numWanting: _ratingInt(ratings, 'wanting'),
      numWishing: _ratingInt(ratings, 'wishing'),
      averageWeight: _ratingValue(ratings, 'averageweight'),
      description: description,
      links: _parseGameLinks(item),
      languageDependenceLevel: _languageDependenceLevel(item),
      bestPlayerCount: bestRange.display,
      bestPlayerCountMin: bestRange.min,
      bestPlayerCountMax: bestRange.max,
      suggestedPlayerAge: _suggestedPlayerAge(item),
      recommendedPlayerCount: recommendedRange.display,
      recommendedPlayerCountMin: recommendedRange.min,
      recommendedPlayerCountMax: recommendedRange.max,
    );
  }

  List<LocalizedName> _parseThingNames(XmlElement item) {
    final names = <LocalizedName>[];
    for (final name in item.findElements('name')) {
      final value = name.getAttribute('value');
      if (value == null || value.isEmpty) continue;
      final type = name.getAttribute('type');
      names.add(
        LocalizedName(
          value: value,
          language: null,
          isPrimary: type == 'primary',
        ),
      );
    }
    return names;
  }

  String? _languageDependenceLevel(XmlElement item) {
    final poll = item
        .findElements('poll')
        .firstWhereOrNull(
          (p) => p.getAttribute('name') == 'language_dependence',
        );
    if (poll == null) return null;

    final results = poll.findElements('results').firstOrNull;
    if (results == null) return null;

    XmlElement? winner;
    var winnerVotes = -1;
    for (final result in results.findElements('result')) {
      final votesText = result.getAttribute('numvotes');
      final votes = int.tryParse(votesText ?? '');
      if (votes != null && votes > winnerVotes) {
        winnerVotes = votes;
        winner = result;
      }
    }

    return winner?.getAttribute('level');
  }

  String? _suggestedPlayerAge(XmlElement item) {
    final poll = item
        .findElements('poll')
        .firstWhereOrNull(
          (p) => p.getAttribute('name') == 'suggested_playerage',
        );
    if (poll == null) return null;

    final results = poll.findElements('results').firstOrNull;
    if (results == null) return null;

    var totalVotes = 0;
    var weightedSum = 0.0;
    for (final result in results.findElements('result')) {
      final ageText = result.getAttribute('value');
      final age = int.tryParse(ageText ?? '');
      if (age == null) continue;
      final votesText = result.getAttribute('numvotes');
      final votes = int.tryParse(votesText ?? '') ?? 0;
      if (votes <= 0) continue;
      totalVotes += votes;
      weightedSum += age * votes;
    }

    if (totalVotes == 0) return null;
    return (weightedSum / totalVotes).toStringAsFixed(1);
  }

  List<GameLink> _parseGameLinks(XmlElement item) {
    final typeMapping = const {
      'boardgamecategory': 'category',
      'boardgamemechanic': 'mechanic',
      'boardgamefamily': 'family',
      'boardgamedesigner': 'designer',
      'boardgameartist': 'artist',
      'boardgamepublisher': 'publisher',
      'boardgameexpansion': 'expansion',
      'boardgameimplementation': 'implementation',
    };

    final links = <GameLink>[];
    for (final link in item.findElements('link')) {
      final rawType = link.getAttribute('type');
      final type = typeMapping[rawType];
      final idText = link.getAttribute('id');
      final name = link.getAttribute('value');
      final id = int.tryParse(idText ?? '');
      if (type == null || id == null || name == null || name.isEmpty) continue;
      links.add(GameLink(bggId: id, type: type, name: name));
    }
    return links;
  }

  _PlayerCountRange _bestPlayerCountRange(XmlElement item) {
    final summary = item
        .findElements('poll-summary')
        .firstWhereOrNull(
          (p) => p.getAttribute('name') == 'suggested_numplayers',
        );
    if (summary != null) {
      final bestWith = summary
          .findElements('result')
          .firstWhereOrNull((r) => r.getAttribute('name') == 'bestwith');
      final value = bestWith?.getAttribute('value');
      if (value != null && value.isNotEmpty) {
        final range = _parsePlayerCountRange(value);
        if (range != null) return range;
      }
    }

    return _legacyBestPlayerCountRange(item);
  }

  _PlayerCountRange _legacyBestPlayerCountRange(XmlElement item) {
    final poll = item
        .findElements('poll')
        .firstWhereOrNull(
          (p) => p.getAttribute('name') == 'suggested_numplayers',
        );
    if (poll == null) return const _PlayerCountRange();

    final winners = <String>[];
    var winnerVotes = -1;
    for (final results in poll.findElements('results')) {
      final numPlayers = results.getAttribute('numplayers');
      if (numPlayers == null || numPlayers.isEmpty) continue;

      for (final result in results.findElements('result')) {
        final value = result.getAttribute('value');
        if (value != 'Best') continue;
        final votesText = result.getAttribute('numvotes');
        final votes = int.tryParse(votesText ?? '');
        if (votes == null) continue;
        if (votes > winnerVotes) {
          winnerVotes = votes;
          winners.clear();
          winners.add(numPlayers);
        } else if (votes == winnerVotes) {
          winners.add(numPlayers);
        }
      }
    }

    if (winners.isEmpty) return const _PlayerCountRange();
    return _playerCountRangeFromValues(winners);
  }

  _PlayerCountRange _recommendedPlayerCountRange(XmlElement item) {
    final summary = item
        .findElements('poll-summary')
        .firstWhereOrNull(
          (p) => p.getAttribute('name') == 'suggested_numplayers',
        );
    if (summary != null) {
      final recommendedWith = summary
          .findElements('result')
          .firstWhereOrNull(
            (r) => r.getAttribute('name') == 'recommmendedwith',
          );
      final value = recommendedWith?.getAttribute('value');
      if (value != null && value.isNotEmpty) {
        final range = _parsePlayerCountRange(value);
        if (range != null) return range;
      }
    }

    return _legacyRecommendedPlayerCountRange(item);
  }

  _PlayerCountRange _legacyRecommendedPlayerCountRange(XmlElement item) {
    final poll = item
        .findElements('poll')
        .firstWhereOrNull(
          (p) => p.getAttribute('name') == 'suggested_numplayers',
        );
    if (poll == null) return const _PlayerCountRange();

    final recommended = <String>[];
    for (final results in poll.findElements('results')) {
      final numPlayers = results.getAttribute('numplayers');
      if (numPlayers == null || numPlayers.isEmpty) continue;

      var recommendedVotes = 0;
      var totalVotes = 0;
      for (final result in results.findElements('result')) {
        final value = result.getAttribute('value');
        final votesText = result.getAttribute('numvotes');
        final votes = int.tryParse(votesText ?? '') ?? 0;
        totalVotes += votes;
        if (value == 'Recommended') {
          recommendedVotes += votes;
        }
      }

      if (totalVotes > 0 && recommendedVotes / totalVotes >= 0.5) {
        recommended.add(numPlayers);
      }
    }

    if (recommended.isEmpty) return const _PlayerCountRange();
    return _playerCountRangeFromConsecutiveValues(recommended);
  }

  _PlayerCountRange? _parsePlayerCountRange(String text) {
    // Normalize dashes: en-dash, em-dash, hyphen-minus all become '-'
    final normalized = text.replaceAll('–', '-').replaceAll('—', '-');

    final expressions = <String>[];
    int? overallMin;
    int? overallMax;
    var hasOpenEnd = false;

    final regex = RegExp(r'(?<min>\d+)\s*(?:-\s*(?<max>\d+))?\s*(?<plus>\+)?');
    for (final match in regex.allMatches(normalized)) {
      final minText = match.namedGroup('min');
      final maxText = match.namedGroup('max');
      final hasPlus = match.namedGroup('plus') != null;
      final min = int.tryParse(minText ?? '');
      if (min == null) continue;

      int? max;
      if (maxText != null) {
        max = int.tryParse(maxText);
      } else if (!hasPlus) {
        max = min;
      }

      if (hasPlus) {
        hasOpenEnd = true;
      }

      overallMin = overallMin == null ? min : math.min(overallMin, min);
      final candidateMax = max;
      if (candidateMax != null) {
        overallMax = overallMax == null
            ? candidateMax
            : math.max(overallMax, candidateMax);
      }

      final displayValue = _formatPlayerCountRange(min, max, hasPlus: hasPlus);
      expressions.add(displayValue);
    }

    if (expressions.isEmpty) return null;

    final display = expressions.join(', ');
    final effectiveMax = hasOpenEnd ? null : overallMax;
    return _PlayerCountRange(
      min: overallMin,
      max: effectiveMax,
      display: display,
    );
  }

  String _formatPlayerCountRange(int min, int? max, {bool hasPlus = false}) {
    if (min == max) {
      return hasPlus ? '$min+' : '$min';
    }
    if (max == null) {
      return '$min+';
    }
    return hasPlus ? '$min-$max+' : '$min-$max';
  }

  _PlayerCountRange _playerCountRangeFromValues(List<String> values) {
    final numbers = values
        .map(_parsePlayerCountValue)
        .whereType<int>()
        .toList();
    if (numbers.isEmpty) return const _PlayerCountRange();
    final min = numbers.reduce(math.min);
    final max = numbers.reduce(math.max);
    return _PlayerCountRange(
      min: min,
      max: max,
      display: _formatPlayerCountRange(min, max),
    );
  }

  _PlayerCountRange _playerCountRangeFromConsecutiveValues(
    List<String> values,
  ) {
    final numbers = values.map(_parsePlayerCountValue).whereType<int>().toList()
      ..sort();
    if (numbers.isEmpty) return const _PlayerCountRange();

    var bestStart = 0;
    var bestEnd = 0;
    var currentStart = 0;
    for (var i = 1; i < numbers.length; i++) {
      if (numbers[i] == numbers[i - 1] + 1) {
        if (i - currentStart > bestEnd - bestStart) {
          bestStart = currentStart;
          bestEnd = i;
        }
      } else {
        currentStart = i;
      }
    }

    final min = numbers[bestStart];
    final max = numbers[bestEnd];
    return _PlayerCountRange(
      min: min,
      max: min == max ? min : max,
      display: _formatPlayerCountRange(min, min == max ? min : max),
    );
  }

  int? _parsePlayerCountValue(String value) {
    final match = RegExp(r'^\d+').firstMatch(value);
    if (match == null) return null;
    return int.tryParse(match.group(0)!);
  }

  double? _ratingValue(XmlElement? ratings, String tag) {
    if (ratings == null) return null;
    final element = ratings.getElement(tag);
    if (element == null) return null;
    final value = element.getAttribute('value');
    if (value == null ||
        value.isEmpty ||
        value.toUpperCase() == 'N/A' ||
        value.toUpperCase() == 'NOT RANKED') {
      return null;
    }
    return double.tryParse(value);
  }

  int? _ratingInt(XmlElement? ratings, String tag) {
    if (ratings == null) return null;
    final element = ratings.getElement(tag);
    if (element == null) return null;
    final value = element.getAttribute('value');
    if (value == null || value.isEmpty) return null;
    return int.tryParse(value);
  }

  int? _statsInt(XmlElement? stats, String attribute) {
    if (stats == null) return null;
    final fromAttribute = stats.getAttribute(attribute);
    if (fromAttribute != null && fromAttribute.isNotEmpty) {
      return int.tryParse(fromAttribute);
    }
    return _firstIntInSubtree(stats, attribute);
  }

  String? _childText(XmlElement parent, String tag) {
    return parent.getElement(tag)?.innerText;
  }

  int? _childInt(XmlElement parent, String tag) {
    final text = _childText(parent, tag);
    return text == null ? null : int.tryParse(text);
  }

  bool _parseBool(XmlElement? parent, String attribute) {
    final value = parent?.getAttribute(attribute);
    return value == '1';
  }
}
