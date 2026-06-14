// lib/features/auth/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:to_best/features/auth/providers/auth_provider.dart';
import 'package:to_best/core/utils/validators.dart';
import 'package:to_best/core/constants/app_colors.dart';
import 'package:to_best/widgets/app_button.dart';
import 'package:to_best/widgets/app_text_field.dart';
import 'package:to_best/app.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _emailCtrl  = TextEditingController();
  final _phoneCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  final _cpassCtrl  = TextEditingController();
  final _promoCtrl  = TextEditingController();
  final _referCtrl  = TextEditingController();

  bool _obscurePass  = true;
  bool _obscureCPass = true;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose();
    _passCtrl.dispose(); _cpassCtrl.dispose();
    _promoCtrl.dispose(); _referCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ok = await ref.read(authProvider.notifier).register({
      'name':          _nameCtrl.text.trim(),
      'email':         _emailCtrl.text.trim(),
      'phone':         _phoneCtrl.text.trim(),
      'password':      _passCtrl.text,
      'promoCode':     _promoCtrl.text.trim(),
      'referralCode':  _referCtrl.text.trim(),
    });
    if (ok && mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final authSt = ref.watch(authProvider);
    final locale = ref.watch(localeProvider).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(locale == 'ar' ? 'إنشاء حساب' : 'Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (authSt.error != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.err.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.err, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(authSt.error!,
                            style: const TextStyle(color: AppColors.err, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              AppTextField(
                controller: _nameCtrl,
                label: locale == 'ar' ? 'الاسم الكامل' : 'Full Name',
                prefixIcon: const Icon(Icons.person_outline, size: 18),
                validator: AppValidators.name,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _emailCtrl,
                label: locale == 'ar' ? 'البريد الإلكتروني' : 'Email',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined, size: 18),
                validator: AppValidators.email,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _phoneCtrl,
                label: locale == 'ar' ? 'رقم الهاتف (اختياري)' : 'Phone (optional)',
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined, size: 18),
                validator: AppValidators.phone,
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
                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                ),
                validator: AppValidators.password,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _cpassCtrl,
                label: locale == 'ar' ? 'تأكيد كلمة المرور' : 'Confirm Password',
                obscureText: _obscureCPass,
                prefixIcon: const Icon(Icons.lock_outline, size: 18),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCPass
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 18,
                  ),
                  onPressed: () =>
                      setState(() => _obscureCPass = !_obscureCPass),
                ),
                validator: (v) =>
                    AppValidators.confirmPassword(v, _passCtrl.text),
              ),
              const Divider(height: 28),
              AppTextField(
                controller: _promoCtrl,
                label: locale == 'ar' ? 'كود الخصم (اختياري)' : 'Promo Code (optional)',
                prefixIcon: const Icon(Icons.discount_outlined, size: 18),
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _referCtrl,
                label: locale == 'ar' ? 'كود الإحالة (اختياري)' : 'Referral Code (optional)',
                prefixIcon: const Icon(Icons.card_giftcard_outlined, size: 18),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: locale == 'ar' ? 'إنشاء الحساب' : 'Create Account',
                loading: authSt.isLoading,
                onPressed: _register,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    locale == 'ar' ? 'لديك حساب بالفعل؟ ' : 'Already have an account? ',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text(locale == 'ar' ? 'تسجيل الدخول' : 'Login'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
