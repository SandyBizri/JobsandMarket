/*import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;
import 'package:url_launcher/url_launcher.dart';
import 'chat_page.dart';
import 'seller_session.dart';

const String _firestoreUrl =
    'https://firestore.googleapis.com/v1/projects/marketplaneproducts/databases/(default)/documents';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Map<String, dynamic> _product;
  bool _deleting  = false;
  bool _isOwner   = false;
  String? _ownerName;
  String _buyerName = 'Guest User';

  @override
  void initState() {
    super.initState();
    _product = Map<String, dynamic>.from(widget.product);
    _checkOwnership();
    _loadBuyerName();
  }

  Future<void> _loadBuyerName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('buyer_name');
    if (name != null && name.trim().isNotEmpty && mounted) {
      setState(() => _buyerName = name.trim());
    }
  }

  Future<void> _checkOwnership() async {
    final owned = await SellerSession.isOwnerOf(_product);
    if (owned && mounted) {
      final name = await SellerSession.getSellerName();
      setState(() {
        _isOwner  = true;
        _ownerName = name;
      });
    }
  }

  bool _guard() {
    if (!_isOwner) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Only the seller can manage this listing."),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
      return false;
    }
    return true;
  }

  // ── Delete photo from Supabase Storage ──────────────────────────────────
  Future<void> _deleteSupabasePhoto(String imageUrl) async {
    if (imageUrl.isEmpty) return;
    try {
      final uri = Uri.parse(imageUrl);
      final segments = uri.pathSegments;
      // URL pattern: .../storage/v1/object/public/BUCKET/FILENAME
      final publicIndex = segments.indexOf('public');
      if (publicIndex != -1 && publicIndex + 2 <= segments.length) {
        final bucket   = segments[publicIndex + 1];
        final fileName = segments.sublist(publicIndex + 2).join('/');
        await Supabase.instance.client.storage.from(bucket).remove([fileName]);
        debugPrint('Supabase photo deleted: $bucket/$fileName');
      }
    } catch (e) {
      debugPrint('Supabase photo delete error: $e');
      // Non-fatal: continue with Firestore deletion even if photo delete fails
    }
  }

  Future<void> _deleteItem() async {
    if (!_guard()) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete Listing"),
        content: const Text("Are you sure? This cannot be undone."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _deleting = true);
    try {
      // 1. Delete photo from Supabase Storage
      await _deleteSupabasePhoto(_product['imageUrl'] ?? '');

      // 2. Delete document from Firestore
      final response = await http.delete(
          Uri.parse('$_firestoreUrl/products/${_product['id']}'));

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ Listing deleted"),
              backgroundColor: Color(0xFF27AE60),
            ),
          );
          Navigator.pop(context, 'deleted');
        }
      } else {
        throw Exception('Firestore error: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint("Delete error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Delete failed: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _deleting = false);
      }
    }
  }

  Future<void> _editStock() async {
    if (!_guard()) return;

    int tempStock = _product['stock'] ?? 0;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => Padding(
          padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Edit Stock",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () =>
                        set(() => tempStock = (tempStock - 1).clamp(0, 9999)),
                    icon: const Icon(Icons.remove_circle_outline, size: 36),
                    color: tempStock <= 0 ? Colors.grey : Colors.redAccent,
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 80, height: 60, alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: tempStock <= 0
                          ? Colors.red.shade50
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: tempStock <= 0
                              ? Colors.red
                              : Colors.grey.shade300),
                    ),
                    child: Text("$tempStock",
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: tempStock <= 0 ? Colors.red : Colors.black)),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: () =>
                        set(() => tempStock = (tempStock + 1).clamp(0, 9999)),
                    icon: const Icon(Icons.add_circle_outline, size: 36),
                    color: const Color(0xFF27AE60),
                  ),
                ],
              ),
              if (tempStock <= 0)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text("⚠️ Item will be hidden from marketplace",
                      style: TextStyle(color: Colors.red, fontSize: 13)),
                ),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await http.patch(
                        Uri.parse(
                            '$_firestoreUrl/products/${_product['id']}?updateMask.fieldPaths=stock'),
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode({
                          'fields': {
                            'stock': {'integerValue': tempStock}
                          }
                        }),
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      setState(() => _product['stock'] = tempStock);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90E2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Save",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _contactWhatsApp(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final uri = Uri.parse('https://wa.me/$cleaned');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Could not open WhatsApp")));
      }
    }
  }

  Future<void> _contactEmail(String email, String title) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'Inquiry about: $title',
        'body':
            'Hi, I am interested in your listing "$title". Is it still available?',
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Could not open email app")));
      }
    }
  }

  void _showContactSheet() {
    final phone      = _product['sellerPhone'] ?? '';
    final email      = _product['sellerEmail'] ?? '';
    final sellerName = _product['sellerName']  ?? 'Seller';
    final title      = _product['title']       ?? 'this item';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor:
                      const Color(0xFF4A90E2).withValues(alpha: 0.1),
                  child: const Icon(Icons.store_outlined,
                      color: Color(0xFF4A90E2)),
                ),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text("Contact Seller",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50))),
                  Text(sellerName,
                      style: const TextStyle(fontSize: 13, color: Colors.grey)),
                ]),
              ]),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),

              _contactTile(
                color: const Color(0xFF4A90E2),
                icon: Icons.forum_outlined,
                label: "In-App Chat",
                subtitle: "Chat directly with the seller",
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(
                        currentUserName: _buyerName,
                        product: _product,
                        sellerName: sellerName,
                        buyerName: _buyerName,
                      ),
                    ),
                  );
                },
              ),

              if (phone.isNotEmpty) ...[
                const SizedBox(height: 12),
                _contactTile(
                  color: const Color(0xFF25D366),
                  icon: Icons.chat_outlined,
                  label: "WhatsApp",
                  subtitle: phone,
                  onTap: () {
                    Navigator.pop(ctx);
                    _contactWhatsApp(phone);
                  },
                ),
              ],

              if (email.isNotEmpty) ...[
                const SizedBox(height: 12),
                _contactTile(
                  color: const Color(0xFF4A90E2),
                  icon: Icons.email_outlined,
                  label: "Email",
                  subtitle: email,
                  onTap: () {
                    Navigator.pop(ctx);
                    _contactEmail(email, title);
                  },
                ),
              ],

              if (phone.isEmpty && email.isEmpty)
                const Center(
                    child: Text("No contact info available.",
                        style: TextStyle(color: Colors.grey))),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contactTile({
    required Color color,
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15, color: color)),
              Text(subtitle,
                  style: const TextStyle(fontSize: 13, color: Colors.grey)),
            ]),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ]),
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    return Container(
      color: Colors.grey[100],
      width: double.infinity,
      height: double.infinity,
      child: () {
        if (imageUrl.isEmpty) {
          return const Center(
            child: Icon(Icons.image, size: 80, color: Colors.grey),
          );
        }
        if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
          return Image.network(
            imageUrl,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
            ),
          );
        }
        try {
          return Image.memory(
            base64Decode(imageUrl),
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
          );
        } catch (_) {
          return const Center(
            child: Icon(Icons.image, size: 80, color: Colors.grey),
          );
        }
      }(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String imageUrl    = _product['imageUrl']    ?? '';
    final int    stock       = _product['stock']       ?? 0;
    final String title       = _product['title']       ?? 'Untitled';
    final String price       = _product['price']       ?? '0';
    final String description = _product['description'] ?? '';
    final String condition   = _product['condition']   ?? '';
    final String category    = _product['category']    ?? '';
    final String subCategory = _product['subCategory'] ?? '';
    final String sellerName  = _product['sellerName']  ?? '';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8)],
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
            actions: [
              if (_isOwner)
                GestureDetector(
                  onTap: _deleteItem,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8)],
                    ),
                    child: _deleting
                        ? const SizedBox(width: 20, height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.red))
                        : const Icon(Icons.delete_outline,
                            color: Colors.red, size: 22),
                  ),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImage(imageUrl),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                if (_isOwner)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    color: const Color(0xFF27AE60).withValues(alpha: 0.1),
                    child: Row(children: [
                      const Icon(Icons.verified_user_outlined,
                          size: 16, color: Color(0xFF27AE60)),
                      const SizedBox(width: 8),
                      Text(
                        "Managing as $_ownerName",
                        style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF27AE60),
                            fontWeight: FontWeight.w500),
                      ),
                    ]),
                  ),

                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (category.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A90E2)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            subCategory.isNotEmpty
                                ? "$category › $subCategory"
                                : category,
                            style: const TextStyle(
                                color: Color(0xFF4A90E2),
                                fontWeight: FontWeight.w600,
                                fontSize: 12),
                          ),
                        ),
                      Text(title,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50))),
                      const SizedBox(height: 8),
                      Row(children: [
                        Text("\$$price",
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4A90E2))),
                        const Spacer(),
                        GestureDetector(
                          onTap: _isOwner ? _editStock : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: stock <= 0
                                  ? Colors.red.withValues(alpha: 0.1)
                                  : const Color(0xFF27AE60)
                                      .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: stock <= 0
                                      ? Colors.red
                                      : const Color(0xFF27AE60)),
                            ),
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.inventory_2_outlined,
                                      size: 14,
                                      color: stock <= 0
                                          ? Colors.red
                                          : const Color(0xFF27AE60)),
                                  const SizedBox(width: 4),
                                  Text(
                                      stock <= 0
                                          ? "Out of stock"
                                          : "$stock in stock",
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: stock <= 0
                                              ? Colors.red
                                              : const Color(0xFF27AE60))),
                                  if (_isOwner) ...[
                                    const SizedBox(width: 4),
                                    Icon(Icons.edit_outlined,
                                        size: 12,
                                        color: stock <= 0
                                            ? Colors.red
                                            : const Color(0xFF27AE60)),
                                  ],
                                ]),
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                if (sellerName.isNotEmpty)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Row(children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor:
                            const Color(0xFF4A90E2).withValues(alpha: 0.1),
                        child: const Icon(Icons.store_outlined,
                            color: Color(0xFF4A90E2), size: 22),
                      ),
                      const SizedBox(width: 14),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Sold by",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                            Text(sellerName,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2C3E50))),
                          ]),
                      const Spacer(),
                      if (!_isOwner)
                        GestureDetector(
                          onTap: _showContactSheet,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A90E2)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: const Color(0xFF4A90E2)
                                      .withValues(alpha: 0.4)),
                            ),
                            child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.message_outlined,
                                      size: 14, color: Color(0xFF4A90E2)),
                                  SizedBox(width: 4),
                                  Text("Contact",
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF4A90E2))),
                                ]),
                          ),
                        ),
                    ]),
                  ),

                const SizedBox(height: 10),

                if (condition.isNotEmpty)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Row(children: [
                      Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A90E2)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.star_outline,
                            color: Color(0xFF4A90E2), size: 22),
                      ),
                      const SizedBox(width: 14),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Condition",
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey)),
                            Text(condition,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2C3E50))),
                          ]),
                    ]),
                  ),

                const SizedBox(height: 10),

                if (description.isNotEmpty)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Description",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50))),
                        const SizedBox(height: 10),
                        Text(description,
                            style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                height: 1.6)),
                      ],
                    ),
                  ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -4))],
        ),
        child: _isOwner
            ? Row(children: [
                OutlinedButton.icon(
                  onPressed: _editStock,
                  icon: const Icon(Icons.inventory_2_outlined, size: 16),
                  label: const Text("Edit Stock"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4A90E2),
                    side: const BorderSide(color: Color(0xFF4A90E2)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _deleting ? null : _deleteItem,
                    icon: _deleting
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.delete_outline, size: 20),
                    label: const Text("Delete Listing",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
              ])
            : ElevatedButton.icon(
                onPressed: stock <= 0 ? null : _showContactSheet,
                icon: const Icon(Icons.chat_outlined, size: 20),
                label: Text(stock <= 0 ? "Out of Stock" : "Contact Seller",
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
      ),
    );
  }
}*/
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;
import 'package:url_launcher/url_launcher.dart';
import 'chat_page.dart';
import 'seller_session.dart';

