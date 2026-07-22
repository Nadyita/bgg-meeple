import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../application/use_cases/load_card_layout_use_case.dart';
import '../../../application/use_cases/load_credentials_use_case.dart';
import '../../../application/use_cases/login_use_case.dart';
import '../../../application/use_cases/save_card_layout_use_case.dart';
import '../../../application/use_cases/save_credentials_use_case.dart';
import '../../../application/use_cases/sync_collection_use_case.dart';
import '../../../domain/value_objects/card_field.dart';
import '../../../domain/value_objects/card_layout_config.dart';
import '../../../domain/value_objects/theme_config.dart';
import '../blocs/settings/settings_bloc.dart';
import '../blocs/settings/settings_event.dart';
import '../blocs/settings/settings_state.dart';
import '../cubits/theme_cubit.dart';
import '../l10n/app_localizations.dart';

/// Settings screen for BGG account, theme, and display preferences.
class SettingsPage extends StatelessWidget {
  const SettingsPage({
    required this.loadCredentials,
    required this.saveCredentials,
    required this.login,
    required this.loadCardLayout,
    required this.saveCardLayout,
    this.syncCollection,
    this.onSyncCompleted,
    super.key,
  });

  final LoadCredentialsUseCase loadCredentials;
  final SaveCredentialsUseCase saveCredentials;
  final LoginUseCase login;
  final LoadCardLayoutUseCase loadCardLayout;
  final SaveCardLayoutUseCase saveCardLayout;
  final SyncCollectionUseCase? syncCollection;
  final VoidCallback? onSyncCompleted;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => SettingsBloc(
        loadCredentials: loadCredentials,
        saveCredentials: saveCredentials,
        login: login,
        syncCollection: syncCollection,
        loadCardLayout: loadCardLayout,
        saveCardLayout: saveCardLayout,
      )..add(const SettingsLoaded()),
      child: Scaffold(
        appBar: AppBar(title: Text(localizations.settingsTitle)),
        body: _SettingsForm(onSyncCompleted: onSyncCompleted),
      ),
    );
  }
}

class _SettingsForm extends StatefulWidget {
  const _SettingsForm({this.onSyncCompleted});

  final VoidCallback? onSyncCompleted;

