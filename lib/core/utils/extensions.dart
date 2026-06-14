// lib/core/utils/extensions.dart
import 'package:flutter/material.dart';
import 'package:to_best/core/constants/app_colors.dart';

extension StringX on String {
  bool get isValidEmail {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(this);
  }

  bool get isValidPhone {
    return RegExp(r'^[\d+\-\s()]{7,15}$').hasMatch(this);
  }

  String get initials {
    final parts = trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0].isEmpty ? '?' : parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Color get muscleColor =>
      AppColors.muscleColors[this] ?? AppColors.accent;

  String truncate(int max) =>
      length <= max ? this : '${substring(0, max)}...';

  bool get isNotNullOrEmpty => isNotEmpty;
}

extension IntX on int {
  String get msToTimeStr {
    final d = Duration(milliseconds: this);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (h > 0) return '$h:$m:$s';
    return '$m:$s';
  }

  String get msToDate {
    final d = DateTime.fromMillisecondsSinceEpoch(this);
    return '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
  }

  bool get isExpired =>
      this > 0 && DateTime.now().millisecondsSinceEpoch > this;

  String get kgStr {
    final d = toDouble();
    return '${d.toStringAsFixed(d == d.roundToDouble() ? 0 : 1)} kg';
  }
}

extension DoubleX on double {
  String get kgStr {
    return '${toStringAsFixed(this == roundToDouble() ? 0 : 1)} kg';
  }
}

extension ListX<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
  T? get lastOrNull  => isEmpty ? null : last;
  List<T> addBetween(T separator) {
    final result = <T>[];
    for (int i = 0; i < length; i++) {
      result.add(this[i]);
      if (i < length - 1) result.add(separator);
    }
    return result;
  }
}

extension ContextX on BuildContext {
  ThemeData get theme    => Theme.of(this);
  ColorScheme get scheme => Theme.of(this).colorScheme;
  TextTheme get text     => Theme.of(this).textTheme;
  bool get isDark        => Theme.of(this).brightness == Brightness.dark;
  double get width       => MediaQuery.of(this).size.width;
  double get height      => MediaQuery.of(this).size.height;
  bool get isRtl        => Directionality.of(this) == TextDirection.rtl;

  void showSnack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? AppColors.err : null,
      ),
    );
  }
}

int min(int a, int b) => a < b ? a : b;
