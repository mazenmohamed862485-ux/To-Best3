// lib/features/workout/screens/video_player_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:to_best/core/constants/app_colors.dart';
import 'package:to_best/app.dart';

/// Opens a Google Drive video inside a WebView
class VideoPlayerScreen extends ConsumerStatefulWidget {
  final String url;
  final String title;

  const VideoPlayerScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  late WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _loading = true),
        onPageFinished: (_) => setState(() => _loading = false),
      ))
      ..loadRequest(Uri.parse(_buildEmbedUrl(widget.url)));
  }

  String _buildEmbedUrl(String url) {
    // Handle Google Drive URLs
    // https://drive.google.com/file/d/FILE_ID/view
    // https://drive.google.com/open?id=FILE_ID
    final RegExp idPattern = RegExp(r'/d/([^/]+)');
    final match = idPattern.firstMatch(url);
    if (match != null) {
      final id = match.group(1);
      return 'https://drive.google.com/file/d/$id/preview';
    }
    // Check ?id= pattern
    final uri = Uri.tryParse(url);
    if (uri != null) {
      final id = uri.queryParameters['id'];
      if (id != null) {
        return 'https://drive.google.com/file/d/$id/preview';
      }
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider).languageCode;
    final isAr   = locale == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.accent,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            Container(
              color: Colors.black38,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
            ),
        ],
      ),
    );
  }
}