  @override
  State<_SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<_SettingsForm> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return BlocListener<SettingsBloc, SettingsState>(
      listener: (context, state) {
        final localizations = AppLocalizations.of(context)!;
        final errorMessage = state.errorMessage(localizations);
        if (errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMessage)));
        }
        if (state.saveSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.settingsCredentialsSavedMessage),
            ),
          );
        }
        if (state.loginSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.settingsLoginSuccessfulMessage),
            ),
          );
        }
        if (state.syncSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations.settingsSyncCompletedMessage)),
          );
          widget.onSyncCompleted?.call();
        }
      },
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  key: const Key('settingsUsernameField'),
                  decoration: InputDecoration(
                    labelText: localizations.settingsBggUsernameLabel,
                    hintText: localizations.searchHint,
                  ),
                  controller: TextEditingController(text: state.username)
                    ..selection = TextSelection.collapsed(
                      offset: state.username.length,
                    ),
                  onChanged: (value) => context.read<SettingsBloc>().add(
                    SettingsUsernameChanged(value),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  key: const Key('settingsPasswordField'),
                  decoration: InputDecoration(
                    labelText: localizations.settingsBggPasswordLabel,
                  ),
                  controller: TextEditingController(text: state.password)
                    ..selection = TextSelection.collapsed(
                      offset: state.password.length,
                    ),
                  obscureText: true,
                  onChanged: (value) => context.read<SettingsBloc>().add(
                    SettingsPasswordChanged(value),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  key: const Key('settingsApiTokenField'),
                  decoration: InputDecoration(
                    labelText: localizations.settingsBggApiTokenLabel,
                    hintText: localizations.settingsBggApiTokenHint,
                  ),
                  controller: TextEditingController(text: state.apiToken)
                    ..selection = TextSelection.collapsed(
                      offset: state.apiToken.length,
                    ),
                  obscureText: true,
                  onChanged: (value) => context.read<SettingsBloc>().add(
                    SettingsApiTokenChanged(value),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  key: const Key('settingsSaveButton'),
                  onPressed: state.isLoading || !state.canSave
                      ? null
                      : () => context.read<SettingsBloc>().add(
                          const SettingsCredentialsSaved(),
                        ),
                  icon: const Icon(Icons.save),
                  label: Text(localizations.settingsSaveCredentialsButton),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  key: const Key('settingsLoginButton'),
                  onPressed: state.isLoading || !state.canSave
                      ? null
                      : () => context.read<SettingsBloc>().add(
                          const SettingsLoginRequested(),
                        ),
                  icon: const Icon(Icons.login),
                  label: Text(localizations.settingsTestLoginButton),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  key: const Key('settingsSyncButton'),
                  onPressed: state.isLoading || !state.canSave
                      ? null
                      : () => context.read<SettingsBloc>().add(
                          const SettingsSyncRequested(),
                        ),
                  icon: const Icon(Icons.sync),
                  label: Text(localizations.settingsSyncCollectionButton),
                ),
                if (state.syncProgress != null) ...[
                  const SizedBox(height: 16),
                  Text(state.syncProgress!),
                ],
                if (state.isLoading) ...[
                  const SizedBox(height: 24),
                  const LinearProgressIndicator(),
                ],
                const Divider(height: 48),
                const _ThemeSection(),
                const Divider(height: 48),
                _CardLayoutSection(config: state.cardLayout),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CardLayoutSection extends StatefulWidget {
  const _CardLayoutSection({required this.config});

  final CardLayoutConfig config;

  @override
  State<_CardLayoutSection> createState() => _CardLayoutSectionState();
}

class _CardLayoutSectionState extends State<_CardLayoutSection> {
  late List<CardField> _order;

  @override
  void initState() {
    super.initState();
    _order = List<CardField>.of(widget.config.fieldOrder);
  }

  @override
  void didUpdateWidget(_CardLayoutSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.fieldOrder != widget.config.fieldOrder) {
      _order = List<CardField>.of(widget.config.fieldOrder);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = widget.config;
    final bloc = context.read<SettingsBloc>();
    final localizations = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.settingsCardLayoutTitle,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: Text(localizations.settingsShowThumbnail),
          value: config.showThumbnail,
          onChanged: (value) => bloc.add(
            SettingsCardLayoutToggled(
              toggle: CardLayoutToggle.showThumbnail,
              value: value,
            ),
          ),
        ),
        SwitchListTile(
          title: Text(localizations.settingsShowVersionSubtitle),
          value: config.showVersionSubtitle,
          onChanged: (value) => bloc.add(
            SettingsCardLayoutToggled(
              toggle: CardLayoutToggle.showVersionSubtitle,
              value: value,
            ),
          ),
        ),
        SwitchListTile(
          title: Text(localizations.settingsHidePlaysWhenZero),
          value: config.hidePlaysOnZero,
          onChanged: (value) => bloc.add(
            SettingsCardLayoutToggled(
              toggle: CardLayoutToggle.hidePlaysOnZero,
              value: value,
            ),
          ),
        ),
        SwitchListTile(
          title: Text(localizations.settingsShowPlayerNamesOnPlays),
          value: config.showPlayerNamesOnPlays,
          onChanged: (value) => bloc.add(
            SettingsCardLayoutToggled(
              toggle: CardLayoutToggle.showPlayerNamesOnPlays,
              value: value,
            ),
          ),
        ),
        SwitchListTile(
          title: Text(localizations.settingsShowGeekRatingUserCount),
          value: config.showGeekRatingUserCount,
          onChanged: (value) => bloc.add(
            SettingsCardLayoutToggled(
              toggle: CardLayoutToggle.showGeekRatingUserCount,
              value: value,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          localizations.settingsVisibleFieldsHint,
          style: theme.textTheme.bodySmall,
        ),
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          onReorderItem: (oldIndex, newIndex) {
            setState(() {
              final item = _order.removeAt(oldIndex);
              _order.insert(newIndex, item);
            });
            context.read<SettingsBloc>().add(
              SettingsCardFieldOrderChanged(List<CardField>.of(_order)),
            );
          },
          children: _order.map((field) {
            final label = _fieldLabel(field, localizations);
            final suffix = _fieldSuffix(field, config, localizations);
            final displayLabel = suffix.isNotEmpty ? '$label ($suffix)' : label;
            final isEnabled = config.isEnabled(field);
            return ListTile(
              key: ValueKey(field),
              leading: Icon(
                isEnabled ? Icons.check_box : Icons.check_box_outline_blank,
              ),
              title: Text(displayLabel),
              onTap: () => bloc.add(
                SettingsCardLayoutToggled(
                  toggle: CardLayoutToggle.field,
                  value: !isEnabled,
                  field: field,
                ),
              ),
              trailing: const Icon(Icons.drag_handle),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _fieldLabel(CardField field, AppLocalizations localizations) {
    return switch (field) {
      CardField.playerCount => localizations.cardFieldPlayerCount,
      CardField.playTime => localizations.cardFieldPlayTime,
      CardField.plays => localizations.cardFieldPlays,
      CardField.ownRating => localizations.cardFieldOwnRating,
      CardField.geekRating => localizations.cardFieldGeekRating,
      CardField.minAge => localizations.cardFieldMinAge,
      CardField.bggRank => localizations.cardFieldBggRank,
    };
  }

  String _fieldSuffix(
    CardField field,
    CardLayoutConfig config,
    AppLocalizations localizations,
  ) {
    return switch (field) {
      CardField.plays =>
        config.hidePlaysOnZero && config.showPlayerNamesOnPlays
            ? '${localizations.cardFieldPlaysHiddenWhenZero}, ${localizations.cardFieldPlaysPlayerNames}'
            : config.hidePlaysOnZero
            ? localizations.cardFieldPlaysHiddenWhenZero
            : config.showPlayerNamesOnPlays
            ? localizations.cardFieldPlaysPlayerNames
            : '',
      CardField.geekRating =>
        config.showGeekRatingUserCount
            ? localizations.cardFieldGeekRatingIncludesUserCount
            : '',
      _ => '',
    };
  }
}

class _ThemeSection extends StatelessWidget {
  const _ThemeSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return BlocBuilder<ThemeCubit, ThemeConfig>(
      builder: (context, config) {
        final themeCubit = context.read<ThemeCubit>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.settingsThemeModeTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text(localizations.settingsThemeModeSystem),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text(localizations.settingsThemeModeLight),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text(localizations.settingsThemeModeDark),
                ),
              ],
              selected: {config.themeMode},
              onSelectionChanged: (selected) {
                if (selected.isNotEmpty) {
                  themeCubit.setThemeMode(selected.first);
                }
              },
            ),
            const SizedBox(height: 24),
            Text(
              localizations.settingsFontSizeTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Slider(
              value: config.fontSizeIndex.toDouble(),
              min: 0,
              max: 4,
              divisions: 4,
              label: '${config.fontSizeIndex + 1}',
              onChanged: (value) {
                themeCubit.setFontSizeIndex(value.round());
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    localizations.settingsShowPlayerFilterHintTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Switch(
                  value: config.showPlayerFilterHint,
                  onChanged: (value) {
                    themeCubit.setShowPlayerFilterHint(value);
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
