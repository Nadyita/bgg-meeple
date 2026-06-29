import 'package:bgg_meeple/application/use_cases/load_card_layout_use_case.dart';
import 'package:bgg_meeple/application/use_cases/save_card_layout_use_case.dart';
import 'package:bgg_meeple/domain/ports/card_layout_store.dart';
import 'package:bgg_meeple/domain/value_objects/card_field.dart';
import 'package:bgg_meeple/domain/value_objects/card_layout_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCardLayoutStore extends Mock implements CardLayoutStore {}

void main() {
  group('LoadCardLayoutUseCase', () {
    late CardLayoutStore store;
    late LoadCardLayoutUseCase useCase;

    setUp(() {
      store = _MockCardLayoutStore();
      useCase = LoadCardLayoutUseCase(store);
    });

    test('returns layout from store', () async {
      const layout = CardLayoutConfig(
        enabledFields: [CardField.playerCount],
        fieldOrder: [CardField.bggRank, CardField.playerCount],
      );
      when(store.load).thenAnswer((_) async => layout);

      final result = await useCase();

      expect(result, layout);
      verify(store.load).called(1);
    });
  });

  group('SaveCardLayoutUseCase', () {
    late CardLayoutStore store;
    late SaveCardLayoutUseCase useCase;

    setUp(() {
      store = _MockCardLayoutStore();
      useCase = SaveCardLayoutUseCase(store);
    });

    test('saves layout to store', () async {
      const layout = CardLayoutConfig(showThumbnail: false);
      when(() => store.save(layout)).thenAnswer((_) async {});

      await useCase(layout);

      verify(() => store.save(layout)).called(1);
    });
  });
}
