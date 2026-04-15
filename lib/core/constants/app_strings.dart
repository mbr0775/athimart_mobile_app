// lib/core/constants/app_strings.dart

class AppStrings {
  AppStrings._();

  // App Info
  static const String appName = 'Athimart';
  static const String appTagline = 'Where Technology Meets Lifestyle, Fitness & Tradition';
  static const String appVersion = '1.0.0';

  // Supabase
  static const String supabaseUrl = 'https://rawwckfkugrcodpvvffc.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJhd3dja2ZrdWdyY29kcHZ2ZmZjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE0MzIyMzgsImV4cCI6MjA4NzAwODIzOH0.lwtfCgfA5dQswimo_N6idQNbgn4S7ZGts82z_rbpums';

  // Auth Screens
  static const String welcome = 'Welcome Back!';
  static const String welcomeSubtitle = 'Sign in to continue shopping';
  static const String createAccount = 'Create Account';
  static const String createAccountSubtitle = 'Join Athimart and start shopping';
  static const String forgotPassword = 'Forgot Password?';
  static const String forgotPasswordSubtitle = "Enter your email and we'll send you a reset link";
  static const String resetPassword = 'Reset Password';

  static const String email = 'Email Address';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String fullName = 'Full Name';
  static const String phoneNumber = 'Phone Number';

  static const String login = 'Sign In';
  static const String signup = 'Create Account';
  static const String sendResetLink = 'Send Reset Link';
  static const String logout = 'Sign Out';

  static const String orContinueWith = 'Or continue with';
  static const String dontHaveAccount = "Don't have an account? ";
  static const String alreadyHaveAccount = 'Already have an account? ';
  static const String signUp = 'Sign Up';
  static const String signIn = 'Sign In';
  static const String backToLogin = 'Back to Sign In';

  static const String checkEmail = 'Check Your Email';
  static const String checkEmailSubtitle =
      "We've sent a password reset link to your email address.";

  // Validation
  static const String emailRequired = 'Email is required';
  static const String emailInvalid = 'Please enter a valid email';
  static const String passwordRequired = 'Password is required';
  static const String passwordTooShort = 'Password must be at least 8 characters';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String nameRequired = 'Full name is required';
  static const String phoneRequired = 'Phone number is required';

  // Messages
  static const String loginSuccess = 'Welcome back!';
  static const String signupSuccess = 'Account created! Please check your email to verify.';
  static const String resetEmailSent = 'Reset link sent! Check your email.';
  static const String logoutSuccess = 'Signed out successfully';
  static const String networkError = 'No internet connection. Please try again.';
  static const String somethingWentWrong = 'Something went wrong. Please try again.';

  // Onboarding
  static const List<String> onboardingTitles = [
    'AI-Powered Gadgets',
    'Premium Natural Essences',
    'Global Fashion & Lifestyle',
  ];
  static const List<String> onboardingSubtitles = [
    'Discover cutting-edge smart devices,\nwearables & home automation tech.',
    'Authentic Oud, Sandalwood, Frankincense\n& rare essential oils from around the world.',
    'Trend-driven clothing, fitness tech,\nand premium lifestyle products.',
  ];

  // Splash
  static const String poweredBy = 'Powered by Tokilo Technologies';
}