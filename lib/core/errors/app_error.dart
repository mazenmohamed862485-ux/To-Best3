// lib/core/errors/app_error.dart
enum AppErrorType {
  network,
  unauthorized,
  rateLimited,
  notConfigured,
  server,
  validation,
  banned,
  versionNotSupported,
  unknown,
}

class AppError implements Exception {
  final AppErrorType type;
  final String message;
  final String? raw;

  const AppError({
    required this.type,
    required this.message,
    this.raw,
  });

  factory AppError.fromCode(String code) {
    switch (code) {
      case 'unauthorized':
        return const AppError(
            type: AppErrorType.unauthorized, message: 'غير مصرح');
      case 'rate_limited':
        return const AppError(
            type: AppErrorType.rateLimited,
            message: 'تجاوزت عدد المحاولات. انتظر 15 دقيقة.');
      case 'not_configured':
        return const AppError(
            type: AppErrorType.notConfigured,
            message: 'لم يُضبط رابط السيرفر بعد.');
      case 'network':
        return const AppError(
            type: AppErrorType.network, message: 'لا يوجد اتصال بالإنترنت');
      case 'banned':
        return const AppError(
            type: AppErrorType.banned, message: 'هذا الحساب محظور');
      case 'version_not_supported':
        return const AppError(
            type: AppErrorType.versionNotSupported,
            message: 'هذه النسخة غير مدعومة. يرجى التحديث.');
      default:
        return AppError(type: AppErrorType.unknown, message: code);
    }
  }

  bool get isNetwork => type == AppErrorType.network;
  bool get isUnauthorized => type == AppErrorType.unauthorized;

  @override
  String toString() => message;
}
