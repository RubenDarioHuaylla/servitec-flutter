import 'package:flutter/material.dart';

import '../models/chat_message.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMine;
  final String senderName;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    required this.senderName,
  });

  @override
  Widget build(BuildContext context) {
    final initial = senderName.isNotEmpty
        ? senderName.trim()[0].toUpperCase()
        : '?';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisAlignment: isMine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Inicial solamente para el otro usuario
          if (!isMine) ...[
            CircleAvatar(
              radius: 16,
              child: Text(
                initial,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(width: 8),
          ],

          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMine
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message.text),

                  const SizedBox(height: 4),

                  Text(
                    _formatTime(message.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? date) {
    if (date == null) return '';

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }
}
