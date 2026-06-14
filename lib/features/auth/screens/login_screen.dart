// lib/features/auth/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:to_best/features/auth/providers/auth_provider.dart';
import 'package:to_best/core/constants/app_colors.dart';
import 'package:to_best/core/utils/validators.dart';
import 'package:to_best/services/secure_storage_service.dart';
import 'package:to_best/widgets/app_button.dart';
import 'package:to_best/widgets/app_text_field.dart';
import 'package:to_best/app.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _urlCtrl   = TextEditingController();
  final _keyCtrl   = TextEditingController();

  bool _obscurePass    = true;
  bool _showSetup      = false;
  bool _setupLoading   = false;

  @override
  void initState() {
    super.initState();
    _loadSavedConfig();
  }

  Future<void> _loadSavedConfig() async {
    final url = await SecureStorageService.instance.getWebAppUrl();
    final key = await SecureStorageService.instance.getSecretKey();
    if (mounted) {
      _urlCtrl.text = url ?? '';
      _keyCtrl.text = key ?? '';
      if (url == null || url.isEmpty) {
        setState(() => _showSetup = true);
      }
    }
  }

  Future<void> _saveConfig() async {
    final url = _urlCtrl.text.trim();
    final key = _keyCtrl.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال رابط السيرفر')),
      );
      return;
    }
    setState(() => _setupLoading = true);
    await SecureStorageService.instance.saveWebAppUrl(url);
    if (key.isNotEmpty) {
      await SecureStorageService.instance.saveSecretKey(key);
    }
    if (mounted) {
      setState(() { _showSetup = false; _setupLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ الإعدادات ✓')),
      );
    }
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ok = await ref.read(authProvider.notifier).login(
      _emailCtrl.text.trim(),
      _passCtrl.text,
    );
    if (ok && mounted) context.go('/home');
  }

  Future<void> _guestLogin() async {
    final codeCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('دخول كضيف'),
        content: TextField(
          controller: codeCtrl,
          decoration: const InputDecoration(hintText: 'كود الضيف'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final ok = await ref.read(authProvider.notifier)
                  .guestLogin(codeCtrl.text.trim());
              if (ok && mounted) context.go('/home');
            },
            child: const Text('دخول'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _urlCtrl.dispose();
    _keyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authSt  = ref.watch(authProvider);
    final locale  = ref.watch(localeProvider).languageCode;
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final scheme  = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              // ── Logo ──────────────────────────────────────────
              Center(
                child: Image.asset(
                  isDark
                      ? 'assets/icons/logo_dark.png'
                      : 'assets/icons/logo_light.png',
                  width: 120, height: 120,
                  errorBuilder: (_, __, ___) => Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Icon(Icons.fitness_center,
                        size: 60, color: AppColors.accent),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'TO Best',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Center(
                child: Text(
                  locale == 'ar'
                      ? 'نظام التدريب والتغذية'
                      : 'Training & Nutrition System',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 36),

              // ── Server setup section ──────────────────────────
              if (_showSetup) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scheme.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: scheme.primary.withOpacity(0.25)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.settings_outlined,
                              size: 18, color: scheme.primary),
                          const SizedBox(width: 8),
                          Text(locale == 'ar'
                              ? 'إعداد السيرفر'
                              : 'Server Setup',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _urlCtrl,
                        label: 'رابط السيرفر (Web App URL)',
                        hint: 'https://script.google.com/...',
                        keyboardType: TextInputType.url,
                        prefixIcon: const Icon(Icons.link, size: 18),
                      ),
                      const SizedBox(height: 10),
                      AppTextField(
                        controller: _keyCtrl,
                        label: 'المفتاح السري (Secret Key)',
                        hint: 'اختياري',
                        obscureText: true,
                        prefixIcon: const Icon(Icons.key, size: 18),
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        label: locale == 'ar' ? 'حفظ الإعدادات' : 'Save Settings',
                        loading: _setupLoading,
                        onPressed: _saveConfig,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ── Login Form ────────────────────────────────────
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (authSt.error != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.err.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: AppColors.err, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(authSt.error!,
                                  style: const TextStyle(
                                      color: AppColors.err, fontSize: 13)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    AppTextField(
                      controller: _emailCtrl,
                      label: locale == 'ar' ? 'البريد الإلكتروني' : 'Email',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined, size: 18),
                      validator: AppValidators.email,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _passCtrl,
                      label: locale == 'ar' ? 'كلمة المرور' : 'Password',
                      obscureText: _obscurePass,
                      prefixIcon: const Icon(Icons.lock_outline, size: 18),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePass
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 18,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePass = !_obscurePass),
                      ),
                      validator: (v) => v == null || v.isEmpty
                          ? (locale == 'ar'
                              ? 'كلمة المرور مطلوبة'
                              : 'Password required')
                          : null,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(
                        onPressed: () => context.push('/forgot-password'),
                        child: Text(locale == 'ar'
                            ? 'نسيت كلمة المرور؟'
                            : 'Forgot password?'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppButton(
                      label: locale == 'ar' ? 'تسجيل الدخول' : 'Login',
                      loading: authSt.isLoading,
                      onPressed: _login,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Register link ─────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    locale == 'ar'
                        ? 'ليس لديك حساب؟ '
                        : "Don't have an account? ",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  TextButton(
                    onPressed: () => context.push('/register'),
                    child: Text(
                        locale == 'ar' ? 'إنشاء حساب' : 'Register'),
                  ),
                ],
              ),

              // ── Guest login ───────────────────────────────────
              OutlinedButton.icon(
                icon: const Icon(Icons.person_outline, size: 16),
                label: Text(
                    locale == 'ar' ? 'دخول كضيف' : 'Guest Login'),
                onPressed: _guestLogin,
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44)),
              ),
              const SizedBox(height: 16),

              // ── Server setup toggle ───────────────────────────
              Center(
                child: TextButton.icon(
                  icon: Icon(_showSetup
                      ? Icons.expand_less
                      : Icons.settings_outlined, size: 16),
                  label: Text(
                    locale == 'ar'
                        ? (_showSetup ? 'إخفاء الإعدادات' : 'إعدادات السيرفر')
                        : (_showSetup ? 'Hide Settings' : 'Server Settings'),
                    style: const TextStyle(fontSize: 12),
                  ),
                  onPressed: () =>
                      setState(() => _showSetup = !_showSetup),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
