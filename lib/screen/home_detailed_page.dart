/*import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_page.dart';
import '/screen/seller_session.dart';

const String _firestoreHomeUrl =
    'https://firestore.googleapis.com/v1/projects/marketplaneproducts/databases/(default)/documents';

class HomeDetailPage extends StatefulWidget {
  final Map<String, dynamic> home;
  const HomeDetailPage({super.key, required this.home});

  @override
  State<HomeDetailPage> createState() => _HomeDetailPageState();
}

class _HomeDetailPageState extends State<HomeDetailPage> {
  late Map<String, dynamic> _home;
  bool _deleting = false;
  bool _isOwner  = false;
  String? _ownerName;

  @override
  void initState() {
    super.initState();
    _home = Map<String, dynamic>.from(widget.home);
    _checkOwnership();
  }

  Future<void> _checkOwnership() async {
    final owned = await SellerSession.isOwnerOf(_home);
    if (owned && mounted) {
      final name = await SellerSession.getSellerName();
      setState(() {
        _isOwner   = true;
        _ownerName = name;
      });
    }
  }

  bool get _isRent => (_home['intent'] ?? '') == 'Rent';

  Color get _intentColor =>
      _isRent ? const Color(0xFF5C6BC0) : const Color(0xFFE67E22);

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

  Future<void> _deleteHome() async {
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
      await _deleteSupabasePhoto(_home['imageUrl'] ?? '');

      // 2. Delete document from Firestore
      final response = await http.delete(
          Uri.parse('$_firestoreHomeUrl/homes/${_home['id']}'));

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

  Future<void> _editPrice() async {
    if (!_guard()) return;

    final controller =
        TextEditingController(text: (_home['price'] ?? '').toString());

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_isRent ? "Edit Monthly Rent" : "Edit Price",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                labelText: _isRent ? "Monthly Rent" : "Price",
                prefixText: "\$ ",
                suffixText: _isRent ? "/ month" : null,
                border: const OutlineInputBorder(),
              ),
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
                    final newPrice = controller.text.trim();
                    await http.patch(
                      Uri.parse(
                          '$_firestoreHomeUrl/homes/${_home['id']}?updateMask.fieldPaths=price'),
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode({
                        'fields': {
                          'price': {'stringValue': newPrice}
                        }
                      }),
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                    setState(() => _home['price'] = newPrice);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _intentColor,
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

  Future<void> _contactEmail(String email, String itemTitle) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'Inquiry about: $itemTitle',
        'body':
            'Hi, I am interested in your listing "$itemTitle". Is it still available?',
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

  Future<void> _showContactSheet() async {
    final prefs = await SharedPreferences.getInstance();
    final buyerName = prefs.getString('buyer_name') ?? 'Guest User';

    if (!mounted) return;

    final phone      = _home['sellerPhone'] ?? '';
    final email      = _home['sellerEmail'] ?? '';
    final sellerName = _home['sellerName']  ?? 'Seller';
    final title      = _home['title']       ?? 'this property';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: _intentColor.withValues(alpha: 0.1),
                    child: Icon(Icons.store_outlined, color: _intentColor),
                  ),
                  const SizedBox(width: 12),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Contact Seller",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50))),
                        Text(sellerName,
                            style: const TextStyle(
                                fontSize: 13, color: Colors.grey)),
                      ]),
                ]),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),

                _contactTile(
                  color: _intentColor,
                  icon: Icons.forum_outlined,
                  label: "In-App Chat",
                  subtitle: "Chat directly with the seller",
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          currentUserName: buyerName,
                          product: _home,
                          sellerName: sellerName,
                          buyerName: buyerName,
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
                    color: _intentColor,
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: color)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          decoration: TextDecoration.none)),
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
          return Center(
            child: Icon(Icons.home_outlined, size: 80, color: Colors.grey[400]),
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
          return Center(
            child: Icon(Icons.home_outlined, size: 80, color: Colors.grey[400]),
          );
        }
      }(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String imageUrl    = _home['imageUrl']    ?? '';
    final String title       = _home['title']       ?? 'Untitled';
    final String price       = _home['price']       ?? '0';
    final String intent      = _home['intent']      ?? '';
    final String subCategory = _home['subCategory'] ?? '';
    final String location    = _home['location']    ?? '';
    final String area        = _home['area']        ?? '';
    final String rooms       = _home['rooms']       ?? '';
    final String baths       = _home['baths']       ?? '';
    final String floor       = _home['floor']       ?? '';
    final bool furnished     = _home['furnished']   == true;
    final String description = _home['description'] ?? '';
    final String sellerName  = _home['sellerName']  ?? '';

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
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8)
                  ],
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
            actions: [
              if (_isOwner)
                GestureDetector(
                  onTap: _deleting ? null : _deleteHome,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8)
                      ],
                    ),
                    child: _deleting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
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
                    color: _intentColor.withValues(alpha: 0.1),
                    child: Row(children: [
                      Icon(Icons.verified_user_outlined,
                          size: 16, color: _intentColor),
                      const SizedBox(width: 8),
                      Text("Managing as $_ownerName",
                          style: TextStyle(
                              fontSize: 13,
                              color: _intentColor,
                              fontWeight: FontWeight.w500)),
                    ]),
                  ),

                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (intent.isNotEmpty || subCategory.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _intentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isRent
                                      ? Icons.key_outlined
                                      : Icons.sell_outlined,
                                  size: 12,
                                  color: _intentColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Home › $intent › $subCategory",
                                  style: TextStyle(
                                      color: _intentColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12),
                                ),
                              ]),
                        ),
                      Text(title,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50))),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _isOwner ? _editPrice : null,
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(
                            _isRent ? "\$$price / month" : "\$$price",
                            style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: _intentColor),
                          ),
                          if (_isOwner) ...[
                            const SizedBox(width: 6),
                            Icon(Icons.edit_outlined,
                                size: 14, color: _intentColor),
                          ],
                        ]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Property Details",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50))),
                      const SizedBox(height: 16),
                      Row(children: [
                        if (area.isNotEmpty)
                          Expanded(
                              child: _specTile(Icons.square_foot_outlined,
                                  "Area", "$area m²")),
                        if (rooms.isNotEmpty)
                          Expanded(
                              child: _specTile(
                                  Icons.bed_outlined, "Bedrooms", rooms)),
                      ]),
                      if (baths.isNotEmpty || floor.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Row(children: [
                          if (baths.isNotEmpty)
                            Expanded(
                                child: _specTile(Icons.bathtub_outlined,
                                    "Bathrooms", baths)),
                          if (floor.isNotEmpty)
                            Expanded(
                                child: _specTile(
                                    Icons.layers_outlined, "Floor", floor)),
                        ]),
                      ],
                      if (location.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _specTile(Icons.location_on_outlined, "Location",
                            location),
                      ],
                      if (furnished) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _intentColor.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: _intentColor.withValues(alpha: 0.2)),
                          ),
                          child: Row(children: [
                            Icon(Icons.chair_outlined,
                                size: 18, color: _intentColor),
                            const SizedBox(width: 8),
                            Text("Furnished",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _intentColor)),
                          ]),
                        ),
                      ],
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
                        backgroundColor: _intentColor.withValues(alpha: 0.1),
                        child: Icon(Icons.store_outlined,
                            color: _intentColor, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_isRent ? "Listed by" : "Sold by",
                                style: const TextStyle(
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
                              color: _intentColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: _intentColor.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.message_outlined,
                                      size: 14, color: _intentColor),
                                  const SizedBox(width: 4),
                                  Text("Contact",
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: _intentColor)),
                                ]),
                          ),
                        ),
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
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, -4))
          ],
        ),
        child: _isOwner
            ? Row(children: [
                OutlinedButton.icon(
                  onPressed: _editPrice,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text("Edit Price"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _intentColor,
                    side: BorderSide(color: _intentColor),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _deleting ? null : _deleteHome,
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
                onPressed: _showContactSheet,
                icon: const Icon(Icons.chat_outlined, size: 20),
                label: Text(
                  _isRent ? "Contact for Rent" : "Contact Seller",
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _intentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
      ),
    );
  }

  Widget _specTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(children: [
        Icon(icon, size: 18, color: _intentColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50)),
                    overflow: TextOverflow.ellipsis),
              ]),
        ),
      ]),
    );
  }
}*/
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_page.dart';
import '/screen/seller_session.dart';

