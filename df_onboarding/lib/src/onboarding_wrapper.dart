import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'onboarding_provider.dart';
import 'onboarding_screen.dart';

class OnboardingWrapper extends ConsumerStatefulWidget {
  const OnboardingWrapper({
    super.key,
    required this.onAlreadyCompleted,
  });

  final VoidCallback onAlreadyCompleted;

  @override
  ConsumerState<OnboardingWrapper> createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends ConsumerState<OnboardingWrapper> {
  bool _hasNavigated = false;

  @override
  Widget build(BuildContext context) {
    final onboardingAsync = ref.watch(onboardingCompletedProvider);

    return onboardingAsync.when(
      data: (completed) {
        if (completed && !_hasNavigated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_hasNavigated) {
              _hasNavigated = true;
              widget.onAlreadyCompleted();
            }
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return const OnboardingScreen();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(onboardingCompletedProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
