import 'package:bgg_meeple/infrastructure/adapters/api/bgg_api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class _MockHttpClient extends Mock implements http.Client {}

void main() {
  group('BggApiClient.fetchCollection with multiple editions', () {
    late http.Client client;
    late BggApiClient apiClient;

    setUp(() {
      client = _MockHttpClient();
      apiClient = BggApiClient(httpClient: client);
    });

    test('keeps separate collection items for the same thingId', () async {
      when(
        () => client.get(
          Uri.parse(
            'https://boardgamegeek.com/xmlapi2/collection?username=multi&version=1&stats=1',
          ),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer(
        (_) async => http.Response('''
          <?xml version="1.0" encoding="utf-8" standalone="yes"?>
          <items totalitems="2" termsofuse="...">
            <item objecttype="thing" objectid="268620" subtype="boardgame" collid="146734775">
              <name sortindex="1">Similo: Märchen</name>
              <originalname>Similo</originalname>
              <yearpublished>2021</yearpublished>
              <image>https://example.com/maerchen.jpg</image>
              <thumbnail>https://example.com/maerchen_t.jpg</thumbnail>
              <stats minplayers="2" maxplayers="8" minplaytime="10" maxplaytime="15" playingtime="15" numowned="24345">
                <rating value="N/A">
                  <usersrated value="7888"/>
                  <average value="6.79133"/>
                  <bayesaverage value="6.47034"/>
                </rating>
              </stats>
              <status own="1" />
              <numplays>0</numplays>
              <version>
                <item type="boardgameversion" id="626612">
                  <name type="primary" sortindex="1" value="German edition 2021"/>
                  <yearpublished value="2021"/>
                </item>
              </version>
            </item>
            <item objecttype="thing" objectid="268620" subtype="boardgame" collid="146718313">
              <name sortindex="1">Similo: Tiere</name>
              <originalname>Similo</originalname>
              <yearpublished>2020</yearpublished>
              <image>https://example.com/tiere.png</image>
              <thumbnail>https://example.com/tiere_t.png</thumbnail>
              <stats minplayers="2" maxplayers="8" minplaytime="10" maxplaytime="15" playingtime="15" numowned="24345">
                <rating value="N/A">
                  <usersrated value="7888"/>
                  <average value="6.79133"/>
                  <bayesaverage value="6.47034"/>
                </rating>
              </stats>
              <status own="1" />
              <numplays>0</numplays>
              <version>
                <item type="boardgameversion" id="520627">
                  <name type="primary" sortindex="1" value="German edition"/>
                  <yearpublished value="2020"/>
                </item>
              </version>
            </item>
          </items>
          ''', 200),
      );

      final items = await apiClient.fetchCollection('multi');

      expect(items.length, 2);
      expect(items.map((i) => i.collId), containsAll([146734775, 146718313]));
      expect(items.every((i) => i.thingId == 268620), isTrue);

      final maerchen = items.firstWhere((i) => i.collId == 146734775);
      expect(maerchen.displayName(preferredLanguage: 'de'), 'Similo: Märchen');
      expect(maerchen.version?.name, 'German edition 2021');
      expect(maerchen.version?.year, 2021);

      final tiere = items.firstWhere((i) => i.collId == 146718313);
      expect(tiere.displayName(preferredLanguage: 'de'), 'Similo: Tiere');
      expect(tiere.version?.name, 'German edition');
      expect(tiere.version?.year, 2020);
    });
  });
}
