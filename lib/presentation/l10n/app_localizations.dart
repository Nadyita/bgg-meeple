import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'BGG Meeple'**
  String get appTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @collectionTitle.
  ///
  /// In en, this message translates to:
  /// **'My Collection'**
  String get collectionTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search games...'**
  String get searchHint;

  /// No description provided for @filterLabel.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filterLabel;

  /// No description provided for @clearSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Clear search and filters'**
  String get clearSearchLabel;

  /// No description provided for @sortLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortLabel;

  /// No description provided for @syncLabel.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get syncLabel;

  /// No description provided for @compactModeEnableTooltip.
  ///
  /// In en, this message translates to:
  /// **'Compact view'**
  String get compactModeEnableTooltip;

  /// No description provided for @compactModeDisableTooltip.
  ///
  /// In en, this message translates to:
  /// **'Card view'**
  String get compactModeDisableTooltip;

  /// No description provided for @unknownGame.
  ///
  /// In en, this message translates to:
  /// **'Unknown game'**
  String get unknownGame;

  /// No description provided for @sortByName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortByName;

  /// No description provided for @sortByPlayTime.
  ///
  /// In en, this message translates to:
  /// **'Play time'**
  String get sortByPlayTime;

  /// No description provided for @sortByBggRating.
  ///
  /// In en, this message translates to:
  /// **'BGG rating'**
  String get sortByBggRating;

  /// No description provided for @sortByYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get sortByYear;

  /// No description provided for @ascending.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get ascending;

  /// No description provided for @descending.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get descending;

  /// No description provided for @playerCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get playerCountLabel;

  /// No description provided for @playTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time (min)'**
  String get playTimeLabel;

  /// No description provided for @ratingLabel.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get ratingLabel;

  /// No description provided for @clearFiltersLabel.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearFiltersLabel;

  /// No description provided for @subTypeOwned.
  ///
  /// In en, this message translates to:
  /// **'owned'**
  String get subTypeOwned;

  /// No description provided for @subTypePreordered.
  ///
  /// In en, this message translates to:
  /// **'preordered'**
  String get subTypePreordered;

  /// No description provided for @subTypeWishlisted.
  ///
  /// In en, this message translates to:
  /// **'wishlist'**
  String get subTypeWishlisted;

  /// No description provided for @subTypeWantToPlay.
  ///
  /// In en, this message translates to:
  /// **'want to play'**
  String get subTypeWantToPlay;

  /// No description provided for @subTypeWantToBuy.
  ///
  /// In en, this message translates to:
  /// **'want to buy'**
  String get subTypeWantToBuy;

  /// No description provided for @subTypePreviouslyOwned.
  ///
  /// In en, this message translates to:
  /// **'previously owned'**
  String get subTypePreviouslyOwned;

  /// No description provided for @subTypePlayed.
  ///
  /// In en, this message translates to:
  /// **'played'**
  String get subTypePlayed;

  /// No description provided for @subTypeRated.
  ///
  /// In en, this message translates to:
  /// **'rated'**
  String get subTypeRated;

  /// No description provided for @subTypeForTrade.
  ///
  /// In en, this message translates to:
  /// **'for trade'**
  String get subTypeForTrade;

  /// No description provided for @subTypeWantInTrade.
  ///
  /// In en, this message translates to:
  /// **'want in trade'**
  String get subTypeWantInTrade;

  /// No description provided for @subTypeHasComment.
  ///
  /// In en, this message translates to:
  /// **'comment'**
  String get subTypeHasComment;

  /// No description provided for @noGamesMatchFilters.
  ///
  /// In en, this message translates to:
  /// **'No games match your filters.'**
  String get noGamesMatchFilters;

  /// No description provided for @collectionEmptyAfterSync.
  ///
  /// In en, this message translates to:
  /// **'Collection will appear here after sync.'**
  String get collectionEmptyAfterSync;

  /// No description provided for @collectionEmptySearch.
  ///
  /// In en, this message translates to:
  /// **'No games match your search.'**
  String get collectionEmptySearch;

  /// No description provided for @settingsBggUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'BGG Username'**
  String get settingsBggUsernameLabel;

  /// No description provided for @settingsBggPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'BGG Password'**
  String get settingsBggPasswordLabel;

  /// No description provided for @settingsSaveCredentialsButton.
  ///
  /// In en, this message translates to:
  /// **'Save Credentials'**
  String get settingsSaveCredentialsButton;

  /// No description provided for @settingsTestLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Test Login'**
  String get settingsTestLoginButton;

  /// No description provided for @settingsSyncCollectionButton.
  ///
  /// In en, this message translates to:
  /// **'Sync Collection'**
  String get settingsSyncCollectionButton;

  /// No description provided for @settingsCredentialsSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Credentials saved'**
  String get settingsCredentialsSavedMessage;

  /// No description provided for @settingsLoginSuccessfulMessage.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get settingsLoginSuccessfulMessage;

  /// No description provided for @settingsSyncCompletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Sync completed'**
  String get settingsSyncCompletedMessage;

  /// No description provided for @settingsCardLayoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Card Layout'**
  String get settingsCardLayoutTitle;

  /// No description provided for @settingsShowThumbnail.
  ///
  /// In en, this message translates to:
  /// **'Show thumbnail'**
  String get settingsShowThumbnail;

  /// No description provided for @settingsShowVersionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show version subtitle'**
  String get settingsShowVersionSubtitle;

  /// No description provided for @settingsHidePlaysWhenZero.
  ///
  /// In en, this message translates to:
  /// **'Hide plays when zero'**
  String get settingsHidePlaysWhenZero;

  /// No description provided for @settingsShowGeekRatingUserCount.
  ///
  /// In en, this message translates to:
  /// **'Show number of ratings for geek rating'**
  String get settingsShowGeekRatingUserCount;

  /// No description provided for @settingsThemeModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsThemeModeTitle;

  /// No description provided for @settingsThemeModeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeModeSystem;

  /// No description provided for @settingsThemeModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeModeLight;

  /// No description provided for @settingsThemeModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeModeDark;

  /// No description provided for @settingsFontSizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Font size'**
  String get settingsFontSizeTitle;

  /// No description provided for @settingsVisibleFieldsHint.
  ///
  /// In en, this message translates to:
  /// **'Visible fields (drag to reorder)'**
  String get settingsVisibleFieldsHint;

  /// No description provided for @cardFieldPlayerCount.
  ///
  /// In en, this message translates to:
  /// **'Player count'**
  String get cardFieldPlayerCount;

  /// No description provided for @cardFieldPlayTime.
  ///
  /// In en, this message translates to:
  /// **'Play time'**
  String get cardFieldPlayTime;

  /// No description provided for @cardFieldPlays.
  ///
  /// In en, this message translates to:
  /// **'Plays'**
  String get cardFieldPlays;

  /// No description provided for @cardFieldOwnRating.
  ///
  /// In en, this message translates to:
  /// **'Your rating'**
  String get cardFieldOwnRating;

  /// No description provided for @cardFieldGeekRating.
  ///
  /// In en, this message translates to:
  /// **'Geek rating'**
  String get cardFieldGeekRating;

  /// No description provided for @cardFieldMinAge.
  ///
  /// In en, this message translates to:
  /// **'Min age'**
  String get cardFieldMinAge;

  /// No description provided for @cardFieldBggRank.
  ///
  /// In en, this message translates to:
  /// **'BGG rank'**
  String get cardFieldBggRank;

  /// No description provided for @cardFieldPlaysHiddenWhenZero.
  ///
  /// In en, this message translates to:
  /// **'Hidden when zero'**
  String get cardFieldPlaysHiddenWhenZero;

  /// No description provided for @cardFieldGeekRatingIncludesUserCount.
  ///
  /// In en, this message translates to:
  /// **'Includes number of ratings'**
  String get cardFieldGeekRatingIncludesUserCount;

  /// Own rating displayed on a collection card
  ///
  /// In en, this message translates to:
  /// **'Your rating: {rating}'**
  String cardOwnRatingLabel(String rating);

  /// Geek rating displayed on a collection card
  ///
  /// In en, this message translates to:
  /// **'Geek rating: {rating}'**
  String cardGeekRatingLabel(String rating);

  /// No description provided for @cardGeekRatingMissing.
  ///
  /// In en, this message translates to:
  /// **'Geek rating: –'**
  String get cardGeekRatingMissing;

  /// Minimum age displayed on a collection card
  ///
  /// In en, this message translates to:
  /// **'Min age: {age}'**
  String cardMinAgeLabel(int age);

  /// BGG rank displayed on a collection card
  ///
  /// In en, this message translates to:
  /// **'BGG rank: {rank}'**
  String cardBggRankLabel(int rank);

  /// Number of plays displayed on a collection card
  ///
  /// In en, this message translates to:
  /// **'Plays: {count}'**
  String cardPlaysLabel(int count);

  /// No description provided for @cardPlayerCountMissing.
  ///
  /// In en, this message translates to:
  /// **'Players: –'**
  String get cardPlayerCountMissing;

  /// Exact player count on a collection card
  ///
  /// In en, this message translates to:
  /// **'{count} Players'**
  String cardPlayerCountExact(int count);

  /// Player count range when only maximum is known
  ///
  /// In en, this message translates to:
  /// **'1 - {max} Players'**
  String cardPlayerCountRangeMaxOnly(int max);

  /// Player count range when only minimum is known
  ///
  /// In en, this message translates to:
  /// **'{min}+ Players'**
  String cardPlayerCountRangeMinOnly(int min);

  /// Player count range on a collection card
  ///
  /// In en, this message translates to:
  /// **'{min} - {max} Players'**
  String cardPlayerCountRange(int min, int max);

  /// No description provided for @cardPlayTimeMissing.
  ///
  /// In en, this message translates to:
  /// **'Time: –'**
  String get cardPlayTimeMissing;

  /// Exact play time on a collection card
  ///
  /// In en, this message translates to:
  /// **'{minutes} Min'**
  String cardPlayTimeExact(int minutes);

  /// Play time when only maximum is known
  ///
  /// In en, this message translates to:
  /// **'{max} Min'**
  String cardPlayTimeMaxOnly(int max);

  /// Play time when only minimum is known
  ///
  /// In en, this message translates to:
  /// **'{min}+ Min'**
  String cardPlayTimeMinOnly(int min);

  /// Play time range on a collection card
  ///
  /// In en, this message translates to:
  /// **'{min} - {max} Min'**
  String cardPlayTimeRange(int min, int max);

  /// Error shown when the card layout configuration cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'Failed to load card layout: {details}'**
  String errorLoadCardLayout(String details);

  /// Error shown when the collection cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'Failed to load collection: {details}'**
  String errorLoadCollection(String details);

  /// Error shown when settings cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'Failed to load settings: {details}'**
  String errorLoadSettings(String details);

  /// Error shown when the BGG login test fails
  ///
  /// In en, this message translates to:
  /// **'Login failed: {details}'**
  String errorLogin(String details);

  /// No description provided for @errorSyncUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Sync is not available'**
  String get errorSyncUnavailable;

  /// Error shown when collection sync fails
  ///
  /// In en, this message translates to:
  /// **'Sync failed: {details}'**
  String errorSyncFailed(String details);

  /// Error shown when credentials cannot be saved
  ///
  /// In en, this message translates to:
  /// **'Failed to save credentials: {details}'**
  String errorSaveCredentials(String details);

  /// Error shown when the card layout configuration cannot be saved
  ///
  /// In en, this message translates to:
  /// **'Failed to save card layout: {details}'**
  String errorSaveCardLayout(String details);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
