// lib/features/profile/screens/profile_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:to_best/features/auth/providers/auth_provider.dart';
import 'package:to_best/features/profile/providers/profile_provider.dart';
import 'package:to_best/core/constants/app_colors.dart';
import 'package:to_best/widgets/app_button.dart';
import 'package:to_best/widgets/app_text_field.dart';
import 'package:to_best/app.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});
  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _phoneCtrl  = TextEditingController();
  bool  _loading    = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    if (user != null) {
      _nameCtrl.text  = user.name;
      _phoneCtrl.text = user.phone ?? '';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _loading = true);
    final ok = await ref.read(profileProvider.notifier).updateProfile(
      user.uid,
      {
        'name':  _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
      },
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث الملف الشخصي ✓'),
          backgroundColor: AppColors.ok,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ، يرجى المحاولة مجدداً'),
          backgroundColor: AppColors.err,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider).languageCode;
    final isAr   = locale == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'تعديل الملف الشخصي' : 'Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller:         _nameCtrl,
                label:              isAr ? 'الاسم الكامل' : 'Full Name',
                prefixIcon:         const Icon(Icons.person_outline, size: 18),
                textCapitalization: TextCapitalization.words,
                validator: (v) => v == null || v.trim().isEmpty
                    ? (isAr ? 'الاسم مطلوب' : 'Name required') : null,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller:   _phoneCtrl,
                label:        isAr ? 'رقم الهاتف (اختياري)' : 'Phone (optional)',
                keyboardType: TextInputType.phone,
                prefixIcon:   const Icon(Icons.phone_outlined, size: 18),
              ),
              const SizedBox(height: 24),
              AppButton(
                label:     isAr ? 'حفظ التغييرات' : 'Save Changes',
                loading:   _loading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
