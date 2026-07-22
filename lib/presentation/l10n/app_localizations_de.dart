// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'BGG Meeple';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get collectionTitle => 'Meine Sammlung';

  @override
  String get searchHint => 'Spiele suchen...';

  @override
  String get filterLabel => 'Filter';

  @override
  String get clearSearchLabel => 'Suche und Filter zurücksetzen';

  @override
  String get sortLabel => 'Sortierung';

  @override
  String get syncLabel => 'Sync';

  @override
  String get compactModeEnableTooltip => 'Kompaktansicht';

  @override
  String get compactModeDisableTooltip => 'Kartenansicht';

  @override
  String get unknownGame => 'Unbekanntes Spiel';

  @override
  String get sortByName => 'Name';

  @override
  String get sortByPlayTime => 'Spieldauer';

  @override
  String get sortByBggRating => 'BGG-Bewertung';

  @override
  String get sortByYear => 'Jahr';

  @override
  String get ascending => 'Aufsteigend';

  @override
  String get descending => 'Absteigend';

  @override
  String get playerCountLabel => 'Spieler';

  @override
  String get playTimeLabel => 'Zeit (Min.)';

  @override
  String get ratingLabel => 'Bewertung';

  @override
  String get playCountLabel => 'Partien';

  @override
  String get clearFiltersLabel => 'Zurücksetzen';

  @override
  String get subTypeOwned => 'owned';

  @override
  String get subTypePreordered => 'preordered';

  @override
  String get subTypeWishlisted => 'wishlisted';

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
  String get noGamesMatchFilters => 'Keine Spiele entsprechen den Filtern.';

  @override
  String get collectionEmptyAfterSync =>
      'Die Sammlung erscheint hier nach der Synchronisation.';

  @override
  String get collectionEmptySearch => 'Keine Spiele entsprechen der Suche.';

  @override
  String get settingsBggUsernameLabel => 'BGG-Benutzername';

  @override
  String get settingsBggPasswordLabel => 'BGG-Passwort';

  @override
  String get settingsBggApiTokenLabel => 'BGG-API-Token (optional)';

  @override
  String get settingsBggApiTokenHint =>
      'Erforderlich für Spieldetails von /xmlapi2/thing';

  @override
  String get settingsSaveCredentialsButton => 'Zugangsdaten speichern';

  @override
  String get settingsTestLoginButton => 'Login testen';

  @override
  String get settingsSyncCollectionButton => 'Sammlung synchronisieren';

  @override
  String get settingsCredentialsSavedMessage => 'Zugangsdaten gespeichert';

  @override
  String get settingsLoginSuccessfulMessage => 'Login erfolgreich';

  @override
  String get settingsSyncCompletedMessage => 'Synchronisation abgeschlossen';

  @override
  String get settingsCardLayoutTitle => 'Kartenlayout';

  @override
  String get settingsShowThumbnail => 'Vorschaubild anzeigen';

  @override
  String get settingsShowVersionSubtitle => 'Version-Untertitel anzeigen';

  @override
  String get settingsHidePlaysWhenZero => 'Partien bei Null ausblenden';

  @override
  String get settingsShowGeekRatingUserCount =>
      'Anzahl Bewertungen für Geek-Rating anzeigen';

  @override
  String get settingsShowPlayerNamesOnPlays => 'Spielernamen anzeigen';

  @override
  String get settingsShowPlayerFilterHintTitle =>
      'Hinweis zum Spielerfilter anzeigen';

  @override
  String get filterAddPlayerLabel => 'Spieler hinzufügen';

  @override
  String get filterPlayerSectionTitle => 'Spieler';

  @override
  String get filterPlayerPickerTitle => 'Spieler auswählen';

  @override
  String get filterPlayerHintTouch =>
      'Zum Entfernen lange auf einen Spieler tippen';

  @override
  String get filterPlayerHintPointer => 'Zum Entfernen auf das X tippen';

  @override
  String get settingsThemeModeTitle => 'Farbschema';

  @override
  String get settingsThemeModeSystem => 'System';

  @override
  String get settingsThemeModeLight => 'Hell';

  @override
  String get settingsThemeModeDark => 'Dunkel';

  @override
  String get settingsFontSizeTitle => 'Schriftgröße';

  @override
  String get settingsVisibleFieldsHint =>
      'Sichtbare Felder (ziehen zum Sortieren)';

  @override
  String get cardFieldPlayerCount => 'Spieleranzahl';

  @override
  String get cardFieldPlayTime => 'Spieldauer';

  @override
  String get cardFieldPlays => 'Partien';

  @override
  String get cardFieldOwnRating => 'Eigene Bewertung';

  @override
  String get cardFieldGeekRating => 'Geek-Rating';

  @override
  String get cardFieldMinAge => 'Mindestalter';

  @override
  String get cardFieldBggRank => 'BGG-Rang';

  @override
  String get cardFieldPlaysHiddenWhenZero => 'Bei Null ausgeblendet';

  @override
  String get cardFieldGeekRatingIncludesUserCount =>
      'Anzahl der Bewertungen einblenden';

  @override
  String get cardFieldPlaysPlayerNames => 'Spielernamen';

  @override
  String cardOwnRatingLabel(String rating) {
    return 'Eigene Bewertung: $rating';
  }

  @override
  String cardGeekRatingLabel(String rating) {
    return 'Geek-Rating: $rating';
  }

  @override
  String get cardGeekRatingMissing => 'Geek-Rating: –';

  @override
  String cardMinAgeLabel(int age) {
    return 'Mindestalter: $age';
  }

  @override
  String cardBggRankLabel(int rank) {
    return 'BGG-Rang: $rank';
  }

  @override
  String cardPlaysLabel(int count) {
    return 'Partien: $count';
  }

  @override
  String get cardPlayerCountMissing => 'Spieler: –';

  @override
  String cardPlayerCountExact(int count) {
    return '$count Spieler';
  }

  @override
  String cardPlayerCountRangeMaxOnly(int max) {
    return '1 - $max Spieler';
  }

  @override
  String cardPlayerCountRangeMinOnly(int min) {
    return '$min+ Spieler';
  }

  @override
  String cardPlayerCountRange(int min, int max) {
    return '$min - $max Spieler';
  }

  @override
  String get cardPlayTimeMissing => 'Zeit: –';

  @override
  String cardPlayTimeExact(int minutes) {
    return '$minutes Min.';
  }

  @override
  String cardPlayTimeMaxOnly(int max) {
    return '$max Min.';
  }

  @override
  String cardPlayTimeMinOnly(int min) {
    return '$min+ Min.';
  }

  @override
  String cardPlayTimeRange(int min, int max) {
    return '$min - $max Min.';
  }

  @override
  String errorLoadCardLayout(String details) {
    return 'Laden des Kartenlayouts fehlgeschlagen: $details';
  }

  @override
  String errorLoadCollection(String details) {
    return 'Laden der Sammlung fehlgeschlagen: $details';
  }

  @override
  String errorLoadSettings(String details) {
    return 'Laden der Einstellungen fehlgeschlagen: $details';
  }

  @override
  String errorLogin(String details) {
    return 'Login fehlgeschlagen: $details';
  }

  @override
  String get errorSyncUnavailable => 'Synchronisation nicht verfügbar';

  @override
  String errorSyncFailed(String details) {
    return 'Synchronisation fehlgeschlagen: $details';
  }

  @override
  String errorSaveCredentials(String details) {
    return 'Speichern der Zugangsdaten fehlgeschlagen: $details';
  }

  @override
  String errorSaveCardLayout(String details) {
    return 'Speichern des Kartenlayouts fehlgeschlagen: $details';
  }

  @override
  String get detailBackTooltip => 'Zurück';

  @override
  String get detailOpenBggTooltip => 'Auf BoardGameGeek öffnen';

  @override
  String detailAlternateNames(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alternative Namen',
      one: '1 alternativer Name',
    );
    return '$_temp0';
  }

  @override
  String get detailOriginalName => 'Originalname';

  @override
  String get detailYearPublished => 'Erscheinungsjahr';

  @override
  String get detailPlayerCount => 'Spieler';

  @override
  String get detailPlayingTime => 'Spieldauer';

  @override
  String get detailRating => 'Bewertung';

  @override
  String get detailRank => 'Rang';

  @override
  String get detailVersion => 'Version';

  @override
  String get detailPlays => 'Partien';

  @override
  String get detailUserCount => 'Bewertungen';

  @override
  String get detailNotAvailable => '–';

  @override
  String get detailGameNotFound => 'Spiel nicht gefunden';
}
