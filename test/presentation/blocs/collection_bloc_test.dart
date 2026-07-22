import 'package:bloc_test/bloc_test.dart';
import 'package:bgg_meeple/application/use_cases/load_card_layout_use_case.dart';
import 'package:bgg_meeple/application/use_cases/load_collection_use_case.dart';
import 'package:bgg_meeple/application/use_cases/load_collection_view_use_case.dart';
import 'package:bgg_meeple/application/use_cases/load_credentials_use_case.dart';
import 'package:bgg_meeple/application/use_cases/load_plays_info_use_case.dart';
import 'package:bgg_meeple/domain/entities/bgg_credentials.dart';
import 'package:bgg_meeple/domain/entities/play.dart';
import 'package:bgg_meeple/domain/entities/play_player.dart';
import 'package:bgg_meeple/domain/value_objects/plays_info.dart';
import 'package:bgg_meeple/application/use_cases/save_collection_view_use_case.dart';
import 'package:bgg_meeple/application/use_cases/sync_collection_use_case.dart';
import 'package:bgg_meeple/domain/entities/collection_item.dart';
import 'package:bgg_meeple/domain/value_objects/card_field.dart';
import 'package:bgg_meeple/domain/value_objects/card_layout_config.dart';
import 'package:bgg_meeple/domain/value_objects/collection_filter.dart';
import 'package:bgg_meeple/domain/value_objects/collection_sort.dart';
import 'package:bgg_meeple/domain/value_objects/collection_sub_type.dart';
import 'package:bgg_meeple/domain/value_objects/collection_view.dart';
import 'package:bgg_meeple/domain/value_objects/localized_name.dart';
import 'package:bgg_meeple/domain/value_objects/player_participation_filter.dart';
import 'package:bgg_meeple/domain/value_objects/version_info.dart';
import 'package:bgg_meeple/presentation/blocs/collection/collection_bloc.dart';
import 'package:bgg_meeple/presentation/blocs/collection/collection_event.dart';
import 'package:bgg_meeple/presentation/blocs/collection/collection_state.dart';
import 'package:bgg_meeple/presentation/l10n/app_localizations_en.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLoadCollectionUseCase extends Mock
    implements LoadCollectionUseCase {}

class _MockLoadCardLayoutUseCase extends Mock
    implements LoadCardLayoutUseCase {}

class _MockLoadCollectionViewUseCase extends Mock
    implements LoadCollectionViewUseCase {}

class _MockSaveCollectionViewUseCase extends Mock
    implements SaveCollectionViewUseCase {}

class _MockSyncCollectionUseCase extends Mock
    implements SyncCollectionUseCase {}

class _MockLoadPlaysInfoUseCase extends Mock implements LoadPlaysInfoUseCase {}

class _FakeLoadCredentialsUseCase extends Fake
    implements LoadCredentialsUseCase {
  @override
  Future<BggCredentials?> call() async => null;
}

class _CollectionViewFake extends Fake implements CollectionView {}

class _FakeLoadCollectionViewUseCase extends Fake
    implements LoadCollectionViewUseCase {
  @override
  Future<CollectionView> call() async => const CollectionView();
}

class _FakeSaveCollectionViewUseCase extends Fake
    implements SaveCollectionViewUseCase {
  @override
  Future<void> call(CollectionView view) async {}
}

CollectionBloc _buildBloc({
  required LoadCollectionUseCase loadCollection,
  required LoadCardLayoutUseCase loadCardLayout,
  LoadCollectionViewUseCase? loadCollectionView,
  SaveCollectionViewUseCase? saveCollectionView,
  LoadCredentialsUseCase? loadCredentials,
  LoadPlaysInfoUseCase? loadPlaysInfo,
  SyncCollectionUseCase? syncCollection,
}) {
  return CollectionBloc(
    loadCollection: loadCollection,
    loadCardLayout: loadCardLayout,
    loadCollectionView: loadCollectionView ?? _FakeLoadCollectionViewUseCase(),
    saveCollectionView: saveCollectionView ?? _FakeSaveCollectionViewUseCase(),
    loadCredentials: loadCredentials ?? _FakeLoadCredentialsUseCase(),
    loadPlaysInfo: loadPlaysInfo ?? _FakeLoadPlaysInfoUseCase(),
    syncCollection: syncCollection,
  );
}

class _FakeLoadPlaysInfoUseCase extends Fake implements LoadPlaysInfoUseCase {
  @override
  Future<PlaysInfo> call() async => const PlaysInfo();
}

