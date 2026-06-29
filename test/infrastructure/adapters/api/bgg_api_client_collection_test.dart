import 'package:bgg_meeple/infrastructure/adapters/api/bgg_api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class _MockHttpClient extends Mock implements http.Client {}

void main() {
  group('BggApiClient.fetchCollection', () {
    late http.Client client;
    late BggApiClient apiClient;

    setUp(() {
      client = _MockHttpClient();
      apiClient = BggApiClient(httpClient: client);
    });

    test('parses the real BGG collection XML', () async {
      when(
        () => client.get(
          Uri.parse(
            'https://boardgamegeek.com/xmlapi2/collection?username=real&version=1&stats=1',
          ),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer(
        (_) async => http.Response('''
          <?xml version="1.0" encoding="utf-8" standalone="yes"?>
          <items totalitems="2" termsofuse="https://boardgamegeek.com/xmlapi/termsofuse" pubdate="Thu, 25 Jun 2026 04:22:01 +0000">
            <item objecttype="thing" objectid="2719" subtype="boardgame" collid="146716083">
              <name sortindex="1">4 gewinnt</name>
              <originalname>Connect Four</originalname>
              <yearpublished>2008</yearpublished>
              <image>https://cf.geekdo-images.com/CSopwI-WJ1SfOzHbe4Bb5Q__original/img/CzVypv1luaszgDTrhlGvk-aqN4I=/0x0/filters:format(png)/pic2718569.png</image>
              <thumbnail>https://cf.geekdo-images.com/CSopwI-WJ1SfOzHbe4Bb5Q__small/img/I40pQrdvrrIppQVCO6IQn7UtqY0=/fit-in/200x150/filters:strip_icc()/pic2718569.png</thumbnail>
              <stats minplayers="2" maxplayers="2" minplaytime="10" maxplaytime="10" playingtime="10" numowned="16498">
                <rating value="N/A">
                  <usersrated value="10552"/>
                  <average value="5.02507"/>
                  <bayesaverage value="5.05634"/>
                  <stddev value="1.59236"/>
                  <median value="0"/>
                  <ranks>
                    <rank type="subtype" id="1" name="boardgame" friendlyname="Board Game Rank" value="30795" bayesaverage="5.05634"/>
                  </ranks>
                </rating>
              </stats>
              <status own="1" prevowned="0" fortrade="0" want="0" wanttoplay="0" wanttobuy="0" wishlist="0" preordered="0" lastmodified="2026-06-24 09:12:37"/>
              <numplays>0</numplays>
              <version>
                <item type="boardgameversion" id="288960">
                  <thumbnail>https://cf.geekdo-images.com/CSopwI-WJ1SfOzHbe4Bb5Q__small/img/I40pQrdvrrIppQVCO6IQn7UtqY0=/fit-in/200x150/filters:strip_icc()/pic2718569.png</thumbnail>
                  <image>https://cf.geekdo-images.com/CSopwI-WJ1SfOzHbe4Bb5Q__original/img/CzVypv1luaszgDTrhlGvk-aqN4I=/0x0/filters:format(png)/pic2718569.png</image>
                  <canonicalname value="4"/>
                  <link type="boardgameversion" id="2719" value="Connect Four" inbound="true"/>
                  <name type="primary" sortindex="1" value="Schmidt multilingual edition 2008"/>
                  <link type="boardgamepublisher" id="38" value="Schmidt Spiele"/>
                  <yearpublished value="2008"/>
                  <productcode value="51214"/>
                  <width value="4.48819"/>
                  <length value="7.24409"/>
                  <depth value="1.53543"/>
                  <weight value="0.507063"/>
                  <link type="language" id="2183" value="Dutch"/>
                  <link type="language" id="2188" value="German"/>
                  <link type="language" id="2193" value="Italian"/>
                </item>
              </version>
            </item>
            <item objecttype="thing" objectid="468438" subtype="boardgame" collid="146735594">
              <name sortindex="1">Crime Places: Zirkus Inferno</name>
              <yearpublished>2026</yearpublished>
              <image>https://cf.geekdo-images.com/JDFzIY3-WzEEX-2tIQ2Mzw__original/img/jhH9dzswiO4NyOlY0pBOr03Erf8=/0x0/filters:format(jpeg)/pic9652441.jpg</image>
              <thumbnail>https://cf.geekdo-images.com/JDFzIY3-WzEEX-2tIQ2Mzw__small/img/9xqBEjI8WuoKtk1nVBFtZzqoCpU=/fit-in/200x150/filters:strip_icc()/pic9652441.jpg</thumbnail>
              <stats minplayers="1" maxplayers="4" minplaytime="120" maxplaytime="180" playingtime="180" numowned="2">
                <rating value="N/A">
                  <usersrated value="0"/>
                  <average value="0"/>
                  <bayesaverage value="0"/>
                  <stddev value="0"/>
                  <median value="0"/>
                  <ranks>
                    <rank type="subtype" id="1" name="boardgame" friendlyname="Board Game Rank" value="Not Ranked" bayesaverage="Not Ranked"/>
                  </ranks>
                </rating>
              </stats>
              <status own="1" prevowned="0" fortrade="0" want="0" wanttoplay="0" wanttobuy="0" wishlist="0" preordered="0" lastmodified="2026-06-23 01:10:00"/>
              <numplays>0</numplays>
              <version>
                <imageid value="9652441"/>
              </version>
            </item>
          </items>
          ''', 200),
      );

      final items = await apiClient.fetchCollection('real');

      expect(items.length, 2);

      final gewinnt = items.first;
      expect(gewinnt.thingId, 2719);
      expect(gewinnt.collId, 146716083);
      expect(gewinnt.displayName(preferredLanguage: 'de'), '4 gewinnt');
      expect(gewinnt.names.first.value, '4 gewinnt');
      expect(gewinnt.names.first.isPrimary, isTrue);
      expect(gewinnt.names.last.value, 'Connect Four');
      expect(gewinnt.yearPublished, 2008);
      expect(gewinnt.minPlayers, 2);
      expect(gewinnt.maxPlayers, 2);
      expect(gewinnt.minPlayTime, 10);
      expect(gewinnt.maxPlayTime, 10);
      expect(gewinnt.bayesAverage, 5.05634);
      expect(gewinnt.ownRating, isNull);
      expect(gewinnt.numPlays, 0);
      expect(gewinnt.geekRatingUserCount, 10552);
      expect(gewinnt.bggRank, 30795);
      expect(gewinnt.thumbnailUrl, isNotNull);
      expect(gewinnt.version?.name, 'Schmidt multilingual edition 2008');
      expect(gewinnt.version?.year, 2008);
      expect(gewinnt.isOwned, isTrue);

      expect(items.last.collId, 146735594);

      final crime = items.last;
      expect(crime.thingId, 468438);
      expect(
        crime.displayName(preferredLanguage: 'de'),
        'Crime Places: Zirkus Inferno',
      );
      expect(crime.minPlayers, 1);
      expect(crime.maxPlayers, 4);
      expect(crime.minPlayTime, 120);
      expect(crime.maxPlayTime, 180);
      expect(crime.bayesAverage, isNull);
      expect(crime.ownRating, isNull);
      expect(crime.version, isNull);
      expect(crime.geekRatingUserCount, 0);
      expect(crime.bggRank, isNull);
    });

    test('returns empty list for empty collection', () async {
      when(
        () => client.get(
          Uri.parse(
            'https://boardgamegeek.com/xmlapi2/collection?username=empty&version=1&stats=1',
          ),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer(
        (_) async => http.Response(
          '<?xml version="1.0"?><items totalitems="0" termsofuse="..."></items>',
          200,
        ),
      );

      final items = await apiClient.fetchCollection('empty');
      expect(items, isEmpty);
    });
  });
}
