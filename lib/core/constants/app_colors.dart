// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand — TO Best green
  static const Color accent       = Color(0xFF4CAF50);
  static const Color accentDark   = Color(0xFF388E3C);
  static const Color accentLight  = Color(0xFF81C784);

  // Dark theme
  static const Color darkBg       = Color(0xFF0D0D12);
  static const Color darkBgCard   = Color(0xFF1A1A24);
  static const Color darkBgInput  = Color(0xFF232330);
  static const Color darkBorder   = Color(0xFF2E2E40);
  static const Color darkText1    = Color(0xFFE8E8F0);
  static const Color darkText2    = Color(0xFF8888AA);
  static const Color darkText3    = Color(0xFF555566);

  // Light theme
  static const Color lightBg      = Color(0xFFF5F5F8);
  static const Color lightBgCard  = Color(0xFFFFFFFF);
  static const Color lightBgInput = Color(0xFFF0F0F5);
  static const Color lightBorder  = Color(0xFFE0E0EA);
  static const Color lightText1   = Color(0xFF1A1A2E);
  static const Color lightText2   = Color(0xFF555566);
  static const Color lightText3   = Color(0xFF9999AA);

  // Semantic
  static const Color ok      = Color(0xFF4CAF50);
  static const Color warn    = Color(0xFFFF9800);
  static const Color err     = Color(0xFFFF4444);
  static const Color info    = Color(0xFF2196F3);
  static const Color pr      = Color(0xFFFFD700);

  // Eval colors
  static const Color evalSuperb  = Color(0xFFFF6B35);
  static const Color evalGood    = Color(0xFF4CAF50);
  static const Color evalStable  = Color(0xFFFFEB3B);
  static const Color evalDown    = Color(0xFFFF4444);

  // Muscle group tags
  static const Map<String, Color> muscleColors = {
    'صدر': Color(0xFF4FC3F7),
    'ظهر': Color(0xFF66BB6A),
    'كتف': Color(0xFFFFA726),
    'بايسبس': Color(0xFFBA68C8),
    'ترايسبس': Color(0xFF4DB6AC),
    'رجل': Color(0xFFFF7043),
    'بطن': Color(0xFF29B6F6),
    'سمانة': Color(0xFF9CCC65),
    'chest': Color(0xFF4FC3F7),
    'back': Color(0xFF66BB6A),
    'shoulder': Color(0xFFFFA726),
    'biceps': Color(0xFFBA68C8),
    'triceps': Color(0xFF4DB6AC),
    'legs': Color(0xFFFF7043),
    'abs': Color(0xFF29B6F6),
    'calves': Color(0xFF9CCC65),
  };
}