const String _firestoreUrl =
    'https://firestore.googleapis.com/v1/projects/marketplaneproducts/databases/(default)/documents';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Map<String, dynamic> _product;
  bool _deleting  = false;
  bool _isOwner   = false;
  String? _ownerName;
  String _buyerName = 'Guest User';

  @override
  void initState() {
    super.initState();
    _product = Map<String, dynamic>.from(widget.product);
    _checkOwnership();
    _loadBuyerName();
  }

  Future<void> _loadBuyerName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('buyer_name');
    if (name != null && name.trim().isNotEmpty && mounted) {
      setState(() => _buyerName = name.trim());
    }
  }

  Future<void> _checkOwnership() async {
    final owned = await SellerSession.isOwnerOf(_product);
    if (owned && mounted) {
      final name = await SellerSession.getSellerName();
      setState(() {
        _isOwner  = true;
        _ownerName = name;
      });
    }
  }

  bool _guard() {
    if (!_isOwner) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Only the seller can manage this listing."),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
      return false;
    }
    return true;
  }

  // ── Delete photo from Supabase Storage ──────────────────────────────────
  Future<void> _deleteSupabasePhoto(String imageUrl) async {
    if (imageUrl.isEmpty) return;
    try {
      final uri = Uri.parse(imageUrl);
      final segments = uri.pathSegments;
      // URL pattern: .../storage/v1/object/public/BUCKET/FILENAME
      final publicIndex = segments.indexOf('public');
      if (publicIndex != -1 && publicIndex + 2 <= segments.length) {
        final bucket   = segments[publicIndex + 1];
        final fileName = segments.sublist(publicIndex + 2).join('/');
        await Supabase.instance.client.storage.from(bucket).remove([fileName]);
        debugPrint('Supabase photo deleted: $bucket/$fileName');
      }
    } catch (e) {
      debugPrint('Supabase photo delete error: $e');
      // Non-fatal: continue with Firestore deletion even if photo delete fails
    }
  }

  Future<void> _deleteItem() async {
    if (!_guard()) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete Listing"),
        content: const Text("Are you sure? This cannot be undone."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _deleting = true);
    try {
      // 1. Delete photo from Supabase Storage
      await _deleteSupabasePhoto(_product['imageUrl'] ?? '');

      // 2. Delete document from Firestore
      final response = await http.delete(
          Uri.parse('$_firestoreUrl/products/${_product['id']}'));

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ Listing deleted"),
              backgroundColor: Color(0xFF27AE60),
            ),
          );
          Navigator.pop(context, 'deleted');
        }
      } else {
        throw Exception('Firestore error: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint("Delete error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Delete failed: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _deleting = false);
      }
    }
  }

  Future<void> _editStock() async {
    if (!_guard()) return;

    int tempStock = _product['stock'] ?? 0;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => Padding(
          padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Edit Stock",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () =>
                        set(() => tempStock = (tempStock - 1).clamp(0, 9999)),
                    icon: const Icon(Icons.remove_circle_outline, size: 36),
                    color: tempStock <= 0 ? Colors.grey : Colors.redAccent,
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 80, height: 60, alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: tempStock <= 0
                          ? Colors.red.shade50
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: tempStock <= 0
                              ? Colors.red
                              : Colors.grey.shade300),
                    ),
                    child: Text("$tempStock",
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: tempStock <= 0 ? Colors.red : Colors.black)),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: () =>
                        set(() => tempStock = (tempStock + 1).clamp(0, 9999)),
                    icon: const Icon(Icons.add_circle_outline, size: 36),
                    color: const Color(0xFF27AE60),
                  ),
                ],
              ),
              if (tempStock <= 0)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text("⚠️ Item will be hidden from marketplace",
                      style: TextStyle(color: Colors.red, fontSize: 13)),
                ),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await http.patch(
                        Uri.parse(
                            '$_firestoreUrl/products/${_product['id']}?updateMask.fieldPaths=stock'),
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode({
                          'fields': {
                            'stock': {'integerValue': tempStock}
                          }
                        }),
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      setState(() => _product['stock'] = tempStock);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90E2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Save",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // ── FIX: Robust WhatsApp launcher ───────────────────────────────────────
  // Changes vs original:
  //   1. Strips '+' in addition to spaces/dashes/parens
  //   2. Skips canLaunchUrl (unreliable for https:// on Android)
  //   3. Wraps in try/catch instead of silent failure
  Future<void> _contactWhatsApp(String phone) async {
    // Strip ALL non-digit characters (spaces, dashes, parens, leading +)
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No phone number available.")),
        );
      }
      return;
    }

    // wa.me requires full international number without '+', e.g. 9613XXXXXX
    final uri = Uri.parse('https://wa.me/$cleaned');

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open WhatsApp. Is it installed?")),
        );
      }
    } catch (e) {
      debugPrint('WhatsApp launch error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open WhatsApp.")),
        );
      }
    }
  }

  Future<void> _contactEmail(String email, String title) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'Inquiry about: $title',
        'body':
            'Hi, I am interested in your listing "$title". Is it still available?',
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Could not open email app")));
      }
    }
  }

  void _showContactSheet() {
    final phone      = _product['sellerPhone'] ?? '';
    final email      = _product['sellerEmail'] ?? '';
    final sellerName = _product['sellerName']  ?? 'Seller';
    final title      = _product['title']       ?? 'this item';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor:
                      const Color(0xFF4A90E2).withValues(alpha: 0.1),
                  child: const Icon(Icons.store_outlined,
                      color: Color(0xFF4A90E2)),
                ),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text("Contact Seller",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50))),
                  Text(sellerName,
                      style: const TextStyle(fontSize: 13, color: Colors.grey)),
                ]),
              ]),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),

              _contactTile(
                color: const Color(0xFF4A90E2),
                icon: Icons.forum_outlined,
                label: "In-App Chat",
                subtitle: "Chat directly with the seller",
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(
                        currentUserName: _buyerName,
                        product: _product,
                        sellerName: sellerName,
                        buyerName: _buyerName,
                      ),
                    ),
                  );
                },
              ),

              if (phone.isNotEmpty) ...[
                const SizedBox(height: 12),
                _contactTile(
                  color: const Color(0xFF25D366),
                  icon: Icons.chat_outlined,
                  label: "WhatsApp",
                  subtitle: phone,
                  onTap: () {
                    Navigator.pop(ctx);
                    _contactWhatsApp(phone);
                  },
                ),
              ],

              if (email.isNotEmpty) ...[
                const SizedBox(height: 12),
                _contactTile(
                  color: const Color(0xFF4A90E2),
                  icon: Icons.email_outlined,
                  label: "Email",
                  subtitle: email,
                  onTap: () {
                    Navigator.pop(ctx);
                    _contactEmail(email, title);
                  },
                ),
              ],

              if (phone.isEmpty && email.isEmpty)
                const Center(
                    child: Text("No contact info available.",
                        style: TextStyle(color: Colors.grey))),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contactTile({
    required Color color,
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15, color: color)),
              Text(subtitle,
                  style: const TextStyle(fontSize: 13, color: Colors.grey)),
            ]),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ]),
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    return Container(
      color: Colors.grey[100],
      width: double.infinity,
      height: double.infinity,
      child: () {
        if (imageUrl.isEmpty) {
          return const Center(
            child: Icon(Icons.image, size: 80, color: Colors.grey),
          );
        }
        if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
          return Image.network(
            imageUrl,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
            ),
          );
        }
        try {
          return Image.memory(
            base64Decode(imageUrl),
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
          );
        } catch (_) {
          return const Center(
            child: Icon(Icons.image, size: 80, color: Colors.grey),
          );
        }
      }(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String imageUrl    = _product['imageUrl']    ?? '';
    final int    stock       = _product['stock']       ?? 0;
    final String title       = _product['title']       ?? 'Untitled';
    final String price       = _product['price']       ?? '0';
    final String description = _product['description'] ?? '';
    final String condition   = _product['condition']   ?? '';
    final String category    = _product['category']    ?? '';
    final String subCategory = _product['subCategory'] ?? '';
    final String sellerName  = _product['sellerName']  ?? '';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8)],
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
            actions: [
              if (_isOwner)
                GestureDetector(
                  onTap: _deleteItem,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8)],
                    ),
                    child: _deleting
                        ? const SizedBox(width: 20, height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.red))
                        : const Icon(Icons.delete_outline,
                            color: Colors.red, size: 22),
                  ),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImage(imageUrl),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                if (_isOwner)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    color: const Color(0xFF27AE60).withValues(alpha: 0.1),
                    child: Row(children: [
                      const Icon(Icons.verified_user_outlined,
                          size: 16, color: Color(0xFF27AE60)),
                      const SizedBox(width: 8),
                      Text(
                        "Managing as $_ownerName",
                        style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF27AE60),
                            fontWeight: FontWeight.w500),
                      ),
                    ]),
                  ),

                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (category.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A90E2)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            subCategory.isNotEmpty
                                ? "$category › $subCategory"
                                : category,
                            style: const TextStyle(
                                color: Color(0xFF4A90E2),
                                fontWeight: FontWeight.w600,
                                fontSize: 12),
                          ),
                        ),
                      Text(title,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50))),
                      const SizedBox(height: 8),
                      Row(children: [
                        Text("\$$price",
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4A90E2))),
                        const Spacer(),
                        GestureDetector(
                          onTap: _isOwner ? _editStock : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: stock <= 0
                                  ? Colors.red.withValues(alpha: 0.1)
                                  : const Color(0xFF27AE60)
                                      .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: stock <= 0
                                      ? Colors.red
                                      : const Color(0xFF27AE60)),
                            ),
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.inventory_2_outlined,
                                      size: 14,
                                      color: stock <= 0
                                          ? Colors.red
                                          : const Color(0xFF27AE60)),
                                  const SizedBox(width: 4),
                                  Text(
                                      stock <= 0
                                          ? "Out of stock"
                                          : "$stock in stock",
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: stock <= 0
                                              ? Colors.red
                                              : const Color(0xFF27AE60))),
                                  if (_isOwner) ...[
                                    const SizedBox(width: 4),
                                    Icon(Icons.edit_outlined,
                                        size: 12,
                                        color: stock <= 0
                                            ? Colors.red
                                            : const Color(0xFF27AE60)),
                                  ],
                                ]),
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                if (sellerName.isNotEmpty)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Row(children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor:
                            const Color(0xFF4A90E2).withValues(alpha: 0.1),
                        child: const Icon(Icons.store_outlined,
                            color: Color(0xFF4A90E2), size: 22),
                      ),
                      const SizedBox(width: 14),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Sold by",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                            Text(sellerName,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2C3E50))),
                          ]),
                      const Spacer(),
                      if (!_isOwner)
                        GestureDetector(
                          onTap: _showContactSheet,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A90E2)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: const Color(0xFF4A90E2)
                                      .withValues(alpha: 0.4)),
                            ),
                            child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.message_outlined,
                                      size: 14, color: Color(0xFF4A90E2)),
                                  SizedBox(width: 4),
                                  Text("Contact",
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF4A90E2))),
                                ]),
                          ),
                        ),
                    ]),
                  ),

                const SizedBox(height: 10),

                if (condition.isNotEmpty)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Row(children: [
                      Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A90E2)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.star_outline,
                            color: Color(0xFF4A90E2), size: 22),
                      ),
                      const SizedBox(width: 14),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Condition",
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey)),
                            Text(condition,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2C3E50))),
                          ]),
                    ]),
                  ),

                const SizedBox(height: 10),

                if (description.isNotEmpty)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Description",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50))),
                        const SizedBox(height: 10),
                        Text(description,
                            style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                height: 1.6)),
                      ],
                    ),
                  ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -4))],
        ),
        child: _isOwner
            ? Row(children: [
                OutlinedButton.icon(
                  onPressed: _editStock,
                  icon: const Icon(Icons.inventory_2_outlined, size: 16),
                  label: const Text("Edit Stock"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4A90E2),
                    side: const BorderSide(color: Color(0xFF4A90E2)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _deleting ? null : _deleteItem,
                    icon: _deleting
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.delete_outline, size: 20),
                    label: const Text("Delete Listing",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
              ])
            : ElevatedButton.icon(
                onPressed: stock <= 0 ? null : _showContactSheet,
                icon: const Icon(Icons.chat_outlined, size: 20),
                label: Text(stock <= 0 ? "Out of Stock" : "Contact Seller",
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
      ),
    );
  }
}