// lib/features/chat/models/message_model.dart
class MessageModel {
  final String  id;
  final String  roomId;
  final String  uid;
  final String  senderName;
  final String? senderPic;
  final String  text;
  final int     ts;
  final bool    edited;
  final bool    pinned;
  final String? replyTo;
  final String? replyText;

  const MessageModel({
    required this.id,
    required this.roomId,
    required this.uid,
    required this.senderName,
    this.senderPic,
    required this.text,
    required this.ts,
    this.edited   = false,
    this.pinned   = false,
    this.replyTo,
    this.replyText,
  });

  factory MessageModel.fromJson(Map<String, dynamic> j) => MessageModel(
    id:          j['id']?.toString()         ?? '',
    roomId:      j['roomId']?.toString()     ?? '',
    uid:         j['uid']?.toString()        ?? '',
    senderName:  j['senderName']?.toString() ?? '',
    senderPic:   j['senderPic']?.toString(),
    text:        j['text']?.toString()       ?? '',
    ts:          (j['ts'] as num?)?.toInt()  ??
                 DateTime.now().millisecondsSinceEpoch,
    edited:      j['edited']  == true,
    pinned:      j['pinned']  == true,
    replyTo:     j['replyTo']?.toString(),
    replyText:   j['replyText']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'id':          id,
    'roomId':      roomId,
    'uid':         uid,
    'senderName':  senderName,
    if (senderPic  != null) 'senderPic':  senderPic,
    'text':        text,
    'ts':          ts,
    if (edited)            'edited':      true,
    if (pinned)            'pinned':      true,
    if (replyTo   != null) 'replyTo':    replyTo,
    if (replyText != null) 'replyText':  replyText,
  };

  MessageModel copyWith({String? text, bool? edited, bool? pinned}) =>
      MessageModel(
        id:         id,
        roomId:     roomId,
        uid:        uid,
        senderName: senderName,
        senderPic:  senderPic,
        text:       text   ?? this.text,
        ts:         ts,
        edited:     edited ?? this.edited,
        pinned:     pinned ?? this.pinned,
        replyTo:    replyTo,
        replyText:  replyText,
      );
}
