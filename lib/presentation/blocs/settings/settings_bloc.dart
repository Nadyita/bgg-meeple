import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../application/use_cases/load_card_layout_use_case.dart';
import '../../../application/use_cases/load_credentials_use_case.dart';
import '../../../application/use_cases/login_use_case.dart';
import '../../../application/use_cases/save_card_layout_use_case.dart';
import '../../../application/use_cases/save_credentials_use_case.dart';
import '../../../application/use_cases/sync_collection_use_case.dart';
import '../../../domain/entities/bgg_credentials.dart';
import '../../../domain/value_objects/card_field.dart';
import '../../../domain/value_objects/card_layout_config.dart';
import 'settings_event.dart';
import 'settings_state.dart';

/// BLoC for the settings screen.
///
/// Handles BGG credentials, login, sync, and card layout configuration.
/// Error messages are stored as localization builders so the BLoC does not
/// depend on [AppLocalizations], which is an InheritedWidget and cannot be
/// safely accessed during BLoC construction.
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({
    required this.loadCredentials,
    required this.saveCredentials,
    required this.login,
    required this.syncCollection,
    required this.loadCardLayout,
    required this.saveCardLayout,
    this.onSyncCompleted,
  }) : super(const SettingsState()) {
    on<SettingsLoaded>(_onLoaded);
    on<SettingsUsernameChanged>(_onUsernameChanged);
    on<SettingsPasswordChanged>(_onPasswordChanged);
    on<SettingsCredentialsSaved>(_onCredentialsSaved);
    on<SettingsLoginRequested>(_onLoginRequested);
    on<SettingsSyncRequested>(_onSyncRequested);
    on<SettingsCardLayoutToggled>(_onCardLayoutToggled);
    on<SettingsCardFieldOrderChanged>(_onCardFieldOrderChanged);
  }

  final LoadCredentialsUseCase loadCredentials;
  final SaveCredentialsUseCase saveCredentials;
  final LoginUseCase login;
  final SyncCollectionUseCase? syncCollection;
  final LoadCardLayoutUseCase loadCardLayout;
  final SaveCardLayoutUseCase saveCardLayout;
  final void Function()? onSyncCompleted;

  Future<void> _onLoaded(
    SettingsLoaded event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final credentials = await loadCredentials();
      final cardLayout = await loadCardLayout();
      emit(
        state.copyWith(
          isLoading: false,
          username: credentials?.username ?? '',
          password: credentials?.password ?? '',
          cardLayout: cardLayout,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorBuilder: (localizations) =>
              localizations.errorLoadSettings(e.toString()),
        ),
      );
    }
  }

  void _onUsernameChanged(
    SettingsUsernameChanged event,
    Emitter<SettingsState> emit,
  ) {
    emit(
      state.copyWith(
        username: event.username,
        saveSuccess: false,
        loginSuccess: false,
        syncSuccess: false,
        clearError: true,
      ),
    );
  }

  void _onPasswordChanged(
    SettingsPasswordChanged event,
    Emitter<SettingsState> emit,
  ) {
    emit(
      state.copyWith(
        password: event.password,
        saveSuccess: false,
        loginSuccess: false,
        syncSuccess: false,
        clearError: true,
      ),
    );
  }

  Future<void> _onLoginRequested(
    SettingsLoginRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isLoggingIn: true, clearError: true));
    try {
      await login(
        credentials: BggCredentials(
          username: state.username,
          password: state.password,
        ),
      );
      emit(state.copyWith(isLoggingIn: false, loginSuccess: true));
    } on Exception catch (e) {
      emit(
        state.copyWith(
          isLoggingIn: false,
          errorBuilder: (localizations) =>
              localizations.errorLogin(e.toString()),
        ),
      );
    }
  }

  Future<void> _onSyncRequested(
    SettingsSyncRequested event,
    Emitter<SettingsState> emit,
  ) async {
    final useCase = syncCollection;
    if (useCase == null) {
      emit(
        state.copyWith(
          errorBuilder: (localizations) => localizations.errorSyncUnavailable,
        ),
      );
      return;
    }
    emit(state.copyWith(isSyncing: true, clearError: true, syncProgress: null));
    try {
      await useCase(
        onProgress: (progress) {
          emit(
            state.copyWith(
              syncProgress: '${progress.phase}: ${progress.loaded}',
            ),
          );
        },
      );
      emit(state.copyWith(isSyncing: false, syncSuccess: true));
      onSyncCompleted?.call();
    } on Exception catch (e) {
      emit(
        state.copyWith(
          isSyncing: false,
          syncProgress: null,
          errorBuilder: (localizations) =>
              localizations.errorSyncFailed(e.toString()),
        ),
      );
    }
  }

  Future<void> _onCredentialsSaved(
    SettingsCredentialsSaved event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      await saveCredentials(
        BggCredentials(username: state.username, password: state.password),
      );
      emit(state.copyWith(isSaving: false, saveSuccess: true));
    } on Exception catch (e) {
      emit(
        state.copyWith(
          isSaving: false,
          errorBuilder: (localizations) =>
              localizations.errorSaveCredentials(e.toString()),
        ),
      );
    }
  }

  Future<void> _onCardLayoutToggled(
    SettingsCardLayoutToggled event,
    Emitter<SettingsState> emit,
  ) async {
    final current = state.cardLayout;
    CardLayoutConfig updated;

    switch (event.toggle) {
      case CardLayoutToggle.showThumbnail:
        updated = current.copyWith(showThumbnail: event.value);
      case CardLayoutToggle.showVersionSubtitle:
        updated = current.copyWith(showVersionSubtitle: event.value);
      case CardLayoutToggle.field:
        final field = event.field;
        if (field == null) {
          updated = current;
        } else {
          final fields = List<CardField>.of(current.enabledFields);
          if (event.value) {
            if (!fields.contains(field)) {
              fields.add(field);
            }
          } else {
            fields.remove(field);
          }
          updated = current.copyWith(enabledFields: fields);
        }
      case CardLayoutToggle.hidePlaysOnZero:
        updated = current.copyWith(hidePlaysOnZero: event.value);
      case CardLayoutToggle.showGeekRatingUserCount:
        updated = current.copyWith(showGeekRatingUserCount: event.value);
    }

    await _saveAndEmitCardLayout(updated, emit);
  }

  Future<void> _onCardFieldOrderChanged(
    SettingsCardFieldOrderChanged event,
    Emitter<SettingsState> emit,
  ) async {
    final updated = state.cardLayout.copyWith(fieldOrder: event.order);
    await _saveAndEmitCardLayout(updated, emit);
  }

  Future<void> _saveAndEmitCardLayout(
    CardLayoutConfig config,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await saveCardLayout(config);
      emit(state.copyWith(cardLayout: config, clearError: true));
    } on Exception catch (e) {
      emit(
        state.copyWith(
          errorBuilder: (localizations) =>
              localizations.errorSaveCardLayout(e.toString()),
        ),
      );
    }
  }
}
