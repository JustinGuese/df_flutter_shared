import 'package:df_ui_widgets/df_ui_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform, debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../auth_providers.dart';
import '../auth_routing.dart';
import 'google_icon.dart';
import 'login_strings.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({
    super.key,
    this.sessionReason,
    this.strings = const DfLoginStrings(),
  });

  final String? sessionReason;
  final DfLoginStrings strings;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reason = widget.sessionReason;
      if (!mounted || reason != 'sessionExpired') return;
      DfSnackbar.show(context, widget.strings.sessionExpired);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Where to land after a successful sign-in — honours `?next=` so a bounce
  /// from an invite link or a paywall returns where it started.
  String _destination(String homeRoute) =>
      dfPostAuthDestination(context, fallback: homeRoute);

  Future<void> _showForgotPasswordDialog() async {
    final s = widget.strings;
    final resetEmailController = TextEditingController();
    final resetFormKey = GlobalKey<FormState>();
    bool resetLoading = false;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(s.resetDialogTitle),
          content: Form(
            key: resetFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(s.resetDialogBody),
                const SizedBox(height: 16),
                TextFormField(
                  controller: resetEmailController,
                  decoration: InputDecoration(
                    labelText: s.emailLabel,
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  enabled: !resetLoading,
                  autofocus: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return s.emailRequired;
                    }
                    if (!value.contains('@')) return s.resetEmailInvalid;
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: resetLoading
                  ? null
                  : () => Navigator.of(context).pop(),
              child: Text(s.resetCancel),
            ),
            FilledButton(
              onPressed: resetLoading
                  ? null
                  : () async {
                      if (!resetFormKey.currentState!.validate()) return;
                      final email = resetEmailController.text.trim();
                      setDialogState(() => resetLoading = true);
                      try {
                        await ref
                            .read(authRepositoryProvider)
                            .sendPasswordReset(email);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          DfSnackbar.show(
                            context,
                            DfLoginStrings.fill(s.resetSent, {
                              'email': email,
                            }),
                          );
                        }
                      } on FirebaseAuthException catch (e) {
                        setDialogState(() => resetLoading = false);
                        if (context.mounted) {
                          String errorMessage;
                          switch (e.code) {
                            case 'user-not-found':
                              errorMessage =
                                  'No account found with this email address.';
                              break;
                            case 'invalid-email':
                              errorMessage = 'Invalid email address.';
                              break;
                            case 'too-many-requests':
                              errorMessage =
                                  'Too many requests. Please try again later.';
                              break;
                            default:
                              errorMessage =
                                  e.message ??
                                  'An error occurred. Please try again.';
                          }
                          DfSnackbar.error(context, errorMessage);
                        }
                      } on Exception catch (error) {
                        setDialogState(() => resetLoading = false);
                        if (context.mounted) {
                          DfSnackbar.error(
                            context,
                            error.toString().replaceAll('Exception: ', ''),
                          );
                        }
                      }
                    },
              child: resetLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Text(s.resetSend),
            ),
          ],
        ),
      ),
    );
    resetEmailController.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final config = ref.read(authConfigProvider);
    try {
      await ref
          .read(authRepositoryProvider)
          .signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      if (mounted) context.go(_destination(config.homeRoute));
    } on Exception catch (error) {
      if (mounted) DfSnackbar.error(context, error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    final config = ref.read(authConfigProvider);
    try {
      final credential = await ref
          .read(authRepositoryProvider)
          .signInWithGoogle();
      // Social sign-in from the *login* screen still creates the account when
      // the user is new, so the registration is reported from here too.
      if (credential.additionalUserInfo?.isNewUser ?? false) {
        config.onRegistered?.call();
      }
      if (mounted) context.go(_destination(config.homeRoute));
    } on Exception catch (error) {
      if (mounted) {
        final errorMessage = error.toString();
        if (errorMessage.contains('cancelled')) return;
        DfSnackbar.error(context, errorMessage.replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithApple() async {
    setState(() => _loading = true);
    final config = ref.read(authConfigProvider);
    try {
      final credential = await ref
          .read(authRepositoryProvider)
          .signInWithApple();
      // See _signInWithGoogle: a first-time Apple user registers here.
      if (credential.additionalUserInfo?.isNewUser ?? false) {
        config.onRegistered?.call();
      }
      if (mounted) context.go(_destination(config.homeRoute));
    } on Exception catch (error) {
      if (mounted) {
        final errorMessage = error.toString();
        if (errorMessage.contains('cancelled') ||
            errorMessage.contains('canceled')) {
          return;
        }
        final friendlyMessage = _appleSignInFriendlyError(errorMessage);
        DfSnackbar.error(context, friendlyMessage);
      }
    } catch (error, stackTrace) {
      debugPrint('Apple Sign-In unexpected error: $error $stackTrace');
      if (mounted) {
        DfSnackbar.error(context, 'Sign-in failed. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _appleSignInFriendlyError(String error) {
    if (error.contains('operation-not-allowed') ||
        error.contains('identity provider configuration')) {
      return 'Apple Sign-In is temporarily unavailable. Please try again or use another sign-in method.';
    }
    if (error.contains('network') ||
        error.contains('timeout') ||
        error.contains('connection')) {
      return 'Please check your connection and try again.';
    }
    if (error.contains('account-exists-with-different-credential')) {
      return 'An account already exists with a different sign-in method. Please sign in with that method instead.';
    }
    return 'Sign-in failed. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = ref.watch(authConfigProvider);
    final s = widget.strings;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(config.logoAssetPath, height: 96),
                      const SizedBox(height: 24),
                      Text(
                        s.welcomeTitle,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        DfLoginStrings.fill(s.subtitle, {
                          'appName': config.appName,
                        }),
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      AutofillGroup(
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: s.emailLabel,
                                prefixIcon: const Icon(Icons.email_outlined),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [
                                AutofillHints.email,
                                AutofillHints.username,
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return s.emailRequired;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: s.passwordLabel,
                                prefixIcon: const Icon(Icons.lock_outline),
                              ),
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                              onFieldSubmitted: (_) {
                                if (!_loading) _signIn();
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return s.passwordRequired;
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _loading ? null : _signIn,
                          child: _loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(s.signInButton),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const Expanded(child: Divider(thickness: 1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              s.orDivider,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider(thickness: 1)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton(
                        onPressed: _loading ? null : _signInWithGoogle,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          side: const BorderSide(color: Color(0xFFDADADA)),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const GoogleIcon(),
                            const SizedBox(width: 12),
                            Text(
                              s.googleButton,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      if (!kIsWeb &&
                          (defaultTargetPlatform == TargetPlatform.iOS ||
                              defaultTargetPlatform ==
                                  TargetPlatform.macOS)) ...[
                        const SizedBox(height: 16),
                        SignInWithAppleButton(
                          onPressed: _loading ? () {} : _signInWithApple,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _loading ? null : _showForgotPasswordDialog,
                        child: Text(s.forgotPassword),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => context.go(
                          '${config.registerRoute}${_nextQuery(context)}',
                        ),
                        child: Text(s.noAccount),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Carries `?next=` along from login to register, so switching between them
/// mid-invite-flow doesn't lose the destination.
String _nextQuery(BuildContext context) {
  final next = GoRouterState.of(context).uri.queryParameters['next'];
  final safe = dfSanitizeNextPath(next);
  return safe == null ? '' : '?next=${Uri.encodeQueryComponent(safe)}';
}
