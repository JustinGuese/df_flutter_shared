import 'package:df_theme/df_theme.dart';
import 'package:flutter/material.dart';

import '../main.dart' show GallerySection;

/// Every colour role, in every weight.
///
/// The four-weight split is the thing to check here: `base` must be usable as
/// an accent, `deep` must carry white button text, `soft` must read as a
/// border, and `bg` must sit behind `deep` text legibly.
class ColorSection extends StatelessWidget {
  const ColorSection({super.key});

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    final c = df.colors;

    return GallerySection(
      eyebrow: 'Tokens',
      title: 'Colour roles',
      children: [
        _SurfaceRow(
          entries: {
            'canvas': c.canvas,
            'surface': c.surface,
            'elevated': c.surfaceElevated,
            'sunken': c.surfaceSunken,
            'hairline': c.hairline,
            'border': c.border,
          },
        ),
        SizedBox(height: df.spacing.md),
        _TextRow(),
        SizedBox(height: df.spacing.md),
        _BrandRow(label: 'brand', triad: c.brand),
        SizedBox(height: df.spacing.xs),
        _BrandRow(label: 'accent', triad: c.accent),
        SizedBox(height: df.spacing.md),
        _RoleRow(label: 'success', role: c.success),
        SizedBox(height: df.spacing.xs),
        _RoleRow(label: 'warning', role: c.warning),
        SizedBox(height: df.spacing.xs),
        _RoleRow(label: 'error', role: c.error),
        SizedBox(height: df.spacing.xs),
        _RoleRow(label: 'info', role: c.info),
      ],
    );
  }
}

class _SurfaceRow extends StatelessWidget {
  const _SurfaceRow({required this.entries});

  final Map<String, Color> entries;

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    return Wrap(
      spacing: df.spacing.xs,
      runSpacing: df.spacing.xs,
      children: [
        for (final e in entries.entries)
          _Swatch(label: e.key, color: e.value, showBorder: true),
      ],
    );
  }
}

class _TextRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final df = context.df;
    final c = df.colors;
    final labels = {
      'textPrimary': c.textPrimary,
      'textSecondary': c.textSecondary,
      'textTertiary': c.textTertiary,
      'textDisabled': c.textDisabled,
    };
    return Container(
      padding: EdgeInsets.all(df.spacing.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: df.shape.radiusMd,
        border: df.hairlineBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final e in labels.entries)
            Padding(
              padding: EdgeInsets.only(bottom: df.spacing.xxs),
              child: Text(
                '${e.key} — the quick brown fox',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: e.value),
              ),
            ),
        ],
      ),
    );
  }
}

class _BrandRow extends StatelessWidget {
  const _BrandRow({required this.label, required this.triad});

  final String label;
  final DfBrandRoleTriad triad;

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    return Wrap(
      spacing: df.spacing.xs,
      runSpacing: df.spacing.xs,
      children: [
        _Swatch(label: '$label.base', color: triad.base),
        _Swatch(label: '$label.deep', color: triad.deep),
        _Swatch(label: '$label.soft', color: triad.soft),
        _Swatch(label: '$label.container', color: triad.container),
      ],
    );
  }
}

class _RoleRow extends StatelessWidget {
  const _RoleRow({required this.label, required this.role});

  final String label;
  final DfColorRole role;

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    return Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: df.spacing.xs,
            runSpacing: df.spacing.xs,
            children: [
              _Swatch(label: '$label.base', color: role.base),
              _Swatch(label: '.deep', color: role.deep),
              _Swatch(label: '.soft', color: role.soft),
              // The pairing that must stay legible: deep text on bg.
              Container(
                width: 96,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: role.bg,
                  borderRadius: df.shape.radiusSm,
                ),
                child: Text(
                  '.bg',
                  style: TextStyle(
                    color: role.deep,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.label,
    required this.color,
    this.showBorder = false,
  });

  final String label;
  final Color color;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 96,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: df.shape.radiusSm,
            border: showBorder ? df.hairlineBorder : null,
          ),
        ),
        SizedBox(height: df.spacing.xxs),
        SizedBox(
          width: 96,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
