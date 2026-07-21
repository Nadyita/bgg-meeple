import 'package:bgg_meeple/domain/entities/play.dart';
import 'package:bgg_meeple/domain/entities/play_player.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Play', () {
    const play = Play(
      id: 1,
      thingId: 13,
      gameName: 'Catan',
      date: '2026-07-18',
      quantity: 2,
      length: 90,
      incomplete: true,
      noWinStats: true,
      location: 'Home',
      comments: 'Fun',
      subtypes: ['boardgame'],
      players: [
        PlayPlayer(
          name: 'Mark',
          score: '10',
          newPlayer: true,
          rating: 8.0,
          win: true,
        ),
      ],
    );

    test('holds all required fields', () {
      expect(play.id, 1);
      expect(play.thingId, 13);
      expect(play.gameName, 'Catan');
      expect(play.date, '2026-07-18');
      expect(play.quantity, 2);
      expect(play.length, 90);
      expect(play.incomplete, isTrue);
      expect(play.noWinStats, isTrue);
      expect(play.location, 'Home');
      expect(play.comments, 'Fun');
      expect(play.subtypes, ['boardgame']);
      expect(play.players, hasLength(1));
    });

    test('copyWith creates an updated copy', () {
      final updated = play.copyWith(quantity: 5, length: 120);

      expect(updated.quantity, 5);
      expect(updated.length, 120);
      expect(updated.id, play.id);
      expect(updated.players, play.players);
    });

    test('equality considers value fields', () {
      final same = play.copyWith();
      final different = play.copyWith(quantity: 99);

      expect(play, same);
      expect(play, isNot(equals(different)));
    });

    test('defaults quantity to 1 and length to 0', () {
      const minimal = Play(
        id: 2,
        thingId: 42,
        gameName: 'Tic-Tac-Toe',
        date: '2026-07-19',
      );

      expect(minimal.quantity, 1);
      expect(minimal.length, 0);
      expect(minimal.incomplete, false);
      expect(minimal.noWinStats, false);
      expect(minimal.players, isEmpty);
    });
  });

  group('PlayPlayer', () {
    const player = PlayPlayer(
      username: 'reidel',
      userId: 4650728,
      name: 'Mark',
      startPosition: '1',
      color: 'red',
      score: '10',
      newPlayer: true,
      rating: 8.0,
      win: true,
    );

    test('holds all required fields', () {
      expect(player.username, 'reidel');
      expect(player.userId, 4650728);
      expect(player.name, 'Mark');
      expect(player.startPosition, '1');
      expect(player.color, 'red');
      expect(player.score, '10');
      expect(player.newPlayer, isTrue);
      expect(player.rating, 8.0);
      expect(player.win, isTrue);
    });

    test('copyWith creates an updated copy', () {
      final updated = player.copyWith(score: '12', win: false);

      expect(updated.score, '12');
      expect(updated.win, false);
      expect(updated.name, player.name);
    });

    test('equality considers value fields', () {
      final same = player.copyWith();
      final different = player.copyWith(score: '99');

      expect(player, same);
      expect(player, isNot(equals(different)));
    });
  });
}
