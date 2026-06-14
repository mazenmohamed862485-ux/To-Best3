// lib/features/profile/screens/subscription_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:to_best/features/auth/providers/auth_provider.dart';
import 'package:to_best/features/profile/providers/profile_provider.dart';
import 'package:to_best/core/constants/app_colors.dart';
import 'package:to_best/widgets/app_button.dart';
import 'package:to_best/widgets/app_text_field.dart';
import 'package:to_best/app.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});
  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  String _selectedPlan = 'full';
  String _paymentType  = 'transfer';
  final _referenceCtrl = TextEditingController();
  final _promoCtrl     = TextEditingController();
  bool  _loading       = false;

  @override
  void dispose() {
    _referenceCtrl.dispose();
    _promoCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    if (_referenceCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال رقم المرجع')),
      );
      return;
    }
    setState(() => _loading = true);
    final ok = await ref.read(profileProvider.notifier)
        .submitSubscriptionRequest(user.uid, {
      'plan':      _selectedPlan,
      'payment':   _paymentType,
      'reference': _referenceCtrl.text.trim(),
      'promo':     _promoCtrl.text.trim(),
      'userName':  user.name,
      'email':     user.email,
      'ts':        DateTime.now().millisecondsSinceEpoch,
    });
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال طلب الاشتراك ✓ سيتم المراجعة قريباً'),
          backgroundColor: AppColors.ok,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('فشل الإرسال، يرجى المحاولة لاحقاً'),
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
        title: Text(isAr ? 'تجديد الاشتراك' : 'Subscribe'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Plan selection
            Text(
              isAr ? 'اختر الخطة' : 'Choose Plan',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _PlanCard(
                  label:    isAr ? 'لايت' : 'Light',
                  price:    isAr ? 'أسعار مخفضة' : 'Discounted',
                  icon:     Icons.flash_on,
                  selected: _selectedPlan == 'light',
                  onTap: () => setState(() => _selectedPlan = 'light'),
                )),
                const SizedBox(width: 10),
                Expanded(child: _PlanCard(
                  label:    isAr ? 'كامل' : 'Full',
                  price:    isAr ? 'جميع الميزات' : 'All Features',
                  icon:     Icons.star,
                  selected: _selectedPlan == 'full',
                  onTap: () => setState(() => _selectedPlan = 'full'),
                )),
              ],
            ),
            const SizedBox(height: 20),

            // Payment method
            Text(
              isAr ? 'طريقة الدفع' : 'Payment Method',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            RadioListTile<String>(
              value:      'transfer',
              groupValue: _paymentType,
              title:      Text(isAr ? 'تحويل بنكي / محفظة' : 'Bank Transfer / Wallet'),
              activeColor: AppColors.accent,
              onChanged: (v) => setState(() => _paymentType = v!),
            ),
            RadioListTile<String>(
              value:      'cash',
              groupValue: _paymentType,
              title:      Text(isAr ? 'كاش' : 'Cash'),
              activeColor: AppColors.accent,
              onChanged: (v) => setState(() => _paymentType = v!),
            ),
            const SizedBox(height: 16),

            // Reference
            AppTextField(
              controller: _referenceCtrl,
              label:      isAr ? 'رقم المرجع / إيصال الدفع' : 'Payment Reference / Receipt',
              prefixIcon: const Icon(Icons.receipt_outlined, size: 18),
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _promoCtrl,
              label:      isAr ? 'كود الخصم (اختياري)' : 'Promo Code (optional)',
              prefixIcon: const Icon(Icons.discount_outlined, size: 18),
            ),
            const SizedBox(height: 24),
            AppButton(
              label:     isAr ? 'إرسال طلب الاشتراك' : 'Submit Request',
              loading:   _loading,
              onPressed: _submit,
            ),
            const SizedBox(height: 12),
            Text(
              isAr
                  ? '* سيقوم الكوتش بمراجعة طلبك وتفعيل الاشتراك خلال 24 ساعة.'
                  : '* Your coach will review and activate within 24 hours.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String     label;
  final String     price;
  final IconData   icon;
  final bool       selected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.label,
    required this.price,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accent.withOpacity(0.12)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.accent : Theme.of(context).dividerColor,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color:  selected ? AppColors.accent : null,
                size:   28),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color:      selected ? AppColors.accent : null,
                )),
            Text(price,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
