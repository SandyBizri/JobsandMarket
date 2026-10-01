import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'seller_session.dart';
import 'add_item.dart';
import 'view_listing_page.dart';

const String _projectId = 'marketplaneproducts';
const String _firestoreUrl =
    'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents';

class MyListingsPage extends StatefulWidget {
  const MyListingsPage({super.key});

  @override
  State<MyListingsPage> createState() => _MyListingsPageState();
}

class _MyListingsPageState extends State<MyListingsPage> {
  List<Map<String, dynamic>> _listings = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMyListings();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchMyListings() async {
    setState(() => _loading = true);
    final sellerName = await SellerSession.getSellerName() ?? '';
    if (sellerName.isEmpty) {
      setState(() => _loading = false);
      return;
    }

    try {
      final responses = await Future.wait([
        http.get(Uri.parse('$_firestoreUrl/products')),
        http.get(Uri.parse('$_firestoreUrl/vehicles')),
        http.get(Uri.parse('$_firestoreUrl/homes')),
      ]);

      final List<Map<String, dynamic>> all = [];

      for (int i = 0; i < responses.length; i++) {
        final res = responses[i];
        if (res.statusCode != 200) continue;
        final data = jsonDecode(res.body);
        final docs = (data['documents'] as List? ?? []);
        final isVehicle = i == 1;
        final isHome = i == 2;

        for (final doc in docs) {
          final fields = doc['fields'] as Map<String, dynamic>;
          final docId = (doc['name'] as String).split('/').last;
          final seller = fields['sellerName']?['stringValue'] ?? '';
          if (seller.trim().toLowerCase() != sellerName.trim().toLowerCase()) continue;

          final createdAtStr =
              fields['createdAt']?['timestampValue'] as String?;
          final createdAt =
              createdAtStr != null ? DateTime.tryParse(createdAtStr) : null;
          final collection =
              isVehicle ? 'vehicles' : isHome ? 'homes' : 'products';

          final stock = int.tryParse(
                  (fields['stock']?['integerValue'] ??
                          fields['stock']?['doubleValue'] ??
                          '1')
                      .toString()) ??
              1;

          all.add({
            'id': docId,
            'collection': collection,
            'isVehicle': isVehicle,
            'isHome': isHome,
            'title': fields['title']?['stringValue'] ?? 'Untitled',
            'price': fields['price']?['stringValue'] ?? '0',
            'imageUrl': fields['imageUrl']?['stringValue'] ?? '',
            'status': fields['status']?['stringValue'] ?? 'available',
            'stock': stock,
            'intent': fields['intent']?['stringValue'] ?? '',
            'location': fields['location']?['stringValue'] ?? '',
            'description': fields['description']?['stringValue'] ?? '',
            'condition': fields['condition']?['stringValue'] ?? '',
            'sellerName': seller,
            'sellerPhone': fields['sellerPhone']?['stringValue'] ?? '',
            'sellerEmail': fields['sellerEmail']?['stringValue'] ?? '',
            'password': fields['password']?['stringValue'] ?? '',
            'createdAt': createdAt,
            // vehicle extras
            'vehicleType': fields['vehicleType']?['stringValue'] ?? '',
            'vehicleCategoryId':
                fields['vehicleCategoryId']?['stringValue'] ?? '',
            'vehicleTypeId': fields['vehicleTypeId']?['stringValue'] ?? '',
            'make': fields['make']?['stringValue'] ?? '',
            'model': fields['model']?['stringValue'] ?? '',
            'year': fields['year']?['stringValue'] ?? '',
            'mileage': fields['mileage']?['stringValue'] ?? '',
            'color': fields['color']?['stringValue'] ?? '',
            // home extras
            'area': fields['area']?['stringValue'] ?? '',
            'rooms': fields['rooms']?['stringValue'] ?? '',
            'baths': fields['baths']?['stringValue'] ?? '',
            'floor': fields['floor']?['stringValue'] ?? '',
            'furnished': fields['furnished']?['booleanValue'] ?? false,
            'propertyCategoryId':
                fields['propertyCategoryId']?['stringValue'] ?? '',
            'subCategoryId': fields['subCategoryId']?['stringValue'] ?? '',
            'subCategory': fields['subCategory']?['stringValue'] ?? '',
            // item extras
            'category': fields['category']?['stringValue'] ?? '',
            'parentCategoryId':
                fields['parentCategoryId']?['stringValue'] ?? '',
          });
        }
      }

      all.sort((a, b) {
        final aT = a['createdAt'] as DateTime?;
        final bT = b['createdAt'] as DateTime?;
        if (aT == null && bT == null) return 0;
        if (aT == null) return 1;
        if (bT == null) return -1;
        return bT.compareTo(aT);
      });

      setState(() {
        _listings = all;
        _filtered = all;
        _loading = false;
      });
    } catch (e) {
      debugPrint('MyListings fetch error: $e');
      setState(() => _loading = false);
    }
  }

