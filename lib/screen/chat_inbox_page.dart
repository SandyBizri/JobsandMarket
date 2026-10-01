// lib/screen/chat_inbox_page.dart
/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_page.dart';

class ChatInboxPage extends StatefulWidget {
  final String currentUserName;
  const ChatInboxPage({super.key, required this.currentUserName});

  @override
  State<ChatInboxPage> createState() => _ChatInboxPageState();
}

class _ChatInboxPageState extends State<ChatInboxPage> {

  Stream<List<Map<String, dynamic>>> _inboxStream() {
    final fs = FirebaseFirestore.instance;

    // ✅ NO orderBy on either query — sorted in Dart below
    final sentStream = fs
        .collection('chats')
        .where('senderName', isEqualTo: widget.currentUserName)
        .snapshots();

    return sentStream.asyncMap((sentSnap) async {
      // ✅ NO orderBy
      final receivedSnap = await fs
          .collection('chats')
          .where('receiverName', isEqualTo: widget.currentUserName)
          .get();

      final allDocs = [...sentSnap.docs, ...receivedSnap.docs];
      final Map<String, Map<String, dynamic>> convMap = {};

      for (final doc in allDocs) {
        final data         = doc.data();
        final groupId      = data['chatGroupId']  as String? ?? '';
        if (groupId.isEmpty) continue;

        final senderName   = data['senderName']   as String? ?? '';
        final receiverName = data['receiverName'] as String? ?? '';
        final partner = senderName == widget.currentUserName
            ? receiverName
            : senderName;
        if (partner.isEmpty) continue;

        final ts           = data['timestamp']    as Timestamp?;
        final text         = data['text']         as String? ?? '';
        final productTitle = data['productTitle'] as String? ?? '';

        final existingTs = convMap[groupId]?['lastTimestamp'] as Timestamp?;
        if (!convMap.containsKey(groupId) ||
            (ts != null &&
                (existingTs == null || ts.compareTo(existingTs) > 0))) {
          convMap[groupId] = {
            'chatGroupId':   groupId,
            'partnerName':   partner,
            'lastMessage':   text,
            'lastTimestamp': ts,
            'productTitle':  productTitle,
          };
        }
      }

      // ✅ Sort in Dart
      return convMap.values.toList()
        ..sort((a, b) {
          final aT = a['lastTimestamp'] as Timestamp?;
          final bT = b['lastTimestamp'] as Timestamp?;
          if (aT == null && bT == null) return 0;
          if (aT == null) return 1;
          if (bT == null) return -1;
          return bT.compareTo(aT);
        });
    });
  }

