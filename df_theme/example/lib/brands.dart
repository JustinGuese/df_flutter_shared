import 'package:df_theme/df_theme.dart';
import 'package:google_fonts/google_fonts.dart';

/// The brands the gallery can switch between.
///
/// Four of these reproduce a shipping app; `dataFortress` is the house default
/// a new app would start from. Seeing them side by side is the point — the
/// palettes are meant to differ while the structure stays identical.
enum GalleryBrand {
  dataFortress('DataFortress'),
  naviCare('NaviCare'),
  psychDiary('PsychDiary'),
  documentChat('DocumentChat'),
  tileDom('TileDom'),
  socialAnxify('SocialAnxify');

  const GalleryBrand(this.label);

  final String label;

  DfBrand build() => switch (this) {
    GalleryBrand.dataFortress => DfBrandPresets.dataFortress(
      typography: DfTypography(
        display: GoogleFonts.fraunces().fontFamily,
        body: GoogleFonts.publicSans().fontFamily,
        mono: GoogleFonts.jetBrainsMono().fontFamily,
      ),
    ),
    GalleryBrand.naviCare => DfBrandPresets.naviCare().copyWith(
      typography: DfTypography(
        display: GoogleFonts.plusJakartaSans().fontFamily,
        body: GoogleFonts.inter().fontFamily,
        mono: GoogleFonts.jetBrainsMono().fontFamily,
      ),
    ),
    GalleryBrand.psychDiary => DfBrandPresets.psychDiary().copyWith(
      typography: DfTypography(
        body: GoogleFonts.inter().fontFamily,
        mono: GoogleFonts.jetBrainsMono().fontFamily,
      ),
    ),
    GalleryBrand.documentChat => DfBrandPresets.documentChat().copyWith(
      typography: DfTypography(
        body: GoogleFonts.inter().fontFamily,
        mono: GoogleFonts.jetBrainsMono().fontFamily,
      ),
    ),
    GalleryBrand.tileDom => DfBrandPresets.tileDom().copyWith(
      typography: DfTypography(
        display: GoogleFonts.syne().fontFamily,
        body: GoogleFonts.sora().fontFamily,
        mono: GoogleFonts.spaceMono().fontFamily,
      ),
    ),
    GalleryBrand.socialAnxify => DfBrandPresets.socialAnxify().copyWith(
      typography: DfTypography(
        display: GoogleFonts.pressStart2p().fontFamily,
        body: GoogleFonts.pressStart2p().fontFamily,
        mono: GoogleFonts.pressStart2p().fontFamily,
        scale: 0.68,
      ),
    ),
  };
}
