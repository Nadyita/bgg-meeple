import 'package:equatable/equatable.dart';

import '../../../domain/value_objects/card_layout_config.dart';
import '../../l10n/app_localizations.dart';

/// Description of an error that should be localized before it is shown to the
/// user. Storing a builder instead of a pre-formatted string keeps the BLoC
/// free of [AppLocalizations], which is an InheritedWidget and cannot be
/// safely accessed during BLoC construction.
typedef LocalizedErrorBuilder = String Function(AppLocalizations localizations);

class SettingsState extends Equatable {
  const SettingsState({
    this.username = '',
    this.password = '',
    this.isLoading = false,
    this.isSaving = false,
    this.isLoggingIn = false,
    this.isSyncing = false,
    this.saveSuccess = false,
    this.loginSuccess = false,
    this.syncSuccess = false,
    this.syncProgress,
    this.cardLayout = const CardLayoutConfig(),
    this.errorBuilder,
  });

  final String username;
  final String password;
  final bool isLoading;
  final bool isSaving;
  final bool isLoggingIn;
  final bool isSyncing;
  final bool saveSuccess;
  final bool loginSuccess;
  final bool syncSuccess;
  final String? syncProgress;
  final CardLayoutConfig cardLayout;
  final LocalizedErrorBuilder? errorBuilder;

  bool get canSave => username.trim().isNotEmpty && password.isNotEmpty;

  /// Convenience accessor that formats the current error for the given locale.
  String? errorMessage(AppLocalizations localizations) =>
      errorBuilder?.call(localizations);

  SettingsState copyWith({
    String? username,
    String? password,
    bool? isLoading,
    bool? isSaving,
    bool? isLoggingIn,
    bool? isSyncing,
    bool? saveSuccess,
    bool? loginSuccess,
    bool? syncSuccess,
    String? syncProgress,
    CardLayoutConfig? cardLayout,
    LocalizedErrorBuilder? errorBuilder,
    bool clearError = false,
    bool clearSaveSuccess = false,
    bool clearLoginSuccess = false,
    bool clearSyncSuccess = false,
    bool clearSyncProgress = false,
  }) {
    return SettingsState(
      username: username ?? this.username,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isLoggingIn: isLoggingIn ?? this.isLoggingIn,
      isSyncing: isSyncing ?? this.isSyncing,
      saveSuccess: clearSaveSuccess ? false : (saveSuccess ?? this.saveSuccess),
      loginSuccess: clearLoginSuccess
          ? false
          : (loginSuccess ?? this.loginSuccess),
      syncSuccess: clearSyncSuccess ? false : (syncSuccess ?? this.syncSuccess),
      syncProgress: clearSyncProgress
          ? null
          : (syncProgress ?? this.syncProgress),
      cardLayout: cardLayout ?? this.cardLayout,
      errorBuilder: clearError ? null : (errorBuilder ?? this.errorBuilder),
    );
  }

  @override
  List<Object?> get props => [
    username,
    password,
    isLoading,
    isSaving,
    isLoggingIn,
    isSyncing,
    saveSuccess,
    loginSuccess,
    syncSuccess,
    syncProgress,
    cardLayout,
    errorBuilder,
  ];
}