  void _applySearch(String q) {
    final query = q.toLowerCase().trim();
    setState(() {
      _searchQuery = query;
      _filtered = query.isEmpty
          ? _listings
          : _listings.where((item) {
              final title = (item['title'] ?? '').toString().toLowerCase();
              final cat = (item['category'] ?? '').toString().toLowerCase();
              final loc = (item['location'] ?? '').toString().toLowerCase();
              return title.contains(query) ||
                  cat.contains(query) ||
                  loc.contains(query);
            }).toList();
    });
  }

  Future<void> _patchDoc(
      String collection, String docId, Map<String, dynamic> fields) async {
    final updateMask =
        fields.keys.map((k) => 'updateMask.fieldPaths=$k').join('&');
    final url = '$_firestoreUrl/$collection/$docId?$updateMask';
    final body = {
      'fields': fields.map((k, v) {
        if (v is bool) return MapEntry(k, {'booleanValue': v});
        if (v is int) return MapEntry(k, {'integerValue': v.toString()});
        return MapEntry(k, {'stringValue': v.toString()});
      })
    };
    await http.patch(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }

  Future<void> _markAsSold(Map<String, dynamic> item) async {
    try {
      await _patchDoc(item['collection'], item['id'], {'status': 'sold'});
      _fetchMyListings();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Marked as sold'),
          behavior: SnackBarBehavior.floating));
    } catch (e) {
      debugPrint('markAsSold error: $e');
    }
  }

  Future<void> _markOutOfStock(Map<String, dynamic> item) async {
  try {
    await _patchDoc(item['collection'], item['id'], {'status': 'outofstock'});
      _fetchMyListings();
    } catch (e) {
      debugPrint('markOutOfStock error: $e');
    }
  }

  Future<void> _deleteDoc(Map<String, dynamic> item) async {
    try {
      await http.delete(
          Uri.parse('$_firestoreUrl/${item['collection']}/${item['id']}'));
      _fetchMyListings();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Listing deleted'),
          behavior: SnackBarBehavior.floating));
    } catch (e) {
      debugPrint('delete error: $e');
    }
  }

  void _confirmDelete(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete listing'),
        content:
            Text('Delete "${item['title']}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteDoc(item);
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
  }

  String _statusLabel(Map<String, dynamic> item) {
    final status = (item['status'] ?? '').toString().toLowerCase();
    if (status == 'sold') return 'Sold';
    if (status == 'pending') return 'Pending';
    if (status == 'outofstock') return 'Out of stock';
    return 'Available';
  }

  Color _statusColor(Map<String, dynamic> item) {
    switch (_statusLabel(item)) {
      case 'Sold':
        return Colors.red.shade400;
      case 'Pending':
        return Colors.orange.shade600;
      case 'Out of stock':
        return Colors.grey;
      default:
        return Colors.green.shade600;
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Your listings',
          style: TextStyle(
              color: Color(0xFF1C1E21),
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1C1E21)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Color(0xFF1C1E21)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Header ───────────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AddItemPage()));
                      _fetchMyListings();
                    },
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Create listing',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1877F2),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 40,
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: _applySearch,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: 'Search your listings',
                      hintStyle: const TextStyle(
                          fontSize: 14, color: Colors.grey),
                      prefixIcon: const Icon(Icons.search,
                          color: Colors.grey, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close,
                                  color: Colors.grey, size: 18),
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                _searchCtrl.clear();
                                _applySearch('');
                              })
                          : null,
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),

          // ── List ─────────────────────────────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.storefront_outlined,
                                size: 60, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'No results for "$_searchQuery"'
                                  : 'You have no listings yet',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 15),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchMyListings,
                        child: ListView.separated(
                          padding:
                              const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) => const Divider(
                              height: 1, indent: 88, endIndent: 16),
                          itemBuilder: (ctx, i) =>
                              _buildTile(_filtered[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(Map<String, dynamic> item) {
    final label = _statusLabel(item);
    final isSold = label == 'Sold';
    final isOutOfStock = label == 'Out of stock';
    final isPending = label == 'Pending';
    final isAvailable = label == 'Available';

    final price = item['isHome'] == true && item['intent'] == 'Rent'
        ? '\$${item['price']}/mo'
        : '\$${item['price']}';

    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ViewListingPage(
              item: item,
              onRefresh: _fetchMyListings,
            ),
          ),
        );
        if (result == 'refresh') _fetchMyListings();
      },
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 64,
                height: 64,
                child: item['imageUrl'] != ''
                    ? Image.network(item['imageUrl'],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.image,
                                color: Colors.grey)))
                    : Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image,
                            color: Colors.grey)),
              ),
            ),
            const SizedBox(width: 12),

            // Info + actions
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] ?? 'Untitled',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C1E21)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: _statusColor(item),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(label,
                          style: TextStyle(
                              fontSize: 12,
                              color: _statusColor(item),
                              fontWeight: FontWeight.w500)),
                      const Text(' · ',
                          style: TextStyle(
                              color: Colors.grey, fontSize: 12)),
                      Text(
                          'Listed on ${_formatDate(item['createdAt'] as DateTime?)}',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                      const Text(' · ',
                          style: TextStyle(
                              color: Colors.grey, fontSize: 12)),
                      Text(price,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Action buttons
                  if (isSold) ...[
                    _greyBtn('Relist', () async {
                      await _patchDoc(item['collection'], item['id'],
                          {'status': 'available'});
                      _fetchMyListings();
                    }),
                  ] else if (isPending) ...[
                    Row(children: [
                      _blueBtn(
                          'Mark as sold', () => _markAsSold(item)),
                      const SizedBox(width: 8),
                      _greyBtn('Share', () {}),
                    ]),
                  ] else if (isOutOfStock) ...[
                    Row(children: [
                      _blueBtn(
                          'Mark as sold', () => _markAsSold(item)),
                      const SizedBox(width: 8),
                      _greyBtn('Delete & relist',
                          () => _confirmDelete(item)),
                    ]),
                  ] else if (isAvailable) ...[
                    Row(children: [
                      _blueBtn(
                          'Mark as sold', () => _markAsSold(item)),
                      const SizedBox(width: 8),
                      item['createdAt'] != null &&
                              DateTime.now()
                                      .difference(
                                          item['createdAt'] as DateTime)
                                      .inDays >
                                  14
                          ? _greyBtn('Delete & relist',
                              () => _confirmDelete(item))
                          : _greyBtn('Share', () {}),
                    ]),
                    if (item['isHome'] != true) ...[
                      const SizedBox(height: 6),
                      _wideGreyBtn('Mark out of stock',
                          () => _markOutOfStock(item)),
                    ],
                  ],
                ],
              ),
            ),

            // More icon → ViewListingPage
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ViewListingPage(
                    item: item,
                    onRefresh: _fetchMyListings,
                  ),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.only(left: 8, top: 2),
                child: Icon(Icons.more_horiz,
                    color: Colors.grey, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Button helpers ────────────────────────────────────────────────────────

  Widget _blueBtn(String label, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
                color: const Color(0xFF1877F2), width: 1.5),
          ),
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF1877F2),
                  fontWeight: FontWeight.w600)),
        ),
      );

  Widget _greyBtn(String label, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF1C1E21),
                  fontWeight: FontWeight.w600)),
        ),
      );

  Widget _wideGreyBtn(String label, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF1877F2),
                    fontWeight: FontWeight.w600)),
          ),
        ),
      );
}