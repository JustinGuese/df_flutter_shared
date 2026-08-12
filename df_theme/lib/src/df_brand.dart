import 'package:flutter/material.dart';

import 'df_motion.dart';
import 'df_palette.dart';
import 'df_shape.dart';
import 'df_spacing.dart';
import 'df_typography.dart';

/// Everything that makes one DF app look like itself.
///
/// An app defines exactly one of these and hands it to `DfTheme.light` /
/// `DfTheme.dark`. Two palettes are carried rather than one so a single brand
/// can answer for both modes; an app that ships only one mode still supplies
/// both, and simply never builds the other theme.
@immutable
class DfBrand {
  const DfBrand({
    required this.name,
    required this.light,
    required this.dark,
    this.typography = const DfTypography.system(),
    this.spacing = const DfSpacing(),
    this.shape = const DfShape(),
    this.motion = const DfMotion(),
    this.logoAsset,
  });

  /// Product name. Used by shared chrome that needs to say what app this is.
  final String name;

  final DfPalette light;
  final DfPalette dark;

  final DfTypography typography;
  final DfSpacing spacing;
  final DfShape shape;
  final DfMotion motion;

  /// Asset path to the app's logo, for shared headers and auth screens.
  final String? logoAsset;

  DfPalette paletteFor(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  DfBrand copyWith({
    String? name,
    DfPalette? light,
    DfPalette? dark,
    DfTypography? typography,
    DfSpacing? spacing,
    DfShape? shape,
    DfMotion? motion,
    String? logoAsset,
  }) => DfBrand(
    name: name ?? this.name,
    light: light ?? this.light,
    dark: dark ?? this.dark,
    typography: typography ?? this.typography,
    spacing: spacing ?? this.spacing,
    shape: shape ?? this.shape,
    motion: motion ?? this.motion,
    logoAsset: logoAsset ?? this.logoAsset,
  );
}
