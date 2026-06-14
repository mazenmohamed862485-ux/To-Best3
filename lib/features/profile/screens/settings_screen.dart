// lib/features/profile/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_best/core/constants/app_colors.dart';
import 'package:to_best/core/constants/app_constants.dart';
import 'package:to_best/core/utils/extensions.dart';
import 'package:to_best/app.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale    = ref.watch(localeProvider).languageCode;
    final isAr      = locale == 'ar';
    final themeMode = ref.watch(themeModeProvider);
    final accent    = ref.watch(accentColorProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'الإعدادات' : 'Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Appearance ────────────────────────────────────
            _SectionTitle(title: isAr ? 'المظهر' : 'Appearance'),
            Card(
              child: Column(
                children: [
                  // Theme
                  ListTile(
                    leading: const Icon(Icons.palette_outlined),
                    title: Text(isAr ? 'الثيم' : 'Theme'),
                    trailing: SegmentedButton<ThemeMode>(
                      segments: [
                        ButtonSegment(
                          value: ThemeMode.light,
                          icon: const Icon(Icons.light_mode, size: 16),
                        ),
                        ButtonSegment(
                          value: ThemeMode.system,
                          icon: const Icon(Icons.brightness_auto, size: 16),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          icon: const Icon(Icons.dark_mode, size: 16),
                        ),
                      ],
                      selected: {themeMode},
                      onSelectionChanged: (s) {
                        if (s.isNotEmpty) {
                          ref.read(themeModeProvider.notifier).set(s.first);
                        }
                      },
                      style: const ButtonStyle(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                  const Divider(height: 0),
                  // Accent color
                  ListTile(
                    leading: const Icon(Icons.color_lens_outlined),
                    title: Text(isAr ? 'لون التطبيق' : 'Accent Color'),
                    subtitle: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: AppConstants.accentColors.map((hex) {
                        final color = Color(
                          int.parse(hex.replaceFirst('#', ''), radix: 16) +
                              0xFF000000,
                        );
                        final selected = accent == color;
                        return GestureDetector(
                          onTap: () =>
                              ref.read(accentColorProvider.notifier).set(color),
                          child: Container(
                            width: 28, height: 28,
                            margin: const EdgeInsets.only(top: 6),
                            decoration: BoxDecoration(
                              color:  color,
                              shape:  BoxShape.circle,
                              border: selected
                                  ? Border.all(
                                      color: Colors.white,
                                      width: 2.5,
                                    )
                                  : null,
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                        color: color.withOpacity(0.5),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      )
                                    ]
                                  : null,
                            ),
                            child: selected
                                ? const Icon(Icons.check,
                                    size: 14, color: Colors.white)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Language ──────────────────────────────────────
            _SectionTitle(title: isAr ? 'اللغة' : 'Language'),
            Card(
              child: Column(
                children: [
                  RadioListTile<String>(
                    value:    'ar',
                    groupValue: locale,
                    title: const Text('العربية'),
                    secondary: const Text('🇸🇦', style: TextStyle(fontSize: 20)),
                    onChanged: (v) {
                      if (v != null) {
                        ref.read(localeProvider.notifier).set(v);
                      }
                    },
                    activeColor: AppColors.accent,
                  ),
                  const Divider(height: 0),
                  RadioListTile<String>(
                    value:    'en',
                    groupValue: locale,
                    title: const Text('English'),
                    secondary: const Text('🇺🇸', style: TextStyle(fontSize: 20)),
                    onChanged: (v) {
                      if (v != null) {
                        ref.read(localeProvider.notifier).set(v);
                      }
                    },
                    activeColor: AppColors.accent,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── App Info ──────────────────────────────────────
            _SectionTitle(title: isAr ? 'عن التطبيق' : 'About'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(isAr ? 'الإصدار' : 'Version'),
                    trailing: Text(
                      AppConstants.appVersion,
                      style: context.text.bodySmall?.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Divider(height: 0),
                  ListTile(
                    leading: const Icon(Icons.build_outlined),
                    title: Text(isAr ? 'Build' : 'Build Number'),
                    trailing: Text(
                      '${AppConstants.appBuild}',
                      style: context.text.bodySmall,
                    ),
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

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
      child: Text(
        title,
        style: context.text.bodySmall?.copyWith(
          color:      context.scheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
