import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'onboarding_page_model.dart';
import 'onboarding_provider.dart';

extension _ColorOpacityCompat on Color {
  Color withOpacityCompat(double opacity) {
    return withValues(alpha: opacity.clamp(0.0, 1.0));
  }
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({
    super.key,
    this.isHelpMode = false,
    this.onCompleted,
    this.onNavigateAfterComplete,
  });

  final bool isHelpMode;
  final Future<void> Function(BuildContext context)? onCompleted;
  final VoidCallback? onNavigateAfterComplete;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Future<void> _completeOnboarding() async {
    final config = ref.read(onboardingConfigProvider);
    if (widget.isHelpMode) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(config.preferencesKey, true);

    if (mounted && widget.onCompleted != null) {
      await widget.onCompleted!(context);
    }

    ref.invalidate(onboardingCompletedProvider);

    if (mounted && widget.onNavigateAfterComplete != null) {
      widget.onNavigateAfterComplete!();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(onboardingConfigProvider);
    final pages = config.pages;
    final page = pages[_currentPage];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: page.gradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (widget.isHelpMode)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor:
                            Colors.white.withOpacityCompat(0.2),
                      ),
                    ),
                  ),
                )
              else if (config.showSkipButton)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: _completeOnboarding,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor:
                            Colors.white.withOpacityCompat(0.2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
                    return _OnboardingPageWidget(page: pages[index]);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    pages.length,
                    (index) => _PageIndicator(isActive: index == _currentPage),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentPage > 0)
                      Flexible(
                        child: OutlinedButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                          ),
                          child: const Text(
                            'Previous',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    Flexible(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentPage < pages.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            _completeOnboarding();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: page.gradient[0],
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          elevation: 8,
                          shadowColor:
                              Colors.black.withOpacityCompat(0.3),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentPage < pages.length - 1
                                  ? 'Next'
                                  : widget.isHelpMode
                                      ? 'Done'
                                      : 'Get Started',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _currentPage < pages.length - 1
                                  ? Icons.arrow_forward
                                  : Icons.rocket_launch,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Below: _OnboardingPageWidget, _ChecklistItem, _PageIndicator using OnboardingPageModel

class _OnboardingPageWidget extends StatefulWidget {
  const _OnboardingPageWidget({required this.page});

  final OnboardingPageModel page;

  @override
  State<_OnboardingPageWidget> createState() => _OnboardingPageWidgetState();
}

class _OnboardingPageWidgetState extends State<_OnboardingPageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  final List<bool> _checkedItems = [];

  @override
  void initState() {
    super.initState();
    _checkedItems.addAll(List.generate(widget.page.features.length, (_) => false));
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();

    Future.delayed(const Duration(milliseconds: 300), () {
      for (int i = 0; i < _checkedItems.length; i++) {
        Future.delayed(Duration(milliseconds: i * 200), () {
          if (mounted) {
            setState(() {
              _checkedItems[i] = true;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    final emojiSize = isSmallScreen ? 100.0 : 140.0;
    final emojiFontSize = isSmallScreen ? 50.0 : 72.0;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: child,
          );
        },
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: emojiSize,
                  height: emojiSize,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacityCompat(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      widget.page.emoji,
                      style: TextStyle(fontSize: emojiFontSize),
                    ),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 24 : 32),
                Text(
                  widget.page.title,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  widget.page.subtitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacityCompat(0.9),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isSmallScreen ? 24 : 40),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacityCompat(0.18),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: List.generate(
                      widget.page.features.length,
                      (index) => _ChecklistItem(
                        text: widget.page.features[index],
                        isChecked: _checkedItems[index],
                        gradient: widget.page.gradient,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({
    required this.text,
    required this.isChecked,
    required this.gradient,
  });

  final String text;
  final bool isChecked;
  final List<Color> gradient;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isChecked ? 1.0 : 0.3,
      duration: const Duration(milliseconds: 300),
      child: AnimatedScale(
        scale: isChecked ? 1.0 : 0.9,
        duration: const Duration(milliseconds: 300),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.elasticOut,
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: isChecked ? LinearGradient(colors: gradient) : null,
                  color: isChecked ? null : Colors.grey[300],
                  shape: BoxShape.circle,
                  boxShadow: isChecked
                      ? [
                          BoxShadow(
                            color: gradient[0].withOpacityCompat(0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: isChecked
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 18,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        isChecked ? FontWeight.w600 : FontWeight.w500,
                    color: isChecked ? Colors.white : Colors.white70,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? Colors.white
            : Colors.white.withOpacityCompat(0.4),
        borderRadius: BorderRadius.circular(4),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.white.withOpacityCompat(0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }
}
