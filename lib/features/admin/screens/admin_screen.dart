// lib/features/admin/screens/admin_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_best/features/admin/providers/admin_provider.dart';
import 'package:to_best/features/auth/models/user_model.dart';
import 'package:to_best/features/auth/providers/auth_provider.dart';
import 'package:to_best/core/constants/app_colors.dart';
import 'package:to_best/core/constants/app_constants.dart';
import 'package:to_best/core/utils/extensions.dart';
import 'package:to_best/widgets/common_widgets.dart';
import 'package:to_best/app.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});
  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 5, vsync: this);
    _loadAll();
  }

  Future<void> _loadAll() async {
    final admin = ref.read(adminProvider.notifier);
    await Future.wait([
      admin.loadUsers(),
      admin.loadSubRequests(),
      admin.loadPromos(),
      admin.loadGuestCodes(),
      admin.loadBanned(),
    ]);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale  = ref.watch(localeProvider).languageCode;
    final isAr    = locale == 'ar';
    final me      = ref.watch(currentUserProvider);
    final adminSt = ref.watch(adminProvider);

    // Access control
    if (me == null || !me.isAdminLike) {
      return Scaffold(
        appBar: AppBar(title: Text(isAr ? 'ممنوع' : 'Access Denied')),
        body: Center(
          child: Text(isAr ? 'ليس لديك صلاحية' : 'Access denied'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'لوحة الإدارة' : 'Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAll,
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          tabs: [
            Tab(text: isAr ? 'المستخدمون' : 'Users'),
            Tab(text: isAr ? 'الطلبات' : 'Requests'),
            Tab(text: isAr ? 'الأكواد' : 'Codes'),
            Tab(text: isAr ? 'الضيوف' : 'Guests'),
            Tab(text: isAr ? 'المحظورون' : 'Banned'),
          ],
        ),
      ),
      body: adminSt.loading
          ? const Center(child: CircularProgressIndicator(
              color: AppColors.accent))
          : TabBarView(
              controller: _tabCtrl,
              children: [
                _UsersTab(
                  users:  adminSt.users,
                  locale: locale,
                  me:     me,
                ),
                _SubRequestsTab(
                  requests: adminSt.subRequests,
                  locale:   locale,
                ),
                _PromoTab(
                  codes:  adminSt.promoCodes,
                  locale: locale,
                  isSuperAdmin: me.isSuperAdmin,
                ),
                _GuestTab(
                  codes:  adminSt.guestCodes,
                  locale: locale,
                  isSuperAdmin: me.isSuperAdmin,
                ),
                _BannedTab(
                  banned: adminSt.bannedList,
                  locale: locale,
                ),
              ],
            ),
    );
  }
}

// ── Users Tab ─────────────────────────────────────────────────
class _UsersTab extends ConsumerStatefulWidget {
  final List<UserModel> users;
  final String          locale;
  final UserModel       me;
  const _UsersTab({required this.users, required this.locale, required this.me});

  @override
  ConsumerState<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends ConsumerState<_UsersTab> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final isAr     = widget.locale == 'ar';
    final filtered = widget.users.where((u) {
      if (_q.isEmpty) return true;
      return u.name.toLowerCase().contains(_q.toLowerCase()) ||
          u.email.toLowerCase().contains(_q.toLowerCase());
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            onChanged: (v) => setState(() => _q = v),
            decoration: InputDecoration(
              hintText:   isAr ? 'بحث...' : 'Search...',
              prefixIcon: const Icon(Icons.search, size: 18),
              isDense:    true,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Text(
                '${filtered.length} ${isAr ? "مستخدم" : "users"}',
                style: context.text.bodySmall,
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? EmptyState(
                  icon:  Icons.people_outline,
                  title: isAr ? 'لا يوجد مستخدمون' : 'No users found',
                )
              : ListView.builder(
                  padding:     const EdgeInsets.all(8),
                  itemCount:   filtered.length,
                  itemBuilder: (_, i) => _UserCard(
                    user:   filtered[i],
                    locale: widget.locale,
                    me:     widget.me,
                  ),
                ),
        ),
      ],
    );
  }
}

