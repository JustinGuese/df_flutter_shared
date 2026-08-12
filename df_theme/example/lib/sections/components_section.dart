import 'package:df_theme/df_theme.dart';
import 'package:flutter/material.dart';

import '../main.dart' show GallerySection;

/// Buttons, inputs, selection controls and surfaces.
///
/// These all come from `DfTheme`'s component sub-themes — none of them is
/// styled here. If a brand looks wrong in this section, the fix belongs in
/// `df_theme_builder.dart`, not in a widget.
class ComponentsSection extends StatefulWidget {
  const ComponentsSection({super.key});

  @override
  State<ComponentsSection> createState() => _ComponentsSectionState();
}

class _ComponentsSectionState extends State<ComponentsSection> {
  bool _switchOn = true;
  bool _checked = true;
  int _radio = 0;
  double _slider = 0.4;
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final df = context.df;

    return GallerySection(
      eyebrow: 'Components',
      title: 'Controls & surfaces',
      children: [
        Wrap(
          spacing: df.spacing.xs,
          runSpacing: df.spacing.xs,
          children: [
            FilledButton(onPressed: () {}, child: const Text('Save changes')),
            OutlinedButton(onPressed: () {}, child: const Text('Cancel')),
            TextButton(onPressed: () {}, child: const Text('Learn more')),
            FilledButton(onPressed: null, child: const Text('Disabled')),
            IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
          ],
        ),
        SizedBox(height: df.spacing.md),

        TextField(
          decoration: const InputDecoration(
            labelText: 'Entry title',
            hintText: 'What happened today?',
          ),
        ),
        SizedBox(height: df.spacing.sm),
        TextField(
          decoration: InputDecoration(
            labelText: 'Email',
            errorText: 'Enter an address we can reach you at.',
            suffixIcon: Icon(Icons.error_outline, color: df.colors.error.base),
          ),
        ),
        SizedBox(height: df.spacing.md),

        Container(
          decoration: BoxDecoration(
            color: df.colors.surface,
            borderRadius: df.shape.radiusMd,
            border: df.hairlineBorder,
          ),
          child: Column(
            children: [
              SwitchListTile(
                value: _switchOn,
                onChanged: (v) => setState(() => _switchOn = v),
                title: const Text('Daily reminder'),
                subtitle: const Text('Every evening at 20:00'),
              ),
              CheckboxListTile(
                value: _checked,
                onChanged: (v) => setState(() => _checked = v ?? false),
                title: const Text('Include mood analysis'),
              ),
              RadioGroup<int>(
                groupValue: _radio,
                onChanged: (v) => setState(() => _radio = v ?? 0),
                child: const Column(
                  children: [
                    RadioListTile<int>(
                      value: 0,
                      title: Text('Keep entries on this device'),
                    ),
                    RadioListTile<int>(
                      value: 1,
                      title: Text('Sync across devices'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: df.spacing.md),

        Slider(value: _slider, onChanged: (v) => setState(() => _slider = v)),
        SizedBox(height: df.spacing.xs),
        const LinearProgressIndicator(value: 0.62),
        SizedBox(height: df.spacing.md),

        Wrap(
          spacing: df.spacing.xs,
          runSpacing: df.spacing.xs,
          children: [
            for (final label in ['Sleep', 'Focus', 'Energy', 'Mood'])
              FilterChip(
                label: Text(label),
                selected: label == 'Focus',
                onSelected: (_) {},
              ),
          ],
        ),
        SizedBox(height: df.spacing.md),

        _TabsCard(index: _tab, onChanged: (i) => setState(() => _tab = i)),
        SizedBox(height: df.spacing.md),

        _SurfaceStack(),
      ],
    );
  }
}

class _TabsCard extends StatelessWidget {
  const _TabsCard({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    return DefaultTabController(
      length: 3,
      initialIndex: index,
      child: Container(
        decoration: BoxDecoration(
          color: df.colors.surface,
          borderRadius: df.shape.radiusMd,
          border: df.hairlineBorder,
        ),
        child: Column(
          children: [
            TabBar(
              onTap: onChanged,
              tabs: const [
                Tab(text: 'Today'),
                Tab(text: 'Week'),
                Tab(text: 'All'),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(df.spacing.md),
              child: Text(
                'Tab ${index + 1} content.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// canvas → surface → elevated → sunken, stacked so the depth order is visible.
class _SurfaceStack extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final df = context.df;
    final t = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.all(df.spacing.md),
      decoration: BoxDecoration(
        color: df.colors.canvas,
        borderRadius: df.shape.radiusLg,
        border: df.hairlineBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('canvas', style: t.labelSmall),
          SizedBox(height: df.spacing.xs),
          Container(
            padding: EdgeInsets.all(df.spacing.md),
            decoration: BoxDecoration(
              color: df.colors.surface,
              borderRadius: df.shape.radiusMd,
              boxShadow: df.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('surface + cardShadow', style: t.labelSmall),
                SizedBox(height: df.spacing.xs),
                Container(
                  padding: EdgeInsets.all(df.spacing.sm),
                  decoration: BoxDecoration(
                    color: df.colors.surfaceSunken,
                    borderRadius: df.shape.radiusSm,
                  ),
                  child: Text('surfaceSunken', style: t.labelSmall),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
