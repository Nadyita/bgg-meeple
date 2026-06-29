import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// User-configurable theme and text-size settings.
class ThemeConfig extends Equatable {
  const ThemeConfig({
    this.themeMode = ThemeMode.system,
    this.fontSizeIndex = 2,
  });

  final ThemeMode themeMode;
  final int fontSizeIndex;

  static const _minFontSizeIndex = 0;
  static const _maxFontSizeIndex = 4;
  static const _defaultFontSizeIndex = 2;

  /// Scales derived from the 5 font-size levels.
  ///
  /// Level 2 (index 2) is the normal/default scale of 1.0.
  static const _fontScales = [0.875, 0.9375, 1.0, 1.0625, 1.125];

  /// Returns the text scale factor for the current font size level.
  double get textScaleFactor {
    final clamped = fontSizeIndex.clamp(_minFontSizeIndex, _maxFontSizeIndex);
    return _fontScales[clamped];
  }

  ThemeConfig copyWith({ThemeMode? themeMode, int? fontSizeIndex}) {
    return ThemeConfig(
      themeMode: themeMode ?? this.themeMode,
      fontSizeIndex: fontSizeIndex ?? this.fontSizeIndex,
    );
  }

  Map<String, dynamic> toJson() {
    return {'themeMode': themeMode.name, 'fontSizeIndex': fontSizeIndex};
  }

  factory ThemeConfig.fromJson(Map<String, dynamic> json) {
    final themeModeName = json['themeMode'] as String?;
    final themeMode = ThemeMode.values.firstWhere(
      (m) => m.name == themeModeName,
      orElse: () => ThemeMode.system,
    );
    final fontSizeIndex =
        (json['fontSizeIndex'] as num? ?? _defaultFontSizeIndex).toInt().clamp(
          _minFontSizeIndex,
          _maxFontSizeIndex,
        );
    return ThemeConfig(themeMode: themeMode, fontSizeIndex: fontSizeIndex);
  }

  @override
  List<Object?> get props => [themeMode, fontSizeIndex];
}
