import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/value_objects/theme_config.dart';
import '../infrastructure/di/service_locator.dart';
import 'cubits/theme_cubit.dart';
import 'l10n/app_localizations.dart';
import 'pages/collection_page.dart';
import 'pages/settings_page.dart';

/// Root widget of the BGG Meeple app.
class BggMeepleApp extends StatelessWidget {
  const BggMeepleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeCubit(
        loadThemeConfig: ServiceLocator.instance.loadThemeConfig,
        saveThemeConfig: ServiceLocator.instance.saveThemeConfig,
      ),
      child: BlocBuilder<ThemeCubit, ThemeConfig>(
        builder: (context, config) {
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(config.textScaleFactor)),
            child: MaterialApp(
              onGenerateTitle: (context) =>
                  AppLocalizations.of(context)!.appTitle,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              themeMode: config.themeMode,
              theme: _theme(Brightness.light),
              darkTheme: _theme(Brightness.dark),
              home: CollectionPage(
                loadCollection: ServiceLocator.instance.loadCollection,
                loadGameDetails: ServiceLocator.instance.loadGameDetails,
                loadCardLayout: ServiceLocator.instance.loadCardLayout,
                loadCollectionView: ServiceLocator.instance.loadCollectionView,
                saveCollectionView: ServiceLocator.instance.saveCollectionView,
                loadCredentials: ServiceLocator.instance.loadCredentials,
                loadPlayPlayerNames:
                    ServiceLocator.instance.loadPlayPlayerNames,
                syncCollection: ServiceLocator.instance.syncCollection,
              ),
              routes: {
                '/settings': (context) {
                  return SettingsPage(
                    loadCredentials: ServiceLocator.instance.loadCredentials,
                    saveCredentials: ServiceLocator.instance.saveCredentials,
                    login: ServiceLocator.instance.login,
                    syncCollection: ServiceLocator.instance.syncCollection,
                    loadCardLayout: ServiceLocator.instance.loadCardLayout,
                    saveCardLayout: ServiceLocator.instance.saveCardLayout,
                    onSyncCompleted: () {
                      Navigator.of(context).pop(true);
                    },
                  );
                },
              },
            ),
          );
        },
      ),
    );
  }

  ThemeData _theme(Brightness brightness) {
    return ThemeData.from(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: brightness,
      ),
      useMaterial3: true,
    );
  }
}
