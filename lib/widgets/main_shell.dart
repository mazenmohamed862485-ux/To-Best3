// lib/widgets/main_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:to_best/core/constants/app_colors.dart';
import 'package:to_best/app.dart';

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale  = ref.watch(localeProvider).languageCode;
    final isAr    = locale == 'ar';
    final location = GoRouterState.of(context).uri.toString();

    int _selectedIndex = 0;
    if (location.startsWith('/workout'))    _selectedIndex = 1;
    if (location.startsWith('/nutrition'))  _selectedIndex = 2;
    if (location.startsWith('/attendance')) _selectedIndex = 3;
    if (location.startsWith('/progress'))   _selectedIndex = 4;
    if (location.startsWith('/chat'))       _selectedIndex = 5;
    if (location.startsWith('/profile'))    _selectedIndex = 6;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (idx) {
          switch (idx) {
            case 0: context.go('/home');       break;
            case 1: context.go('/workout');    break;
            case 2: context.go('/nutrition');  break;
            case 3: context.go('/attendance'); break;
            case 4: context.go('/progress');   break;
            case 5: context.go('/chat');       break;
            case 6: context.go('/profile');    break;
          }
        },
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon:  const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: isAr ? 'الرئيسية' : 'Home',
          ),
          NavigationDestination(
            icon:  const Icon(Icons.fitness_center_outlined),
            selectedIcon: const Icon(Icons.fitness_center),
            label: isAr ? 'تمرين' : 'Workout',
          ),
          NavigationDestination(
            icon:  const Icon(Icons.restaurant_outlined),
            selectedIcon: const Icon(Icons.restaurant),
            label: isAr ? 'تغذية' : 'Nutrition',
          ),
          NavigationDestination(
            icon:  const Icon(Icons.calendar_today_outlined),
            selectedIcon: const Icon(Icons.calendar_today),
            label: isAr ? 'إلتزام' : 'Attendance',
          ),
          NavigationDestination(
            icon:  const Icon(Icons.show_chart_outlined),
            selectedIcon: const Icon(Icons.show_chart),
            label: isAr ? 'تقدم' : 'Progress',
          ),
          NavigationDestination(
            icon:  const Icon(Icons.chat_bubble_outline),
            selectedIcon: const Icon(Icons.chat_bubble),
            label: isAr ? 'دردشة' : 'Chat',
          ),
          NavigationDestination(
            icon:  const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: isAr ? 'ملفي' : 'Profile',
          ),
        ],
      ),
    );
  }
}
