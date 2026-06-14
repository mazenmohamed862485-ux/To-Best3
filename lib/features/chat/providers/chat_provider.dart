// lib/features/chat/providers/chat_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_best/features/chat/models/message_model.dart';
import 'package:to_best/services/api_service.dart';
import 'package:to_best/services/cache_service.dart';

class ChatState {
  final List<MessageModel> messages;
  final MessageModel?      pinnedMessage;
  final bool               loading;
  final String?            error;

  const ChatState({
    this.messages      = const [],
    this.pinnedMessage,
    this.loading       = false,
    this.error,
  });

  ChatState copyWith({
    List<MessageModel>? messages,
    MessageModel?       pinnedMessage,
    bool?               loading,
    String?             error,
    bool                clearPin   = false,
    bool                clearError = false,
  }) =>
      ChatState(
        messages:      messages      ?? this.messages,
        pinnedMessage: clearPin ? null : (pinnedMessage ?? this.pinnedMessage),
        loading:       loading       ?? this.loading,
        error:         clearError ? null : (error ?? this.error),
      );
}

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier() : super(const ChatState());

  final _api   = ApiService.instance;
  final _cache = CacheService.instance;

  String? _roomId;
  Timer?  _pollTimer;
  int     _lastTs = 0;

  void setRoom(String roomId) {
    if (_roomId == roomId) return;
    _roomId = roomId;
    _lastTs = 0;
    _pollTimer?.cancel();
    _loadCached();
    fetchMessages();
    // Poll every 10 seconds
    _pollTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => fetchMessages(),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCached() async {
    if (_roomId == null) return;
    final cached = await _cache.getChatCache(_roomId!);
    if (cached != null) {
      final msgs = (cached['messages'] as List?)
          ?.map((m) => MessageModel.fromJson(m as Map<String, dynamic>))
          .toList() ?? [];
      _lastTs = (cached['last_ts'] as int?) ?? 0;
      if (mounted) state = state.copyWith(messages: msgs);
    }
  }

  Future<void> fetchMessages() async {
    if (_roomId == null) return;
    try {
      final newMsgs = await _api.fetchMessages(_roomId!, _lastTs);
      if (newMsgs.isNotEmpty) {
        final models = newMsgs
            .map((m) => MessageModel.fromJson(m))
            .toList();
        final maxTs = models
            .map((m) => m.ts)
            .reduce((a, b) => a > b ? a : b);
        if (maxTs > _lastTs) _lastTs = maxTs;

        // Merge with existing
        final existing  = state.messages;
        final existingIds = existing.map((m) => m.id).toSet();
        final merged   = [
          ...existing,
          ...models.where((m) => !existingIds.contains(m.id)),
        ]..sort((a, b) => a.ts.compareTo(b.ts));

        if (mounted) state = state.copyWith(messages: merged);

        // Cache
        await _cache.saveChatMessages(
            _roomId!, merged.map((m) => m.toJson()).toList(), _lastTs);
      }

      // Fetch pinned
      final pinned = await _api.fetchPinnedMessage(_roomId!);
      if (pinned != null && mounted) {
        state = state.copyWith(
            pinnedMessage: MessageModel.fromJson(pinned));
      }
    } catch (_) {}
  }

  Future<bool> sendMessage({
    required String uid,
    required String senderName,
    String?         senderPic,
    required String text,
    String?         replyToId,
    String?         replyText,
  }) async {
    if (_roomId == null || text.trim().isEmpty) return false;
    final msg = MessageModel(
      id:         'msg_${DateTime.now().millisecondsSinceEpoch}_$uid',
      roomId:     _roomId!,
      uid:        uid,
      senderName: senderName,
      senderPic:  senderPic,
      text:       text.trim(),
      ts:         DateTime.now().millisecondsSinceEpoch,
      replyTo:    replyToId,
      replyText:  replyText,
    );

    // Optimistic update
    final updated = [...state.messages, msg]
      ..sort((a, b) => a.ts.compareTo(b.ts));
    if (mounted) state = state.copyWith(messages: updated);

    final ok = await _api.sendMessage(_roomId!, msg.toJson());
    if (!ok) {
      // Rollback
      if (mounted) {
        state = state.copyWith(
            messages: state.messages.where((m) => m.id != msg.id).toList());
      }
    }
    return ok;
  }

  Future<bool> deleteMessage(String msgId) async {
    if (_roomId == null) return false;
    final ok = await _api.deleteMessage(_roomId!, msgId);
    if (ok && mounted) {
      state = state.copyWith(
          messages: state.messages.where((m) => m.id != msgId).toList());
    }
    return ok;
  }

  Future<bool> editMessage(String msgId, String newText) async {
    if (_roomId == null) return false;
    final ok = await _api.editMessage(_roomId!, msgId, newText);
    if (ok && mounted) {
      state = state.copyWith(
        messages: state.messages.map((m) {
          if (m.id == msgId) return m.copyWith(text: newText, edited: true);
          return m;
        }).toList(),
      );
    }
    return ok;
  }

  Future<bool> pinMessage(String msgId) async {
    if (_roomId == null) return false;
    final msg = state.messages.firstWhere((m) => m.id == msgId,
        orElse: () => const MessageModel(
            id: '', roomId: '', uid: '', senderName: '', text: '', ts: 0));
    if (msg.id.isEmpty) return false;
    return _api.pinMessage(_roomId!, msg.toJson());
  }
}

// Provider factory for rooms
final chatProvider = StateNotifierProvider.family<ChatNotifier, ChatState, String>(
    (ref, roomId) => ChatNotifier()..setRoom(roomId));
