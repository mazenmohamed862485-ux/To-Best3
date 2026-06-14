// lib/features/chat/screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_best/features/auth/providers/auth_provider.dart';
import 'package:to_best/features/chat/providers/chat_provider.dart';
import 'package:to_best/features/chat/models/message_model.dart';
import 'package:to_best/core/constants/app_colors.dart';
import 'package:to_best/core/constants/app_constants.dart';
import 'package:to_best/core/utils/date_helper.dart';
import 'package:to_best/core/utils/extensions.dart';
import 'package:to_best/widgets/common_widgets.dart';
import 'package:to_best/app.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _scrollCtrl = ScrollController();
  String _currentRoom = AppConstants.roomGeneral;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        setState(() {
          _currentRoom = [
            AppConstants.roomGeneral,
            AppConstants.roomAnnouncements,
            AppConstants.roomSupport,
          ][_tabCtrl.index];
        });
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider).languageCode;
    final isAr   = locale == 'ar';
    final user   = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'الدردشة' : 'Chat'),
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: false,
          tabs: [
            Tab(text: isAr ? 'العام' : 'General'),
            Tab(text: isAr ? 'الإعلانات' : 'Announce'),
            Tab(text: isAr ? 'الدعم' : 'Support'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _RoomView(
            roomId: AppConstants.roomGeneral,
            locale: locale,
          ),
          _RoomView(
            roomId: AppConstants.roomAnnouncements,
            locale: locale,
            readOnly: !(user?.isAdminLike ?? false),
          ),
          _RoomView(
            roomId: AppConstants.roomSupport,
            locale: locale,
          ),
        ],
      ),
    );
  }
}

class _RoomView extends ConsumerStatefulWidget {
  final String  roomId;
  final String  locale;
  final bool    readOnly;

  const _RoomView({
    required this.roomId,
    required this.locale,
    this.readOnly = false,
  });

  @override
  ConsumerState<_RoomView> createState() => _RoomViewState();
}

