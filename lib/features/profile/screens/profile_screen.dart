// lib/features/profile/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:to_best/features/auth/providers/auth_provider.dart';
import 'package:to_best/features/profile/providers/profile_provider.dart';
import 'package:to_best/core/constants/app_colors.dart';
import 'package:to_best/core/utils/extensions.dart';
import 'package:to_best/widgets/common_widgets.dart';
import 'package:to_best/app.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider).languageCode;
    final isAr   = locale == 'ar';
    final user   = ref.watch(currentUserProvider);

    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'الملف الشخصي' : 'Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/profile/edit'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar + name
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final ok = await ref.read(profileProvider.notifier)
                          .uploadProfilePicture(user.uid);
                      if (ok && context.mounted) {
                        context.showSnack(isAr ? 'تم تحديث الصورة ✓' : 'Photo updated ✓');
                      }
                    },
                    child: Stack(
                      children: [
                        UserAvatar(
                            imageUrl: user.profilePicUrl,
                            name: user.name,
                            radius: 44),
                        Positioned(
                          bottom: 0, right: 0,
                          child: Container(
                            width: 26, height: 26,
                            decoration: const BoxDecoration(
                              color: AppColors.accent, shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt,
                                size: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(user.name, style: context.text.titleLarge),
                  Text(user.email, style: context.text.bodySmall),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user.displayRole,
                      style: const TextStyle(
                        color:      AppColors.accent,
                        fontWeight: FontWeight.w700,
                        fontSize:   12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Subscription status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? 'الاشتراك' : 'Subscription',
                      style: context.text.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    InfoRow(
                      label: isAr ? 'الحالة' : 'Status',
                      value: user.subscriptionActive
                          ? (isAr ? '✅ نشط' : '✅ Active')
                          : (isAr ? '⛔ غير نشط' : '⛔ Inactive'),
                      valueColor: user.subscriptionActive
                          ? AppColors.ok : AppColors.err,
                    ),
                    if (user.subscriptionType != null)
                      InfoRow(
                        label: isAr ? 'النوع' : 'Type',
                        value: user.subscriptionType!,
                      ),
                    if (!user.subscriptionActive && !user.isAdminLike)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.payment, size: 16),
                          label: Text(isAr ? 'تجديد الاشتراك' : 'Renew'),
                          onPressed: () => context.push('/profile/subscribe'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 42),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Program
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? 'البرنامج' : 'Program',
                      style: context.text.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    InfoRow(
                      label: isAr ? 'البرنامج الحالي' : 'Current Program',
                      value: user.program ?? (isAr ? 'لا يوجد' : 'None'),
                      valueColor: user.program != null
                          ? AppColors.accent : null,
                    ),
                    if (user.programDays != null)
                      InfoRow(
                        label: isAr ? 'أيام التدريب' : 'Training Days',
                        value: '${user.programDays} ${isAr ? "يوم/أسبوع" : "days/week"}',
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Referral
            if (user.referralCode != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr ? 'الإحالة' : 'Referral',
                        style: context.text.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      InfoRow(
                        label: isAr ? 'كودك' : 'Your Code',
                        value: user.referralCode!,
                        valueColor: AppColors.accent,
                      ),
                      if (user.referralCoins != null)
                        InfoRow(
                          label: isAr ? 'النقاط' : 'Points',
                          value: '${user.referralCoins}',
                        ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 10),

            // Actions
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: Text(isAr ? 'تغيير كلمة المرور' : 'Change Password'),
                    trailing: const Icon(Icons.chevron_right, size: 16),
                    onTap: () => context.push('/profile/change-password'),
                  ),
                  const Divider(height: 0),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: Text(isAr ? 'الإعدادات' : 'Settings'),
                    trailing: const Icon(Icons.chevron_right, size: 16),
                    onTap: () => context.push('/settings'),
                  ),
                  const Divider(height: 0),
                  ListTile(
                    leading: const Icon(Icons.logout, color: AppColors.err),
                    title: Text(
                      isAr ? 'تسجيل الخروج' : 'Logout',
                      style: const TextStyle(color: AppColors.err),
                    ),
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(isAr ? 'تسجيل الخروج' : 'Logout'),
                          content: Text(isAr
                              ? 'هل تريد تسجيل الخروج؟'
                              : 'Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(isAr ? 'لا' : 'No'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.err),
                              child: Text(isAr ? 'خروج' : 'Logout'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) context.go('/login');
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
