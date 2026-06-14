// lib/features/profile/screens/change_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:to_best/features/auth/providers/auth_provider.dart';
import 'package:to_best/features/profile/providers/profile_provider.dart';
import 'package:to_best/core/constants/app_colors.dart';
import 'package:to_best/core/utils/validators.dart';
import 'package:to_best/widgets/app_button.dart';
import 'package:to_best/widgets/app_text_field.dart';
import 'package:to_best/app.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends ConsumerState<ChangePasswordScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _oldCtrl   = TextEditingController();
  final _newCtrl   = TextEditingController();
  final _cNewCtrl  = TextEditingController();
  bool  _loading   = false;
  bool  _obsOld    = true;
  bool  _obsNew    = true;
  bool  _obsCNew   = true;
  String? _error;

  @override
  void dispose() {
    _oldCtrl.dispose();
    _newCtrl.dispose();
    _cNewCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() { _loading = true; _error = null; });
    try {
      final ok = await ref.read(profileProvider.notifier)
          .changePassword(user.uid, _oldCtrl.text, _newCtrl.text);
      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تغيير كلمة المرور بنجاح ✓'),
            backgroundColor: AppColors.ok,
          ),
        );
        context.pop();
      } else {
        setState(() {
          _error   = 'كلمة المرور الحالية غير صحيحة.';
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
        title: Text(isAr ? 'تغيير كلمة المرور' : 'Change Password'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                const SizedBox(height: 16),
              ],
              AppTextField(
                controller:  _oldCtrl,
                label:       isAr ? 'كلمة المرور الحالية' : 'Current Password',
                obscureText: _obsOld,
                prefixIcon:  const Icon(Icons.lock_outline, size: 18),
                suffixIcon: IconButton(
                  icon: Icon(_obsOld
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined, size: 18),
                  onPressed: () => setState(() => _obsOld = !_obsOld),
                ),
                validator: (v) => v == null || v.isEmpty
                    ? (isAr ? 'مطلوب' : 'Required') : null,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller:  _newCtrl,
                label:       isAr ? 'كلمة المرور الجديدة' : 'New Password',
                obscureText: _obsNew,
                prefixIcon:  const Icon(Icons.lock_outline, size: 18),
                suffixIcon: IconButton(
                  icon: Icon(_obsNew
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined, size: 18),
                  onPressed: () => setState(() => _obsNew = !_obsNew),
                ),
                validator: AppValidators.password,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller:  _cNewCtrl,
                label:       isAr ? 'تأكيد كلمة المرور الجديدة' : 'Confirm New Password',
                obscureText: _obsCNew,
                prefixIcon:  const Icon(Icons.lock_outline, size: 18),
                suffixIcon: IconButton(
                  icon: Icon(_obsCNew
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined, size: 18),
                  onPressed: () => setState(() => _obsCNew = !_obsCNew),
                ),
                validator: (v) =>
                    AppValidators.confirmPassword(v, _newCtrl.text),
              ),
              const SizedBox(height: 24),
              AppButton(
                label:     isAr ? 'تغيير كلمة المرور' : 'Change Password',
                loading:   _loading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