class _UserCard extends ConsumerWidget {
  final UserModel user;
  final String    locale;
  final UserModel me;
  const _UserCard({required this.user, required this.locale, required this.me});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = locale == 'ar';
    Color statusColor;
    switch (user.status) {
      case 'active':    statusColor = AppColors.ok;   break;
      case 'pending':   statusColor = AppColors.warn; break;
      case 'suspended': statusColor = AppColors.err;  break;
      default:          statusColor = AppColors.darkText2;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: UserAvatar(
          imageUrl: user.profilePicUrl,
          name:     user.name,
          radius:   20,
        ),
        title: Text(user.name, style: context.text.titleSmall),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color:        statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                user.status,
                style: TextStyle(
                    fontSize: 10, color: statusColor, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 6),
            Text(user.displayRole, style: context.text.labelSmall),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoRow(label: 'Email', value: user.email),
                if (user.phone != null)
                  InfoRow(label: isAr ? 'هاتف' : 'Phone', value: user.phone!),
                if (user.program != null)
                  InfoRow(label: isAr ? 'البرنامج' : 'Program', value: user.program!),
                InfoRow(
                  label: isAr ? 'الاشتراك' : 'Subscription',
                  value: user.subscriptionStatus,
                  valueColor: user.subscriptionActive ? AppColors.ok : AppColors.err,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (user.status == 'pending')
                      _AdminBtn(
                        label: isAr ? 'قبول' : 'Approve',
                        color: AppColors.ok,
                        onTap: () => ref.read(adminProvider.notifier)
                            .approveUser(user.uid, true),
                      ),
                    if (user.status == 'active')
                      _AdminBtn(
                        label: isAr ? 'تعليق' : 'Suspend',
                        color: AppColors.warn,
                        onTap: () => ref.read(adminProvider.notifier)
                            .updateUser(user.uid, {'status': 'suspended'}),
                      ),
                    if (user.status == 'suspended')
                      _AdminBtn(
                        label: isAr ? 'تفعيل' : 'Activate',
                        color: AppColors.ok,
                        onTap: () => ref.read(adminProvider.notifier)
                            .updateUser(user.uid, {'status': 'active'}),
                      ),
                    if (me.isSuperAdmin)
                      _AdminBtn(
                        label: isAr ? 'حذف' : 'Delete',
                        color: AppColors.err,
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(isAr ? 'حذف المستخدم' : 'Delete User'),
                              content: Text(isAr
                                  ? 'هل تريد حذف ${user.name} نهائياً؟'
                                  : 'Permanently delete ${user.name}?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text(isAr ? 'إلغاء' : 'Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.err),
                                  child: Text(isAr ? 'حذف' : 'Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            ref.read(adminProvider.notifier)
                                .deleteUser(user.uid);
                          }
                        },
                      ),
                    _AdminBtn(
                      label: isAr ? 'تسجيل خروج' : 'Force Logout',
                      color: AppColors.info,
                      onTap: () => ref.read(adminProvider.notifier)
                          .forceLogoutUser(
                              user.uid,
                              DateTime.now().millisecondsSinceEpoch.toString()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminBtn extends StatelessWidget {
  final String       label;
  final Color        color;
  final VoidCallback onTap;

  const _AdminBtn({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:        color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
          border:       Border.all(color: color.withOpacity(0.4)),
        ),
        child: Text(
          label,
          style: TextStyle(
              fontSize: 12, color: color, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ── Subscription Requests Tab ─────────────────────────────────
class _SubRequestsTab extends ConsumerWidget {
  final List<Map<String, dynamic>> requests;
  final String                     locale;
  const _SubRequestsTab({required this.requests, required this.locale});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = locale == 'ar';
    if (requests.isEmpty) {
      return EmptyState(
          icon:  Icons.inbox,
          title: isAr ? 'لا توجد طلبات' : 'No requests');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: requests.length,
      itemBuilder: (_, i) {
        final req = requests[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoRow(label: isAr ? 'المستخدم' : 'User',
                    value: req['userName']?.toString() ?? ''),
                InfoRow(label: isAr ? 'النوع' : 'Type',
                    value: req['type']?.toString() ?? ''),
                InfoRow(label: isAr ? 'الحالة' : 'Status',
                    value: req['status']?.toString() ?? ''),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            ref.read(adminProvider.notifier)
                                .updateSubRequest(
                                    req['id']?.toString() ?? '',
                                    'rejected', {}),
                        style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.err,
                            side: const BorderSide(color: AppColors.err)),
                        child: Text(isAr ? 'رفض' : 'Reject'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            ref.read(adminProvider.notifier)
                                .updateSubRequest(
                                    req['id']?.toString() ?? '',
                                    'approved', {}),
                        child: Text(isAr ? 'قبول' : 'Approve'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Promo Tab ─────────────────────────────────────────────────
class _PromoTab extends ConsumerWidget {
  final List<Map<String, dynamic>> codes;
  final String                     locale;
  final bool                       isSuperAdmin;
  const _PromoTab({
    required this.codes,
    required this.locale,
    required this.isSuperAdmin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = locale == 'ar';
    return Column(
      children: [
        if (isSuperAdmin)
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton.icon(
              icon:      const Icon(Icons.add, size: 16),
              label:     Text(isAr ? 'إنشاء كود' : 'Create Code'),
              onPressed: () => _showCreatePromo(context, ref, isAr),
              style:     ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44)),
            ),
          ),
        Expanded(
          child: codes.isEmpty
              ? EmptyState(
                  icon:  Icons.discount_outlined,
                  title: isAr ? 'لا توجد أكواد' : 'No promo codes')
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: codes.length,
                  itemBuilder: (_, i) {
                    final c = codes[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(c['code']?.toString() ?? '',
                            style: context.text.titleSmall),
                        subtitle: Text(
                          '${isAr ? "خصم" : "Discount"}: ${c['discount']}%  '
                          '${isAr ? "استخدام" : "Uses"}: ${c['uses']}/${c['maxUses']}',
                          style: context.text.bodySmall,
                        ),
                        trailing: isSuperAdmin
                            ? IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: AppColors.err),
                                onPressed: () =>
                                    ref.read(adminProvider.notifier)
                                        .deletePromo(c['code']?.toString() ?? ''),
                              )
                            : null,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showCreatePromo(
      BuildContext context, WidgetRef ref, bool isAr) {
    final codeCtrl     = TextEditingController();
    final discCtrl     = TextEditingController();
    final maxUsesCtrl  = TextEditingController(text: '1');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isAr ? 'كود خصم جديد' : 'New Promo Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeCtrl,
              decoration:
                  InputDecoration(labelText: isAr ? 'الكود' : 'Code'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: discCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: isAr ? 'نسبة الخصم (%)' : 'Discount (%)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: maxUsesCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: isAr ? 'الحد الأقصى' : 'Max Uses'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isAr ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(adminProvider.notifier).createPromo(
                codeCtrl.text.trim(),
                double.tryParse(discCtrl.text) ?? 0,
                int.tryParse(maxUsesCtrl.text) ?? 1,
              );
              Navigator.pop(context);
            },
            child: Text(isAr ? 'إنشاء' : 'Create'),
          ),
        ],
      ),
    );
  }
}

// ── Guest Codes Tab ───────────────────────────────────────────
class _GuestTab extends ConsumerWidget {
  final List<Map<String, dynamic>> codes;
  final String                     locale;
  final bool                       isSuperAdmin;
  const _GuestTab({
    required this.codes,
    required this.locale,
    required this.isSuperAdmin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = locale == 'ar';
    return Column(
      children: [
        if (isSuperAdmin)
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton.icon(
              icon:  const Icon(Icons.add, size: 16),
              label: Text(isAr ? 'إنشاء كود ضيف' : 'Create Guest Code'),
              onPressed: () {
                final ctrl = TextEditingController();
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(isAr ? 'كود ضيف جديد' : 'New Guest Code'),
                    content: TextField(
                      controller: ctrl,
                      decoration: InputDecoration(
                          labelText: isAr ? 'الكود' : 'Code'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(isAr ? 'إلغاء' : 'Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(adminProvider.notifier)
                              .createGuestCode(ctrl.text.trim());
                          Navigator.pop(context);
                        },
                        child: Text(isAr ? 'إنشاء' : 'Create'),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44)),
            ),
          ),
        Expanded(
          child: codes.isEmpty
              ? EmptyState(
                  icon:  Icons.person_outline,
                  title: isAr ? 'لا توجد أكواد ضيوف' : 'No guest codes')
              : ListView.builder(
                  padding:     const EdgeInsets.all(12),
                  itemCount:   codes.length,
                  itemBuilder: (_, i) {
                    final c = codes[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(c['code']?.toString() ?? '',
                            style: context.text.titleSmall),
                        subtitle: Text(
                          '${isAr ? "استخدم" : "Used"}: ${c['used'] == true ? (isAr ? "نعم" : "Yes") : (isAr ? "لا" : "No")}',
                          style: context.text.bodySmall,
                        ),
                        trailing: isSuperAdmin
                            ? IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: AppColors.err),
                                onPressed: () =>
                                    ref.read(adminProvider.notifier)
                                        .deleteGuestCode(c['code']?.toString() ?? ''),
                              )
                            : null,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ── Banned Tab ────────────────────────────────────────────────
class _BannedTab extends ConsumerWidget {
  final List<Map<String, dynamic>> banned;
  final String                     locale;
  const _BannedTab({required this.banned, required this.locale});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = locale == 'ar';
    if (banned.isEmpty) {
      return EmptyState(
          icon:  Icons.block,
          title: isAr ? 'لا يوجد محظورون' : 'No banned entries');
    }
    return ListView.builder(
      padding:     const EdgeInsets.all(12),
      itemCount:   banned.length,
      itemBuilder: (_, i) {
        final entry = banned[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.block, color: AppColors.err),
            title: Text(
              entry['email']?.toString() ?? entry['phone']?.toString() ?? 'N/A',
              style: context.text.titleSmall,
            ),
            subtitle: Text(
              entry['reason']?.toString() ?? '',
              style: context.text.bodySmall,
            ),
            trailing: TextButton(
              onPressed: () => ref.read(adminProvider.notifier)
                  .unbanIdentity(entry['id']?.toString() ?? ''),
              child: Text(
                isAr ? 'رفع الحظر' : 'Unban',
                style: const TextStyle(color: AppColors.ok, fontSize: 12),
              ),
            ),
          ),
        );
      },
    );
  }
}
