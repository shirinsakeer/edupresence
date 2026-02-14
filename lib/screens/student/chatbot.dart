import 'package:edupresence/providers/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
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
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('EduAI Assistant'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            tooltip: "Clear Chat",
            onPressed: () => chatProvider.clearChat(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: chatProvider.messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 20),
                    itemCount: chatProvider.messages.length,
                    itemBuilder: (context, index) {
                      final msg = chatProvider.messages[index];
                      final isUser = msg['role'] == 'user';
                      return _buildMessageBubble(msg['text'] ?? '', isUser);
                    },
                  ),
          ),
          if (chatProvider.isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 12,
                    width: 12,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Color(0xFF94A3B8)),
                  ),
                  const SizedBox(width: 8),
                  Text("Gemini is thinking...",
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          _buildInputArea(chatProvider),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Hero(
            tag: 'ai_icon',
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1A56BE).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  size: 48, color: Color(0xFF1A56BE)),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "EduPresence Intelligence",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              "I can help you analyze attendance, suggest study plans, or answer app questions!",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String content, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF1A56BE) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
          boxShadow: [
            if (isUser)
              BoxShadow(
                color: const Color(0xFF1A56BE).withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
          ],
        ),
        child: Text(
          content,
          style: TextStyle(
            color: isUser ? Colors.white : const Color(0xFF334155),
            fontWeight: isUser ? FontWeight.w600 : FontWeight.w500,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(ChatProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: "Ask anything...",
                hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      const BorderSide(color: Color(0xFF1A56BE), width: 1.5),
                ),
              ),
              onSubmitted: (v) {
                if (v.trim().isNotEmpty) {
                  provider.sendMessage(v);
                  _controller.clear();
                  _scrollToBottom();
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              if (_controller.text.trim().isNotEmpty) {
                provider.sendMessage(_controller.text);
                _controller.clear();
                _scrollToBottom();
              }
            },
            child: Container(
              height: 52,
              width: 52,
              decoration: const BoxDecoration(
                color: Color(0xFF1A56BE),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.send_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
