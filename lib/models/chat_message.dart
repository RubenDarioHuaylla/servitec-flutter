import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime? createdAt;
  final bool read;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.createdAt,
    required this.read,
  });

  factory ChatMessage.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    if (data == null) {
      throw Exception(
        'El mensaje ${document.id} no contiene información',
      );
    }

    return ChatMessage(
      id: document.id,
      senderId: data['senderId'] as String? ?? '',
      text: data['text'] as String? ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate(),
      read: data['read'] as bool? ?? false,
    );
  }
}