  String _formatTime(Timestamp? ts) {
    if (ts == null) return '';
    final dt = ts.toDate().toLocal();
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text('My Messages',
            style: TextStyle(
                color: Color(0xFF2C3E50), fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF2C3E50)),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _inboxStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final conversations = snapshot.data ?? [];

          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined,
                      size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text('No conversations yet',
                      style: TextStyle(
                          color: Colors.grey[500], fontSize: 16)),
                  const SizedBox(height: 6),
                  Text('Start chatting from any product listing',
                      style: TextStyle(
                          color: Colors.grey[400], fontSize: 13)),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: conversations.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              final conv         = conversations[index];
              final partner      = conv['partnerName']   as String? ?? 'Unknown';
              final lastMsg      = conv['lastMessage']   as String? ?? '';
              final lastTs       = conv['lastTimestamp'] as Timestamp?;
              final productTitle = conv['productTitle']  as String? ?? '';

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor:
                      const Color(0xFF4A90E2).withValues(alpha: .15),
                  child: Text(
                    partner.isNotEmpty ? partner[0].toUpperCase() : '?',
                    style: const TextStyle(
                        color: Color(0xFF4A90E2),
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(partner,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Color(0xFF2C3E50))),
                    Text(_formatTime(lastTs),
                        style: TextStyle(
                            color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (productTitle.isNotEmpty)
                      Text(productTitle,
                          style: const TextStyle(
                              color: Color(0xFF4A90E2),
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    Text(
                      lastMsg.isNotEmpty
                          ? lastMsg
                          : 'Tap to view conversation',
                      style: TextStyle(
                          color: Colors.grey[600], fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                trailing:
                    const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(
                        buyerName:  widget.currentUserName,
                        sellerName: partner,
                        product: {
                          'title':    productTitle,
                          'imageUrl': '',
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}*/
// lib/screen/chat_inbox_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_page.dart';

class ChatInboxPage extends StatefulWidget {
  final String currentUserName;
  const ChatInboxPage({super.key, required this.currentUserName});

  @override
  State<ChatInboxPage> createState() => _ChatInboxPageState();
}

class _ChatInboxPageState extends State<ChatInboxPage> {

  Stream<List<Map<String, dynamic>>> _inboxStream() {
    final fs = FirebaseFirestore.instance;

    final sentStream = fs
        .collection('chats')
        .where('senderName', isEqualTo: widget.currentUserName)
        .snapshots();

    return sentStream.asyncMap((sentSnap) async {
      final receivedSnap = await fs
          .collection('chats')
          .where('receiverName', isEqualTo: widget.currentUserName)
          .get();

      final allDocs = [...sentSnap.docs, ...receivedSnap.docs];
      final Map<String, Map<String, dynamic>> convMap = {};

      for (final doc in allDocs) {
        final data         = doc.data();
        final groupId      = data['chatGroupId']  as String? ?? '';
        if (groupId.isEmpty) continue;

        final senderName   = data['senderName']   as String? ?? '';
        final receiverName = data['receiverName'] as String? ?? '';

        // ← Determine who the "partner" is (the other person in the conversation)
        final partner = senderName == widget.currentUserName
            ? receiverName
            : senderName;
        if (partner.isEmpty) continue;

        final ts           = data['timestamp']    as Timestamp?;
        final text         = data['text']         as String? ?? '';
        final productTitle = data['productTitle'] as String? ?? '';

        final existingTs = convMap[groupId]?['lastTimestamp'] as Timestamp?;
        if (!convMap.containsKey(groupId) ||
            (ts != null &&
                (existingTs == null || ts.compareTo(existingTs) > 0))) {
          convMap[groupId] = {
            'chatGroupId':   groupId,
            'partnerName':   partner,
            'lastMessage':   text,
            'lastTimestamp': ts,
            'productTitle':  productTitle,
            'productImage':  data['productImage'] as String? ?? '',
            'buyerName':     senderName == widget.currentUserName ? widget.currentUserName : partner,
            'sellerName':    senderName == widget.currentUserName ? partner : widget.currentUserName,
          };
        }
      }

      return convMap.values.toList()
        ..sort((a, b) {
          final aT = a['lastTimestamp'] as Timestamp?;
          final bT = b['lastTimestamp'] as Timestamp?;
          if (aT == null && bT == null) return 0;
          if (aT == null) return 1;
          if (bT == null) return -1;
          return bT.compareTo(aT);
        });
    });
  }

  String _formatTime(Timestamp? ts) {
    if (ts == null) return '';
    final dt = ts.toDate().toLocal();
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text('My Messages',
            style: TextStyle(
                color: Color(0xFF2C3E50), fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF2C3E50)),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _inboxStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final conversations = snapshot.data ?? [];

          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined,
                      size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text('No conversations yet',
                      style: TextStyle(
                          color: Colors.grey[500], fontSize: 16)),
                  const SizedBox(height: 6),
                  Text('Start chatting from any product listing',
                      style: TextStyle(
                          color: Colors.grey[400], fontSize: 13)),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: conversations.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              final conv         = conversations[index];
              final partner      = conv['partnerName']   as String? ?? 'Unknown';
              final lastMsg      = conv['lastMessage']   as String? ?? '';
              final lastTs       = conv['lastTimestamp'] as Timestamp?;
              final productTitle = conv['productTitle']  as String? ?? '';
              final buyerName    = conv['buyerName']     as String? ?? widget.currentUserName;
              final sellerName   = conv['sellerName']    as String? ?? partner;

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor:
                      const Color(0xFF4A90E2).withValues(alpha: .15),
                  child: Text(
                    partner.isNotEmpty ? partner[0].toUpperCase() : '?',
                    style: const TextStyle(
                        color: Color(0xFF4A90E2),
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(partner,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Color(0xFF2C3E50))),
                    Text(_formatTime(lastTs),
                        style: TextStyle(
                            color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (productTitle.isNotEmpty)
                      Text(productTitle,
                          style: const TextStyle(
                              color: Color(0xFF4A90E2),
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    Text(
                      lastMsg.isNotEmpty
                          ? lastMsg
                          : 'Tap to view conversation',
                      style: TextStyle(
                          color: Colors.grey[600], fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                trailing:
                    const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(
                        currentUserName: widget.currentUserName, // ← ADDED: pass who is logged in
                        buyerName:       buyerName,              // ← FIXED: correct buyer
                        sellerName:      sellerName,             // ← FIXED: correct seller
                        product: {
                          'title':    productTitle,
                          'imageUrl': conv['productImage'] as String? ?? '',
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}