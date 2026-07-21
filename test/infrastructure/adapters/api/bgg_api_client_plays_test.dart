import 'package:bgg_meeple/domain/entities/bgg_session.dart';
import 'package:bgg_meeple/domain/ports/session_store.dart';
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

  group('BggApiClient.fetchPlays', () {
    late http.Client client;
    late _MockSessionStore sessionStore;
    late BggApiClient apiClient;

    setUp(() {
      client = _MockHttpClient();
      sessionStore = _MockSessionStore();
      apiClient = BggApiClient(
        httpClient: client,
        sessionStore: sessionStore,
        retryDelay: Duration.zero,
      );
      when(() => sessionStore.load()).thenAnswer(
        (_) async => const BggSession(
          sessionCookies: 'bggusername=u; bggpassword=p; SessionID=s',
          apiToken: 'my-bearer-token',
        ),
      );
    });

    test('fetches a single page of plays', () async {
      when(
        () => client.get(
          Uri.parse(
            'https://boardgamegeek.com/xmlapi2/plays?username=reidel&subtype=boardgame&page=1',
          ),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer(
        (_) async => http.Response('''<?xml version="1.0" encoding="utf-8"?>
          <plays username="reidel" userid="4650728" total="2" page="1" termsofuse="https://boardgamegeek.com/xmlapi/termsofuse">
            <play id="116471755" date="2026-07-18" quantity="1" length="0" incomplete="0" nowinstats="0" location="">
              <item name="Anno Domini: Frauen" objecttype="thing" objectid="17924">
                <subtypes>
                  <subtype value="boardgame"/>
                </subtypes>
              </item>
              <players>
                <player username="" userid="0" name="Dine" startposition="" color="" score="" new="0" rating="0" win="0"/>
              </players>
            </play>
            <play id="116471756" date="2026-07-19" quantity="3" length="90" incomplete="1" nowinstats="1" location="Home">
              <item name="Catan" objecttype="thing" objectid="13">
                <subtypes>
                  <subtype value="boardgame"/>
                </subtypes>
              </item>
              <comments>Fun game</comments>
              <players>
                <player username="reidel" userid="4650728" name="Mark" startposition="1" color="red" score="10" new="1" rating="8" win="1"/>
              </players>
            </play>
          </plays>''', 200),
      );

      final plays = await apiClient.fetchPlays('reidel');

      expect(plays, hasLength(2));

      final first = plays.first;
      expect(first.id, 116471755);
      expect(first.thingId, 17924);
      expect(first.gameName, 'Anno Domini: Frauen');
      expect(first.date, '2026-07-18');
      expect(first.quantity, 1);
      expect(first.length, 0);
      expect(first.incomplete, false);
      expect(first.noWinStats, false);
      expect(first.location, isNull);
      expect(first.comments, isNull);
      expect(first.subtypes, ['boardgame']);
      expect(first.players, hasLength(1));
      expect(first.players.first.name, 'Dine');

      final second = plays.last;
      expect(second.id, 116471756);
      expect(second.thingId, 13);
      expect(second.gameName, 'Catan');
      expect(second.quantity, 3);
      expect(second.length, 90);
      expect(second.incomplete, isTrue);
      expect(second.noWinStats, isTrue);
      expect(second.location, 'Home');
      expect(second.comments, 'Fun game');
      expect(second.players.first.username, 'reidel');
      expect(second.players.first.userId, 4650728);
      expect(second.players.first.startPosition, '1');
      expect(second.players.first.color, 'red');
      expect(second.players.first.score, '10');
      expect(second.players.first.newPlayer, isTrue);
      expect(second.players.first.rating, 8.0);
      expect(second.players.first.win, isTrue);
    });

    test('fetches multiple pages until all plays are loaded', () async {
      when(
        () => client.get(
          Uri.parse(
            'https://boardgamegeek.com/xmlapi2/plays?username=reidel&subtype=boardgame&page=1',
          ),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer(
        (_) async => http.Response('''<?xml version="1.0" encoding="utf-8"?>
          <plays username="reidel" userid="4650728" total="3" page="1" termsofuse="...">
            <play id="1" date="2026-07-18" quantity="1" length="0" incomplete="0" nowinstats="0" location="">
              <item name="Game A" objecttype="thing" objectid="1"/>
            </play>
            <play id="2" date="2026-07-18" quantity="1" length="0" incomplete="0" nowinstats="0" location="">
              <item name="Game A" objecttype="thing" objectid="1"/>
            </play>
          </plays>''', 200),
      );

      when(
        () => client.get(
          Uri.parse(
            'https://boardgamegeek.com/xmlapi2/plays?username=reidel&subtype=boardgame&page=2',
          ),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer(
        (_) async => http.Response('''<?xml version="1.0" encoding="utf-8"?>
          <plays username="reidel" userid="4650728" total="3" page="2" termsofuse="...">
            <play id="3" date="2026-07-19" quantity="1" length="0" incomplete="0" nowinstats="0" location="">
              <item name="Game A" objecttype="thing" objectid="1"/>
            </play>
          </plays>''', 200),
      );

      final plays = await apiClient.fetchPlays('reidel');

      expect(plays, hasLength(3));
      expect(plays.map((p) => p.id), [1, 2, 3]);

      verify(
        () => client.get(
          Uri.parse(
            'https://boardgamegeek.com/xmlapi2/plays?username=reidel&subtype=boardgame&page=1',
          ),
          headers: any(named: 'headers'),
        ),
      ).called(1);
      verify(
        () => client.get(
          Uri.parse(
            'https://boardgamegeek.com/xmlapi2/plays?username=reidel&subtype=boardgame&page=2',
          ),
          headers: any(named: 'headers'),
        ),
      ).called(1);
    });

    test('returns empty list when user has no plays', () async {
      when(
        () => client.get(
          Uri.parse(
            'https://boardgamegeek.com/xmlapi2/plays?username=empty&subtype=boardgame&page=1',
          ),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer(
        (_) async => http.Response('''<?xml version="1.0" encoding="utf-8"?>
          <plays username="empty" userid="0" total="0" page="1" termsofuse="...">
          </plays>''', 200),
      );

      final plays = await apiClient.fetchPlays('empty');

      expect(plays, isEmpty);
    });

    test('retries on HTTP 202 and then returns plays', () async {
      when(
        () => client.get(
          Uri.parse(
            'https://boardgamegeek.com/xmlapi2/plays?username=reidel&subtype=boardgame&page=1',
          ),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer((_) async => http.Response('', 202));
      when(
        () => client.get(
          Uri.parse(
            'https://boardgamegeek.com/xmlapi2/plays?username=reidel&subtype=boardgame&page=1',
          ),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer(
        (_) async => http.Response('''<?xml version="1.0" encoding="utf-8"?>
          <plays username="reidel" userid="4650728" total="1" page="1" termsofuse="...">
            <play id="1" date="2026-07-18" quantity="1" length="0" incomplete="0" nowinstats="0" location="">
              <item name="Game A" objecttype="thing" objectid="1"/>
            </play>
          </plays>''', 200),
      );

      final plays = await apiClient.fetchPlays('reidel');

      expect(plays, hasLength(1));
    });

    test('throws BggSessionExpiredException on 401', () async {
      when(
        () => client.get(
          Uri.parse(
            'https://boardgamegeek.com/xmlapi2/plays?username=reidel&subtype=boardgame&page=1',
          ),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer((_) async => http.Response('unauthorized', 401));

      expect(
        () => apiClient.fetchPlays('reidel'),
        throwsA(isA<BggSessionExpiredException>()),
      );
    });

    test('handles play without players', () async {
      when(
        () => client.get(
          Uri.parse(
            'https://boardgamegeek.com/xmlapi2/plays?username=reidel&subtype=boardgame&page=1',
          ),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer(
        (_) async => http.Response('''<?xml version="1.0" encoding="utf-8"?>
          <plays username="reidel" userid="4650728" total="1" page="1" termsofuse="...">
            <play id="1" date="2026-07-18" quantity="1" length="0" incomplete="0" nowinstats="0" location="">
              <item name="Solo Game" objecttype="thing" objectid="1"/>
            </play>
          </plays>''', 200),
      );

      final plays = await apiClient.fetchPlays('reidel');

      expect(plays.single.players, isEmpty);
    });
  });
}
