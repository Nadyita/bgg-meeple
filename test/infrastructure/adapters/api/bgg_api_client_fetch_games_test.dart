import 'dart:convert';

import 'package:bgg_meeple/domain/entities/bgg_session.dart';
import 'package:bgg_meeple/domain/ports/session_store.dart';
import 'package:bgg_meeple/domain/value_objects/game_link.dart';
import 'package:bgg_meeple/infrastructure/adapters/api/bgg_api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class _MockHttpClient extends Mock implements http.Client {}

class _MockSessionStore extends Mock implements SessionStore {}

class _UriFake extends Fake implements Uri {}

void main() {
  setUpAll(() {
    registerFallbackValue(_UriFake());
  });

  group('BggApiClient fetchGames', () {
    late http.Client client;
    late _MockSessionStore sessionStore;
    late BggApiClient apiClient;

    setUp(() {
      client = _MockHttpClient();
      sessionStore = _MockSessionStore();
      apiClient = BggApiClient(httpClient: client, sessionStore: sessionStore);
    });

    test('sends Authorization Bearer header when api token is present', () async {
      when(() => sessionStore.load()).thenAnswer(
        (_) async => const BggSession(
          sessionCookies: 'bggusername=u; bggpassword=p; SessionID=s',
          apiToken: 'my-bearer-token',
        ),
      );

      when(
        () => client.get(
          Uri.parse('https://boardgamegeek.com/xmlapi2/thing?id=1&stats=1'),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer(
        (_) async => http.Response(
          '<?xml version="1.0"?><items><item id="1"><name type="primary" value="Catan"/></item></items>',
          200,
        ),
      );

      final games = await apiClient.fetchGames([1]);

      expect(games, hasLength(1));
      verify(
        () => client.get(
          Uri.parse('https://boardgamegeek.com/xmlapi2/thing?id=1&stats=1'),
          headers: {'Authorization': 'Bearer my-bearer-token'},
        ),
      ).called(1);
    });

    test('parses description, polls and links from /thing XML', () async {
      when(() => sessionStore.load()).thenAnswer(
        (_) async => const BggSession(
          sessionCookies: 'bggusername=u; bggpassword=p; SessionID=s',
          apiToken: 'my-bearer-token',
        ),
      );

      const xml = '''
<?xml version="1.0" encoding="utf-8"?>
<items>
  <item type="boardgame" id="172308">
    <thumbnail>https://example.com/thumb.jpg</thumbnail>
    <image>https://example.com/image.jpg</image>
    <name type="primary" value="Broom Service"/>
    <description>Score the most victory points.</description>
    <yearpublished value="2015"/>
    <minplayers value="2"/>
    <maxplayers value="5"/>
    <minplaytime value="30"/>
    <maxplaytime value="75"/>
    <playingtime value="75"/>
    <minage value="10"/>
    <poll name="suggested_numplayers" title="User Suggested Number of Players" totalvotes="231">
      <results numplayers="4">
        <result value="Best" numvotes="113"/>
        <result value="Recommended" numvotes="69"/>
        <result value="Not Recommended" numvotes="7"/>
      </results>
    </poll>
    <poll-summary name="suggested_numplayers" title="User Suggested Number of Players">
      <result name="bestwith" value="Best with 4 players"/>
      <result name="recommmendedwith" value="Recommended with 2–5 players"/>
    </poll-summary>
    <poll name="suggested_playerage" title="User Suggested Player Age" totalvotes="49">
      <results>
        <result value="6" numvotes="1"/>
        <result value="8" numvotes="17"/>
        <result value="10" numvotes="25"/>
        <result value="12" numvotes="6"/>
        <result value="21 and up" numvotes="0"/>
      </results>
    </poll>
    <poll name="language_dependence" title="Language Dependence" totalvotes="38">
      <results>
        <result level="1" value="No necessary in-game text" numvotes="1"/>
        <result level="2" value="Some necessary text" numvotes="22"/>
        <result level="3" value="Moderate in-game text" numvotes="12"/>
      </results>
    </poll>
    <link type="boardgamecategory" id="1010" value="Fantasy"/>
    <link type="boardgamemechanic" id="2046" value="Area Movement"/>
    <link type="boardgamefamily" id="45609" value="Game: Broom Service"/>
    <link type="boardgamefamily" id="58" value="Series: Alea Big Box"/>
    <link type="boardgamedesigner" id="8397" value="Andreas Pelikan"/>
    <link type="boardgameartist" id="12130" value="Vincent Dutrait"/>
    <link type="boardgamepublisher" id="9" value="alea"/>
    <link type="boardgameexpansion" id="204573" value="Brettspiel Adventskalender 2016"/>
    <link type="boardgameimplementation" id="34084" value="Witch's Brew" inbound="true"/>
  </item>
</items>
''';

      when(
        () => client.get(
          Uri.parse(
            'https://boardgamegeek.com/xmlapi2/thing?id=172308&stats=1',
          ),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer(
        (_) async => http.Response.bytes(
          utf8.encode(xml),
          200,
          headers: {'content-type': 'text/xml; charset=utf-8'},
        ),
      );

      final games = await apiClient.fetchGames([172308]);

      expect(games, hasLength(1));
      final game = games.first;
      expect(game.id, 172308);
      expect(game.description, 'Score the most victory points.');
      expect(game.bestPlayerCount, '4');
      expect(game.bestPlayerCountMin, 4);
      expect(game.bestPlayerCountMax, 4);
      expect(game.recommendedPlayerCount, '2-5');
      expect(game.recommendedPlayerCountMin, 2);
      expect(game.recommendedPlayerCountMax, 5);
      expect(game.suggestedPlayerAge, '9.5');
      expect(game.languageDependenceLevel, '2');

      final families = game.links.where((l) => l.type == 'family').toList();
      expect(families, hasLength(2));
      expect(
        families,
        contains(
          const GameLink(
            bggId: 45609,
            type: 'family',
            name: 'Game: Broom Service',
          ),
        ),
      );
      expect(game.links.where((l) => l.type == 'category'), [
        const GameLink(bggId: 1010, type: 'category', name: 'Fantasy'),
      ]);
      expect(game.links.where((l) => l.type == 'mechanic'), [
        const GameLink(bggId: 2046, type: 'mechanic', name: 'Area Movement'),
      ]);
      expect(game.links.where((l) => l.type == 'designer'), [
        const GameLink(bggId: 8397, type: 'designer', name: 'Andreas Pelikan'),
      ]);
      expect(game.links.where((l) => l.type == 'artist'), [
        const GameLink(bggId: 12130, type: 'artist', name: 'Vincent Dutrait'),
      ]);
      expect(game.links.where((l) => l.type == 'publisher'), [
        const GameLink(bggId: 9, type: 'publisher', name: 'alea'),
      ]);
      expect(game.links.where((l) => l.type == 'expansion'), [
        const GameLink(
          bggId: 204573,
          type: 'expansion',
          name: 'Brettspiel Adventskalender 2016',
        ),
      ]);
      expect(game.links.where((l) => l.type == 'implementation'), [
        const GameLink(
          bggId: 34084,
          type: 'implementation',
          name: "Witch's Brew",
        ),
      ]);
    });

    test('parses all player count range forms from poll-summary', () async {
      when(() => sessionStore.load()).thenAnswer(
        (_) async => const BggSession(
          sessionCookies: 'bggusername=u; bggpassword=p; SessionID=s',
          apiToken: 'my-bearer-token',
        ),
      );

      const xml = '''
<items>
  <item id="1">
    <name type="primary" value="A"/>
    <poll-summary name="suggested_numplayers">
      <result name="bestwith" value="Best with 3 players"/>
      <result name="recommmendedwith" value="Recommended with 4–5 players"/>
    </poll-summary>
  </item>
  <item id="2">
    <name type="primary" value="B"/>
    <poll-summary name="suggested_numplayers">
      <result name="bestwith" value="Best with 5+ players"/>
      <result name="recommmendedwith" value="Recommended with 8—18+ players"/>
    </poll-summary>
  </item>
  <item id="3">
    <name type="primary" value="C"/>
    <poll-summary name="suggested_numplayers">
      <result name="bestwith" value="Best with 8-10+ players"/>
    </poll-summary>
  </item>
  <item id="4">
    <name type="primary" value="D"/>
    <poll-summary name="suggested_numplayers">
      <result name="bestwith" value="Best with 6, 8 players"/>
      <result name="recommmendedwith" value="Recommended with 4, 6–10, 12 players"/>
    </poll-summary>
  </item>
  <item id="5">
    <name type="primary" value="E"/>
    <poll-summary name="suggested_numplayers">
      <result name="recommmendedwith" value="Recommended with 4, 6+ players"/>
    </poll-summary>
  </item>
</items>
''';

      when(() => client.get(any(), headers: any(named: 'headers'))).thenAnswer(
        (_) async => http.Response.bytes(
          utf8.encode(xml),
          200,
          headers: {'content-type': 'text/xml; charset=utf-8'},
        ),
      );

      final games = await apiClient.fetchGames([1, 2, 3, 4, 5]);

      expect(games, hasLength(5));
      final first = games.firstWhere((g) => g.id == 1);
      expect(first.bestPlayerCount, '3');
      expect(first.bestPlayerCountMin, 3);
      expect(first.bestPlayerCountMax, 3);
      expect(first.recommendedPlayerCount, '4-5');
      expect(first.recommendedPlayerCountMin, 4);
      expect(first.recommendedPlayerCountMax, 5);

      final second = games.firstWhere((g) => g.id == 2);
      expect(second.bestPlayerCount, '5+');
      expect(second.bestPlayerCountMin, 5);
      expect(second.bestPlayerCountMax, isNull);
      expect(second.recommendedPlayerCount, '8-18+');
      expect(second.recommendedPlayerCountMin, 8);
      expect(second.recommendedPlayerCountMax, isNull);

      final third = games.firstWhere((g) => g.id == 3);
      expect(third.bestPlayerCount, '8-10+');
      expect(third.bestPlayerCountMin, 8);
      expect(third.bestPlayerCountMax, isNull);

      final fourth = games.firstWhere((g) => g.id == 4);
      expect(fourth.bestPlayerCount, '6, 8');
      expect(fourth.bestPlayerCountMin, 6);
      expect(fourth.bestPlayerCountMax, 8);
      expect(fourth.recommendedPlayerCount, '4, 6-10, 12');
      expect(fourth.recommendedPlayerCountMin, 4);
      expect(fourth.recommendedPlayerCountMax, 12);

      final fifth = games.firstWhere((g) => g.id == 5);
      expect(fifth.recommendedPlayerCount, '4, 6+');
      expect(fifth.recommendedPlayerCountMin, 4);
      expect(fifth.recommendedPlayerCountMax, isNull);
    });

    test(
      'falls back to legacy best player count when poll-summary is missing',
      () async {
        when(() => sessionStore.load()).thenAnswer(
          (_) async => const BggSession(
            sessionCookies: 'bggusername=u; bggpassword=p; SessionID=s',
            apiToken: 'my-bearer-token',
          ),
        );

        const xml = '''
<items>
  <item id="1">
    <name type="primary" value="Catan"/>
    <poll name="suggested_numplayers" totalvotes="10">
      <results numplayers="3">
        <result value="Best" numvotes="7"/>
      </results>
    </poll>
  </item>
</items>
''';

        when(
          () => client.get(
            Uri.parse('https://boardgamegeek.com/xmlapi2/thing?id=1&stats=1'),
            headers: any(named: 'headers'),
          ),
        ).thenAnswer(
          (_) async => http.Response.bytes(
            utf8.encode(xml),
            200,
            headers: {'content-type': 'text/xml; charset=utf-8'},
          ),
        );

        final games = await apiClient.fetchGames([1]);

        expect(games.first.bestPlayerCount, '3');
      },
    );
  });
}
