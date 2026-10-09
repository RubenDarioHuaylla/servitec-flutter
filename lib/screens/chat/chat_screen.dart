import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/chat_message.dart';
import '../../services/chat_service.dart';
import '../../widgets/chat_message_bubble.dart';
import '../../services/user_service.dart';

class ChatScreen extends StatefulWidget {
  final String serviceId;

  const ChatScreen({super.key, required this.serviceId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _messageController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  String? _conversationId;

  bool _isLoading = true;
  bool _isSending = false;

  String? _errorMessage;

  final UserService _userService = UserService();
  final Map<String, String> _userNames = {};

  @override
  void initState() {
    super.initState();

    _loadConversation();
  }

  Future<String> _getUserName(String userId) async {
    if (_userNames.containsKey(userId)) {
      return _userNames[userId]!;
    }

    final name = await _userService.getUserName(userId);

    _userNames[userId] = name;

    return name;
  }

  Future<void> _loadConversation() async {
    try {
      final conversationId = await _chatService.getConversationIdByServiceId(
        widget.serviceId,
      );

      if (!mounted) return;

      setState(() {
        _conversationId = conversationId;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final conversationId = _conversationId;

    if (conversationId == null) {
      return;
    }

    final text = _messageController.text.trim();

    if (text.isEmpty) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      await _chatService.sendMessage(
        conversationId: conversationId,
        text: text,
      );

      _messageController.clear();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(content: Text('No se pudo enviar el mensaje: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'No se pudo abrir el chat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadConversation,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final conversationId = _conversationId;

    if (conversationId == null) {
      return const Center(child: Text('No se encontró la conversación'));
    }

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<ChatMessage>>(
            stream: _chatService.getMessages(conversationId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error al cargar mensajes: '
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final messages = snapshot.data ?? [];

              if (messages.isEmpty) {
                return _buildEmptyChat();
              }

              return ListView.builder(
                controller: _scrollController,
                reverse: true,
                padding: const EdgeInsets.all(12),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];

                  final currentUser = _auth.currentUser;

                  final isMine =
                      currentUser != null &&
                      message.senderId == currentUser.uid;

                  return FutureBuilder<String>(
                    future: _getUserName(message.senderId),
                    builder: (context, nameSnapshot) {
                      final senderName = nameSnapshot.data ?? '';

                      return ChatMessageBubble(
                        message: message,
                        isMine: isMine,
                        senderName: senderName,
                      );
                    },
                  );
                },
              );
            },
          ),
        ),

        _buildMessageInput(),
      ],
    );
  }

  Widget _buildEmptyChat() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline, size: 70, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Todavía no hay mensajes',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              'Envía un mensaje para '
              'iniciar la conversación.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                minLines: 1,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            const SizedBox(width: 8),

            IconButton.filled(
              onPressed: _isSending ? null : _sendMessage,
              icon: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
