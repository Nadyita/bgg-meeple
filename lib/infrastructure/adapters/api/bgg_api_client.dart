import 'dart:async';
import 'dart:convert';

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

    // ignore: avoid_print
    print('[BggApiClient] Login response status: ${response.statusCode}');

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
    // ignore: avoid_print
    print(
      '[BggApiClient] Extracted token: ${token != null ? 'yes (length ${token.length})' : 'no'}',
    );
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

    final params = {'username': username, 'version': '1', 'stats': '1'};

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
    // ignore: avoid_print
    print('[BggApiClient] fetchGames called for ${ids.length} ids');
    // ignore: avoid_print
    print(
      '[BggApiClient] session has cookies: ${session?.hasCookies}, has token: ${session?.hasApiToken}',
    );

    if (session == null || !session.hasApiToken) {
      // ignore: avoid_print
      print('[BggApiClient] No API token available, skipping /thing fetch');
      return [];
    }

    final games = <BoardGame>[];
    for (var i = 0; i < ids.length; i += _maxThingIdsPerRequest) {
      final batch = ids.skip(i).take(_maxThingIdsPerRequest).toList();
      final uri = Uri.parse(
        '$_baseUrl$_thingPath',
      ).replace(queryParameters: {'id': batch.join(','), 'stats': '1'});
      // ignore: avoid_print
      print('[BggApiClient] Fetching /thing for ids: $batch');

      final response = await _getWithRetry(uri, useToken: true);

      // ignore: avoid_print
      print(
        '[BggApiClient] /thing response status: ${response.statusCode}, length: ${response.body.length}',
      );

      final root = _parseXml(response.body);
      final items =
          root.getElement('items')?.findElements('item').toList() ?? [];
      // ignore: avoid_print
      print('[BggApiClient] /thing parsed ${items.length} items');
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
      categories: _linkValues(item, 'boardgamecategory'),
      mechanics: _linkValues(item, 'boardgamemechanic'),
      designers: _linkValues(item, 'boardgamedesigner'),
      artists: _linkValues(item, 'boardgameartist'),
      publishers: _linkValues(item, 'boardgamepublisher'),
      families: _linkValues(item, 'boardgamefamily'),
      languageDependence: _languageDependence(item),
      bestPlayerCount: _bestPlayerCount(item),
      recommendedPlayerCount: _recommendedPlayerCount(item),
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

  List<String> _linkValues(XmlElement item, String linkType) {
    return item
        .findElements('link')
        .where((e) => e.getAttribute('type') == linkType)
        .map((e) => e.getAttribute('value'))
        .whereType<String>()
        .where((v) => v.isNotEmpty)
        .toList();
  }

  String? _languageDependence(XmlElement item) {
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

    if (winner == null) return null;
    final level = winner.getAttribute('level');
    final value = winner.getAttribute('value');
    if (value != null && value.isNotEmpty) return value;
    return level;
  }

  String? _bestPlayerCount(XmlElement item) {
    final poll = item
        .findElements('poll')
        .firstWhereOrNull(
          (p) => p.getAttribute('name') == 'suggested_numplayers',
        );
    if (poll == null) return null;

    XmlElement? winner;
    var winnerVotes = -1;
    for (final result in poll.findAllElements('result')) {
      final numPlayers = result.getAttribute('numplayers');
      if (numPlayers == null || numPlayers.isEmpty) continue;
      final votesText = result.getAttribute('numvotes');
      final votes = int.tryParse(votesText ?? '');
      if (votes != null && votes > winnerVotes) {
        winnerVotes = votes;
        winner = result;
      }
    }

    return winner?.getAttribute('numplayers');
  }

  String? _recommendedPlayerCount(XmlElement item) {
    final poll = item
        .findElements('poll')
        .firstWhereOrNull(
          (p) => p.getAttribute('name') == 'suggested_numplayers',
        );
    if (poll == null) return null;

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

    if (recommended.isEmpty) return null;
    return recommended.join(', ');
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
