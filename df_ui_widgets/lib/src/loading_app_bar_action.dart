import 'package:flutter/material.dart';

/// A reusable loading indicator widget for AppBar actions.
class LoadingAppBarAction extends StatelessWidget {
  const LoadingAppBarAction({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
