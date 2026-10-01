import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'add_item.dart';

const String _vlProjectId = 'marketplaneproducts';
const String _vlFirestoreUrl =
    'https://firestore.googleapis.com/v1/projects/$_vlProjectId/databases/(default)/documents';

class ViewListingPage extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback? onRefresh;

  const ViewListingPage({
    super.key,
    required this.item,
    this.onRefresh,
  });

  @override
  State<ViewListingPage> createState() => _ViewListingPageState();
}

class _ViewListingPageState extends State<ViewListingPage> {
  late Map<String, dynamic> _item;

  @override
  void initState() {
    super.initState();
    _item = Map<String, dynamic>.from(widget.item);
  }

  String get _collection {
  if (_item['isVehicle'] == true) return 'vehicles';
  if (_item['isHome'] == true) return 'homes';
  return _item['collection'] ?? 'products';
}
  String get _docId => _item['id'] ?? '';

  // ── Firestore helpers ─────────────────────────────────────────────────────

  Future<void> _patchField(Map<String, dynamic> fields) async {
    final updateMask =
        fields.keys.map((k) => 'updateMask.fieldPaths=$k').join('&');
    final url = '$_vlFirestoreUrl/$_collection/$_docId?$updateMask';
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

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _markAsSold() async {
    await _patchField({'status': 'sold'});
    setState(() => _item['status'] = 'sold');
    widget.onRefresh?.call();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Marked as sold'),
        behavior: SnackBarBehavior.floating));
  }

  Future<void> _markAsPending() async {
    await _patchField({'status': 'pending'});
    setState(() => _item['status'] = 'pending');
    widget.onRefresh?.call();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Marked as pending'),
        behavior: SnackBarBehavior.floating));
  }

  Future<void> _markAsAvailable() async {
    await _patchField({'status': 'available'});
    setState(() => _item['status'] = 'available');
    widget.onRefresh?.call();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Marked as available'),
        behavior: SnackBarBehavior.floating));
  }

  Future<void> _renewPost() async {
    await _patchField({
      'status': 'available',
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    });
    setState(() => _item['status'] = 'available');
    widget.onRefresh?.call();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Post renewed'),
        behavior: SnackBarBehavior.floating));
  }

  Future<void> _deleteListing() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete listing'),
        content:
            Text('Delete "${_item['title']}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await http.delete(
        Uri.parse('$_vlFirestoreUrl/$_collection/$_docId'));
    widget.onRefresh?.call();
    if (!mounted) return;
    Navigator.pop(context, 'refresh');
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Listing deleted'),
        behavior: SnackBarBehavior.floating));
  }

  // ── Edit listing — opens AddItemPage pre-filled with this item's data ─────

  Future<void> _editListing() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddItemPage(editItem: _item),
      ),
    );
    if (result == 'refresh') {
      widget.onRefresh?.call();
      // Re-fetch updated item from Firestore so the view reflects changes
      try {
        final url = '$_vlFirestoreUrl/$_collection/$_docId';
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200 && mounted) {
          final data = jsonDecode(response.body);
          final fields = data['fields'] as Map<String, dynamic>;
          setState(() {
            _item['title']       = fields['title']?['stringValue']       ?? _item['title'];
            _item['price']       = fields['price']?['stringValue']       ?? _item['price'];
            _item['description'] = fields['description']?['stringValue'] ?? _item['description'];
            _item['condition']   = fields['condition']?['stringValue']   ?? _item['condition'];
            _item['imageUrl']    = fields['imageUrl']?['stringValue']    ?? _item['imageUrl'];
            _item['stock']       = int.tryParse(
                  (fields['stock']?['integerValue'] ?? _item['stock']).toString()) ??
                _item['stock'];
          });
        }
      } catch (e) {
        debugPrint('Re-fetch error: $e');
      }
    }
  }

  // ── Computed helpers ──────────────────────────────────────────────────────

  String get _statusLabel {
    final status = (_item['status'] ?? '').toString().toLowerCase();
    if (status == 'sold') return 'Sold';
    if (status == 'pending') return 'Pending';
    if (status == 'outofstock') return 'Out of stock';
    return 'Available';
  }

  Color get _statusColor {
    switch (_statusLabel) {
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

  String get _priceDisplay => _item['isHome'] == true &&
          _item['intent'] == 'Rent'
      ? '\$${_item['price']}/mo'
      : '\$${_item['price']}';

  bool get _isSold => _statusLabel == 'Sold';
  bool get _isPending => _statusLabel == 'Pending';

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final imageUrl = _item['imageUrl'] as String? ?? '';
    final location = _item['location'] as String? ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'View listing',
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
            onPressed: _showMoreSheet,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ─────────────────────────────────────────────────────
            AspectRatio(
              aspectRatio: 16/ 9,
              child: Container(
                color: Colors.grey[100],
                child: imageUrl.isNotEmpty
                    ? Image.network(imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.image,
                                size: 60, color: Colors.grey)))
                    : const Center(
                        child: Icon(Icons.image,
                            size: 60, color: Colors.grey)),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    _item['title'] ?? 'Untitled',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C1E21)),
                  ),
                  const SizedBox(height: 4),

                  // Price · location
                  Row(children: [
                    Text(_priceDisplay,
                        style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1C1E21),
                            fontWeight: FontWeight.w500)),
                    if (location.isNotEmpty) ...[
                      const Text(' · ',
                          style: TextStyle(
                              color: Colors.grey, fontSize: 16)),
                      Flexible(
                        child: Text(location,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 6),

                  // Status badge
                  Row(children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                          color: _statusColor, shape: BoxShape.circle),
                    ),
                    Text(_statusLabel,
                        style: TextStyle(
                            color: _statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ]),
                  const SizedBox(height: 20),

                  // ── Primary buttons ────────────────────────────────────
                  if (!_isSold) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _markAsSold,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1877F2),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding:
                              const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Mark as sold',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _renewPost,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1C1E21),
                        side: const BorderSide(
                            color: Color(0xFFDADDE1), width: 1.5),
                        padding:
                            const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Renew post',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Divider(height: 1, color: Color(0xFFDADDE1)),
                  const SizedBox(height: 16),

                  // ── Icon actions row ───────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _iconAction(
                        icon: _isPending
                            ? Icons.play_circle_outline
                            : Icons.pause_circle_outline,
                        label: _isPending
                            ? 'Mark as\navailable'
                            : 'Mark as\npending',
                        onTap: _isPending
                            ? _markAsAvailable
                            : _markAsPending,
                      ),
                      _iconAction(
                        icon: Icons.edit_outlined,
                        label: 'Edit listing',
                        // ← Now correctly opens the form pre-filled
                        onTap: _editListing,
                      ),
                      _iconAction(
                        icon: Icons.delete_outline,
                        label: 'Delete\nlisting',
                        onTap: _deleteListing,
                      ),
                      _iconAction(
                        icon: Icons.more_horiz,
                        label: 'More',
                        onTap: _showMoreSheet,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(height: 1, color: Color(0xFFDADDE1)),
                  const SizedBox(height: 16),

                  // ── Description ────────────────────────────────────────
                  if ((_item['description'] as String? ?? '').isNotEmpty) ...[
                    const Text('Description',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C1E21))),
                    const SizedBox(height: 6),
                    Text(_item['description'] ?? '',
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF606770))),
                    const SizedBox(height: 16),
                  ],

                  // ── Extra details ──────────────────────────────────────
                  if (_item['isVehicle'] == true) _vehicleDetails(),
                  if (_item['isHome'] == true) _homeDetails(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom sheet ──────────────────────────────────────────────────────────

  void _showMoreSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share listing'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.refresh_outlined),
              title: const Text('Renew post'),
              onTap: () {
                Navigator.pop(ctx);
                _renewPost();
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit listing'),
              onTap: () {
                Navigator.pop(ctx);
                _editListing();
              },
            ),
            if (!_isPending)
              ListTile(
                leading: const Icon(Icons.pause_circle_outline,
                    color: Colors.orange),
                title: const Text('Mark as pending',
                    style: TextStyle(color: Colors.orange)),
                onTap: () {
                  Navigator.pop(ctx);
                  _markAsPending();
                },
              ),
            if (_isPending)
              ListTile(
                leading: const Icon(Icons.play_circle_outline,
                    color: Colors.green),
                title: const Text('Mark as available',
                    style: TextStyle(color: Colors.green)),
                onTap: () {
                  Navigator.pop(ctx);
                  _markAsAvailable();
                },
              ),
            ListTile(
              leading:
                  const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete listing',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                _deleteListing();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Widget helpers ────────────────────────────────────────────────────────

  Widget _iconAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: const Color(0xFF1C1E21)),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 11, color: Color(0xFF606770)),
          ),
        ],
      ),
    );
  }

  Widget _vehicleDetails() {
    final details = <String, String>{
      if ((_item['make'] as String? ?? '').isNotEmpty) 'Make': _item['make'],
      if ((_item['model'] as String? ?? '').isNotEmpty) 'Model': _item['model'],
      if ((_item['year'] as String? ?? '').isNotEmpty) 'Year': _item['year'],
      if ((_item['mileage'] as String? ?? '').isNotEmpty)
        'Mileage': _item['mileage'],
      if ((_item['color'] as String? ?? '').isNotEmpty) 'Color': _item['color'],
      if ((_item['condition'] as String? ?? '').isNotEmpty)
        'Condition': _item['condition'],
    };
    if (details.isEmpty) return const SizedBox.shrink();
    return _detailsSection('Vehicle details', details);
  }

  Widget _homeDetails() {
    final details = <String, String>{
      if ((_item['area'] as String? ?? '').isNotEmpty)
        'Area': '${_item['area']} m²',
      if ((_item['rooms'] as String? ?? '').isNotEmpty) 'Rooms': _item['rooms'],
      if ((_item['baths'] as String? ?? '').isNotEmpty)
        'Bathrooms': _item['baths'],
      if ((_item['floor'] as String? ?? '').isNotEmpty) 'Floor': _item['floor'],
      'Furnished': (_item['furnished'] == true) ? 'Yes' : 'No',
      if ((_item['intent'] as String? ?? '').isNotEmpty) 'Type': _item['intent'],
    };
    if (details.isEmpty) return const SizedBox.shrink();
    return _detailsSection('Property details', details);
  }

  Widget _detailsSection(String title, Map<String, String> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1C1E21))),
        const SizedBox(height: 10),
        ...details.entries.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(e.key,
                      style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF606770),
                          fontWeight: FontWeight.w500)),
                ),
                Expanded(
                  child: Text(e.value,
                      style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF1C1E21),
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}