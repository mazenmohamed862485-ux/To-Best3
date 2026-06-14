// lib/features/auth/screens/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:to_best/features/profile/providers/profile_provider.dart';
import 'package:to_best/core/constants/app_colors.dart';
import 'package:to_best/core/utils/validators.dart';
import 'package:to_best/widgets/app_button.dart';
import 'package:to_best/widgets/app_text_field.dart';
import 'package:to_best/app.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends ConsumerState<ForgotPasswordScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _emailCtrl  = TextEditingController();
  final _codeCtrl   = TextEditingController();
  final _passCtrl   = TextEditingController();
  final _cpassCtrl  = TextEditingController();

  bool _codeSent  = false;
  bool _loading   = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _passCtrl.dispose();
    _cpassCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _loading = true; _error = null; });
    try {
      final ok = await ref.read(profileProvider.notifier)
          .forgotPassword(_emailCtrl.text.trim());
      if (ok) {
        setState(() { _codeSent = true; _loading = false; });
      } else {
        setState(() {
          _error   = 'لم يتم إرسال الرمز. تحقق من البريد.';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _resetPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _loading = true; _error = null; });
    try {
      final ok = await ref.read(profileProvider.notifier).resetPassword(
        _emailCtrl.text.trim(),
        _codeCtrl.text.trim(),
        _passCtrl.text,
      );
      if (ok && mounted) {
        context.go('/login');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تغيير كلمة المرور بنجاح ✓'),
            backgroundColor: AppColors.ok,
          ),
        );
      } else {
        setState(() {
          _error   = 'رمز التحقق غير صحيح أو منتهي.';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider).languageCode;
    final isAr   = locale == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'نسيت كلمة المرور' : 'Forgot Password'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.lock_reset_outlined,
                  size: 72, color: AppColors.accent),
              const SizedBox(height: 16),
              Text(
                isAr
                    ? 'أدخل بريدك الإلكتروني وسنرسل لك رمز التحقق'
                    : 'Enter your email and we\'ll send you a verification code',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:        AppColors.err.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(_error!,
                      style: const TextStyle(color: AppColors.err)),
                ),
                const SizedBox(height: 12),
              ],

              AppTextField(
                controller:   _emailCtrl,
                label:        isAr ? 'البريد الإلكتروني' : 'Email',
                keyboardType: TextInputType.emailAddress,
                prefixIcon:   const Icon(Icons.email_outlined, size: 18),
                validator:    AppValidators.email,
                readOnly:     _codeSent,
              ),

              if (_codeSent) ...[
                const SizedBox(height: 14),
                AppTextField(
                  controller: _codeCtrl,
                  label:      isAr ? 'رمز التحقق' : 'Verification Code',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.pin, size: 18),
                  validator: (v) => v == null || v.isEmpty
                      ? (isAr ? 'الرمز مطلوب' : 'Code required')
                      : null,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _passCtrl,
                  label:      isAr ? 'كلمة المرور الجديدة' : 'New Password',
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outline, size: 18),
                  validator: AppValidators.password,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _cpassCtrl,
                  label:      isAr ? 'تأكيد كلمة المرور' : 'Confirm Password',
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outline, size: 18),
                  validator: (v) =>
                      AppValidators.confirmPassword(v, _passCtrl.text),
                ),
              ],

              const SizedBox(height: 24),
              AppButton(
                label:   _codeSent
                    ? (isAr ? 'تغيير كلمة المرور' : 'Reset Password')
                    : (isAr ? 'إرسال رمز التحقق' : 'Send Code'),
                loading: _loading,
                onPressed: _codeSent ? _resetPassword : _sendCode,
              ),

              if (_codeSent) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => setState(() { _codeSent = false; }),
                  child: Text(isAr ? 'إعادة الإرسال' : 'Resend Code'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
