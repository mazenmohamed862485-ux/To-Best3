// lib/features/auth/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:to_best/features/auth/providers/auth_provider.dart';
import 'package:to_best/services/update_service.dart';
import 'package:to_best/core/constants/app_colors.dart';
import 'package:to_best/app.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<double>   _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack),
    );
    _animCtrl.forward();
    _init();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    // Wait for animation
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // Check for updates
    final updateInfo = await UpdateService.instance.checkForUpdate();

    if (!mounted) return;

    if (updateInfo.status == UpdateStatus.required ||
        updateInfo.status == UpdateStatus.blocked) {
      _showUpdateScreen(updateInfo, required: true);
      return;
    }

    if (updateInfo.status == UpdateStatus.optional) {
      _showUpdateDialog(updateInfo);
      return;
    }

    _navigate();
  }

  void _navigate() {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  void _showUpdateDialog(UpdateInfo info) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('تحديث متوفر'),
        content: Text(
          info.message ?? 'يتوفر إصدار جديد ${info.latestVersion ?? ""} من التطبيق.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigate();
            },
            child: const Text('لاحقاً'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _launchUpdate(info.downloadUrl);
              _navigate();
            },
            child: const Text('تحديث الآن'),
          ),
        ],
      ),
    );
  }

  void _showUpdateScreen(UpdateInfo info, {required bool required}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: const Text('يجب تحديث التطبيق'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.system_update, size: 64, color: AppColors.accent),
              const SizedBox(height: 16),
              Text(
                info.message ??
                    'هذه النسخة غير مدعومة. يرجى التحديث للاستمرار.',
                textAlign: TextAlign.center,
              ),
              if (info.latestVersion != null) ...[
                const SizedBox(height: 8),
                Text('الإصدار الجديد: ${info.latestVersion}',
                    style: const TextStyle(color: AppColors.accent)),
              ],
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text('تحميل التحديث'),
                onPressed: () => _launchUpdate(info.downloadUrl),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUpdate(String? url) async {
    if (url == null || url.isEmpty) return;
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = ref.watch(localeProvider).languageCode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Image.asset(
                  isDark
                      ? 'assets/icons/logo_dark.png'
                      : 'assets/icons/logo_light.png',
                  width:  160,
                  height: 160,
                  errorBuilder: (_, __, ___) => Container(
                    width:  160,
                    height: 160,
                    decoration: BoxDecoration(
                      color:        AppColors.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      size:  72,
                      color: AppColors.accent,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // App name
                Text(
                  'TO Best',
                  style: TextStyle(
                    fontSize:   32,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.darkText1 : AppColors.lightText1,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  locale == 'ar' ? 'نظام التدريب والتغذية' : 'Training & Nutrition System',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.darkText2 : AppColors.lightText2,
                  ),
                ),
                const SizedBox(height: 48),
                const SizedBox(
                  width:  32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
