import 'package:df_theme/df_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth_providers.dart';
import 'sign_in_sheet_strings.dart';

/// Modal bottom sheet prompting the user to sign in to save and sync progress.
///
/// Generalised from the app's `SaveProgressSheet`, styled exclusively with
/// `context.df` tokens (radii, spacing, palette).
class DfSignInSheet extends ConsumerStatefulWidget {
  const DfSignInSheet({
    super.key,
    this.strings = const DfSignInSheetStrings(),
    this.onSignedIn,
  });

  /// User-facing copy for the sheet.
  final DfSignInSheetStrings strings;

  /// Optional callback invoked after a successful sign-in before closing.
  final VoidCallback? onSignedIn;

  /// Presents the [DfSignInSheet] modal bottom sheet.
  static Future<T?> show<T>(
    BuildContext context, {
    DfSignInSheetStrings strings = const DfSignInSheetStrings(),
    String? title,
    String? subtitle,
    VoidCallback? onSignedIn,
  }) {
    final effectiveStrings = (title != null || subtitle != null)
        ? strings.copyWith(title: title, subtitle: subtitle)
        : strings;

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          DfSignInSheet(strings: effectiveStrings, onSignedIn: onSignedIn),
    );
  }

  @override
  ConsumerState<DfSignInSheet> createState() => _DfSignInSheetState();
}

class _DfSignInSheetState extends ConsumerState<DfSignInSheet> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    final authRepo = ref.read(authRepositoryProvider);
    try {
      await authRepo.signInWithGoogle();
      widget.onSignedIn?.call();
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final err = e.toString();
        if (err.contains('cancelled') || err.contains('canceled')) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.strings.fillGoogleFailed(e))),
        );
      }
    }
  }

  Future<void> _handleAppleSignIn() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    final authRepo = ref.read(authRepositoryProvider);
    try {
      await authRepo.signInWithApple();
      widget.onSignedIn?.call();
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final err = e.toString();
        if (err.contains('cancelled') || err.contains('canceled')) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.strings.fillAppleFailed(e))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    final theme = Theme.of(context);
    final strings = widget.strings;

    return Container(
      padding: EdgeInsets.all(df.spacing.lg),
      decoration: BoxDecoration(
        color: df.colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(df.shape.xl)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: df.spacing.xlPlus,
                height: df.spacing.xxs,
                decoration: BoxDecoration(
                  color: df.colors.hairline,
                  borderRadius: df.shape.radiusPill,
                ),
              ),
            ),
            SizedBox(height: df.spacing.mdPlus),
            Text(
              strings.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: df.colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: df.spacing.sm),
            Text(
              strings.subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: df.colors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: df.spacing.lg),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleGoogleSignIn,
              icon: Icon(Icons.g_mobiledata, size: df.shape.xl),
              label: Text(strings.googleButton),
              style: ElevatedButton.styleFrom(
                backgroundColor: df.colors.surfaceElevated,
                foregroundColor: df.colors.textPrimary,
                padding: EdgeInsets.symmetric(vertical: df.shape.md),
                shape: RoundedRectangleBorder(
                  borderRadius: df.shape.radiusButton,
                ),
              ),
            ),
            SizedBox(height: df.spacing.sm),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleAppleSignIn,
              icon: Icon(Icons.apple, size: df.shape.lg + 2),
              label: Text(strings.appleButton),
              style: ElevatedButton.styleFrom(
                backgroundColor: df.colors.textPrimary,
                foregroundColor: df.colors.surface,
                padding: EdgeInsets.symmetric(vertical: df.shape.md),
                shape: RoundedRectangleBorder(
                  borderRadius: df.shape.radiusButton,
                ),
              ),
            ),
            SizedBox(height: df.spacing.md),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                strings.notNowButton,
                style: TextStyle(color: df.colors.textTertiary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
