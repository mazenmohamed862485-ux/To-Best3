// lib/services/update_service.dart
import 'package:to_best/services/api_service.dart';
import 'package:to_best/core/constants/app_constants.dart';

enum UpdateStatus {
  none,
  optional,   // update available but not required
  required,   // app will not work without update
  blocked,    // version is explicitly blocked
}

class UpdateInfo {
  final UpdateStatus status;
  final String?      latestVersion;
  final String?      downloadUrl;
  final String?      message;

  const UpdateInfo({
    required this.status,
    this.latestVersion,
    this.downloadUrl,
    this.message,
  });

  static const none = UpdateInfo(status: UpdateStatus.none);
}

class UpdateService {
  UpdateService._();
  static final UpdateService instance = UpdateService._();

  final _api = ApiService.instance;

  /// Check the server for update info.
  /// Returns [UpdateInfo.none] if the server doesn't support version checks
  /// or there's a network error — app continues normally.
  Future<UpdateInfo> checkForUpdate() async {
    try {
      final res = await _api.checkVersion(
        AppConstants.appVersion,
        AppConstants.appBuild,
      );

      if (res == null) return UpdateInfo.none;

      final status = res['updateStatus']?.toString() ?? 'none';
      final latestVersion = res['latestVersion']?.toString();
      final downloadUrl   = res['downloadUrl']?.toString();
      final message       = res['message']?.toString();

      switch (status) {
        case 'required':
          return UpdateInfo(
            status:        UpdateStatus.required,
            latestVersion: latestVersion,
            downloadUrl:   downloadUrl,
            message:       message,
          );
        case 'optional':
          return UpdateInfo(
            status:        UpdateStatus.optional,
            latestVersion: latestVersion,
            downloadUrl:   downloadUrl,
            message:       message,
          );
        case 'blocked':
          return UpdateInfo(
            status:        UpdateStatus.blocked,
            latestVersion: latestVersion,
            downloadUrl:   downloadUrl,
            message:       message ??
                'هذه النسخة لم تعد مدعومة. يرجى التحديث للاستمرار.',
          );
        default:
          return UpdateInfo.none;
      }
    } catch (_) {
      // Network or server error — don't block the user
      return UpdateInfo.none;
    }
  }
}
