// lib/core/constants/app_constants.dart
class AppConstants {
  AppConstants._();

  static const String appName    = 'TO Best';
  static const String appVersion = '8.2.0';
  static const int    appBuild   = 1;
  static const String dbName     = 'to_best_cache.db';
  static const int    dbVersion  = 1;

  // Sync
  static const int syncIntervalSeconds   = 30;
  static const int apiTimeoutSeconds     = 14;
  static const int maxRetryAttempts      = 3;

  // Cache keys
  static const String keyCurrentUser    = 'current_user';
  static const String keyWebAppUrl      = 'web_app_url';
  static const String keySessionToken   = 'session_token';
  static const String keyTheme          = 'theme';
  static const String keyLocale         = 'locale';
  static const String keyAccentColor    = 'accent_color';
  static const String keyRestDuration   = 'rest_timer_duration';
  static const String keyRestSound      = 'rest_timer_sound';
  static const String keySelectedProg   = 'selected_program';
  static const String keyProgramDays    = 'program_days';
  static const String keyGymDays        = 'gym_days';
  static const String keyShowOldValues  = 'show_old_values';
  static const String keyShowEpley      = 'show_epley';
  static const String keyShowRPE        = 'show_rpe';
  static const String keyShowRepSuggest = 'show_rep_suggest';
  static const String keyWakeLock       = 'wake_lock';
  static const String keyHandMode       = 'hand_mode';
  static const String keyNotifications  = 'notifications_enabled';

  // Update system keys
  static const String keyLastUpdateCheck = 'last_update_check';
  static const String keySkippedVersion  = 'skipped_version';

  // Attendance marks
  static const String attGym   = 'gym';
  static const String attAbs   = 'absent';
  static const String attRest  = 'rest';

  // Roles
  static const String roleSuperAdmin = 'SUPER_ADMIN';
  static const String roleAdmin      = 'ADMIN';
  static const String roleCoach      = 'COACH';
  static const String roleTrainee    = 'TRAINEE';
  static const String roleViewer     = 'VIEWER';

  // Subscription plans
  static const String planLight = 'light';
  static const String planFull  = 'full';

  // Programs
  static const Map<String, String> programs = {
    'UL':     'Upper / Lower',
    'AP':     'Anterior / Posterior',
    'FB':     'Full Body',
    'ARNOLD': 'Arnold',
    'PPL':    'Push / Pull / Legs',
    'CUSTOM': 'Custom Program',
  };

  // Chat rooms
  static const String roomGeneral       = 'general';
  static const String roomAnnouncements = 'announcements';
  static const String roomSupport       = 'support';

  // Rest timer sounds
  static const List<String> restSounds = [
    'bell', 'beep', 'chime', 'whistle', 'silent'
  ];

  // Accent colors (hex strings)
  static const List<String> accentColors = [
    '#4CAF50', '#7c6eff', '#FF5722', '#2196F3',
    '#FF9800', '#E91E63', '#00BCD4', '#8BC34A',
  ];

  // Update check interval (hours)
  static const int updateCheckIntervalHours = 6;
}