class _RoomViewState extends ConsumerState<_RoomView> {
  final _msgCtrl    = TextEditingController();
  final _scrollCtrl = ScrollController();
  MessageModel? _replyTo;
  bool _sending = false;

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _sending = true);
    _msgCtrl.clear();
    await ref.read(chatProvider(widget.roomId).notifier).sendMessage(
      uid:         user.uid,
      senderName:  user.name,
      senderPic:   user.profilePicUrl,
      text:        text,
      replyToId:   _replyTo?.id,
      replyText:   _replyTo?.text.truncate(60),
    );
    setState(() {
      _sending = false;
      _replyTo = null;
    });
    _scrollToBottom();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAr   = widget.locale == 'ar';
    final chatSt = ref.watch(chatProvider(widget.roomId));
    final user   = ref.watch(currentUserProvider);
    final msgs   = chatSt.messages;

    // Auto-scroll on new messages
    if (msgs.isNotEmpty) _scrollToBottom();

    return Column(
      children: [
        // Pinned message
        if (chatSt.pinnedMessage != null)
          _PinnedBanner(msg: chatSt.pinnedMessage!, locale: widget.locale),

        // Messages
        Expanded(
          child: msgs.isEmpty
              ? Center(
                  child: Text(
                    isAr ? 'لا توجد رسائل بعد' : 'No messages yet',
                    style: context.text.bodySmall,
                  ),
                )
              : ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  itemCount: msgs.length,
                  itemBuilder: (_, i) {
                    final msg    = msgs[i];
                    final isMe   = msg.uid == user?.uid;
                    final isAdmin = user?.isAdminLike ?? false;
                    return _MessageBubble(
                      msg:      msg,
                      isMe:     isMe,
                      locale:   widget.locale,
                      canAdmin: isAdmin,
                      onReply:  () => setState(() => _replyTo = msg),
                      onDelete: isAdmin || isMe
                          ? () => ref
                              .read(chatProvider(widget.roomId).notifier)
                              .deleteMessage(msg.id)
                          : null,
                      onPin: isAdmin
                          ? () => ref
                              .read(chatProvider(widget.roomId).notifier)
                              .pinMessage(msg.id)
                          : null,
                    );
                  },
                ),
        ),

        // Reply preview
        if (_replyTo != null)
          Container(
            color: context.scheme.primary.withOpacity(0.06),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 3, height: 36,
                  color: context.scheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_replyTo!.senderName,
                          style: TextStyle(
                            fontSize: 11,
                            color:    context.scheme.primary,
                            fontWeight: FontWeight.w700,
                          )),
                      Text(_replyTo!.text.truncate(50),
                          style: context.text.bodySmall),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () => setState(() => _replyTo = null),
                ),
              ],
            ),
          ),

        // Input bar
        if (!widget.readOnly)
          Container(
            color: context.theme.cardColor,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller:  _msgCtrl,
                      maxLines:    null,
                      minLines:    1,
                      decoration: InputDecoration(
                        hintText: isAr ? 'اكتب رسالة...' : 'Type a message...',
                        isDense:  true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: _sending
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.accent),
                          )
                        : const Icon(Icons.send, color: AppColors.accent),
                    onPressed: _sending ? null : _sendMessage,
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            color: context.theme.cardColor,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Text(
                isAr ? '🔒 هذه القناة للإعلانات فقط' : '🔒 Announcements only',
                style: context.text.bodySmall,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Pinned Banner ─────────────────────────────────────────────
class _PinnedBanner extends StatelessWidget {
  final MessageModel msg;
  final String       locale;
  const _PinnedBanner({required this.msg, required this.locale});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.accent.withOpacity(0.08),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.push_pin, size: 14, color: AppColors.accent),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              msg.text.truncate(80),
              style: context.text.bodySmall?.copyWith(
                  color: AppColors.accent),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Message Bubble ────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final MessageModel msg;
  final bool         isMe;
  final String       locale;
  final bool         canAdmin;
  final VoidCallback  onReply;
  final VoidCallback? onDelete;
  final VoidCallback? onPin;

  const _MessageBubble({
    required this.msg,
    required this.isMe,
    required this.locale,
    required this.canAdmin,
    required this.onReply,
    this.onDelete,
    this.onPin,
  });

  @override
  Widget build(BuildContext context) {
    final isAr   = locale == 'ar';
    final scheme = context.scheme;

    return GestureDetector(
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          builder: (_) => Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.reply),
                title: Text(isAr ? 'رد' : 'Reply'),
                onTap: () { Navigator.pop(context); onReply(); },
              ),
              if (onDelete != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: AppColors.err),
                  title: Text(isAr ? 'حذف' : 'Delete',
                      style: const TextStyle(color: AppColors.err)),
                  onTap: () { Navigator.pop(context); onDelete!(); },
                ),
              if (onPin != null)
                ListTile(
                  leading: const Icon(Icons.push_pin, color: AppColors.accent),
                  title: Text(isAr ? 'تثبيت' : 'Pin',
                      style: const TextStyle(color: AppColors.accent)),
                  onTap: () { Navigator.pop(context); onPin!(); },
                ),
            ],
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              UserAvatar(
                  imageUrl: msg.senderPic, name: msg.senderName, radius: 14),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.72),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isMe
                      ? scheme.primary.withOpacity(0.2)
                      : context.theme.cardColor,
                  borderRadius: BorderRadius.only(
                    topLeft:     const Radius.circular(14),
                    topRight:    const Radius.circular(14),
                    bottomLeft:  Radius.circular(isMe ? 14 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 14),
                  ),
                  border: Border.all(
                    color: isMe
                        ? scheme.primary.withOpacity(0.3)
                        : context.theme.dividerColor,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMe)
                      Text(
                        msg.senderName,
                        style: TextStyle(
                          fontSize:   11,
                          fontWeight: FontWeight.w700,
                          color:      scheme.primary,
                        ),
                      ),
                    if (msg.replyText != null) ...[
                      Container(
                        padding: const EdgeInsets.all(6),
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: scheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                          border: Border(
                            left: BorderSide(
                                color: scheme.primary, width: 2),
                          ),
                        ),
                        child: Text(
                          msg.replyText!.truncate(60),
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                    Text(msg.text, style: context.text.bodyMedium),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DateHelper.formatTime(
                              DateTime.fromMillisecondsSinceEpoch(msg.ts)),
                          style: context.text.labelSmall,
                        ),
                        if (msg.edited) ...[
                          const SizedBox(width: 4),
                          Text(isAr ? '(معدّل)' : '(edited)',
                              style: context.text.labelSmall),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
