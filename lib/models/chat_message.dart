import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  TEXT,
  IMAGE,
  FILE,
  UNKNOWN,
}

class ChatMessage {
  final String senderID;
  final MessageType type;
  final String content;
  final DateTime sentTime;
  final String? url;
  bool isRead;

  ChatMessage({
    required this.content,
    required this.type,
    required this.senderID,
    required this.sentTime,
    this.url,
    this.isRead = false,
  });

  factory ChatMessage.fromJSON(Map<String, dynamic> json) {
    MessageType messageType;
    switch (json['type']) {
      case 'text':
        messageType = MessageType.TEXT;
        break;
      case 'image':
        messageType = MessageType.IMAGE;
        break;
      case 'file':
        messageType = MessageType.FILE;
        break;
      default:
        messageType = MessageType.UNKNOWN;
    }
    return ChatMessage(
      content: json['content'],
      type: messageType,
      senderID: json['sender_id'],
      sentTime: json['sent_time'].toDate(),
      url: json['url'],
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    String messageType;
    switch (type) {
      case MessageType.TEXT:
        messageType = 'text';
        break;
      case MessageType.IMAGE:
        messageType = 'image';
        break;
      case MessageType.FILE:
        messageType = 'file';
        break;
      default:
        messageType = '';
    }
    return {
      'content': content,
      'type': messageType,
      'sender_id': senderID,
      'sent_time': Timestamp.fromDate(sentTime),
      'url': url,
      'isRead': isRead,
    };
  }

  void toggleIsRead() {
    isRead = !isRead;
  }
}
