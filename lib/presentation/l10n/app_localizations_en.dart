// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'BGG Meeple';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get collectionTitle => 'My Collection';

  @override
  String get searchHint => 'Search games...';

  @override
  String get filterLabel => 'Filters';

  @override
  String get clearSearchLabel => 'Clear search and filters';

  @override
  String get sortLabel => 'Sort';

  @override
  String get syncLabel => 'Sync';

  @override
  String get compactModeEnableTooltip => 'Compact view';

  @override
  String get compactModeDisableTooltip => 'Card view';

  @override
  String get unknownGame => 'Unknown game';

  @override
  String get sortByName => 'Name';

  @override
  String get sortByPlayTime => 'Play time';

  @override
  String get sortByBggRating => 'BGG rating';

  @override
  String get sortByYear => 'Year';

  @override
  String get ascending => 'Ascending';

  @override
  String get descending => 'Descending';

  @override
  String get playerCountLabel => 'Players';

  @override
  String get playTimeLabel => 'Time (min)';

  @override
  String get ratingLabel => 'Rating';

  @override
  String get clearFiltersLabel => 'Clear';

  @override
  String get subTypeOwned => 'owned';

  @override
  String get subTypePreordered => 'preordered';

  @override
  String get subTypeWishlisted => 'wishlist';

  @override
  String get subTypeWantToPlay => 'want to play';

  @override
  String get subTypeWantToBuy => 'want to buy';

  @override
  String get subTypePreviouslyOwned => 'previously owned';

  @override
  String get subTypePlayed => 'played';

  @override
  String get subTypeRated => 'rated';

  @override
  String get subTypeForTrade => 'for trade';

  @override
  String get subTypeWantInTrade => 'want in trade';

  @override
  String get subTypeHasComment => 'comment';

  @override
  String get noGamesMatchFilters => 'No games match your filters.';

  @override
  String get collectionEmptyAfterSync =>
      'Collection will appear here after sync.';

  @override
  String get collectionEmptySearch => 'No games match your search.';

  @override
  String get settingsBggUsernameLabel => 'BGG Username';

  @override
  String get settingsBggPasswordLabel => 'BGG Password';

  @override
  String get settingsBggApiTokenLabel => 'BGG API Token (optional)';

  @override
  String get settingsBggApiTokenHint =>
      'Required for game details from /xmlapi2/thing';

  @override
  String get settingsSaveCredentialsButton => 'Save Credentials';

  @override
  String get settingsTestLoginButton => 'Test Login';

  @override
  String get settingsSyncCollectionButton => 'Sync Collection';

  @override
  String get settingsCredentialsSavedMessage => 'Credentials saved';

  @override
  String get settingsLoginSuccessfulMessage => 'Login successful';

  @override
  String get settingsSyncCompletedMessage => 'Sync completed';

  @override
  String get settingsCardLayoutTitle => 'Card Layout';

  @override
  String get settingsShowThumbnail => 'Show thumbnail';

  @override
  String get settingsShowVersionSubtitle => 'Show version subtitle';

  @override
  String get settingsHidePlaysWhenZero => 'Hide plays when zero';

  @override
  String get settingsShowGeekRatingUserCount =>
      'Show number of ratings for geek rating';

  @override
  String get settingsShowPlayerNamesOnPlays => 'Show player names';

  @override
  String get settingsShowPlayerFilterHintTitle => 'Show player filter hint';

  @override
  String get filterAddPlayerLabel => 'Add player';

  @override
  String get filterPlayerSectionTitle => 'Players';

  @override
  String get filterPlayerPickerTitle => 'Select a player';

  @override
  String get filterPlayerHintTouch => 'Long-press a player chip to remove it';

  @override
  String get filterPlayerHintPointer =>
      'Tap the X on a player chip to remove it';

  @override
  String get settingsThemeModeTitle => 'Theme';

  @override
  String get settingsThemeModeSystem => 'System';

  @override
  String get settingsThemeModeLight => 'Light';

  @override
  String get settingsThemeModeDark => 'Dark';

  @override
  String get settingsFontSizeTitle => 'Font size';

  @override
  String get settingsVisibleFieldsHint => 'Visible fields (drag to reorder)';

  @override
  String get cardFieldPlayerCount => 'Player count';

  @override
  String get cardFieldPlayTime => 'Play time';

  @override
  String get cardFieldPlays => 'Plays';

  @override
  String get cardFieldOwnRating => 'Your rating';

  @override
  String get cardFieldGeekRating => 'Geek rating';

  @override
  String get cardFieldMinAge => 'Min age';

  @override
  String get cardFieldBggRank => 'BGG rank';

  @override
  String get cardFieldPlaysHiddenWhenZero => 'Hidden when zero';

  @override
  String get cardFieldGeekRatingIncludesUserCount =>
      'Includes number of ratings';

  @override
  String get cardFieldPlaysPlayerNames => 'Player names';

  @override
  String cardOwnRatingLabel(String rating) {
    return 'Your rating: $rating';
  }

  @override
  String cardGeekRatingLabel(String rating) {
    return 'Geek rating: $rating';
  }

  @override
  String get cardGeekRatingMissing => 'Geek rating: –';

  @override
  String cardMinAgeLabel(int age) {
    return 'Min age: $age';
  }

  @override
  String cardBggRankLabel(int rank) {
    return 'BGG rank: $rank';
  }

  @override
  String cardPlaysLabel(int count) {
    return 'Plays: $count';
  }

  @override
  String get cardPlayerCountMissing => 'Players: –';

  @override
  String cardPlayerCountExact(int count) {
    return '$count Players';
  }

  @override
  String cardPlayerCountRangeMaxOnly(int max) {
    return '1 - $max Players';
  }

  @override
  String cardPlayerCountRangeMinOnly(int min) {
    return '$min+ Players';
  }

  @override
  String cardPlayerCountRange(int min, int max) {
    return '$min - $max Players';
  }

  @override
  String get cardPlayTimeMissing => 'Time: –';

  @override
  String cardPlayTimeExact(int minutes) {
    return '$minutes Min';
  }

  @override
  String cardPlayTimeMaxOnly(int max) {
    return '$max Min';
  }

  @override
  String cardPlayTimeMinOnly(int min) {
    return '$min+ Min';
  }

  @override
  String cardPlayTimeRange(int min, int max) {
    return '$min - $max Min';
  }

  @override
  String errorLoadCardLayout(String details) {
    return 'Failed to load card layout: $details';
  }

  @override
  String errorLoadCollection(String details) {
    return 'Failed to load collection: $details';
  }

  @override
  String errorLoadSettings(String details) {
    return 'Failed to load settings: $details';
  }

  @override
  String errorLogin(String details) {
    return 'Login failed: $details';
  }

  @override
  String get errorSyncUnavailable => 'Sync is not available';

  @override
  String errorSyncFailed(String details) {
    return 'Sync failed: $details';
  }

  @override
  String errorSaveCredentials(String details) {
    return 'Failed to save credentials: $details';
  }

  @override
  String errorSaveCardLayout(String details) {
    return 'Failed to save card layout: $details';
  }

  @override
  String get detailBackTooltip => 'Back';

  @override
  String get detailOpenBggTooltip => 'Open on BoardGameGeek';

  @override
  String detailAlternateNames(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alternate names',
      one: '1 alternate name',
    );
    return '$_temp0';
  }

  @override
  String get detailOriginalName => 'Original name';

  @override
  String get detailYearPublished => 'Year published';

  @override
  String get detailPlayerCount => 'Players';

  @override
  String get detailPlayingTime => 'Playing time';

  @override
  String get detailRating => 'Rating';

  @override
  String get detailRank => 'Rank';

  @override
  String get detailVersion => 'Version';

  @override
  String get detailPlays => 'Plays';

  @override
  String get detailUserCount => 'votes';

  @override
  String get detailNotAvailable => '–';

  @override
  String get detailGameNotFound => 'Game not found';
}