const String _firestoreHomeUrl =
    'https://firestore.googleapis.com/v1/projects/marketplaneproducts/databases/(default)/documents';

class HomeDetailPage extends StatefulWidget {
  final Map<String, dynamic> home;
  const HomeDetailPage({super.key, required this.home});

  @override
  State<HomeDetailPage> createState() => _HomeDetailPageState();
}

class _HomeDetailPageState extends State<HomeDetailPage> {
  late Map<String, dynamic> _home;
  bool _deleting = false;
  bool _isOwner  = false;
  String? _ownerName;

  @override
  void initState() {
    super.initState();
    _home = Map<String, dynamic>.from(widget.home);
    _checkOwnership();
  }

  Future<void> _checkOwnership() async {
    final owned = await SellerSession.isOwnerOf(_home);
    if (owned && mounted) {
      final name = await SellerSession.getSellerName();
      setState(() {
        _isOwner   = true;
        _ownerName = name;
      });
    }
  }

  bool get _isRent => (_home['intent'] ?? '') == 'Rent';

  Color get _intentColor =>
      _isRent ? const Color(0xFF5C6BC0) : const Color(0xFFE67E22);

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

  Future<void> _deleteHome() async {
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
      await _deleteSupabasePhoto(_home['imageUrl'] ?? '');

      // 2. Delete document from Firestore
      final response = await http.delete(
          Uri.parse('$_firestoreHomeUrl/homes/${_home['id']}'));

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

  Future<void> _editPrice() async {
    if (!_guard()) return;

    final controller =
        TextEditingController(text: (_home['price'] ?? '').toString());

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_isRent ? "Edit Monthly Rent" : "Edit Price",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                labelText: _isRent ? "Monthly Rent" : "Price",
                prefixText: "\$ ",
                suffixText: _isRent ? "/ month" : null,
                border: const OutlineInputBorder(),
              ),
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
                    final newPrice = controller.text.trim();
                    await http.patch(
                      Uri.parse(
                          '$_firestoreHomeUrl/homes/${_home['id']}?updateMask.fieldPaths=price'),
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode({
                        'fields': {
                          'price': {'stringValue': newPrice}
                        }
                      }),
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                    setState(() => _home['price'] = newPrice);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _intentColor,
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
          const SnackBar(
              content: Text("Could not open WhatsApp. Is it installed?")),
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

  Future<void> _contactEmail(String email, String itemTitle) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'Inquiry about: $itemTitle',
        'body':
            'Hi, I am interested in your listing "$itemTitle". Is it still available?',
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

  Future<void> _showContactSheet() async {
    final prefs = await SharedPreferences.getInstance();
    final buyerName = prefs.getString('buyer_name') ?? 'Guest User';

    if (!mounted) return;

    final phone      = _home['sellerPhone'] ?? '';
    final email      = _home['sellerEmail'] ?? '';
    final sellerName = _home['sellerName']  ?? 'Seller';
    final title      = _home['title']       ?? 'this property';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: _intentColor.withValues(alpha: 0.1),
                    child: Icon(Icons.store_outlined, color: _intentColor),
                  ),
                  const SizedBox(width: 12),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Contact Seller",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50))),
                        Text(sellerName,
                            style: const TextStyle(
                                fontSize: 13, color: Colors.grey)),
                      ]),
                ]),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),

                _contactTile(
                  color: _intentColor,
                  icon: Icons.forum_outlined,
                  label: "In-App Chat",
                  subtitle: "Chat directly with the seller",
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          currentUserName: buyerName,
                          product: _home,
                          sellerName: sellerName,
                          buyerName: buyerName,
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
                    color: _intentColor,
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: color)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          decoration: TextDecoration.none)),
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
          return Center(
            child: Icon(Icons.home_outlined, size: 80, color: Colors.grey[400]),
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
          return Center(
            child: Icon(Icons.home_outlined, size: 80, color: Colors.grey[400]),
          );
        }
      }(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String imageUrl    = _home['imageUrl']    ?? '';
    final String title       = _home['title']       ?? 'Untitled';
    final String price       = _home['price']       ?? '0';
    final String intent      = _home['intent']      ?? '';
    final String subCategory = _home['subCategory'] ?? '';
    final String location    = _home['location']    ?? '';
    final String area        = _home['area']        ?? '';
    final String rooms       = _home['rooms']       ?? '';
    final String baths       = _home['baths']       ?? '';
    final String floor       = _home['floor']       ?? '';
    final bool furnished     = _home['furnished']   == true;
    final String description = _home['description'] ?? '';
    final String sellerName  = _home['sellerName']  ?? '';

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
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8)
                  ],
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
            actions: [
              if (_isOwner)
                GestureDetector(
                  onTap: _deleting ? null : _deleteHome,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8)
                      ],
                    ),
                    child: _deleting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
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
                    color: _intentColor.withValues(alpha: 0.1),
                    child: Row(children: [
                      Icon(Icons.verified_user_outlined,
                          size: 16, color: _intentColor),
                      const SizedBox(width: 8),
                      Text("Managing as $_ownerName",
                          style: TextStyle(
                              fontSize: 13,
                              color: _intentColor,
                              fontWeight: FontWeight.w500)),
                    ]),
                  ),

                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (intent.isNotEmpty || subCategory.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _intentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isRent
                                      ? Icons.key_outlined
                                      : Icons.sell_outlined,
                                  size: 12,
                                  color: _intentColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Home › $intent › $subCategory",
                                  style: TextStyle(
                                      color: _intentColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12),
                                ),
                              ]),
                        ),
                      Text(title,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50))),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _isOwner ? _editPrice : null,
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(
                            _isRent ? "\$$price / month" : "\$$price",
                            style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: _intentColor),
                          ),
                          if (_isOwner) ...[
                            const SizedBox(width: 6),
                            Icon(Icons.edit_outlined,
                                size: 14, color: _intentColor),
                          ],
                        ]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Property Details",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50))),
                      const SizedBox(height: 16),
                      Row(children: [
                        if (area.isNotEmpty)
                          Expanded(
                              child: _specTile(Icons.square_foot_outlined,
                                  "Area", "$area m²")),
                        if (rooms.isNotEmpty)
                          Expanded(
                              child: _specTile(
                                  Icons.bed_outlined, "Bedrooms", rooms)),
                      ]),
                      if (baths.isNotEmpty || floor.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Row(children: [
                          if (baths.isNotEmpty)
                            Expanded(
                                child: _specTile(Icons.bathtub_outlined,
                                    "Bathrooms", baths)),
                          if (floor.isNotEmpty)
                            Expanded(
                                child: _specTile(
                                    Icons.layers_outlined, "Floor", floor)),
                        ]),
                      ],
                      if (location.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _specTile(Icons.location_on_outlined, "Location",
                            location),
                      ],
                      if (furnished) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _intentColor.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: _intentColor.withValues(alpha: 0.2)),
                          ),
                          child: Row(children: [
                            Icon(Icons.chair_outlined,
                                size: 18, color: _intentColor),
                            const SizedBox(width: 8),
                            Text("Furnished",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _intentColor)),
                          ]),
                        ),
                      ],
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
                        backgroundColor: _intentColor.withValues(alpha: 0.1),
                        child: Icon(Icons.store_outlined,
                            color: _intentColor, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_isRent ? "Listed by" : "Sold by",
                                style: const TextStyle(
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
                              color: _intentColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: _intentColor.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.message_outlined,
                                      size: 14, color: _intentColor),
                                  const SizedBox(width: 4),
                                  Text("Contact",
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: _intentColor)),
                                ]),
                          ),
                        ),
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
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, -4))
          ],
        ),
        child: _isOwner
            ? Row(children: [
                OutlinedButton.icon(
                  onPressed: _editPrice,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text("Edit Price"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _intentColor,
                    side: BorderSide(color: _intentColor),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _deleting ? null : _deleteHome,
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
                onPressed: _showContactSheet,
                icon: const Icon(Icons.chat_outlined, size: 20),
                label: Text(
                  _isRent ? "Contact for Rent" : "Contact Seller",
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _intentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
      ),
    );
  }

  Widget _specTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(children: [
        Icon(icon, size: 18, color: _intentColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50)),
                    overflow: TextOverflow.ellipsis),
              ]),
        ),
      ]),
    );
  }
}