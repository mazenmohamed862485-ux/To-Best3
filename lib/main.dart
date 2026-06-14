// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_best/services/cache_service.dart';
import 'package:to_best/services/sync_service.dart';
import 'package:to_best/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait by default (can be changed per-screen)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor:      Colors.transparent,
      statusBarBrightness: Brightness.dark,
    ),
  );

  // Initialize local cache
  await CacheService.instance.init();

  // Initialize sync service
  await SyncService.instance.init();

  runApp(
    const ProviderScope(
      child: ToBestApp(),
    ),
  );
}