void main() {
  setUpAll(() {
    registerFallbackValue(_CollectionViewFake());
  });

  group('CollectionBloc', () {
    late LoadCollectionUseCase loadCollection;
    late LoadCardLayoutUseCase loadCardLayout;
    late LoadCollectionViewUseCase loadCollectionView;
    late SaveCollectionViewUseCase saveCollectionView;
    late LoadPlaysInfoUseCase loadPlaysInfo;

    setUp(() {
      loadCollection = _MockLoadCollectionUseCase();
      loadCardLayout = _MockLoadCardLayoutUseCase();
      loadCollectionView = _MockLoadCollectionViewUseCase();
      saveCollectionView = _MockSaveCollectionViewUseCase();
      loadPlaysInfo = _MockLoadPlaysInfoUseCase();
      when(
        loadCardLayout.call,
      ).thenAnswer((_) async => const CardLayoutConfig());
      when(
        loadCollectionView.call,
      ).thenAnswer((_) async => const CollectionView());
      when(() => saveCollectionView.call(any())).thenAnswer((_) async {});
      when(loadPlaysInfo.call).thenAnswer((_) async => const PlaysInfo());
    });

    blocTest<CollectionBloc, CollectionState>(
      'loads plays info with collection',
      build: () {
        when(loadCollection.call).thenAnswer(
          (_) async => const [
            CollectionItem(thingId: 1, names: []),
            CollectionItem(thingId: 2, names: []),
          ],
        );
        final play1 = _play(
          thingId: 1,
          players: [const PlayPlayer(name: 'Dine')],
        );
        final play2 = _play(
          thingId: 1,
          players: [const PlayPlayer(name: 'Mark')],
        );
        final play3 = _play(
          thingId: 2,
          players: [const PlayPlayer(name: 'Eva')],
        );
        when(loadPlaysInfo.call).thenAnswer(
          (_) async => PlaysInfo(
            playerNamesByGame: const {
              1: ['Dine', 'Mark'],
              2: ['Eva'],
            },
            playsByGame: {
              1: [play1, play2],
              2: [play3],
            },
          ),
        );
        return _buildBloc(
          loadCollection: loadCollection,
          loadCardLayout: loadCardLayout,
          loadCollectionView: loadCollectionView,
          saveCollectionView: saveCollectionView,
          loadPlaysInfo: loadPlaysInfo,
        );
      },
      act: (bloc) => bloc.add(const CollectionLoaded()),
      skip: 1,
      expect: () => [
        predicate<CollectionState>(
          (s) =>
              s.playsInfo.playerNamesByGame[1]!.length == 2 &&
              s.playsInfo.playerNamesByGame[1]![0] == 'Dine' &&
              s.playsInfo.playerNamesByGame[1]![1] == 'Mark' &&
              s.playsInfo.playerNamesByGame[2]!.length == 1 &&
              s.playsInfo.playerNamesByGame[2]![0] == 'Eva' &&
              s.playsInfo.playsByGame[1]!.length == 2 &&
              s.playsInfo.playsByGame[2]!.length == 1,
        ),
      ],
    );

    blocTest<CollectionBloc, CollectionState>(
      'emits loaded items on CollectionLoaded',
      build: () {
        when(loadCollection.call).thenAnswer(
          (_) async => const [
            CollectionItem(thingId: 1, names: []),
            CollectionItem(thingId: 2, names: []),
          ],
        );
        return _buildBloc(
          loadCollection: loadCollection,
          loadCardLayout: loadCardLayout,
          loadCollectionView: loadCollectionView,
          saveCollectionView: saveCollectionView,
        );
      },
      act: (bloc) => bloc.add(const CollectionLoaded()),
      expect: () => [
        const CollectionState(isLoading: true),
        const CollectionState(
          items: [
            CollectionItem(thingId: 1, names: []),
            CollectionItem(thingId: 2, names: []),
          ],
          filteredItems: [
            CollectionItem(thingId: 1, names: []),
            CollectionItem(thingId: 2, names: []),
          ],
          cardLayout: CardLayoutConfig(),
        ),
      ],
    );

    blocTest<CollectionBloc, CollectionState>(
      'emits error when loading fails',
      build: () {
        when(loadCollection.call).thenThrow(Exception('database error'));
        return _buildBloc(
          loadCollection: loadCollection,
          loadCardLayout: loadCardLayout,
          loadCollectionView: loadCollectionView,
          saveCollectionView: saveCollectionView,
        );
      },
      act: (bloc) => bloc.add(const CollectionLoaded()),
      expect: () => [
        const CollectionState(isLoading: true),
        predicate<CollectionState>(
          (s) =>
              s.errorMessage(AppLocalizationsEn()) ==
              'Failed to load collection: Exception: database error',
        ),
      ],
    );

    blocTest<CollectionBloc, CollectionState>(
      'filters items by search text',
      build: () {
        when(loadCollection.call).thenAnswer(
          (_) async => [
            const CollectionItem(
              thingId: 1,
              names: [
                LocalizedName(value: 'Catan', language: null, isPrimary: true),
              ],
            ),
            const CollectionItem(
              thingId: 2,
              names: [
                LocalizedName(
                  value: 'Carcassonne',
                  language: null,
                  isPrimary: true,
                ),
              ],
            ),
          ],
        );
        return _buildBloc(
          loadCollection: loadCollection,
          loadCardLayout: loadCardLayout,
          loadCollectionView: loadCollectionView,
          saveCollectionView: saveCollectionView,
        );
      },
      act: (bloc) => bloc
        ..add(const CollectionLoaded())
        ..add(const CollectionSearchTextChanged('car'))
        ..add(const CollectionSearchTextChanged('')),
      skip: 3,
      expect: () => [
        predicate<CollectionState>(
          (s) => s.searchText.isEmpty && s.filteredItems.length == 2,
        ),
      ],
    );

    blocTest<CollectionBloc, CollectionState>(
      'search only matches game names, not version names',
      build: () {
        when(loadCollection.call).thenAnswer(
          (_) async => [
            const CollectionItem(
              thingId: 1,
              names: [
                LocalizedName(value: 'Catan', language: null, isPrimary: true),
              ],
              version: VersionInfo(
                id: 10,
                name: 'Carcassonne big box',
                year: null,
              ),
            ),
            const CollectionItem(
              thingId: 2,
              names: [
                LocalizedName(
                  value: 'Carcassonne',
                  language: null,
                  isPrimary: true,
                ),
              ],
              version: VersionInfo(
                id: 11,
                name: 'Catan revised edition',
                year: null,
              ),
            ),
          ],
        );
        return _buildBloc(
          loadCollection: loadCollection,
          loadCardLayout: loadCardLayout,
          loadCollectionView: loadCollectionView,
          saveCollectionView: saveCollectionView,
        );
      },
      act: (bloc) => bloc
        ..add(const CollectionLoaded())
        ..add(const CollectionSearchTextChanged('car')),
      skip: 2,
      expect: () => [
        predicate<CollectionState>(
          (s) =>
              s.searchText == 'car' &&
              s.filteredItems.length == 1 &&
              s.filteredItems.first.thingId == 2,
        ),
      ],
    );

    blocTest<CollectionBloc, CollectionState>(
      'clears search, filters, and sort on CollectionViewCleared',
      build: () {
        when(loadCollection.call).thenAnswer(
          (_) async => const [
            CollectionItem(
              thingId: 1,
              names: [
                LocalizedName(value: 'Catan', language: null, isPrimary: true),
              ],
            ),
            CollectionItem(
              thingId: 2,
              names: [
                LocalizedName(
                  value: 'Carcassonne',
                  language: null,
                  isPrimary: true,
                ),
              ],
            ),
          ],
        );
        return _buildBloc(
          loadCollection: loadCollection,
          loadCardLayout: loadCardLayout,
          loadCollectionView: loadCollectionView,
          saveCollectionView: saveCollectionView,
        );
      },
      act: (bloc) => bloc
        ..add(const CollectionLoaded())
        ..add(const CollectionSearchTextChanged('car'))
        ..add(
          const CollectionFilterChanged(
            CollectionFilter(selectedSubTypes: [CollectionSubType.owned]),
          ),
        )
        ..add(
          const CollectionSortChanged(
            CollectionSort(sortBy: SortBy.playTime, ascending: false),
          ),
        )
        ..add(const CollectionViewCleared()),
      skip: 5,
      expect: () => [
        predicate<CollectionState>(
          (s) =>
              s.searchText.isEmpty &&
              s.filter == const CollectionFilter() &&
              s.sort == const CollectionSort() &&
              s.filteredItems.length == 2,
        ),
      ],
      verify: (_) {
        verify(() => saveCollectionView.call(const CollectionView())).called(1);
      },
    );

    blocTest<CollectionBloc, CollectionState>(
      'updates items after sync',
      build: () => _buildBloc(
        loadCollection: loadCollection,
        loadCardLayout: loadCardLayout,
      ),
      act: (bloc) => bloc.add(
        const CollectionSynced([CollectionItem(thingId: 3, names: [])]),
      ),
      expect: () => [
        const CollectionState(
          items: [CollectionItem(thingId: 3, names: [])],
          filteredItems: [CollectionItem(thingId: 3, names: [])],
        ),
      ],
    );

    blocTest<CollectionBloc, CollectionState>(
      'filters by collection sub-type with OR logic',
      build: () {
        when(loadCollection.call).thenAnswer(
          (_) async => const [
            CollectionItem(thingId: 1, names: [], isOwned: true),
            CollectionItem(thingId: 2, names: [], isWishlisted: true),
            CollectionItem(thingId: 3, names: []),
          ],
        );
        return _buildBloc(
          loadCollection: loadCollection,
          loadCardLayout: loadCardLayout,
          loadCollectionView: loadCollectionView,
          saveCollectionView: saveCollectionView,
        );
      },
      act: (bloc) => bloc
        ..add(const CollectionLoaded())
        ..add(
          const CollectionFilterChanged(
            CollectionFilter(
              selectedSubTypes: [
                CollectionSubType.owned,
                CollectionSubType.wishlisted,
              ],
            ),
          ),
        ),
      skip: 2,
      expect: () => [
        predicate<CollectionState>(
          (s) =>
              s.filteredItems.length == 2 &&
              s.filteredItems.every((i) => i.thingId == 1 || i.thingId == 2),
        ),
      ],
    );

    blocTest<CollectionBloc, CollectionState>(
      'filters by player count range',
      build: () {
        when(loadCollection.call).thenAnswer(
          (_) async => const [
            CollectionItem(thingId: 1, names: [], minPlayers: 2, maxPlayers: 4),
            CollectionItem(thingId: 2, names: [], minPlayers: 1, maxPlayers: 1),
            CollectionItem(thingId: 3, names: [], minPlayers: 3, maxPlayers: 5),
            CollectionItem(thingId: 4, names: [], minPlayers: 1, maxPlayers: 6),
          ],
        );
        return _buildBloc(
          loadCollection: loadCollection,
          loadCardLayout: loadCardLayout,
          loadCollectionView: loadCollectionView,
          saveCollectionView: saveCollectionView,
        );
      },
      act: (bloc) => bloc
        ..add(const CollectionLoaded())
        ..add(
          const CollectionFilterChanged(
            CollectionFilter(minPlayers: 2, maxPlayers: 4),
          ),
        ),
      skip: 2,
      expect: () => [
        predicate<CollectionState>(
          (s) =>
              s.filteredItems.length == 3 &&
              s.filteredItems.every(
                (i) => i.thingId == 1 || i.thingId == 3 || i.thingId == 4,
              ),
        ),
      ],
    );

    blocTest<CollectionBloc, CollectionState>(
      'filters by play time range using maxPlayTime',
      build: () {
        when(loadCollection.call).thenAnswer(
          (_) async => const [
            CollectionItem(thingId: 1, names: [], maxPlayTime: 60),
            CollectionItem(thingId: 2, names: [], maxPlayTime: 120),
            CollectionItem(thingId: 3, names: [], maxPlayTime: null),
          ],
        );
        return _buildBloc(
          loadCollection: loadCollection,
          loadCardLayout: loadCardLayout,
          loadCollectionView: loadCollectionView,
          saveCollectionView: saveCollectionView,
        );
      },
      act: (bloc) => bloc
        ..add(const CollectionLoaded())
        ..add(
          const CollectionFilterChanged(
            CollectionFilter(minPlayTime: 30, maxPlayTime: 90),
          ),
        ),
      skip: 2,
      expect: () => [
        predicate<CollectionState>(
          (s) =>
              s.filteredItems.length == 1 && s.filteredItems.first.thingId == 1,
        ),
      ],
    );

    blocTest<CollectionBloc, CollectionState>(
      'filters by play time range using minPlayTime fallback',
      build: () {
        when(loadCollection.call).thenAnswer(
          (_) async => const [
            CollectionItem(
              thingId: 1,
              names: [],
              minPlayTime: 45,
              maxPlayTime: null,
            ),
            CollectionItem(
              thingId: 2,
              names: [],
              minPlayTime: 120,
              maxPlayTime: null,
            ),
            CollectionItem(
              thingId: 3,
              names: [],
              minPlayTime: null,
              maxPlayTime: null,
            ),
          ],
        );
        return _buildBloc(
          loadCollection: loadCollection,
          loadCardLayout: loadCardLayout,
          loadCollectionView: loadCollectionView,
          saveCollectionView: saveCollectionView,
        );
      },
      act: (bloc) => bloc
        ..add(const CollectionLoaded())
        ..add(
          const CollectionFilterChanged(
            CollectionFilter(minPlayTime: 30, maxPlayTime: 90),
          ),
        ),
      skip: 2,
      expect: () => [
        predicate<CollectionState>(
          (s) =>
              s.filteredItems.length == 1 && s.filteredItems.first.thingId == 1,
        ),
      ],
    );

    blocTest<CollectionBloc, CollectionState>(
      'prefers own rating over bayesaverage for rating range filter',
      build: () {
        when(loadCollection.call).thenAnswer(
          (_) async => const [
            CollectionItem(
              thingId: 1,
              names: [],
              ownRating: 8.0,
              bayesAverage: 6.0,
            ),
            CollectionItem(
              thingId: 2,
              names: [],
              ownRating: null,
              bayesAverage: 7.5,
            ),
            CollectionItem(
              thingId: 3,
              names: [],
              ownRating: 6.0,
              bayesAverage: 8.0,
            ),
            CollectionItem(
              thingId: 4,
              names: [],
              ownRating: null,
              bayesAverage: null,
            ),
          ],
        );
        return _buildBloc(
          loadCollection: loadCollection,
          loadCardLayout: loadCardLayout,
          loadCollectionView: loadCollectionView,
          saveCollectionView: saveCollectionView,
        );
      },
      act: (bloc) => bloc
        ..add(const CollectionLoaded())
        ..add(
          const CollectionFilterChanged(
            CollectionFilter(minRating: 7.0, maxRating: 8.0),
          ),
        ),
      skip: 2,
      expect: () => [
        predicate<CollectionState>(
          (s) =>
              s.filteredItems.length == 2 &&
              s.filteredItems.every((i) => i.thingId == 1 || i.thingId == 2),
        ),
      ],
    );

    blocTest<CollectionBloc, CollectionState>(
      'combines search and filters with AND logic',
      build: () {
        when(loadCollection.call).thenAnswer(
          (_) async => const [
            CollectionItem(
              thingId: 1,
              names: [
                LocalizedName(value: 'Catan', language: null, isPrimary: true),
              ],
              isOwned: true,
            ),
            CollectionItem(
              thingId: 2,
              names: [
                LocalizedName(
                  value: 'Carcassonne',
                  language: null,
                  isPrimary: true,
                ),
              ],
              isOwned: true,
            ),
          ],
        );
        return _buildBloc(
          loadCollection: loadCollection,
          loadCardLayout: loadCardLayout,
          loadCollectionView: loadCollectionView,
          saveCollectionView: saveCollectionView,
        );
      },
      act: (bloc) => bloc
        ..add(const CollectionLoaded())
        ..add(const CollectionSearchTextChanged('car'))
        ..add(
          const CollectionFilterChanged(
            CollectionFilter(
              selectedSubTypes: [CollectionSubType.owned],
              minPlayers: 1,
              maxPlayers: 10,
            ),
          ),
        ),
      skip: 3,
      expect: () => [
        predicate<CollectionState>(
          (s) =>
              s.searchText == 'car' &&
              s.filteredItems.length == 1 &&
              s.filteredItems.first.thingId == 2,
        ),
      ],
    );

    blocTest<CollectionBloc, CollectionState>(
      'filters by player participation requiring played',
      build: () {
        when(loadCollection.call).thenAnswer(
          (_) async => const [
            CollectionItem(thingId: 1, names: []),
            CollectionItem(thingId: 2, names: []),
            CollectionItem(thingId: 3, names: []),
          ],
        );
        when(loadPlaysInfo.call).thenAnswer(
          (_) async => PlaysInfo(
            playerNamesByGame: const {
              1: ['Markus'],
              2: ['Markus', 'Anna'],
            },
            playsByGame: {
              1: [
                _play(
                  id: 1,
                  thingId: 1,
                  players: [const PlayPlayer(name: 'Markus')],
                ),
              ],
              2: [
                _play(
                  id: 2,
                  thingId: 2,
                  players: [
                    const PlayPlayer(name: 'Markus'),
                    const PlayPlayer(name: 'Anna'),
                  ],
                ),
              ],
            },
          ),
        );
        return _buildBloc(
          loadCollection: loadCollection,
          loadCardLayout: loadCardLayout,
          loadCollectionView: loadCollectionView,
          saveCollectionView: saveCollectionView,
          loadPlaysInfo: loadPlaysInfo,
        );
      },
      act: (bloc) => bloc
        ..add(const CollectionLoaded())
        ..add(
          const CollectionFilterChanged(
            CollectionFilter(
              playerParticipation: {'Markus': PlayerParticipationFilter.played},
            ),
          ),
        ),
      skip: 2,
      expect: () => [
        predicate<CollectionState>(
          (s) =>
              s.filteredItems.length == 2 &&
              s.filteredItems.every((i) => i.thingId == 1 || i.thingId == 2),
        ),
      ],
    );

    blocTest<CollectionBloc, CollectionState>(
      'filters by player participation requiring notPlayed for a combination',
      build: () {
        when(loadCollection.call).thenAnswer(
          (_) async => const [
            CollectionItem(thingId: 1, names: []),
            CollectionItem(thingId: 2, names: []),
            CollectionItem(thingId: 3, names: []),
          ],
        );
        when(loadPlaysInfo.call).thenAnswer(
          (_) async => PlaysInfo(
            playerNamesByGame: const {
              1: ['Markus', 'Dine'],
              2: ['Markus', 'Dine'],
            },
            playsByGame: {
              1: [
                _play(
                  id: 11,
                  thingId: 1,
                  players: [
                    const PlayPlayer(name: 'Markus'),
                    const PlayPlayer(name: 'Dine'),
                  ],
                ),
              ],
              2: [
                _play(
                  id: 21,
                  thingId: 2,
                  players: [const PlayPlayer(name: 'Dine')],
                ),
                _play(
                  id: 22,
                  thingId: 2,
                  players: [const PlayPlayer(name: 'Markus')],
                ),
              ],
            },
          ),
        );
        return _buildBloc(
          loadCollection: loadCollection,
          loadCardLayout: loadCardLayout,
          loadCollectionView: loadCollectionView,
          saveCollectionView: saveCollectionView,
          loadPlaysInfo: loadPlaysInfo,
        );
      },
      act: (bloc) => bloc
        ..add(const CollectionLoaded())
        ..add(
          const CollectionFilterChanged(
            CollectionFilter(
              playerParticipation: {
                'Markus': PlayerParticipationFilter.notPlayed,
                'Dine': PlayerParticipationFilter.played,
              },
            ),
          ),
        ),
      skip: 2,
      expect: () => [
        predicate<CollectionState>(
          (s) =>
              s.filteredItems.length == 1 && s.filteredItems.first.thingId == 2,
        ),
      ],
    );

    blocTest<CollectionBloc, CollectionState>(
      'matches player names case-insensitively',
      build: () {
        when(loadCollection.call).thenAnswer(
          (_) async => const [CollectionItem(thingId: 1, names: [])],
        );
        when(loadPlaysInfo.call).thenAnswer(
          (_) async => PlaysInfo(
            playerNamesByGame: const {
              1: ['markus'],
            },
            playsByGame: {
              1: [
                _play(thingId: 1, players: [const PlayPlayer(name: 'markus')]),
              ],
            },
          ),
        );
        return _buildBloc(
          loadCollection: loadCollection,
          loadCardLayout: loadCardLayout,
          loadCollectionView: loadCollectionView,
          saveCollectionView: saveCollectionView,
          loadPlaysInfo: loadPlaysInfo,
        );
      },
      act: (bloc) => bloc
        ..add(const CollectionLoaded())
        ..add(
          const CollectionFilterChanged(
            CollectionFilter(
              playerParticipation: {'Markus': PlayerParticipationFilter.played},
            ),
          ),
        ),
      skip: 2,
      expect: () => [
        predicate<CollectionState>(
          (s) =>
              s.filteredItems.length == 1 && s.filteredItems.first.thingId == 1,
        ),
      ],
    );

    blocTest<CollectionBloc, CollectionState>(
      'combines search and player filters with AND logic',
      build: () {
        when(loadCollection.call).thenAnswer(
          (_) async => const [
            CollectionItem(
              thingId: 1,
              names: [
                LocalizedName(value: 'Catan', language: null, isPrimary: true),
              ],
            ),
            CollectionItem(
              thingId: 2,
              names: [
                LocalizedName(
                  value: 'Carcassonne',
                  language: null,
                  isPrimary: true,
                ),
              ],
            ),
          ],
        );
        when(loadPlaysInfo.call).thenAnswer(
          (_) async => PlaysInfo(
            playerNamesByGame: const {
              1: ['Markus'],
              2: ['Markus'],
            },
            playsByGame: {
              1: [
                _play(thingId: 1, players: [const PlayPlayer(name: 'Markus')]),
              ],
              2: [
                _play(thingId: 2, players: [const PlayPlayer(name: 'Markus')]),
              ],
            },
          ),
        );
        return _buildBloc(
          loadCollection: loadCollection,
          loadCardLayout: loadCardLayout,
          loadCollectionView: loadCollectionView,
          saveCollectionView: saveCollectionView,
          loadPlaysInfo: loadPlaysInfo,
        );
      },
      act: (bloc) => bloc
        ..add(const CollectionLoaded())
        ..add(const CollectionSearchTextChanged('car'))
        ..add(
          const CollectionFilterChanged(
            CollectionFilter(
              playerParticipation: {'Markus': PlayerParticipationFilter.played},
            ),
          ),
        ),
      skip: 3,
      expect: () => [
        predicate<CollectionState>(
          (s) =>
              s.filteredItems.length == 1 && s.filteredItems.first.thingId == 2,
        ),
      ],
    );

    blocTest<CollectionBloc, CollectionState>(
      'filters by play count range using numPlays when no player filter is active',
      build: () {
        when(loadCollection.call).thenAnswer(
          (_) async => const [
            CollectionItem(thingId: 1, names: [], numPlays: 5),
            CollectionItem(thingId: 2, names: [], numPlays: 0),
            CollectionItem(thingId: 3, names: [], numPlays: 12),
          ],
        );
        return _buildBloc(
          loadCollection: loadCollection,
          loadCardLayout: loadCardLayout,
          loadCollectionView: loadCollectionView,
          saveCollectionView: saveCollectionView,
        );
      },
      act: (bloc) => bloc
        ..add(const CollectionLoaded())
        ..add(
          const CollectionFilterChanged(
            CollectionFilter(minPlays: 1, maxPlays: 10),
          ),
        ),
      skip: 2,
      expect: () => [
        predicate<CollectionState>(
          (s) =>
              s.filteredItems.length == 1 && s.filteredItems.first.thingId == 1,
        ),
      ],
    );

    blocTest<CollectionBloc, CollectionState>(
      'filters by play count range using matching plays when player filter is active',
      build: () {
        when(loadCollection.call).thenAnswer(
          (_) async => const [
            CollectionItem(thingId: 1, names: [], numPlays: 5),
            CollectionItem(thingId: 2, names: [], numPlays: 5),
          ],
        );
        when(loadPlaysInfo.call).thenAnswer(
          (_) async => PlaysInfo(
            playerNamesByGame: const {
              1: ['Dine', 'Mark'],
              2: ['Dine', 'Mark'],
            },
            playsByGame: {
              1: [
                _play(
                  id: 101,
                  thingId: 1,
                  players: [const PlayPlayer(name: 'Dine')],
                ),
                _play(
                  id: 102,
                  thingId: 1,
                  players: [
                    const PlayPlayer(name: 'Dine'),
                    const PlayPlayer(name: 'Mark'),
                  ],
                ),
                _play(
                  id: 103,
                  thingId: 1,
                  players: [const PlayPlayer(name: 'Mark')],
                ),
              ],
              2: [
                _play(
                  id: 201,
                  thingId: 2,
                  players: [
                    const PlayPlayer(name: 'Dine'),
                    const PlayPlayer(name: 'Mark'),
                  ],
                ),
                _play(
                  id: 202,
                  thingId: 2,
                  players: [const PlayPlayer(name: 'Mark')],
                ),
              ],
            },
          ),
        );
        return _buildBloc(
          loadCollection: loadCollection,
          loadCardLayout: loadCardLayout,
          loadCollectionView: loadCollectionView,
          saveCollectionView: saveCollectionView,
          loadPlaysInfo: loadPlaysInfo,
        );
      },
      act: (bloc) => bloc
        ..add(const CollectionLoaded())
        ..add(
          const CollectionFilterChanged(
            CollectionFilter(
              minPlays: 1,
              maxPlays: 1,
              playerParticipation: {
                'Dine': PlayerParticipationFilter.played,
                'Mark': PlayerParticipationFilter.notPlayed,
              },
            ),
          ),
        ),
      skip: 2,
      expect: () => [
        predicate<CollectionState>(
          (s) =>
              s.filteredItems.length == 1 && s.filteredItems.first.thingId == 1,
        ),
      ],
    );

    blocTest<CollectionBloc, CollectionState>(
      'sorts by name ascending by default',
      build: () {
        when(loadCollection.call).thenAnswer(
          (_) async => const [
            CollectionItem(
              thingId: 1,
              names: [
                LocalizedName(value: 'Catan', language: null, isPrimary: true),
              ],
            ),
            CollectionItem(
              thingId: 2,
              names: [
                LocalizedName(
                  value: 'Agricola',
                  language: null,
                  isPrimary: true,
                ),
              ],
            ),
          ],
        );
        return _buildBloc(
          loadCollection: loadCollection,
          loadCardLayout: loadCardLayout,
          loadCollectionView: loadCollectionView,
          saveCollectionView: saveCollectionView,
        );
      },
      act: (bloc) => bloc.add(const CollectionLoaded()),
      skip: 1,
      expect: () => [
        predicate<CollectionState>(
          (s) =>
              s.filteredItems.length == 2 &&
              s.filteredItems[0].thingId == 2 &&
              s.filteredItems[1].thingId == 1,
        ),
      ],
    );

    blocTest<CollectionBloc, CollectionState>(
      'sorts by play time descending',
      build: () {
        when(loadCollection.call).thenAnswer(
          (_) async => const [
            CollectionItem(thingId: 1, names: [], maxPlayTime: 60),
            CollectionItem(thingId: 2, names: [], maxPlayTime: 120),
            CollectionItem(thingId: 3, names: [], maxPlayTime: 90),
          ],
        );
        return _buildBloc(
          loadCollection: loadCollection,
          loadCardLayout: loadCardLayout,
          loadCollectionView: loadCollectionView,
          saveCollectionView: saveCollectionView,
        );
      },
      act: (bloc) => bloc
        ..add(const CollectionLoaded())
        ..add(
          const CollectionSortChanged(
            CollectionSort(sortBy: SortBy.playTime, ascending: false),
          ),
        ),
      skip: 2,
      expect: () => [
        predicate<CollectionState>(
          (s) =>
              s.filteredItems.length == 3 &&
              s.filteredItems[0].thingId == 2 &&
              s.filteredItems[1].thingId == 3 &&
              s.filteredItems[2].thingId == 1,
        ),
      ],
    );

    blocTest<CollectionBloc, CollectionState>(
      'sorts by BGG rating ascending',
      build: () {
        when(loadCollection.call).thenAnswer(
          (_) async => const [
            CollectionItem(thingId: 1, names: [], bayesAverage: 7.5),
            CollectionItem(thingId: 2, names: [], bayesAverage: 6.5),
            CollectionItem(thingId: 3, names: [], bayesAverage: 8.0),
          ],
        );
        return _buildBloc(
          loadCollection: loadCollection,
          loadCardLayout: loadCardLayout,
          loadCollectionView: loadCollectionView,
          saveCollectionView: saveCollectionView,
        );
      },
      act: (bloc) => bloc
        ..add(const CollectionLoaded())
        ..add(
          const CollectionSortChanged(
            CollectionSort(sortBy: SortBy.bggRating, ascending: true),
          ),
        ),
      skip: 2,
      expect: () => [
        predicate<CollectionState>(
          (s) =>
              s.filteredItems.length == 3 &&
              s.filteredItems[0].thingId == 2 &&
              s.filteredItems[1].thingId == 1 &&
              s.filteredItems[2].thingId == 3,
        ),
      ],
    );

    blocTest<CollectionBloc, CollectionState>(
      'toggles compact mode',
      build: () => _buildBloc(
        loadCollection: loadCollection,
        loadCardLayout: loadCardLayout,
        loadCollectionView: loadCollectionView,
        saveCollectionView: saveCollectionView,
      ),
      act: (bloc) => bloc.add(const CollectionCompactModeToggled()),
      expect: () => [predicate<CollectionState>((s) => s.isCompactMode)],
    );

    blocTest<CollectionBloc, CollectionState>(
      'toggles compact mode off again',
      build: () => _buildBloc(
        loadCollection: loadCollection,
        loadCardLayout: loadCardLayout,
        loadCollectionView: loadCollectionView,
        saveCollectionView: saveCollectionView,
      ),
      seed: () => const CollectionState(isCompactMode: true),
      act: (bloc) => bloc.add(const CollectionCompactModeToggled()),
      expect: () => [predicate<CollectionState>((s) => !s.isCompactMode)],
    );

    blocTest<CollectionBloc, CollectionState>(
      'falls back to default view state when loadCollectionView fails',
      build: () {
        when(loadCollection.call).thenAnswer(
          (_) async => const [
            CollectionItem(thingId: 1, names: []),
            CollectionItem(thingId: 2, names: []),
          ],
        );
        when(loadCollectionView.call).thenThrow(Exception('storage error'));
        return _buildBloc(
          loadCollection: loadCollection,
          loadCardLayout: loadCardLayout,
          loadCollectionView: loadCollectionView,
          saveCollectionView: saveCollectionView,
        );
      },
      act: (bloc) => bloc.add(const CollectionLoaded()),
      skip: 1,
      expect: () => [
        predicate<CollectionState>(
          (s) =>
              s.searchText.isEmpty &&
              s.filter == const CollectionFilter() &&
              s.sort == const CollectionSort() &&
              s.filteredItems.length == 2,
        ),
      ],
    );

    blocTest<CollectionBloc, CollectionState>(
      'persists search text changes',
      build: () => _buildBloc(
        loadCollection: loadCollection,
        loadCardLayout: loadCardLayout,
        loadCollectionView: loadCollectionView,
        saveCollectionView: saveCollectionView,
      ),
      act: (bloc) => bloc.add(const CollectionSearchTextChanged('catan')),
      expect: () => [
        predicate<CollectionState>((s) => s.searchText == 'catan'),
      ],
      verify: (_) {
        verify(
          () => saveCollectionView.call(
            const CollectionView(searchText: 'catan'),
          ),
        ).called(1);
      },
    );

    blocTest<CollectionBloc, CollectionState>(
      'persists filter changes',
      build: () => _buildBloc(
        loadCollection: loadCollection,
        loadCardLayout: loadCardLayout,
        loadCollectionView: loadCollectionView,
        saveCollectionView: saveCollectionView,
      ),
      act: (bloc) => bloc.add(
        const CollectionFilterChanged(
          CollectionFilter(minPlayers: 2, maxPlayers: 4),
        ),
      ),
      expect: () => [
        predicate<CollectionState>(
          (s) => s.filter.minPlayers == 2 && s.filter.maxPlayers == 4,
        ),
      ],
      verify: (_) {
        verify(
          () => saveCollectionView.call(
            const CollectionView(
              filter: CollectionFilter(minPlayers: 2, maxPlayers: 4),
            ),
          ),
        ).called(1);
      },
    );

    blocTest<CollectionBloc, CollectionState>(
      'persists sort changes',
      build: () => _buildBloc(
        loadCollection: loadCollection,
        loadCardLayout: loadCardLayout,
        loadCollectionView: loadCollectionView,
        saveCollectionView: saveCollectionView,
      ),
      act: (bloc) => bloc.add(
        const CollectionSortChanged(
          CollectionSort(sortBy: SortBy.year, ascending: false),
        ),
      ),
      expect: () => [
        predicate<CollectionState>(
          (s) => s.sort.sortBy == SortBy.year && s.sort.ascending == false,
        ),
      ],
      verify: (_) {
        verify(
          () => saveCollectionView.call(
            const CollectionView(
              sort: CollectionSort(sortBy: SortBy.year, ascending: false),
            ),
          ),
        ).called(1);
      },
    );

    blocTest<CollectionBloc, CollectionState>(
      'does not emit error when persistence fails',
      build: () => _buildBloc(
        loadCollection: loadCollection,
        loadCardLayout: loadCardLayout,
        loadCollectionView: loadCollectionView,
        saveCollectionView: saveCollectionView,
      ),
      act: (bloc) => bloc.add(const CollectionSearchTextChanged('catan')),
      expect: () => [
        predicate<CollectionState>(
          (s) =>
              s.searchText == 'catan' &&
              s.errorMessage(AppLocalizationsEn()) == null,
        ),
      ],
      setUp: () {
        when(
          () => saveCollectionView.call(any()),
        ).thenThrow(Exception('save failed'));
      },
    );

    blocTest<CollectionBloc, CollectionState>(
      'reloads card layout without changing items',
      build: () {
        const customConfig = CardLayoutConfig(
          enabledFields: [CardField.bggRank],
          fieldOrder: [CardField.bggRank],
        );
        when(loadCardLayout.call).thenAnswer((_) async => customConfig);
        return _buildBloc(
          loadCollection: loadCollection,
          loadCardLayout: loadCardLayout,
          loadCollectionView: loadCollectionView,
          saveCollectionView: saveCollectionView,
        );
      },
      act: (bloc) => bloc.add(const CollectionCardLayoutReloaded()),
      expect: () => [
        predicate<CollectionState>(
          (s) =>
              listEquals(s.cardLayout.enabledFields, [CardField.bggRank]) &&
              listEquals(s.cardLayout.fieldOrder, [CardField.bggRank]),
        ),
      ],
      verify: (_) {
        verify(loadCardLayout.call).called(1);
      },
    );

    blocTest<CollectionBloc, CollectionState>(
      'syncs, reloads collection, and refreshes plays info on CollectionSyncRequested',
      build: () {
        final syncCollection = _MockSyncCollectionUseCase();
        when(
          () => syncCollection.call(onProgress: any(named: 'onProgress')),
        ).thenAnswer(
          (_) async =>
              const SyncResult(items: [], duration: Duration(seconds: 1)),
        );
        when(loadCollection.call).thenAnswer(
          (_) async => const [CollectionItem(thingId: 10, names: [])],
        );
        when(loadPlaysInfo.call).thenAnswer(
          (_) async => const PlaysInfo(
            playerNamesByGame: {
              10: ['Dine', 'Eva', 'Mark'],
            },
          ),
        );
        return _buildBloc(
          loadCollection: loadCollection,
          loadCardLayout: loadCardLayout,
          loadCollectionView: loadCollectionView,
          saveCollectionView: saveCollectionView,
          loadPlaysInfo: loadPlaysInfo,
          syncCollection: syncCollection,
        );
      },
      act: (bloc) => bloc.add(const CollectionSyncRequested()),
      expect: () => [
        predicate<CollectionState>((s) => s.isSyncing),
        predicate<CollectionState>(
          (s) =>
              !s.isSyncing &&
              s.items.length == 1 &&
              s.items.first.thingId == 10 &&
              s.playsInfo.playerNamesByGame[10]!.length == 3 &&
              s.playsInfo.playerNamesByGame[10]![0] == 'Dine' &&
              s.playsInfo.playerNamesByGame[10]![1] == 'Eva' &&
              s.playsInfo.playerNamesByGame[10]![2] == 'Mark' &&
              s.errorMessage(AppLocalizationsEn()) == null,
        ),
      ],
    );

    blocTest<CollectionBloc, CollectionState>(
      'syncs and reloads collection on CollectionSyncRequested',
      build: () {
        final syncCollection = _MockSyncCollectionUseCase();
        when(
          () => syncCollection.call(onProgress: any(named: 'onProgress')),
        ).thenAnswer(
          (_) async =>
              const SyncResult(items: [], duration: Duration(seconds: 1)),
        );
        when(loadCollection.call).thenAnswer(
          (_) async => const [CollectionItem(thingId: 10, names: [])],
        );
        return _buildBloc(
          loadCollection: loadCollection,
          loadCardLayout: loadCardLayout,
          loadCollectionView: loadCollectionView,
          saveCollectionView: saveCollectionView,
          syncCollection: syncCollection,
        );
      },
      act: (bloc) => bloc.add(const CollectionSyncRequested()),
      expect: () => [
        predicate<CollectionState>((s) => s.isSyncing),
        predicate<CollectionState>(
          (s) =>
              !s.isSyncing &&
              s.items.length == 1 &&
              s.items.first.thingId == 10 &&
              s.errorMessage(AppLocalizationsEn()) == null,
        ),
      ],
    );

    blocTest<CollectionBloc, CollectionState>(
      'emits error when sync fails',
      build: () {
        final syncCollection = _MockSyncCollectionUseCase();
        when(
          () => syncCollection.call(onProgress: any(named: 'onProgress')),
        ).thenThrow(Exception('network error'));
        return _buildBloc(
          loadCollection: loadCollection,
          loadCardLayout: loadCardLayout,
          loadCollectionView: loadCollectionView,
          saveCollectionView: saveCollectionView,
          syncCollection: syncCollection,
        );
      },
      act: (bloc) => bloc.add(const CollectionSyncRequested()),
      expect: () => [
        predicate<CollectionState>((s) => s.isSyncing),
        predicate<CollectionState>(
          (s) =>
              !s.isSyncing &&
              s.errorMessage(AppLocalizationsEn()) ==
                  'Sync failed: Exception: network error',
        ),
      ],
    );

    blocTest<CollectionBloc, CollectionState>(
      'emits error when sync use case is not available',
      build: () => _buildBloc(
        loadCollection: loadCollection,
        loadCardLayout: loadCardLayout,
        loadCollectionView: loadCollectionView,
        saveCollectionView: saveCollectionView,
      ),
      act: (bloc) => bloc.add(const CollectionSyncRequested()),
      expect: () => [
        predicate<CollectionState>((s) => s.isSyncing),
        predicate<CollectionState>(
          (s) =>
              !s.isSyncing &&
              s.errorMessage(AppLocalizationsEn()) == 'Sync is not available',
        ),
      ],
    );
  });
}

Play _play({int? id, required int thingId, required List<PlayPlayer> players}) {
  return Play(
    id: id ?? thingId,
    thingId: thingId,
    gameName: 'Game $thingId',
    date: '2026-01-01',
    players: players,
  );
}
