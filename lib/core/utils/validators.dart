// lib/core/utils/validators.dart
class AppValidators {
  AppValidators._();

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'هذا الحقل مطلوب';
    final reg = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!reg.hasMatch(v.trim())) return 'بريد إلكتروني غير صحيح';
    if (v.length > 100) return 'البريد طويل جداً';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.trim().isEmpty) return 'كلمة المرور مطلوبة';
    if (v.length < 8)   return 'يجب أن تكون 8 أحرف على الأقل';
    if (v.length > 100) return 'كلمة المرور طويلة جداً';
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(v);
    final hasDigit  = RegExp(r'\d').hasMatch(v);
    if (!hasLetter || !hasDigit) return 'يجب أن تحتوي على حروف وأرقام';
    return null;
  }

  static String? name(String? v) {
    if (v == null || v.trim().isEmpty) return 'الاسم مطلوب';
    if (v.trim().length > 80) return 'الاسم طويل جداً';
    return null;
  }

  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final reg = RegExp(r'^[\d+\-\s()]+$');
    if (!reg.hasMatch(v.trim())) return 'رقم هاتف غير صحيح';
    if (v.length > 15) return 'رقم الهاتف طويل جداً';
    return null;
  }

  static String? required(String? v, [String? msg]) {
    if (v == null || v.trim().isEmpty) return msg ?? 'هذا الحقل مطلوب';
    return null;
  }

  static String? confirmPassword(String? v, String original) {
    if (v == null || v.isEmpty) return 'تأكيد كلمة المرور مطلوب';
    if (v != original) return 'كلمتا المرور غير متطابقتين';
    return null;
  }

  static String? url(String? v) {
    if (v == null || v.trim().isEmpty) return 'الرابط مطلوب';
    final reg = RegExp(r'^https?://.+');
    if (!reg.hasMatch(v.trim())) return 'رابط غير صحيح (يجب أن يبدأ بـ https://)';
    return null;
  }

  static String? positiveNumber(String? v) {
    if (v == null || v.trim().isEmpty) return 'القيمة مطلوبة';
    final n = double.tryParse(v);
    if (n == null || n <= 0) return 'يجب أن تكون قيمة موجبة';
    return null;
  }
}
