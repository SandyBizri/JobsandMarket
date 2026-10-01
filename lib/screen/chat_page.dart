// lib/screen/chat_page.dart
/*import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  final String sellerName;
  final String buyerName;
  final Map<String, dynamic> product;

  const ChatPage({
    super.key,
    required this.sellerName,
    required this.buyerName,
    required this.product,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final String _chatGroupId;
  late final String _currentUserName;

  @override
  void initState() {
    super.initState();
    _currentUserName = widget.buyerName;

    final names = [widget.buyerName, widget.sellerName]..sort();
    final productSlug = (widget.product['title'] ?? 'item')
        .toString()
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');

    _chatGroupId = '${names.join('_')}__$productSlug';
    debugPrint('>>> chatGroupId: $_chatGroupId');
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();

    final receiverName = _currentUserName == widget.buyerName
        ? widget.sellerName
        : widget.buyerName;

    try {
      await FirebaseFirestore.instance.collection('chats').add({
        'chatGroupId':  _chatGroupId,
        'text':         text,
        'senderName':   _currentUserName,
        'receiverName': receiverName,
        'productTitle': widget.product['title'] ?? '',
        'timestamp':    FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Send error: $e');
    }
  }

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

  String _formatTime(Timestamp? ts) {
    if (ts == null) return '';
    final dt = ts.toDate().toLocal();
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF4A90E2).withValues(alpha: .15),
              child: Text(
                widget.sellerName.isNotEmpty
                    ? widget.sellerName[0].toUpperCase()
                    : 'S',
                style: const TextStyle(
                    color: Color(0xFF4A90E2), fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.sellerName,
                      style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                  Text(widget.product['title'] ?? '',
                      style:
                          TextStyle(color: Colors.grey[600], fontSize: 12),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _ProductBanner(product: widget.product),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // ✅ NO orderBy — sorted in Dart below
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .where('chatGroupId', isEqualTo: _chatGroupId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  debugPrint('Stream error: ${snapshot.error}');
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                // ✅ Sort by timestamp in Dart
                final docs = (snapshot.data?.docs ?? []).toList()
                  ..sort((a, b) {
                    final aT = (a.data() as Map)['timestamp'] as Timestamp?;
                    final bT = (b.data() as Map)['timestamp'] as Timestamp?;
                    if (aT == null && bT == null) return 0;
                    if (aT == null) return -1;
                    if (bT == null) return 1;
                    return aT.compareTo(bT);
                  });

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 56, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text('No messages yet. Say hi! 👋',
                            style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  );
                }

                _scrollToBottom();

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  itemCount: docs.length,
                  itemBuilder: (_, index) {
                    final data =
                        docs[index].data() as Map<String, dynamic>;
                    final isMe = data['senderName'] == _currentUserName;
                    return _ChatBubble(
                      text:       data['text']       ?? '',
                      isMe:       isMe,
                      senderName: data['senderName'] ?? '',
                      time: _formatTime(data['timestamp'] as Timestamp?),
                    );
                  },
                );
              },
            ),
          ),
          _MessageInputBar(
            controller: _messageController,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Product Banner
// ─────────────────────────────────────────────────────────────────────────────
class _ProductBanner extends StatelessWidget {
  final Map<String, dynamic> product;
  const _ProductBanner({required this.product});

  @override
  Widget build(BuildContext context) {
    final imageUrl = product['imageUrl'] ?? '';
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildImage(imageUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['title'] ?? 'Product',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                if (product['price'] != null)
                  Text('\$${product['price']}',
                      style: const TextStyle(
                          color: Color(0xFF4A90E2),
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.isEmpty) return _placeholder();
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(imageUrl,
          width: 52, height: 52, fit: BoxFit.cover,
          loadingBuilder: (_, child, progress) =>
              progress == null ? child : _placeholder(),
          errorBuilder: (_, __, ___) => _placeholder());
    }
    try {
      return Image.memory(base64Decode(imageUrl),
          width: 52, height: 52, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder());
    } catch (_) {
      return _placeholder();
    }
  }

  Widget _placeholder() => Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8)),
        child: const Icon(Icons.image, color: Colors.grey));
}

// ─────────────────────────────────────────────────────────────────────────────
// Chat Bubble
// ─────────────────────────────────────────────────────────────────────────────
class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final String senderName;
  final String time;

  const _ChatBubble({
    required this.text,
    required this.isMe,
    required this.senderName,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: Colors.grey[300],
              child: Text(
                senderName.isNotEmpty ? senderName[0].toUpperCase() : '?',
                style:
                    const TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFF4A90E2) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: .06),
                          blurRadius: 4,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: Text(text,
                      style: TextStyle(
                          color: isMe ? Colors.white : Colors.black87,
                          fontSize: 14)),
                ),
                const SizedBox(height: 2),
                Text(time,
                    style:
                        TextStyle(color: Colors.grey[500], fontSize: 11)),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 6),
            CircleAvatar(
              radius: 14,
              backgroundColor:
                  const Color(0xFF4A90E2).withValues(alpha: .15),
              child: Text(
                senderName.isNotEmpty ? senderName[0].toUpperCase() : 'M',
                style: const TextStyle(
                    fontSize: 11, color: Color(0xFF4A90E2)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Message Input Bar
// ─────────────────────────────────────────────────────────────────────────────
class _MessageInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _MessageInputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => onSend(),
                maxLines: 4,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: const Color(0xFFF0F2F5),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: const Color(0xFF4A90E2),
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: onSend,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.send_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/
// lib/screen/chat_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  final String sellerName;
  final String buyerName;
  final String currentUserName; // ← ADDED: who is actually using the app right now
  final Map<String, dynamic> product;

  const ChatPage({
    super.key,
    required this.sellerName,
    required this.buyerName,
    required this.currentUserName, // ← ADDED
    required this.product,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final String _chatGroupId;
  late final String _currentUserName;

  @override
  void initState() {
    super.initState();
    _currentUserName = widget.currentUserName; // ← FIXED: was widget.buyerName

    final names = [widget.buyerName, widget.sellerName]..sort();
    final productSlug = (widget.product['title'] ?? 'item')
        .toString()
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');

    _chatGroupId = '${names.join('_')}__$productSlug';
    debugPrint('>>> chatGroupId: $_chatGroupId');
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();

    // ← FIXED: correctly resolves receiver based on who the current user actually is
    final receiverName = _currentUserName == widget.buyerName
        ? widget.sellerName
        : widget.buyerName;

    try {
      await FirebaseFirestore.instance.collection('chats').add({
        'chatGroupId':  _chatGroupId,
        'text':         text,
        'senderName':   _currentUserName,
        'receiverName': receiverName,
        'productTitle': widget.product['title'] ?? '',
        'productImage': widget.product['imageUrl'] ?? '',
        'timestamp':    FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Send error: $e');
    }
  }

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

  String _formatTime(Timestamp? ts) {
    if (ts == null) return '';
    final dt = ts.toDate().toLocal();
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF4A90E2).withValues(alpha: .15),
              child: Text(
                widget.sellerName.isNotEmpty
                    ? widget.sellerName[0].toUpperCase()
                    : 'S',
                style: const TextStyle(
                    color: Color(0xFF4A90E2), fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.sellerName,
                      style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                  Text(widget.product['title'] ?? '',
                      style:
                          TextStyle(color: Colors.grey[600], fontSize: 12),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _ProductBanner(product: widget.product),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .where('chatGroupId', isEqualTo: _chatGroupId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  debugPrint('Stream error: ${snapshot.error}');
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final docs = (snapshot.data?.docs ?? []).toList()
                  ..sort((a, b) {
                    final aT = (a.data() as Map)['timestamp'] as Timestamp?;
                    final bT = (b.data() as Map)['timestamp'] as Timestamp?;
                    if (aT == null && bT == null) return 0;
                    if (aT == null) return -1;
                    if (bT == null) return 1;
                    return aT.compareTo(bT);
                  });

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 56, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text('No messages yet. Say hi! 👋',
                            style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  );
                }

                _scrollToBottom();

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  itemCount: docs.length,
                  itemBuilder: (_, index) {
                    final data =
                        docs[index].data() as Map<String, dynamic>;
                    final isMe = data['senderName'] == _currentUserName;
                    return _ChatBubble(
                      text:       data['text']       ?? '',
                      isMe:       isMe,
                      senderName: data['senderName'] ?? '',
                      time: _formatTime(data['timestamp'] as Timestamp?),
                    );
                  },
                );
              },
            ),
          ),
          _MessageInputBar(
            controller: _messageController,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Product Banner
// ─────────────────────────────────────────────────────────────────────────────
class _ProductBanner extends StatelessWidget {
  final Map<String, dynamic> product;
  const _ProductBanner({required this.product});

  @override
  Widget build(BuildContext context) {
    final imageUrl = product['imageUrl'] ?? '';
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildImage(imageUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['title'] ?? 'Product',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                if (product['price'] != null)
                  Text('\$${product['price']}',
                      style: const TextStyle(
                          color: Color(0xFF4A90E2),
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.isEmpty) return _placeholder();
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(imageUrl,
          width: 52, height: 52, fit: BoxFit.cover,
          loadingBuilder: (_, child, progress) =>
              progress == null ? child : _placeholder(),
          errorBuilder: (_, __, ___) => _placeholder());
    }
    try {
      return Image.memory(base64Decode(imageUrl),
          width: 52, height: 52, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder());
    } catch (_) {
      return _placeholder();
    }
  }

  Widget _placeholder() => Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8)),
        child: const Icon(Icons.image, color: Colors.grey));
}

// ─────────────────────────────────────────────────────────────────────────────
// Chat Bubble
// ─────────────────────────────────────────────────────────────────────────────
class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final String senderName;
  final String time;

  const _ChatBubble({
    required this.text,
    required this.isMe,
    required this.senderName,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: Colors.grey[300],
              child: Text(
                senderName.isNotEmpty ? senderName[0].toUpperCase() : '?',
                style:
                    const TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFF4A90E2) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: .06),
                          blurRadius: 4,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: Text(text,
                      style: TextStyle(
                          color: isMe ? Colors.white : Colors.black87,
                          fontSize: 14)),
                ),
                const SizedBox(height: 2),
                Text(time,
                    style:
                        TextStyle(color: Colors.grey[500], fontSize: 11)),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 6),
            CircleAvatar(
              radius: 14,
              backgroundColor:
                  const Color(0xFF4A90E2).withValues(alpha: .15),
              child: Text(
                senderName.isNotEmpty ? senderName[0].toUpperCase() : 'M',
                style: const TextStyle(
                    fontSize: 11, color: Color(0xFF4A90E2)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Message Input Bar
// ─────────────────────────────────────────────────────────────────────────────
class _MessageInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _MessageInputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => onSend(),
                maxLines: 4,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: const Color(0xFFF0F2F5),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: const Color(0xFF4A90E2),
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: onSend,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.send_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}