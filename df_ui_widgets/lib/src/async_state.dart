import 'package:df_theme/df_theme.dart';
import 'package:flutter/material.dart';

/// A centred loading indicator with an optional label.
///
/// Exists because `CircularProgressIndicator` was inlined ~60 times across the
/// apps, each with slightly different padding and sizing.
class DfLoading extends StatelessWidget {
  const DfLoading({super.key, this.label, this.compact = false});

  /// Shown under the spinner. Say what is loading — "Loading entries" beats a
  /// bare "Loading…".
  final String? label;

  /// Inline size, for use inside a button or list row rather than a whole page.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    final indicator = SizedBox(
      width: compact ? 18 : 32,
      height: compact ? 18 : 32,
      child: CircularProgressIndicator(strokeWidth: compact ? 2 : 3),
    );

    if (compact) return Center(child: indicator);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(df.spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            indicator,
            if (label != null) ...[
              SizedBox(height: df.spacing.md),
              Text(
                label!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shown when there is nothing yet — and therefore an invitation to act.
///
/// An empty screen is a moment for direction, not an apology, so [action] is
/// strongly encouraged wherever the user can actually create the missing thing.
class DfEmptyState extends StatelessWidget {
  const DfEmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.action,
  });

  /// One short line naming what is missing.
  final String title;

  /// Optional detail — how to get started, or why this is empty.
  final String? message;

  final IconData? icon;

  /// The next step. Usually a `FilledButton`.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    final text = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(df.spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 40, color: df.colors.textTertiary),
              SizedBox(height: df.spacing.md),
            ],
            Text(title, textAlign: TextAlign.center, style: text.titleMedium),
            if (message != null) ...[
              SizedBox(height: df.spacing.xs),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: text.bodySmall?.copyWith(color: df.colors.textSecondary),
              ),
            ],
            if (action != null) ...[SizedBox(height: df.spacing.lg), action!],
          ],
        ),
      ),
    );
  }
}

/// Shown when something failed.
///
/// Errors state what happened and what to do about it. They do not apologise
/// and they are never vague — "Could not reach the server" is actionable,
/// "Something went wrong" is not.
class DfErrorState extends StatelessWidget {
  const DfErrorState({
    super.key,
    required this.title,
    this.message,
    this.onRetry,
    this.retryLabel = 'Try again',
    this.compact = false,
  });

  /// What went wrong, in the interface's voice.
  final String title;

  /// How to fix it, when the user can.
  final String? message;

  final VoidCallback? onRetry;
  final String retryLabel;

  /// Inline variant for a failed section inside an otherwise working screen.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final df = context.df;
    final text = Theme.of(context).textTheme;

    final body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: compact
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: df.colors.error.deep, size: 20),
            SizedBox(width: df.spacing.xs),
            Flexible(
              child: Text(
                title,
                style: text.titleSmall?.copyWith(color: df.colors.error.deep),
              ),
            ),
          ],
        ),
        if (message != null) ...[
          SizedBox(height: df.spacing.xs),
          Text(
            message!,
            textAlign: compact ? TextAlign.start : TextAlign.center,
            style: text.bodySmall?.copyWith(color: df.colors.error.deep),
          ),
        ],
        if (onRetry != null) ...[
          SizedBox(height: df.spacing.sm),
          TextButton(onPressed: onRetry, child: Text(retryLabel)),
        ],
      ],
    );

    final card = Container(
      width: compact ? double.infinity : null,
      padding: EdgeInsets.all(df.spacing.md),
      decoration: BoxDecoration(
        color: df.colors.error.bg,
        borderRadius: df.shape.radiusMd,
        border: Border.all(color: df.colors.error.soft),
      ),
      child: body,
    );

    if (compact) return card;
    return Center(
      child: Padding(padding: EdgeInsets.all(df.spacing.xl), child: card),
    );
  }
}

/// Renders an [AsyncValue]-shaped result with the house loading and error
/// states, so screens stop hand-rolling the three branches.
///
/// Deliberately takes plain callbacks rather than depending on Riverpod —
/// df_ui_widgets stays widget-only, and not every consumer uses Riverpod.
///
/// ```dart
/// final entries = ref.watch(entriesProvider);
/// return DfAsyncBuilder(
///   isLoading: entries.isLoading,
///   error: entries.error,
///   data: entries.valueOrNull,
///   onRetry: () => ref.invalidate(entriesProvider),
///   builder: (context, rows) => _EntryList(rows),
/// );
/// ```
class DfAsyncBuilder<T> extends StatelessWidget {
  const DfAsyncBuilder({
    super.key,
    required this.isLoading,
    required this.data,
    required this.builder,
    this.error,
    this.onRetry,
    this.loadingLabel,
    this.errorTitle = 'Could not load this',
    this.errorMessage,
  });

  final bool isLoading;
  final Object? error;
  final T? data;
  final Widget Function(BuildContext context, T data) builder;
  final VoidCallback? onRetry;
  final String? loadingLabel;
  final String errorTitle;

  /// Overrides the message shown under [errorTitle]. Leave null to show
  /// nothing — raw exception text is rarely useful to a user, so pass a written
  /// explanation when there is one.
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    // Stale data outranks a spinner: a refresh should not blank the screen.
    if (data != null && (isLoading || error != null)) {
      return builder(context, data as T);
    }
    if (isLoading) return DfLoading(label: loadingLabel);
    if (error != null) {
      return DfErrorState(
        title: errorTitle,
        message: errorMessage,
        onRetry: onRetry,
      );
    }
    if (data == null) return const SizedBox.shrink();
    return builder(context, data as T);
  }
}

/// Snackbars in the house style.
///
/// Wraps `ScaffoldMessenger` so tone and duration stay consistent instead of
/// being re-decided at each of the ~60 call sites across the apps.
abstract final class DfSnackbar {
  /// Confirms something happened. Use the past tense of the action's own verb —
  /// "Published", not "Success".
  static void show(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) => _show(context, message, actionLabel, onAction, null);

  /// Reports a failure. Say what failed and what to do next.
  static void error(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) => _show(
    context,
    message,
    actionLabel,
    onAction,
    context.df.colors.error.deep,
  );

  static void _show(
    BuildContext context,
    String message,
    String? actionLabel,
    VoidCallback? onAction,
    Color? background,
  ) {
    ScaffoldMessenger.of(context)
      // One at a time: a queue of stale toasts is noise.
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: background,
          duration: Duration(seconds: onAction != null ? 6 : 4),
          action: (actionLabel != null && onAction != null)
              ? SnackBarAction(label: actionLabel, onPressed: onAction)
              : null,
        ),
      );
  }
}
