// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_best/core/constants/app_colors.dart';
import 'package:to_best/core/constants/app_constants.dart';
import 'package:to_best/core/theme/app_theme.dart';
import 'package:to_best/features/auth/providers/auth_provider.dart';
import 'package:to_best/features/auth/screens/splash_screen.dart';
import 'package:to_best/features/auth/screens/login_screen.dart';
import 'package:to_best/features/auth/screens/register_screen.dart';
import 'package:to_best/features/auth/screens/forgot_password_screen.dart';
import 'package:to_best/features/home/screens/home_screen.dart';
import 'package:to_best/features/workout/screens/workout_screen.dart';
import 'package:to_best/features/nutrition/screens/nutrition_screen.dart';
import 'package:to_best/features/attendance/screens/attendance_screen.dart';
import 'package:to_best/features/progress/screens/progress_screen.dart';
import 'package:to_best/features/chat/screens/chat_screen.dart';
import 'package:to_best/features/profile/screens/profile_screen.dart';
import 'package:to_best/features/profile/screens/settings_screen.dart';
import 'package:to_best/features/admin/screens/admin_screen.dart';
import 'package:to_best/features/profile/screens/change_password_screen.dart';
import 'package:to_best/features/profile/screens/profile_edit_screen.dart';
import 'package:to_best/features/profile/screens/subscription_screen.dart';
import 'package:to_best/widgets/main_shell.dart';

// ────────────────────────────────────────────────────────────
// Locale Provider
// ────────────────────────────────────────────────────────────
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('ar')) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final lang  = prefs.getString(AppConstants.keyLocale) ?? 'ar';
    state = Locale(lang);
  }

  Future<void> set(String lang) async {
    state = Locale(lang);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyLocale, lang);
  }
}

final localeProvider =
    StateNotifierProvider<LocaleNotifier, Locale>(
        (_) => LocaleNotifier());

// ────────────────────────────────────────────────────────────
// Theme Mode Provider
// ────────────────────────────────────────────────────────────
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final t     = prefs.getString(AppConstants.keyTheme) ?? 'dark';
    state = _fromString(t);
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyTheme, _toString(mode));
  }

  ThemeMode _fromString(String s) {
    switch (s) {
      case 'light':  return ThemeMode.light;
      case 'system': return ThemeMode.system;
      default:       return ThemeMode.dark;
    }
  }

  String _toString(ThemeMode m) {
    switch (m) {
      case ThemeMode.light:  return 'light';
      case ThemeMode.system: return 'system';
      default:               return 'dark';
    }
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
        (_) => ThemeModeNotifier());

// ────────────────────────────────────────────────────────────
// Accent Color Provider
// ────────────────────────────────────────────────────────────
class AccentColorNotifier extends StateNotifier<Color> {
  AccentColorNotifier() : super(AppColors.accent) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final hex   = prefs.getString(AppConstants.keyAccentColor);
    if (hex != null) {
      try {
        state = Color(int.parse(hex, radix: 16) + 0xFF000000);
      } catch (_) {}
    }
  }

  Future<void> set(Color color) async {
    state = color;
    final prefs = await SharedPreferences.getInstance();
    final hex   = color.value.toRadixString(16).padLeft(8, '0').substring(2);
    await prefs.setString(AppConstants.keyAccentColor, hex);
  }
}

final accentColorProvider =
    StateNotifierProvider<AccentColorNotifier, Color>(
        (_) => AccentColorNotifier());

// ────────────────────────────────────────────────────────────
// Router
// ────────────────────────────────────────────────────────────
final _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path:     '/splash',
      builder:  (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path:     '/login',
      builder:  (_, __) => const LoginScreen(),
    ),
    GoRoute(
      path:     '/register',
      builder:  (_, __) => const RegisterScreen(),
    ),
    GoRoute(
      path:     '/forgot-password',
      builder:  (_, __) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path:    '/admin',
      builder: (_, __) => const AdminScreen(),
    ),
    GoRoute(
      path:    '/settings',
      builder: (_, __) => const SettingsScreen(),
    ),
    GoRoute(
      path:    '/profile/edit',
      builder: (_, __) => const ProfileEditScreen(),
    ),
    GoRoute(
      path:    '/profile/change-password',
      builder: (_, __) => const ChangePasswordScreen(),
    ),
    GoRoute(
      path:    '/profile/subscribe',
      builder: (_, __) => const SubscriptionScreen(),
    ),
    // Shell routes (bottom nav)
    ShellRoute(
      builder: (_, __, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path:    '/home',
          builder: (_, __) => const HomeScreen(),
        ),
        GoRoute(
          path:    '/workout',
          builder: (_, __) => const WorkoutScreen(),
        ),
        GoRoute(
          path:    '/nutrition',
          builder: (_, __) => const NutritionScreen(),
        ),
        GoRoute(
          path:    '/attendance',
          builder: (_, __) => const AttendanceScreen(),
        ),
        GoRoute(
          path:    '/progress',
          builder: (_, __) => const ProgressScreen(),
        ),
        GoRoute(
          path:    '/chat',
          builder: (_, __) => const ChatScreen(),
        ),
        GoRoute(
          path:    '/profile',
          builder: (_, __) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);

// ────────────────────────────────────────────────────────────
// Root App Widget
// ────────────────────────────────────────────────────────────
class ToBestApp extends ConsumerWidget {
  const ToBestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale    = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final accent    = ref.watch(accentColorProvider);

    return MaterialApp.router(
      title:          AppConstants.appName,
      debugShowCheckedModeBanner: false,
      routerConfig:   _router,
      // Locale
      locale:         locale,
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Theme
      themeMode:  themeMode,
      theme:      AppTheme.light(accent: accent),
      darkTheme:  AppTheme.dark(accent: accent),
      // RTL/LTR
      builder: (context, child) {
        return Directionality(
          textDirection: locale.languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
