import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/chat_message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getConversationIdByServiceId(String serviceId) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No hay una sesión activa');
    }

    final snapshot = await _firestore
        .collection('conversations')
        .where('serviceId', isEqualTo: serviceId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception('No se encontró la conversación del servicio');
    }

    final conversation = snapshot.docs.first;

    final data = conversation.data();

    final participantIds = List<String>.from(
      data['participantIds'] as List? ?? const [],
    );

    if (!participantIds.contains(user.uid)) {
      throw Exception('No perteneces a esta conversación');
    }

    return conversation.id;
  }

  Stream<List<ChatMessage>> getMessages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map(ChatMessage.fromFirestore).toList();
        });
  }

  Future<void> sendMessage({
    required String conversationId,
    required String text,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No hay una sesión activa');
    }

    final message = text.trim();

    if (message.isEmpty) {
      return;
    }

    final conversationReference = _firestore
        .collection('conversations')
        .doc(conversationId);

    final messageReference = conversationReference.collection('messages').doc();

    final batch = _firestore.batch();

    batch.set(messageReference, {
      'senderId': user.uid,
      'text': message,
      'createdAt': FieldValue.serverTimestamp(),
      'read': false,
    });

    batch.update(conversationReference, {
      'lastMessage': message,
      'lastMessageAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}
