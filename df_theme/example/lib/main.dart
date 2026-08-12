import 'package:df_theme/df_theme.dart';
import 'package:flutter/material.dart';

import 'brands.dart';
import 'sections/color_section.dart';
import 'sections/components_section.dart';
import 'sections/feedback_section.dart';
import 'sections/type_section.dart';
import 'widgets/section_header.dart';

void main() => runApp(const GalleryApp());

/// Renders every themed component under each brand, in both modes.
///
/// This is how a df_theme change gets reviewed: switch brands and modes and
/// look for anything that inverts, clips, or loses contrast.
class GalleryApp extends StatefulWidget {
  const GalleryApp({super.key});

  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  GalleryBrand _brand = GalleryBrand.dataFortress;
  ThemeMode _mode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    final brand = _brand.build();
    return MaterialApp(
      title: 'df_theme gallery',
      debugShowCheckedModeBanner: false,
      theme: DfTheme.light(brand),
      darkTheme: DfTheme.dark(brand),
      themeMode: _mode,
      home: GalleryHome(
        brand: _brand,
        mode: _mode,
        onBrandChanged: (b) => setState(() => _brand = b),
        onModeToggled: () => setState(
          () => _mode = _mode == ThemeMode.light
              ? ThemeMode.dark
              : ThemeMode.light,
        ),
      ),
    );
  }
}

class GalleryHome extends StatelessWidget {
  const GalleryHome({
    super.key,
    required this.brand,
    required this.mode,
    required this.onBrandChanged,
    required this.onModeToggled,
  });

  final GalleryBrand brand;
  final ThemeMode mode;
  final ValueChanged<GalleryBrand> onBrandChanged;
  final VoidCallback onModeToggled;

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(df.brandName),
        actions: [
          IconButton(
            onPressed: onModeToggled,
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDark ? 'Switch to light' : 'Switch to dark',
          ),
          SizedBox(width: df.spacing.xs),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _BrandPicker(selected: brand, onChanged: onBrandChanged),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            df.spacing.md,
            df.spacing.lg,
            df.spacing.md,
            df.spacing.xxl,
          ),
          children: [
            const _SignaturePanel(),
            SizedBox(height: df.spacing.xl),
            const ColorSection(),
            SizedBox(height: df.spacing.xl),
            const TypeSection(),
            SizedBox(height: df.spacing.xl),
            const ComponentsSection(),
            SizedBox(height: df.spacing.xl),
            const FeedbackSection(),
          ],
        ),
      ),
    );
  }
}

class _BrandPicker extends StatelessWidget {
  const _BrandPicker({required this.selected, required this.onChanged});

  final GalleryBrand selected;
  final ValueChanged<GalleryBrand> onChanged;

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    // A scrolling Row rather than ListView.separated: a horizontal ListView
    // hands its children unbounded width, and ChoiceChip mis-measures under
    // that, clipping the final glyph of every label.
    return SizedBox(
      height: 56,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: df.spacing.md),
        child: Row(
          children: [
            for (final b in GalleryBrand.values)
              Padding(
                padding: EdgeInsets.only(right: df.spacing.xs),
                child: ChoiceChip(
                  label: Text(b.label),
                  selected: b == selected,
                  onSelected: (_) => onChanged(b),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The house signature: an eyebrow, a rule, and a display-face title.
class _SignaturePanel extends StatelessWidget {
  const _SignaturePanel();

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    final text = Theme.of(context).textTheme;
    // Never hardcode white on a gradient: onGradient measures the real stops,
    // which is what keeps a pale brand's hero panel readable.
    final fg = df.onGradient('header');

    return Container(
      padding: EdgeInsets.all(df.spacing.lg),
      decoration: BoxDecoration(
        gradient: df.gradient('header'),
        borderRadius: df.shape.radiusLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DESIGN SYSTEM',
            style: df.typography.eyebrow(fg.withValues(alpha: 0.75)),
          ),
          SizedBox(height: df.spacing.sm),
          Text(df.brandName, style: text.displaySmall?.copyWith(color: fg)),
          SizedBox(height: df.spacing.xs),
          Text(
            'Every component below is built from tokens. Switch brand or mode '
            'and nothing should invert, clip, or lose contrast.',
            style: text.bodyMedium?.copyWith(color: fg.withValues(alpha: 0.85)),
          ),
        ],
      ),
    );
  }
}

/// Shared by every section, so the gallery itself demonstrates the signature.
class GallerySection extends StatelessWidget {
  const GallerySection({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.children,
  });

  final String eyebrow;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DfSectionHeader(eyebrow: eyebrow, title: title),
        SizedBox(height: df.spacing.md),
        ...children,
      ],
    );
  }
}
