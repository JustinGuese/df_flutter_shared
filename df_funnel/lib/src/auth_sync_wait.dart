import 'dart:async';

import 'package:material_ui/material_ui.dart';

/// Spinner shown while the RevenueCat/auth sync is still settling (see
/// `dfAuthSyncSettledProvider`). After [timeout] it shows [fallback], so a
/// sync that never reports back cannot trap the user on a spinner.
class DfAuthSyncWait extends StatefulWidget {
  const DfAuthSyncWait({
    super.key,
    required this.fallback,
    this.timeout = const Duration(seconds: 8),
  });

  /// What to show once [timeout] elapses (typically the paywall).
  final WidgetBuilder fallback;
  final Duration timeout;

  @override
  State<DfAuthSyncWait> createState() => _DfAuthSyncWaitState();
}

class _DfAuthSyncWaitState extends State<DfAuthSyncWait> {
  Timer? _timer;
  bool _timedOut = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.timeout, () {
      if (mounted) setState(() => _timedOut = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_timedOut) return widget.fallback(context);
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
