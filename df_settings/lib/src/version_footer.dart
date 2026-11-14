import 'package:df_theme/df_theme.dart';
import 'package:flutter/material.dart';

import 'settings_strings.dart';

/// Renders application version and build metadata at the bottom of settings.
///
/// Designed to sit as a discreet footer in [DfSettingsScaffold].
class DfVersionFooter extends StatelessWidget {
  const DfVersionFooter({
    super.key,
    required this.version,
    this.buildNumber,
    this.appName,
    this.copyright,
    this.strings = const DfSettingsStrings(),
    this.padding,
    this.onTap,
    this.textStyle,
  });

  /// The semantic version string (e.g. '1.2.0').
  final String version;

  /// Optional build number (e.g. '42').
  final String? buildNumber;

  /// Optional application name displayed before version.
  final String? appName;

  /// Optional copyright notice rendered below version.
  final String? copyright;

  /// Localized strings.
  final DfSettingsStrings strings;

  /// Outer padding. Defaults to [DfSpacing.md] vertical.
  final EdgeInsetsGeometry? padding;

  /// Optional tap handler (e.g., for developer debug menu or tap counters).
  final VoidCallback? onTap;

  /// Custom text style. Defaults to theme labelSmall in textTertiary.
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final df = context.df;

    final versionCore = buildNumber != null
        ? '${strings.versionLabel} $version ($buildNumber)'
        : '${strings.versionLabel} $version';

    final versionLine = appName != null ? '$appName $versionCore' : versionCore;

    final defaultStyle = Theme.of(
      context,
    ).textTheme.labelSmall?.copyWith(color: df.colors.textTertiary);

    final effectiveStyle = textStyle ?? defaultStyle;

    final child = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(versionLine, style: effectiveStyle, textAlign: TextAlign.center),
        if (copyright != null) ...[
          SizedBox(height: df.spacing.xxs),
          Text(copyright!, style: effectiveStyle, textAlign: TextAlign.center),
        ],
      ],
    );

    final padded = Padding(
      padding: padding ?? EdgeInsets.symmetric(vertical: df.spacing.md),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: df.shape.radiusSm,
        child: padded,
      );
    }

    return padded;
  }
}
