// lib/services/cache_service.dart
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:to_best/core/constants/app_constants.dart';

/// SQLite-based local cache (server is always the primary source of truth).
class CacheService {
  CacheService._();
  static final CacheService instance = CacheService._();

  Database? _db;

  Future<void> init() async {
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      join(dbPath, AppConstants.dbName),
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Generic key-value store
    await db.execute('''
      CREATE TABLE kv (
        key   TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
    // Workout logs per user per day
    await db.execute('''
      CREATE TABLE workout_logs (
        uid_date  TEXT PRIMARY KEY,
        data      TEXT,
        synced    INTEGER DEFAULT 0
      )
    ''');
    // Attendance per user per month
    await db.execute('''
      CREATE TABLE attendance (
        uid_month TEXT PRIMARY KEY,
        data      TEXT,
        synced    INTEGER DEFAULT 0
      )
    ''');
    // Meals per user per day
    await db.execute('''
      CREATE TABLE meals (
        uid_date  TEXT PRIMARY KEY,
        data      TEXT,
        synced    INTEGER DEFAULT 0
      )
    ''');
    // Meal plans per user
    await db.execute('''
      CREATE TABLE meal_plans (
        uid   TEXT PRIMARY KEY,
        data  TEXT
      )
    ''');
    // Body measurements per user
    await db.execute('''
      CREATE TABLE measurements (
        uid   TEXT PRIMARY KEY,
        data  TEXT
      )
    ''');
    // Chat messages cache per room
    await db.execute('''
      CREATE TABLE chat_cache (
        room_id   TEXT PRIMARY KEY,
        messages  TEXT,
        last_ts   INTEGER DEFAULT 0
      )
    ''');
    // Users list cache
    await db.execute('''
      CREATE TABLE users_cache (
        uid   TEXT PRIMARY KEY,
        data  TEXT
      )
    ''');
    // Offline sync queue
    await db.execute('''
      CREATE TABLE sync_queue (
        id      TEXT PRIMARY KEY,
        action  TEXT,
        key_val TEXT,
        data    TEXT,
        ts      INTEGER,
        retries INTEGER DEFAULT 0
      )
    ''');
    // Notifications
    await db.execute('''
      CREATE TABLE notifications (
        uid  TEXT,
        data TEXT,
        ts   INTEGER
      )
    ''');
  }

  Database get _database {
    assert(_db != null, 'CacheService not initialized. Call init() first.');
    return _db!;
  }

  // ── Generic KV ──────────────────────────────────────────
  Future<void> kvSet(String key, dynamic value) async {
    await _database.insert(
      'kv',
      {'key': key, 'value': jsonEncode(value)},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<dynamic> kvGet(String key) async {
    final rows = await _database.query(
        'kv', where: 'key = ?', whereArgs: [key], limit: 1);
    if (rows.isEmpty) return null;
    final raw = rows.first['value'] as String?;
    if (raw == null) return null;
    try { return jsonDecode(raw); } catch (_) { return raw; }
  }

  Future<void> kvDel(String key) async {
    await _database.delete('kv', where: 'key = ?', whereArgs: [key]);
  }

  // ── Current User ──────────────────────────────────────────
  Future<void> saveCurrentUser(Map<String, dynamic> user) async =>
      kvSet(AppConstants.keyCurrentUser, user);

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final v = await kvGet(AppConstants.keyCurrentUser);
    return v as Map<String, dynamic>?;
  }

  Future<void> clearCurrentUser() => kvDel(AppConstants.keyCurrentUser);

  // ── Settings ──────────────────────────────────────────────
  Future<void> saveSetting(String key, dynamic value) =>
      kvSet('setting_$key', value);

  Future<dynamic> getSetting(String key) => kvGet('setting_$key');

  // ── Workout Logs ──────────────────────────────────────────
  Future<void> saveWorkoutLog(
      String uid, String dateKey, Map<String, dynamic> data) async {
    await _database.insert(
      'workout_logs',
      {'uid_date': '${uid}_$dateKey', 'data': jsonEncode(data), 'synced': 0},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getWorkoutLog(
      String uid, String dateKey) async {
    final rows = await _database.query('workout_logs',
        where: 'uid_date = ?', whereArgs: ['${uid}_$dateKey']);
    if (rows.isEmpty) return null;
    try {
      return jsonDecode(rows.first['data'] as String)
          as Map<String, dynamic>;
    } catch (_) { return null; }
  }

  Future<Map<String, Map<String, dynamic>>> getAllWorkoutLogs(
      String uid) async {
    final rows = await _database.query('workout_logs',
        where: 'uid_date LIKE ?', whereArgs: ['${uid}_%']);
    final result = <String, Map<String, dynamic>>{};
    for (final row in rows) {
      final key =
          (row['uid_date'] as String).replaceFirst('${uid}_', '');
      try {
        result[key] =
            jsonDecode(row['data'] as String) as Map<String, dynamic>;
      } catch (_) {}
    }
    return result;
  }

  Future<void> markWorkoutLogSynced(String uid, String dateKey) async {
    await _database.update(
      'workout_logs',
      {'synced': 1},
      where: 'uid_date = ?',
      whereArgs: ['${uid}_$dateKey'],
    );
  }

  // ── Attendance ────────────────────────────────────────────
  Future<void> saveAttendance(
      String uid, String monthKey, Map<String, dynamic> data) async {
    await _database.insert(
      'attendance',
      {
        'uid_month': '${uid}_$monthKey',
        'data': jsonEncode(data),
        'synced': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getAttendance(
      String uid, String monthKey) async {
    final rows = await _database.query('attendance',
        where: 'uid_month = ?', whereArgs: ['${uid}_$monthKey']);
    if (rows.isEmpty) return null;
    try {
      return jsonDecode(rows.first['data'] as String)
          as Map<String, dynamic>;
    } catch (_) { return null; }
  }

  // ── Meals ─────────────────────────────────────────────────
  Future<void> saveMeals(
      String uid, String dateKey, Map<String, dynamic> data) async {
    await _database.insert(
      'meals',
      {'uid_date': '${uid}_$dateKey', 'data': jsonEncode(data), 'synced': 0},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getMeals(
      String uid, String dateKey) async {
    final rows = await _database.query('meals',
        where: 'uid_date = ?', whereArgs: ['${uid}_$dateKey']);
    if (rows.isEmpty) return null;
    try {
      return jsonDecode(rows.first['data'] as String)
          as Map<String, dynamic>;
    } catch (_) { return null; }
  }

  // ── Measurements ──────────────────────────────────────────
  Future<void> saveMeasurements(
      String uid, Map<String, dynamic> data) async {
    await _database.insert('measurements',
        {'uid': uid, 'data': jsonEncode(data)},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getMeasurements(String uid) async {
    final rows = await _database.query('measurements',
        where: 'uid = ?', whereArgs: [uid]);
    if (rows.isEmpty) return null;
    try {
      return jsonDecode(rows.first['data'] as String)
          as Map<String, dynamic>;
    } catch (_) { return null; }
  }

  // ── Users Cache ───────────────────────────────────────────
  Future<void> upsertUser(String uid, Map<String, dynamic> data) async {
    await _database.insert('users_cache',
        {'uid': uid, 'data': jsonEncode(data)},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAllCachedUsers() async {
    final rows = await _database.query('users_cache');
    final result = <Map<String, dynamic>>[];
    for (final row in rows) {
      try {
        result.add(
            jsonDecode(row['data'] as String) as Map<String, dynamic>);
      } catch (_) {}
    }
    return result;
  }

  Future<void> clearUsersCache() =>
      _database.delete('users_cache');

  // ── Chat ──────────────────────────────────────────────────
  Future<void> saveChatMessages(
      String roomId, List<Map<String, dynamic>> messages, int lastTs) async {
    await _database.insert(
      'chat_cache',
      {
        'room_id': roomId,
        'messages': jsonEncode(messages),
        'last_ts': lastTs,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getChatCache(String roomId) async {
    final rows = await _database.query('chat_cache',
        where: 'room_id = ?', whereArgs: [roomId]);
    if (rows.isEmpty) return null;
    return {
      'messages': jsonDecode(rows.first['messages'] as String? ?? '[]'),
      'last_ts': rows.first['last_ts'],
    };
  }

  // ── Sync Queue ────────────────────────────────────────────
  Future<void> enqueueSync({
    required String id,
    required String action,
    required String keyVal,
    required Map<String, dynamic> data,
  }) async {
    await _database.insert(
      'sync_queue',
      {
        'id':      id,
        'action':  action,
        'key_val': keyVal,
        'data':    jsonEncode(data),
        'ts':      DateTime.now().millisecondsSinceEpoch,
        'retries': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getPendingSyncs() async {
    final rows = await _database.query('sync_queue',
        orderBy: 'ts ASC');
    final result = <Map<String, dynamic>>[];
    for (final row in rows) {
      result.add({
        'id':      row['id'],
        'action':  row['action'],
        'key_val': row['key_val'],
        'data':    jsonDecode(row['data'] as String),
        'ts':      row['ts'],
        'retries': row['retries'],
      });
    }
    return result;
  }

  Future<void> removeSyncItem(String id) async {
    await _database.delete('sync_queue',
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> incrementRetries(String id) async {
    await _database.rawUpdate(
        'UPDATE sync_queue SET retries = retries + 1 WHERE id = ?', [id]);
  }

  Future<int> getPendingSyncCount() async {
    final result =
        await _database.rawQuery('SELECT COUNT(*) as c FROM sync_queue');
    return result.first['c'] as int? ?? 0;
  }

  // ── Cleanup ───────────────────────────────────────────────
  Future<void> clearAll() async {
    await _database.delete('kv');
    await _database.delete('workout_logs');
    await _database.delete('attendance');
    await _database.delete('meals');
    await _database.delete('measurements');
    await _database.delete('chat_cache');
    await _database.delete('users_cache');
    await _database.delete('sync_queue');
    await _database.delete('notifications');
    await _database.delete('meal_plans');
  }
}
