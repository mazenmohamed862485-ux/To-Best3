// lib/widgets/common_widgets.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:to_best/core/constants/app_colors.dart';
import 'package:to_best/core/utils/extensions.dart';

// ── User Avatar ───────────────────────────────────────────────
class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String  name;
  final double  radius;

  const UserAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.accent.withOpacity(0.2),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl:    imageUrl!,
            width:       radius * 2,
            height:      radius * 2,
            fit:         BoxFit.cover,
            errorWidget: (_, __, ___) => _initials(isDark),
          ),
        ),
      );
    }
    return CircleAvatar(
      radius:          radius,
      backgroundColor: AppColors.accent.withOpacity(0.15),
      child:           _initials(isDark),
    );
  }

  Widget _initials(bool isDark) => Text(
    name.initials,
    style: TextStyle(
      fontSize:   radius * 0.7,
      fontWeight: FontWeight.w700,
      color:      AppColors.accent,
    ),
  );
}

// ── Section Header ────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String  title;
  final Widget? trailing;

  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: context.text.titleSmall?.copyWith(
                color: context.scheme.primary,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ── Loading Overlay ───────────────────────────────────────────
class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool   loading;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (loading)
          const ColoredBox(
            color: Colors.black38,
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.accent,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Empty State ────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String   title;
  final String?  subtitle;
  final Widget?  action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.accent.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(
              title,
              style: context.text.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: context.text.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String  label;
  final String  value;
  final IconData? icon;
  final Color?  color;
  final String? sub;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color,
    this.sub,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.accent;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 14, color: c),
                  const SizedBox(width: 4),
                ],
                Text(
                  label,
                  style: context.text.bodySmall?.copyWith(color: c),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: context.text.headlineSmall?.copyWith(
                color: c, fontWeight: FontWeight.w900,
              ),
            ),
            if (sub != null)
              Text(sub!, style: context.text.labelSmall),
          ],
        ),
      ),
    );
  }
}

// ── Info Row ──────────────────────────────────────────────────
class InfoRow extends StatelessWidget {
  final String  label;
  final String  value;
  final Color?  valueColor;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.text.bodySmall),
          Text(
            value,
            style: context.text.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color:      valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sync Indicator ────────────────────────────────────────────
class SyncIndicator extends StatelessWidget {
  final int pendingCount;

  const SyncIndicator({super.key, required this.pendingCount});

  @override
  Widget build(BuildContext context) {
    if (pendingCount == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:        AppColors.warn.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: AppColors.warn.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 10, height: 10,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: AppColors.warn,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$pendingCount',
            style: const TextStyle(
              fontSize: 11, color: AppColors.warn, fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Macro Ring ────────────────────────────────────────────────
class MacroProgressBar extends StatelessWidget {
  final String label;
  final double current;
  final double target;
  final Color  color;

  const MacroProgressBar({
    super.key,
    required this.label,
    required this.current,
    required this.target,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: context.text.bodySmall),
            Text(
              '${current.toInt()} / ${target.toInt()}g',
              style: context.text.labelSmall?.copyWith(
                  color: color, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value:           ratio,
            color:           color,
            backgroundColor: color.withOpacity(0.15),
            minHeight:       6,
          ),
        ),
      ],
    );
  }
}
