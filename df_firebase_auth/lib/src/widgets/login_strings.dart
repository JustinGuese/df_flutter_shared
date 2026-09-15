/// Copy for [LoginScreen]. English defaults; pass a localized instance to
/// translate. Mirrors the pattern in `DfAccountSettingsStrings`.
class DfLoginStrings {
  const DfLoginStrings({
    this.welcomeTitle = 'Welcome back',
    this.subtitle = 'Sign in to your {appName} workspace',
    this.emailLabel = 'Email',
    this.emailRequired = 'Please enter your email',
    this.passwordLabel = 'Password',
    this.passwordRequired = 'Please enter your password',
    this.signInButton = 'Sign in',
    this.orDivider = 'OR',
    this.googleButton = 'Sign in with Google',
    this.forgotPassword = 'Forgot password?',
    this.noAccount = "Don't have an account? Sign up",
    this.sessionExpired = 'Your session expired. Please sign in again.',
    this.resetDialogTitle = 'Reset password',
    this.resetDialogBody =
        "Enter your email address and we'll send you a link to reset your password.",
    this.resetEmailInvalid = 'Please enter a valid email address',
    this.resetCancel = 'Cancel',
    this.resetSend = 'Send reset link',
    this.resetSent = 'Password reset email sent to {email}. Check your inbox.',
  });

  final String welcomeTitle;
  final String subtitle;
  final String emailLabel;
  final String emailRequired;
  final String passwordLabel;
  final String passwordRequired;
  final String signInButton;
  final String orDivider;
  final String googleButton;
  final String forgotPassword;
  final String noAccount;
  final String sessionExpired;
  final String resetDialogTitle;
  final String resetDialogBody;
  final String resetEmailInvalid;
  final String resetCancel;
  final String resetSend;
  final String resetSent;

  /// Substitutes `{placeholder}` tokens, e.g. `fill(subtitle, {'appName':
  /// config.appName})`.
  static String fill(String template, Map<String, String> values) {
    var result = template;
    for (final entry in values.entries) {
      result = result.replaceAll('{${entry.key}}', entry.value);
    }
    return result;
  }
}

/// Copy for [RegisterScreen]. English defaults; pass a localized instance to
/// translate.
class DfRegisterStrings {
  const DfRegisterStrings({
    this.title = 'Create your account',
    this.emailLabel = 'Email',
    this.emailRequired = 'Please enter your email',
    this.passwordLabel = 'Password',
    this.passwordTooShort = 'Password must be at least 6 characters',
    this.confirmPasswordLabel = 'Confirm password',
    this.passwordMismatch = 'Passwords do not match',
    this.signUpButton = 'Sign up',
    this.orDivider = 'OR',
    this.googleButton = 'Sign up with Google',
    this.haveAccount = 'Already have an account? Sign in',
  });

  final String title;
  final String emailLabel;
  final String emailRequired;
  final String passwordLabel;
  final String passwordTooShort;
  final String confirmPasswordLabel;
  final String passwordMismatch;
  final String signUpButton;
  final String orDivider;
  final String googleButton;
  final String haveAccount;
}
