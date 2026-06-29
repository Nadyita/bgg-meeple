import 'package:bgg_meeple/domain/entities/board_game.dart';
import 'package:bgg_meeple/domain/value_objects/localized_name.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BoardGame', () {
    test('holds all required fields', () {
      const game = BoardGame(
        id: 42,
        names: [
          LocalizedName(value: 'Catan', language: 'English', isPrimary: true),
        ],
        imageUrl: 'https://example.com/image.png',
        thumbnailUrl: 'https://example.com/thumb.png',
        yearPublished: 1995,
        minPlayers: 3,
        maxPlayers: 4,
        minPlayTime: 60,
        maxPlayTime: 120,
        minAge: 10,
        bayesAverage: 7.12,
      );

      expect(game.id, 42);
      expect(game.names.length, 1);
      expect(game.names.first.value, 'Catan');
      expect(game.yearPublished, 1995);
      expect(game.bayesAverage, 7.12);
    });

    test('toString contains id', () {
      const game = BoardGame(
        id: 1,
        names: [LocalizedName(value: 'A', language: null, isPrimary: true)],
      );

      expect(game.toString(), contains('id: 1'));
    });
  });
}
