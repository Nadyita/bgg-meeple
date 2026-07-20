import 'package:equatable/equatable.dart';

import '../../../domain/value_objects/card_field.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class SettingsLoaded extends SettingsEvent {
  const SettingsLoaded();
}

class SettingsUsernameChanged extends SettingsEvent {
  const SettingsUsernameChanged(this.username);

  final String username;

  @override
  List<Object?> get props => [username];
}

class SettingsPasswordChanged extends SettingsEvent {
  const SettingsPasswordChanged(this.password);

  final String password;

  @override
  List<Object?> get props => [password];
}

class SettingsApiTokenChanged extends SettingsEvent {
  const SettingsApiTokenChanged(this.apiToken);

  final String apiToken;

  @override
  List<Object?> get props => [apiToken];
}

class SettingsCredentialsSaved extends SettingsEvent {
  const SettingsCredentialsSaved();
}

class SettingsLoginRequested extends SettingsEvent {
  const SettingsLoginRequested();
}

class SettingsSyncRequested extends SettingsEvent {
  const SettingsSyncRequested();
}

/// Toggles a card layout option.
class SettingsCardLayoutToggled extends SettingsEvent {
  const SettingsCardLayoutToggled({
    required this.toggle,
    this.value = false,
    this.field,
  });

  final CardLayoutToggle toggle;
  final bool value;
  final CardField? field;

  @override
  List<Object?> get props => [toggle, value, field];
}

/// Updates the order of draggable card fields.
class SettingsCardFieldOrderChanged extends SettingsEvent {
  const SettingsCardFieldOrderChanged(this.order);

  final List<CardField> order;

  @override
  List<Object?> get props => [order];
}

/// Identifies which card layout aspect is being toggled.
enum CardLayoutToggle {
  showThumbnail,
  showVersionSubtitle,
  field,
  hidePlaysOnZero,
  showGeekRatingUserCount,
}
