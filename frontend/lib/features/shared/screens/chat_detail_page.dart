import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/services/chat_service.dart';
import 'package:frontend/features/shared/widgets/typing_indicator.dart' show TypingBubble;

class ChatDetailPage extends StatefulWidget {
  final String chatId;
  final String name;
  final String image;
  final String recipientId;

  const ChatDetailPage({
    super.key,
    required this.chatId,
    required this.name,
    required this.image,
    required this.recipientId,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _currentUserId;
  Timer? _typingTimer;
  Timer? _hideTypingTimer;
  bool _isTyping = false;
  bool _otherUserTyping = false;
  DateTime? _lastTypingEvent;
  StreamSubscription? _typingSubscription;

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _currentUserId = ChatService.getCurrentUserId();
    ChatService.markMessagesAsRead(widget.chatId);
    _listenToTypingStatus();
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _hideTypingTimer?.cancel();
    _typingSubscription?.cancel();
    // Set typing to false when leaving
    ChatService.setTyping(widget.chatId, false);
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _listenToTypingStatus() {
    _typingSubscription = ChatService.getTypingStream(widget.chatId).listen((typingStatus) {
      if (!mounted) return;

      final otherStatus = typingStatus[widget.recipientId];
      final now = DateTime.now();

      if (otherStatus == true) {
        _lastTypingEvent = now;
        _hideTypingTimer?.cancel();
        if (!_otherUserTyping) {
          setState(() => _otherUserTyping = true);
        }
        return;
      }

      // Grace: keep visible up to 1200ms after last true event
      if (_lastTypingEvent == null) {
        if (_otherUserTyping) setState(() => _otherUserTyping = false);
        return;
      }

      final elapsed = now.difference(_lastTypingEvent!).inMilliseconds;
      if (elapsed < 1200) {
        _hideTypingTimer?.cancel();
        _hideTypingTimer = Timer(Duration(milliseconds: 1200 - elapsed), () {
          if (!mounted) return;
          if (_otherUserTyping) setState(() => _otherUserTyping = false);
        });
        if (!_otherUserTyping) {
          setState(() => _otherUserTyping = true);
        }
      } else {
        _hideTypingTimer?.cancel();
        if (_otherUserTyping) setState(() => _otherUserTyping = false);
      }
    });
  }

  void _onTextChanged(String text) {
    if (text.isNotEmpty && !_isTyping) {
      _isTyping = true;
      ChatService.setTyping(widget.chatId, true);
    }

    // Reset timer on every keystroke
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (_isTyping) {
        _isTyping = false;
        ChatService.setTyping(widget.chatId, false);
      }
    });
  }

  void sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    _msgController.clear();
    
    // Stop typing indicator
    _typingTimer?.cancel();
    if (_isTyping) {
      _isTyping = false;
      ChatService.setTyping(widget.chatId, false);
    }

    await ChatService.sendMessage(
      chatId: widget.chatId,
      text: text,
      recipientId: widget.recipientId,
      recipientName: widget.name,
      recipientImage: widget.image,
    );

    scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(backgroundImage: AssetImage(widget.image)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  "Online",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: ChatService.getMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data?.docs ?? [];
                
                if (messages.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    scrollToBottom();
                    // Mark messages as read whenever stream updates
                    ChatService.markMessagesAsRead(widget.chatId);
                  });
                }

                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada pesan',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  );
                }

                const bottomPadding = TypingBubble.totalHeight + 16;

                return Stack(
                  children: [
                    ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10).copyWith(bottom: bottomPadding),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final doc = messages[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final fromMe = data['senderId'] == _currentUserId;
                        final text = data['text'] ?? '';
                        final read = data['read'] ?? false;

                    return Align(
                      alignment: fromMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 14,
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: fromMe
                              ? AppColors.chatBubbleSent
                              : AppColors.chatBubbleReceived,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(18),
                            topRight: const Radius.circular(18),
                            bottomLeft: Radius.circular(fromMe ? 18 : 0),
                            bottomRight: Radius.circular(fromMe ? 0 : 18),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Text(
                                text,
                                style: const TextStyle(fontSize: 15, height: 1.3),
                              ),
                            ),

                            if (fromMe) ...[
                              const SizedBox(width: 6),
                              Icon(
                                Icons.done_all,
                                size: 18,
                                color: read
                                    ? AppColors.info
                                    : AppColors.textSecondary,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                      },
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 6,
                      child: IgnorePointer(
                        child: Visibility(
                          visible: true,
                          maintainAnimation: true,
                          maintainState: true,
                          maintainSize: true,
                          child: AnimatedOpacity(
                            opacity: _otherUserTyping ? 1 : 0,
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeInOut,
                            child: const TypingBubble(key: ValueKey('typing-bubble')),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.chatInputBackground,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.chatInputField,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.attach_file,
                          size: 22,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _msgController,
                            onChanged: _onTextChanged,
                            decoration: const InputDecoration(
                              hintText: "Balasan",
                              hintStyle: TextStyle(
                                color: AppColors.textLight,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: sendMessage,
                  child: const CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.send, color: AppColors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
