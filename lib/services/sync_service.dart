// lib/services/sync_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:to_best/services/api_service.dart';
import 'package:to_best/services/cache_service.dart';
import 'package:to_best/core/constants/app_constants.dart';

class SyncService {
  SyncService._();
  static final SyncService instance = SyncService._();

  final _api   = ApiService.instance;
  final _cache = CacheService.instance;

  Timer? _syncTimer;
  final _pendingController = StreamController<int>.broadcast();

  Stream<int> get pendingCountStream => _pendingController.stream;

  Future<void> init() async {
    // Listen for connectivity changes
    Connectivity().onConnectivityChanged.listen((results) {
      final hasConn = results.any((r) => r != ConnectivityResult.none);
      if (hasConn) {
        forcSync();
      }
    });

    // Periodic sync
    _syncTimer = Timer.periodic(
      const Duration(seconds: AppConstants.syncIntervalSeconds),
      (_) => _trySyncQueue(),
    );

    // Initial count
    _emitCount();
  }

  void dispose() {
    _syncTimer?.cancel();
    _pendingController.close();
  }

  // ── Enqueue an item for sync ──────────────────────────────
  Future<void> enqueue(
    String action,
    String keyVal,
    Map<String, dynamic> data,
  ) async {
    final id = '${action}_${keyVal}_${DateTime.now().millisecondsSinceEpoch}';
    await _cache.enqueueSync(
      id:      id,
      action:  action,
      keyVal:  keyVal,
      data:    data,
    );
    _emitCount();
    // Try to sync immediately
    _trySyncQueue();
  }

  // ── Force immediate sync ──────────────────────────────────
  Future<void> forcSync() => _trySyncQueue();

  // ── Process the sync queue ────────────────────────────────
  Future<void> _trySyncQueue() async {
    // Check connectivity
    final connectivity = await Connectivity().checkConnectivity();
    final hasConn = connectivity.any((r) => r != ConnectivityResult.none);
    if (!hasConn) return;

    final items = await _cache.getPendingSyncs();
    if (items.isEmpty) return;

    for (final item in items) {
      final id      = item['id'] as String;
      final action  = item['action'] as String;
      final data    = item['data'] as Map<String, dynamic>;
      final retries = (item['retries'] as int?) ?? 0;

      if (retries >= AppConstants.maxRetryAttempts) {
        // Too many retries — remove from queue to avoid blocking
        await _cache.removeSyncItem(id);
        continue;
      }

      try {
        final payload = {'action': action, ...data};
        final ok = await _api.pushData(payload);
        if (ok) {
          await _cache.removeSyncItem(id);
        } else {
          await _cache.incrementRetries(id);
        }
      } catch (_) {
        await _cache.incrementRetries(id);
      }
    }

    _emitCount();
  }

  Future<void> _emitCount() async {
    try {
      final count = await _cache.getPendingSyncCount();
      if (!_pendingController.isClosed) {
        _pendingController.add(count);
      }
    } catch (_) {}
  }

  // ── Pull full user data from server ───────────────────────
  Future<Map<String, dynamic>?> pullUserData(String uid) async {
    try {
      return await _api.fullSyncPull(uid);
    } catch (_) {
      return null;
    }
  }
}
