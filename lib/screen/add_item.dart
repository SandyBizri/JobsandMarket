/*import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;
import 'package:url_launcher/url_launcher.dart';
import 'add_vehicle.dart';
import 'add_home.dart';
import 'seller_profile_page.dart';

const String projectId = 'marketplaneproducts';
const String firestoreUrl =
    'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents';

// ─── CATEGORY MODEL ──────────────────────────────────────────────────────────

class ItemCategory {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final String? parentId;
  final String? description;

  const ItemCategory({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    this.parentId,
    this.description,
  });
}

const List<ItemCategory> itemCategories = [
  ItemCategory(id: 'electronics',        label: 'Electronics',            icon: Icons.devices_outlined,             color: Color(0xFF4A90E2), description: 'Devices & accessories'),
  ItemCategory(id: 'phones_tablets',     label: 'Phones & Tablets',       icon: Icons.smartphone_outlined,          color: Color(0xFF1E88E5), parentId: 'electronics'),
  ItemCategory(id: 'computers',          label: 'Computers & Laptops',    icon: Icons.laptop_outlined,              color: Color(0xFF1976D2), parentId: 'electronics'),
  ItemCategory(id: 'cameras',            label: 'Cameras',                icon: Icons.camera_alt_outlined,          color: Color(0xFF1565C0), parentId: 'electronics'),
  ItemCategory(id: 'audio',              label: 'Audio & Headphones',     icon: Icons.headphones_outlined,          color: Color(0xFF0D47A1), parentId: 'electronics'),
  ItemCategory(id: 'gaming',             label: 'Gaming & Consoles',      icon: Icons.sports_esports_outlined,      color: Color(0xFF5E35B1), parentId: 'electronics'),
  ItemCategory(id: 'tv_video',           label: 'TVs & Video',            icon: Icons.tv_outlined,                  color: Color(0xFF283593), parentId: 'electronics'),
  ItemCategory(id: 'wearables',          label: 'Wearables',              icon: Icons.watch_outlined,               color: Color(0xFF3949AB), parentId: 'electronics'),
  ItemCategory(id: 'networking',         label: 'Networking & WiFi',      icon: Icons.router_outlined,              color: Color(0xFF1A237E), parentId: 'electronics'),
  ItemCategory(id: 'cables_accessories', label: 'Cables & Accessories',   icon: Icons.usb_outlined,                 color: Color(0xFF4527A0), parentId: 'electronics'),
  ItemCategory(id: 'clothing',           label: 'Clothing & Fashion',     icon: Icons.checkroom_outlined,           color: Color(0xFFE91E8C), description: 'Apparel, shoes & accessories'),
  ItemCategory(id: 'mens_clothing',      label: "Men's Clothing",         icon: Icons.person_outlined,              color: Color(0xFFD81B60), parentId: 'clothing'),
  ItemCategory(id: 'womens_clothing',    label: "Women's Clothing",       icon: Icons.people_outlined,              color: Color(0xFFC2185B), parentId: 'clothing'),
  ItemCategory(id: 'kids_clothing',      label: "Kids' Clothing",         icon: Icons.child_care_outlined,          color: Color(0xFFAD1457), parentId: 'clothing'),
  ItemCategory(id: 'shoes',             label: 'Shoes & Footwear',       icon: Icons.directions_walk_outlined,     color: Color(0xFF880E4F), parentId: 'clothing'),
  ItemCategory(id: 'bags',              label: 'Bags & Luggage',         icon: Icons.luggage_outlined,             color: Color(0xFFF06292), parentId: 'clothing'),
  ItemCategory(id: 'jewelry',           label: 'Jewelry & Watches',      icon: Icons.diamond_outlined,             color: Color(0xFFE91E63), parentId: 'clothing'),
  ItemCategory(id: 'sportswear',        label: 'Sportswear',             icon: Icons.directions_run_outlined,      color: Color(0xFFEC407A), parentId: 'clothing'),
  ItemCategory(id: 'hats_scarves',      label: 'Hats, Scarves & Gloves', icon: Icons.accessibility_outlined,       color: Color(0xFFF48FB1), parentId: 'clothing'),
  ItemCategory(id: 'furniture',          label: 'Furniture & Home',       icon: Icons.chair_outlined,               color: Color(0xFF8D6E63), description: 'Furniture, décor & home essentials'),
  ItemCategory(id: 'living_room',        label: 'Living Room',            icon: Icons.weekend_outlined,             color: Color(0xFF6D4C41), parentId: 'furniture'),
  ItemCategory(id: 'bedroom',            label: 'Bedroom',                icon: Icons.bed_outlined,                 color: Color(0xFF5D4037), parentId: 'furniture'),
  ItemCategory(id: 'office_furniture',   label: 'Office Furniture',       icon: Icons.desk_outlined,                color: Color(0xFF4E342E), parentId: 'furniture'),
  ItemCategory(id: 'outdoor_furniture',  label: 'Outdoor & Garden',       icon: Icons.outdoor_grill_outlined,       color: Color(0xFF3E2723), parentId: 'furniture'),
  ItemCategory(id: 'lighting',           label: 'Lighting',               icon: Icons.light_outlined,               color: Color(0xFFA1887F), parentId: 'furniture'),
  ItemCategory(id: 'home_decor',         label: 'Home Décor',             icon: Icons.format_paint_outlined,        color: Color(0xFFBCAAA4), parentId: 'furniture'),
  ItemCategory(id: 'storage',            label: 'Storage & Organization', icon: Icons.inventory_2_outlined,         color: Color(0xFF795548), parentId: 'furniture'),
  ItemCategory(id: 'books',              label: 'Books & Media',          icon: Icons.menu_book_outlined,           color: Color(0xFF26A69A), description: 'Books, movies, music & magazines'),
  ItemCategory(id: 'fiction',            label: 'Fiction',                icon: Icons.book_outlined,                color: Color(0xFF00897B), parentId: 'books'),
  ItemCategory(id: 'non_fiction',        label: 'Non-Fiction',            icon: Icons.library_books_outlined,       color: Color(0xFF00796B), parentId: 'books'),
  ItemCategory(id: 'textbooks',          label: 'Textbooks & Education',  icon: Icons.school_outlined,              color: Color(0xFF00695C), parentId: 'books'),
  ItemCategory(id: 'sports',             label: 'Sports & Outdoors',      icon: Icons.sports_soccer_outlined,       color: Color(0xFF27AE60), description: 'Sports gear, fitness & outdoor equipment'),
  ItemCategory(id: 'fitness',            label: 'Gym & Fitness',          icon: Icons.fitness_center_outlined,      color: Color(0xFF2E7D32), parentId: 'sports'),
  ItemCategory(id: 'cycling',            label: 'Cycling',                icon: Icons.directions_bike_outlined,     color: Color(0xFF388E3C), parentId: 'sports'),
  ItemCategory(id: 'camping_hiking',     label: 'Camping & Hiking',       icon: Icons.terrain_outlined,             color: Color(0xFF43A047), parentId: 'sports'),
  ItemCategory(id: 'toys',               label: 'Toys & Games',           icon: Icons.toys_outlined,                color: Color(0xFFFF7043), description: 'Toys, board games & educational play'),
  ItemCategory(id: 'board_games',        label: 'Board Games & Puzzles',  icon: Icons.extension_outlined,           color: Color(0xFFE64A19), parentId: 'toys'),
  ItemCategory(id: 'video_games',        label: 'Video Games',            icon: Icons.videogame_asset_outlined,     color: Color(0xFFDD2C00), parentId: 'toys'),
  ItemCategory(id: 'beauty',             label: 'Beauty & Health',        icon: Icons.spa_outlined,                 color: Color(0xFFAB47BC), description: 'Cosmetics, skincare & personal care'),
  ItemCategory(id: 'skincare',           label: 'Skincare',               icon: Icons.face_outlined,                color: Color(0xFF8E24AA), parentId: 'beauty'),
  ItemCategory(id: 'makeup',             label: 'Makeup & Cosmetics',     icon: Icons.brush_outlined,               color: Color(0xFF7B1FA2), parentId: 'beauty'),
  ItemCategory(id: 'kitchen',            label: 'Kitchen & Dining',       icon: Icons.kitchen_outlined,             color: Color(0xFFE67E22), description: 'Cookware, appliances & tableware'),
  ItemCategory(id: 'cookware',           label: 'Cookware & Bakeware',    icon: Icons.soup_kitchen_outlined,        color: Color(0xFFD35400), parentId: 'kitchen'),
  ItemCategory(id: 'small_appliances',   label: 'Small Appliances',       icon: Icons.microwave_outlined,           color: Color(0xFFBA4A00), parentId: 'kitchen'),
  ItemCategory(id: 'tools',              label: 'Tools & DIY',            icon: Icons.handyman_outlined,            color: Color(0xFF546E7A), description: 'Power tools, hand tools & hardware'),
  ItemCategory(id: 'power_tools',        label: 'Power Tools',            icon: Icons.construction_outlined,        color: Color(0xFF455A64), parentId: 'tools'),
  ItemCategory(id: 'hand_tools',         label: 'Hand Tools',             icon: Icons.hardware_outlined,            color: Color(0xFF37474F), parentId: 'tools'),
  ItemCategory(id: 'baby',               label: 'Baby & Kids',            icon: Icons.child_care_outlined,          color: Color(0xFFEC407A), description: 'Baby gear, nursery & kids essentials'),
  ItemCategory(id: 'baby_gear',          label: 'Strollers & Car Seats',  icon: Icons.accessible_outlined,          color: Color(0xFFC2185B), parentId: 'baby'),
  ItemCategory(id: 'music_instruments',  label: 'Music & Instruments',    icon: Icons.music_note_outlined,          color: Color(0xFF5C6BC0), description: 'Instruments & audio equipment'),
  ItemCategory(id: 'guitars',            label: 'Guitars & Bass',         icon: Icons.music_note_outlined,          color: Color(0xFF3949AB), parentId: 'music_instruments'),
  ItemCategory(id: 'art',                label: 'Art & Collectibles',     icon: Icons.palette_outlined,             color: Color(0xFFD4AC0D), description: 'Art, antiques, crafts & collectibles'),
  ItemCategory(id: 'paintings_prints',   label: 'Paintings & Prints',     icon: Icons.image_outlined,               color: Color(0xFFB7950B), parentId: 'art'),
  ItemCategory(id: 'pets',               label: 'Pet Supplies',           icon: Icons.pets_outlined,                color: Color(0xFF795548), description: 'Food, accessories & care for pets'),
  ItemCategory(id: 'dog_supplies',       label: 'Dog Supplies',           icon: Icons.pets_outlined,                color: Color(0xFF6D4C41), parentId: 'pets'),
  ItemCategory(id: 'other',              label: 'Other',                  icon: Icons.category_outlined,            color: Color(0xFF90A4AE), description: 'Anything that doesn\'t fit above'),
  ItemCategory(id: 'office_supplies',    label: 'Office Supplies',        icon: Icons.business_center_outlined,     color: Color(0xFF78909C), parentId: 'other'),
  ItemCategory(id: 'services',           label: 'Services & Rentals',     icon: Icons.miscellaneous_services_outlined, color: Color(0xFFB0BEC5), parentId: 'other'),
];

List<ItemCategory> get parentCategories =>
    itemCategories.where((c) => c.parentId == null).toList();

List<ItemCategory> subcategoriesOf(String parentId) =>
    itemCategories.where((c) => c.parentId == parentId).toList();

const Set<String> _skipSubCategoryIds = {'other'};

// ─── PAGE ─────────────────────────────────────────────────────────────────────

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  String? _selectedType;
  ItemCategory? _selectedParentCategory;
  ItemCategory? _selectedSubCategory;

  String get _appBarTitle {
    if (_selectedType == null) return "What are you selling?";
    if (_selectedType == "Item" && _selectedParentCategory == null) return "Item Category";
    if (_selectedType == "Item" && _selectedSubCategory == null) return _selectedParentCategory!.label;
    return "New Listing";
  }

  void _handleBack() {
    if (_selectedSubCategory != null) {
      if (_selectedParentCategory != null &&
          _skipSubCategoryIds.contains(_selectedParentCategory!.id)) {
        setState(() {
          _selectedSubCategory = null;
          _selectedParentCategory = null;
        });
      } else {
        setState(() => _selectedSubCategory = null);
      }
    } else if (_selectedParentCategory != null) {
      setState(() => _selectedParentCategory = null);
    } else {
      setState(() => _selectedType = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: (_selectedType != null)
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _handleBack)
            : IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_selectedType == null) return _buildTypeSelector();
    if (_selectedType == "Item") {
      if (_selectedParentCategory == null) return _buildParentCategories();
      if (_selectedSubCategory == null) return _buildSubCategories(_selectedParentCategory!);
    }
    return _ItemForm(
      type: _selectedType!,
      parentCategory: _selectedParentCategory,
      subCategory: _selectedSubCategory,
    );
  }

  Widget _buildTypeSelector() {
    final options = [
      {'label': 'Item',    'icon': Icons.shopping_bag_outlined,  'color': const Color(0xFF4A90E2)},
      {'label': 'Vehicle', 'icon': Icons.directions_car_outlined, 'color': const Color(0xFF27AE60)},
      {'label': 'Home',    'icon': Icons.home_outlined,           'color': const Color(0xFFE67E22)},
    ];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Choose a category",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
          const SizedBox(height: 8),
          const Text("Select the type of listing you want to create.",
              style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 32),
          ...options.map((opt) => GestureDetector(
                onTap: () {
                  if (opt['label'] == 'Vehicle') {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddVehiclePage()));
                  } else if (opt['label'] == 'Home') {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddHomePage()));
                  } else {
                    setState(() => _selectedType = opt['label'] as String);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Row(children: [
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        color: (opt['color'] as Color).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(opt['icon'] as IconData, color: opt['color'] as Color, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(opt['label'] as String,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  ]),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildParentCategories() {
    final parents = parentCategories;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Select a category",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
        const SizedBox(height: 4),
        const Text("What kind of item are you selling?",
            style: TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.88,
          ),
          itemCount: parents.length,
          itemBuilder: (context, index) => _CategoryCard(
            category: parents[index],
            onTap: () {
              final cat = parents[index];
              if (_skipSubCategoryIds.contains(cat.id)) {
                setState(() {
                  _selectedParentCategory = cat;
                  _selectedSubCategory = cat;
                });
              } else {
                setState(() => _selectedParentCategory = cat);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubCategories(ItemCategory parent) {
    final subs = subcategoriesOf(parent.id);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: parent.color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: parent.color.withValues(alpha: 0.25)),
          ),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: parent.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: Icon(parent.icon, color: parent.color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(parent.label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: parent.color)),
                if (parent.description != null)
                  Text(parent.description!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ]),
            ),
          ]),
        ),
        const Text("Select a subcategory",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.88,
          ),
          itemCount: subs.length,
          itemBuilder: (context, index) => _CategoryCard(
            category: subs[index],
            onTap: () => setState(() => _selectedSubCategory = subs[index]),
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final ItemCategory category;
  final VoidCallback onTap;
  const _CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: category.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(category.icon, color: category.color, size: 26),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(category.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50)),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── ITEM FORM ────────────────────────────────────────────────────────────────

class _ItemForm extends StatefulWidget {
  final String type;
  final ItemCategory? parentCategory;
  final ItemCategory? subCategory;
  const _ItemForm({required this.type, this.parentCategory, this.subCategory});

  @override
  State<_ItemForm> createState() => _ItemFormState();
}

class _ItemFormState extends State<_ItemForm> {
  final _titleController       = TextEditingController();
  final _priceController       = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stockController       = TextEditingController(text: '1');
  final _sellerNameController  = TextEditingController();

  File? _imageFile;
  String _selectedCondition = 'Used - Good';
  bool _isUploading       = false;
  bool _isSearchingSeller = false;
  bool _sellerVerified    = false;
  String? _sellerPhone;
  String? _sellerEmail;

  final List<String> _conditions = ['New', 'Used - Like New', 'Used - Good', 'Used - Fair'];

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _stockController.dispose();
    _sellerNameController.dispose();
    super.dispose();
  }

  // ─── WhatsApp launcher ───────────────────────────────────────────────────

  Future<void> _openWhatsApp() async {
    if (_sellerPhone == null || _sellerPhone!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No phone number available for this seller")),
      );
      return;
    }
    final phone = _sellerPhone!.replaceAll(RegExp(r'\D'), '');
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid phone number")),
      );
      return;
    }
    final Uri whatsappUri = Uri.parse('https://wa.me/$phone');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("WhatsApp is not installed or the number is invalid"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ─── Seller lookup ───────────────────────────────────────────────────────

  Future<void> _lookupSeller() async {
    final name = _sellerNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter your seller name")));
      return;
    }
    setState(() { _isSearchingSeller = true; _sellerVerified = false; });
    try {
      final response = await http.post(
        Uri.parse('$firestoreUrl:runQuery'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'structuredQuery': {
            'from': [{'collectionId': 'sellers'}],
            'where': {'fieldFilter': {'field': {'fieldPath': 'name'}, 'op': 'EQUAL', 'value': {'stringValue': name}}},
            'limit': 1,
          }
        }),
      );
      if (response.statusCode == 200) {
        final results = jsonDecode(response.body) as List;
        final doc = results.isNotEmpty ? results[0]['document'] : null;
        if (doc != null) {
          final fields = doc['fields'] as Map<String, dynamic>;
          setState(() {
            _sellerVerified = true;
            _sellerPhone = fields['phone']?['stringValue'] ?? '';
            _sellerEmail = fields['email']?['stringValue'] ?? '';
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("No seller profile found. Please create one first."),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Seller lookup error: $e");
    } finally {
      if (mounted) setState(() => _isSearchingSeller = false);
    }
  }

  // ─── Image picker ────────────────────────────────────────────────────────

  Future<void> _pickImage() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text("Add Photo", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: GestureDetector(
                onTap: () async { Navigator.pop(ctx); await _getImage(ImageSource.camera); },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90E2).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Column(children: [
                    Icon(Icons.camera_alt_outlined, size: 36, color: Color(0xFF4A90E2)),
                    SizedBox(height: 8),
                    Text("Camera", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF4A90E2))),
                  ]),
                ),
              )),
              const SizedBox(width: 16),
              Expanded(child: GestureDetector(
                onTap: () async { Navigator.pop(ctx); await _getImage(ImageSource.gallery); },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF27AE60).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Column(children: [
                    Icon(Icons.photo_library_outlined, size: 36, color: Color(0xFF27AE60)),
                    SizedBox(height: 8),
                    Text("Gallery", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF27AE60))),
                  ]),
                ),
              )),
            ]),
          ]),
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source, imageQuality: 70);
    if (image != null) setState(() => _imageFile = File(image.path));
  }

  // ─── Supabase upload (FIXED) ─────────────────────────────────────────────

  Future<String?> _uploadToSupabase() async {
    if (_imageFile == null) return null;
    try {
      final supabase = Supabase.instance.client;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

      // ── FIX 1: added FileOptions with contentType and upsert:true ──
      await supabase.storage.from('products').upload(
        fileName,
        _imageFile!,
        fileOptions: const FileOptions(
          contentType: 'image/jpeg',
          upsert: true,
        ),
      );

      // ── FIX 2: getPublicUrl never throws, so this is always safe ──
      final publicUrl = supabase.storage.from('products').getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      debugPrint("Supabase upload error: $e");
      // ── FIX 3: show the real error so you can diagnose it ──
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Photo upload failed: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 6),
          ),
        );
      }
      return null;
    }
  }

  // ─── Stock controls ──────────────────────────────────────────────────────

  void _changeStock(int delta) {
    final current = int.tryParse(_stockController.text) ?? 1;
    setState(() => _stockController.text = (current + delta).clamp(0, 9999).toString());
  }

  // ─── Publish product ─────────────────────────────────────────────────────

  Future<void> _uploadProduct() async {
    if (!_sellerVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please verify your seller profile first")),
      );
      return;
    }
    if (_titleController.text.trim().isEmpty || _priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title and Price are required")),
      );
      return;
    }

    final int stock = int.tryParse(_stockController.text) ?? 0;
    setState(() => _isUploading = true);

    try {
      // ── Upload photo first; if it fails we still know why (snackbar shown inside) ──
      String? photoUrl;
      if (_imageFile != null) {
        photoUrl = await _uploadToSupabase();
        // If upload failed, ask user whether to continue without photo
        if (photoUrl == null && mounted) {
          final continueAnyway = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text("Photo Upload Failed"),
              content: const Text("The photo could not be uploaded. Do you want to publish the listing without a photo?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A90E2)),
                  child: const Text("Publish Anyway", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
          if (continueAnyway != true) {
            setState(() => _isUploading = false);
            return;
          }
        }
      }

      final response = await http.post(
        Uri.parse('$firestoreUrl/products'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'fields': {
          'title':            {'stringValue': _titleController.text.trim()},
          'price':            {'stringValue': _priceController.text.trim()},
          'description':      {'stringValue': _descriptionController.text.trim()},
          'category':         {'stringValue': widget.type},
          'parentCategory':   {'stringValue': widget.parentCategory?.label ?? ''},
          'parentCategoryId': {'stringValue': widget.parentCategory?.id ?? ''},
          'subCategory':      {'stringValue': widget.subCategory?.label ?? ''},
          'subCategoryId':    {'stringValue': widget.subCategory?.id ?? ''},
          'condition':        {'stringValue': _selectedCondition},
          'imageUrl':         {'stringValue': photoUrl ?? ''},
          'stock':            {'integerValue': stock},
          'sellerName':       {'stringValue': _sellerNameController.text.trim()},
          'sellerPhone':      {'stringValue': _sellerPhone ?? ''},
          'sellerEmail':      {'stringValue': _sellerEmail ?? ''},
          'createdAt':        {'timestampValue': DateTime.now().toUtc().toIso8601String()},
        }}),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ Item published!"),
              backgroundColor: Color(0xFF27AE60),
            ),
          );
          Navigator.pop(context);
        }
      } else {
        // ── FIX 4: show Firestore error too ──
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to publish: ${response.statusCode} ${response.body}"),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Upload error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final int stock = int.tryParse(_stockController.text) ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category breadcrumb
          if (widget.parentCategory != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.parentCategory!.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(widget.parentCategory!.icon, size: 14, color: widget.parentCategory!.color),
                const SizedBox(width: 6),
                Text(
                  (widget.subCategory != null && widget.subCategory!.id != widget.parentCategory!.id)
                      ? "${widget.parentCategory!.label} › ${widget.subCategory!.label}"
                      : widget.parentCategory!.label,
                  style: TextStyle(
                    color: widget.parentCategory!.color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ]),
            ),

          // Photo picker
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 200, width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _imageFile == null
                  ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.add_a_photo_outlined, size: 44, color: Colors.grey[500]),
                      const SizedBox(height: 8),
                      Text("Tap to add photo", style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                      Text("Camera or Gallery", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                    ])
                  : Stack(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_imageFile!, fit: BoxFit.cover, width: double.infinity, height: 200),
                      ),
                      Positioned(
                        top: 8, right: 8,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.black.withValues(alpha: 0.6),
                            child: const Icon(Icons.edit, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ]),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: "Title", border: OutlineInputBorder()),
          ),
          const SizedBox(height: 15),

          // Price
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Price", prefixText: "\$ ", border: OutlineInputBorder()),
          ),
          const SizedBox(height: 15),

          // Stock
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(children: [
              const Text("Stock", style: TextStyle(fontSize: 16, color: Colors.black54)),
              const Spacer(),
              IconButton(
                onPressed: () => _changeStock(-1),
                icon: const Icon(Icons.remove_circle_outline),
                color: stock <= 0 ? Colors.grey : Colors.redAccent,
              ),
              SizedBox(
                width: 50,
                child: TextField(
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  onChanged: (v) => setState(() {}),
                  decoration: const InputDecoration(border: InputBorder.none),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: stock <= 0 ? Colors.red : Colors.black,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _changeStock(1),
                icon: const Icon(Icons.add_circle_outline),
                color: const Color(0xFF27AE60),
              ),
            ]),
          ),
          if (stock <= 0)
            const Padding(
              padding: EdgeInsets.only(top: 6, left: 4),
              child: Text(
                "⚠️ Stock is 0 — item won't appear in marketplace",
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          const SizedBox(height: 15),

          // Condition
          DropdownButtonFormField(
            initialValue: _selectedCondition,
            decoration: const InputDecoration(labelText: "Condition", border: OutlineInputBorder()),
            items: _conditions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (val) => setState(() => _selectedCondition = val as String),
          ),
          const SizedBox(height: 15),

          // Description
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: "Description", border: OutlineInputBorder()),
          ),
          const SizedBox(height: 20),

          // ─── Seller section ───────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF27AE60).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF27AE60).withValues(alpha: 0.3)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Icon(Icons.store_outlined, color: Color(0xFF27AE60), size: 20),
                SizedBox(width: 8),
                Text("Your Seller Profile",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
              ]),
              const SizedBox(height: 4),
              const Text("Enter your seller name to link this listing.",
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SellerProfilePage()),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  alignment: Alignment.centerLeft,
                ),
                child: const Text(
                  "Don't have a profile? Create one here",
                  style: TextStyle(
                    color: Color(0xFF27AE60),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Seller name + search button
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _sellerNameController,
                    decoration: const InputDecoration(
                      labelText: "Seller Name",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _isSearchingSeller ? null : _lookupSeller,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27AE60),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isSearchingSeller
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.search, color: Colors.white),
                ),
              ]),

              // ─── Verified seller card with WhatsApp button ────────────────
              if (_sellerVerified)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27AE60).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.check_circle, color: Color(0xFF27AE60), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Linked to ${_sellerNameController.text.trim()}\n📞 $_sellerPhone  ✉️ $_sellerEmail",
                              style: const TextStyle(fontSize: 12, color: Color(0xFF27AE60)),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _openWhatsApp,
                            icon: const Icon(Icons.chat, color: Colors.white, size: 18),
                            label: const Text(
                              "Contact on WhatsApp",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF25D366),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ]),
          ),
          const SizedBox(height: 25),

          // Publish button
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: _isUploading ? null : _uploadProduct,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A90E2)),
              child: _isUploading
                  ? const SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text("Publish", style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}*/
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;
import 'package:url_launcher/url_launcher.dart';
import 'add_vehicle.dart';
import 'add_home.dart';
import 'seller_profile_page.dart';
import 'seller_session.dart';

const String projectId = 'marketplaneproducts';
const String firestoreUrl =
    'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents';

// ─── CATEGORY MODEL ──────────────────────────────────────────────────────────

class ItemCategory {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final String? parentId;
  final String? description;

  const ItemCategory({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    this.parentId,
    this.description,
  });
}

const List<ItemCategory> itemCategories = [
  ItemCategory(id: 'electronics',        label: 'Electronics',            icon: Icons.devices_outlined,             color: Color(0xFF4A90E2), description: 'Devices & accessories'),
  ItemCategory(id: 'phones_tablets',     label: 'Phones & Tablets',       icon: Icons.smartphone_outlined,          color: Color(0xFF1E88E5), parentId: 'electronics'),
  ItemCategory(id: 'computers',          label: 'Computers & Laptops',    icon: Icons.laptop_outlined,              color: Color(0xFF1976D2), parentId: 'electronics'),
  ItemCategory(id: 'cameras',            label: 'Cameras',                icon: Icons.camera_alt_outlined,          color: Color(0xFF1565C0), parentId: 'electronics'),
  ItemCategory(id: 'audio',              label: 'Audio & Headphones',     icon: Icons.headphones_outlined,          color: Color(0xFF0D47A1), parentId: 'electronics'),
  ItemCategory(id: 'gaming',             label: 'Gaming & Consoles',      icon: Icons.sports_esports_outlined,      color: Color(0xFF5E35B1), parentId: 'electronics'),
  ItemCategory(id: 'tv_video',           label: 'TVs & Video',            icon: Icons.tv_outlined,                  color: Color(0xFF283593), parentId: 'electronics'),
  ItemCategory(id: 'wearables',          label: 'Wearables',              icon: Icons.watch_outlined,               color: Color(0xFF3949AB), parentId: 'electronics'),
  ItemCategory(id: 'networking',         label: 'Networking & WiFi',      icon: Icons.router_outlined,              color: Color(0xFF1A237E), parentId: 'electronics'),
  ItemCategory(id: 'cables_accessories', label: 'Cables & Accessories',   icon: Icons.usb_outlined,                 color: Color(0xFF4527A0), parentId: 'electronics'),
  ItemCategory(id: 'clothing',           label: 'Clothing & Fashion',     icon: Icons.checkroom_outlined,           color: Color(0xFFE91E8C), description: 'Apparel, shoes & accessories'),
  ItemCategory(id: 'mens_clothing',      label: "Men's Clothing",         icon: Icons.person_outlined,              color: Color(0xFFD81B60), parentId: 'clothing'),
  ItemCategory(id: 'womens_clothing',    label: "Women's Clothing",       icon: Icons.people_outlined,              color: Color(0xFFC2185B), parentId: 'clothing'),
  ItemCategory(id: 'kids_clothing',      label: "Kids' Clothing",         icon: Icons.child_care_outlined,          color: Color(0xFFAD1457), parentId: 'clothing'),
  ItemCategory(id: 'shoes',             label: 'Shoes & Footwear',       icon: Icons.directions_walk_outlined,     color: Color(0xFF880E4F), parentId: 'clothing'),
  ItemCategory(id: 'bags',              label: 'Bags & Luggage',         icon: Icons.luggage_outlined,             color: Color(0xFFF06292), parentId: 'clothing'),
  ItemCategory(id: 'jewelry',           label: 'Jewelry & Watches',      icon: Icons.diamond_outlined,             color: Color(0xFFE91E63), parentId: 'clothing'),
  ItemCategory(id: 'sportswear',        label: 'Sportswear',             icon: Icons.directions_run_outlined,      color: Color(0xFFEC407A), parentId: 'clothing'),
  ItemCategory(id: 'hats_scarves',      label: 'Hats, Scarves & Gloves', icon: Icons.accessibility_outlined,       color: Color(0xFFF48FB1), parentId: 'clothing'),
  ItemCategory(id: 'furniture',          label: 'Furniture & Home',       icon: Icons.chair_outlined,               color: Color(0xFF8D6E63), description: 'Furniture, décor & home essentials'),
  ItemCategory(id: 'living_room',        label: 'Living Room',            icon: Icons.weekend_outlined,             color: Color(0xFF6D4C41), parentId: 'furniture'),
  ItemCategory(id: 'bedroom',            label: 'Bedroom',                icon: Icons.bed_outlined,                 color: Color(0xFF5D4037), parentId: 'furniture'),
  ItemCategory(id: 'office_furniture',   label: 'Office Furniture',       icon: Icons.desk_outlined,                color: Color(0xFF4E342E), parentId: 'furniture'),
  ItemCategory(id: 'outdoor_furniture',  label: 'Outdoor & Garden',       icon: Icons.outdoor_grill_outlined,       color: Color(0xFF3E2723), parentId: 'furniture'),
  ItemCategory(id: 'lighting',           label: 'Lighting',               icon: Icons.light_outlined,               color: Color(0xFFA1887F), parentId: 'furniture'),
  ItemCategory(id: 'home_decor',         label: 'Home Décor',             icon: Icons.format_paint_outlined,        color: Color(0xFFBCAAA4), parentId: 'furniture'),
  ItemCategory(id: 'storage',            label: 'Storage & Organization', icon: Icons.inventory_2_outlined,         color: Color(0xFF795548), parentId: 'furniture'),
  ItemCategory(id: 'books',              label: 'Books & Media',          icon: Icons.menu_book_outlined,           color: Color(0xFF26A69A), description: 'Books, movies, music & magazines'),
  ItemCategory(id: 'fiction',            label: 'Fiction',                icon: Icons.book_outlined,                color: Color(0xFF00897B), parentId: 'books'),
  ItemCategory(id: 'non_fiction',        label: 'Non-Fiction',            icon: Icons.library_books_outlined,       color: Color(0xFF00796B), parentId: 'books'),
  ItemCategory(id: 'textbooks',          label: 'Textbooks & Education',  icon: Icons.school_outlined,              color: Color(0xFF00695C), parentId: 'books'),
  ItemCategory(id: 'sports',             label: 'Sports & Outdoors',      icon: Icons.sports_soccer_outlined,       color: Color(0xFF27AE60), description: 'Sports gear, fitness & outdoor equipment'),
  ItemCategory(id: 'fitness',            label: 'Gym & Fitness',          icon: Icons.fitness_center_outlined,      color: Color(0xFF2E7D32), parentId: 'sports'),
  ItemCategory(id: 'cycling',            label: 'Cycling',                icon: Icons.directions_bike_outlined,     color: Color(0xFF388E3C), parentId: 'sports'),
  ItemCategory(id: 'camping_hiking',     label: 'Camping & Hiking',       icon: Icons.terrain_outlined,             color: Color(0xFF43A047), parentId: 'sports'),
  ItemCategory(id: 'toys',               label: 'Toys & Games',           icon: Icons.toys_outlined,                color: Color(0xFFFF7043), description: 'Toys, board games & educational play'),
  ItemCategory(id: 'board_games',        label: 'Board Games & Puzzles',  icon: Icons.extension_outlined,           color: Color(0xFFE64A19), parentId: 'toys'),
  ItemCategory(id: 'video_games',        label: 'Video Games',            icon: Icons.videogame_asset_outlined,     color: Color(0xFFDD2C00), parentId: 'toys'),
  ItemCategory(id: 'beauty',             label: 'Beauty & Health',        icon: Icons.spa_outlined,                 color: Color(0xFFAB47BC), description: 'Cosmetics, skincare & personal care'),
  ItemCategory(id: 'skincare',           label: 'Skincare',               icon: Icons.face_outlined,                color: Color(0xFF8E24AA), parentId: 'beauty'),
  ItemCategory(id: 'makeup',             label: 'Makeup & Cosmetics',     icon: Icons.brush_outlined,               color: Color(0xFF7B1FA2), parentId: 'beauty'),
  ItemCategory(id: 'kitchen',            label: 'Kitchen & Dining',       icon: Icons.kitchen_outlined,             color: Color(0xFFE67E22), description: 'Cookware, appliances & tableware'),
  ItemCategory(id: 'cookware',           label: 'Cookware & Bakeware',    icon: Icons.soup_kitchen_outlined,        color: Color(0xFFD35400), parentId: 'kitchen'),
  ItemCategory(id: 'small_appliances',   label: 'Small Appliances',       icon: Icons.microwave_outlined,           color: Color(0xFFBA4A00), parentId: 'kitchen'),
  ItemCategory(id: 'tools',              label: 'Tools & DIY',            icon: Icons.handyman_outlined,            color: Color(0xFF546E7A), description: 'Power tools, hand tools & hardware'),
  ItemCategory(id: 'power_tools',        label: 'Power Tools',            icon: Icons.construction_outlined,        color: Color(0xFF455A64), parentId: 'tools'),
  ItemCategory(id: 'hand_tools',         label: 'Hand Tools',             icon: Icons.hardware_outlined,            color: Color(0xFF37474F), parentId: 'tools'),
  ItemCategory(id: 'baby',               label: 'Baby & Kids',            icon: Icons.child_care_outlined,          color: Color(0xFFEC407A), description: 'Baby gear, nursery & kids essentials'),
  ItemCategory(id: 'baby_gear',          label: 'Strollers & Car Seats',  icon: Icons.accessible_outlined,          color: Color(0xFFC2185B), parentId: 'baby'),
  ItemCategory(id: 'music_instruments',  label: 'Music & Instruments',    icon: Icons.music_note_outlined,          color: Color(0xFF5C6BC0), description: 'Instruments & audio equipment'),
  ItemCategory(id: 'guitars',            label: 'Guitars & Bass',         icon: Icons.music_note_outlined,          color: Color(0xFF3949AB), parentId: 'music_instruments'),
  ItemCategory(id: 'art',                label: 'Art & Collectibles',     icon: Icons.palette_outlined,             color: Color(0xFFD4AC0D), description: 'Art, antiques, crafts & collectibles'),
  ItemCategory(id: 'paintings_prints',   label: 'Paintings & Prints',     icon: Icons.image_outlined,               color: Color(0xFFB7950B), parentId: 'art'),
  ItemCategory(id: 'pets',               label: 'Pet Supplies',           icon: Icons.pets_outlined,                color: Color(0xFF795548), description: 'Food, accessories & care for pets'),
  ItemCategory(id: 'dog_supplies',       label: 'Dog Supplies',           icon: Icons.pets_outlined,                color: Color(0xFF6D4C41), parentId: 'pets'),
  ItemCategory(id: 'other',              label: 'Other',                  icon: Icons.category_outlined,            color: Color(0xFF90A4AE), description: 'Anything that doesn\'t fit above'),
  ItemCategory(id: 'office_supplies',    label: 'Office Supplies',        icon: Icons.business_center_outlined,     color: Color(0xFF78909C), parentId: 'other'),
  ItemCategory(id: 'services',           label: 'Services & Rentals',     icon: Icons.miscellaneous_services_outlined, color: Color(0xFFB0BEC5), parentId: 'other'),
];

List<ItemCategory> get parentCategories =>
    itemCategories.where((c) => c.parentId == null).toList();

List<ItemCategory> subcategoriesOf(String parentId) =>
    itemCategories.where((c) => c.parentId == parentId).toList();

const Set<String> _skipSubCategoryIds = {'other'};

// ─── PAGE ─────────────────────────────────────────────────────────────────────

class AddItemPage extends StatefulWidget {
  /// Pass this to open the page in edit mode with the form pre-filled.
  final Map<String, dynamic>? editItem;

  const AddItemPage({super.key, this.editItem});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  String? _selectedType;
  ItemCategory? _selectedParentCategory;
  ItemCategory? _selectedSubCategory;

  /// True when we jumped straight into the form because editItem was provided.
  bool get _isEditMode => widget.editItem != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      // Skip type / category selection — jump straight to the form.
      _selectedType = 'Item';
      final item = widget.editItem!;

      // Restore parent category from saved parentCategoryId
      final parentId = item['parentCategoryId']?.toString() ?? '';
      if (parentId.isNotEmpty) {
        _selectedParentCategory = itemCategories
            .where((c) => c.id == parentId)
            .cast<ItemCategory?>()
            .firstWhere((_) => true, orElse: () => null);
      }

      // Restore sub category from saved subCategoryId
      final subId = item['subCategoryId']?.toString() ?? '';
      if (subId.isNotEmpty) {
        _selectedSubCategory = itemCategories
            .where((c) => c.id == subId)
            .cast<ItemCategory?>()
            .firstWhere((_) => true, orElse: () => null);
      }

      // If only a parent was saved (no sub), treat parent as selected sub too
      // so the form renders immediately.
      if (_selectedParentCategory != null && _selectedSubCategory == null) {
        _selectedSubCategory = _selectedParentCategory;
      }
    }
  }

  String get _appBarTitle {
    if (_isEditMode) return 'Edit Listing';
    if (_selectedType == null) return "What are you selling?";
    if (_selectedType == "Item" && _selectedParentCategory == null) return "Item Category";
    if (_selectedType == "Item" && _selectedSubCategory == null) return _selectedParentCategory!.label;
    return "New Listing";
  }

  void _handleBack() {
    if (_isEditMode) {
      Navigator.pop(context);
      return;
    }
    if (_selectedSubCategory != null) {
      if (_selectedParentCategory != null &&
          _skipSubCategoryIds.contains(_selectedParentCategory!.id)) {
        setState(() {
          _selectedSubCategory = null;
          _selectedParentCategory = null;
        });
      } else {
        setState(() => _selectedSubCategory = null);
      }
    } else if (_selectedParentCategory != null) {
      setState(() => _selectedParentCategory = null);
    } else {
      setState(() => _selectedType = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: (_selectedType != null || _isEditMode)
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _handleBack)
            : IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Edit mode: go straight to form
    if (_isEditMode) {
      return _ItemForm(
        type: 'Item',
        parentCategory: _selectedParentCategory,
        subCategory: _selectedSubCategory,
        editItem: widget.editItem,
      );
    }

    if (_selectedType == null) return _buildTypeSelector();
    if (_selectedType == "Item") {
      if (_selectedParentCategory == null) return _buildParentCategories();
      if (_selectedSubCategory == null) return _buildSubCategories(_selectedParentCategory!);
    }
    return _ItemForm(
      type: _selectedType!,
      parentCategory: _selectedParentCategory,
      subCategory: _selectedSubCategory,
    );
  }

  Widget _buildTypeSelector() {
    final options = [
      {'label': 'Item',    'icon': Icons.shopping_bag_outlined,  'color': const Color(0xFF4A90E2)},
      {'label': 'Vehicle', 'icon': Icons.directions_car_outlined, 'color': const Color(0xFF27AE60)},
      {'label': 'Home',    'icon': Icons.home_outlined,           'color': const Color(0xFFE67E22)},
    ];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Choose a category",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
          const SizedBox(height: 8),
          const Text("Select the type of listing you want to create.",
              style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 32),
          ...options.map((opt) => GestureDetector(
                onTap: () {
                  if (opt['label'] == 'Vehicle') {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddVehiclePage()));
                  } else if (opt['label'] == 'Home') {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddHomePage()));
                  } else {
                    setState(() => _selectedType = opt['label'] as String);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Row(children: [
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        color: (opt['color'] as Color).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(opt['icon'] as IconData, color: opt['color'] as Color, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(opt['label'] as String,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  ]),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildParentCategories() {
    final parents = parentCategories;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Select a category",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
        const SizedBox(height: 4),
        const Text("What kind of item are you selling?",
            style: TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.88,
          ),
          itemCount: parents.length,
          itemBuilder: (context, index) => _CategoryCard(
            category: parents[index],
            onTap: () {
              final cat = parents[index];
              if (_skipSubCategoryIds.contains(cat.id)) {
                setState(() {
                  _selectedParentCategory = cat;
                  _selectedSubCategory = cat;
                });
              } else {
                setState(() => _selectedParentCategory = cat);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubCategories(ItemCategory parent) {
    final subs = subcategoriesOf(parent.id);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: parent.color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: parent.color.withValues(alpha: 0.25)),
          ),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: parent.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: Icon(parent.icon, color: parent.color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(parent.label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: parent.color)),
                if (parent.description != null)
                  Text(parent.description!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ]),
            ),
          ]),
        ),
        const Text("Select a subcategory",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.88,
          ),
          itemCount: subs.length,
          itemBuilder: (context, index) => _CategoryCard(
            category: subs[index],
            onTap: () => setState(() => _selectedSubCategory = subs[index]),
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final ItemCategory category;
  final VoidCallback onTap;
  const _CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: category.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(category.icon, color: category.color, size: 26),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(category.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50)),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── ITEM FORM ────────────────────────────────────────────────────────────────

class _ItemForm extends StatefulWidget {
  final String type;
  final ItemCategory? parentCategory;
  final ItemCategory? subCategory;

  /// Non-null when editing an existing listing.
  final Map<String, dynamic>? editItem;

  const _ItemForm({
    required this.type,
    this.parentCategory,
    this.subCategory,
    this.editItem,
  });

  @override
  State<_ItemForm> createState() => _ItemFormState();
}

class _ItemFormState extends State<_ItemForm> {
  final _titleController       = TextEditingController();
  final _priceController       = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stockController       = TextEditingController(text: '1');
  final _sellerNameController  = TextEditingController();
Future<void> _autoFillSellerFromSession() async {
  final name = await SellerSession.getSellerName();
  if (name != null && name.isNotEmpty && mounted) {
    setState(() => _sellerNameController.text = name);
    await _lookupSeller();
  }
}
  File? _imageFile;
  String _selectedCondition = 'Used - Good';
  bool _isUploading       = false;
  bool _isSearchingSeller = false;
  bool _sellerVerified    = false;
  String? _sellerPhone;
  String? _sellerEmail;

  /// Keeps the existing remote image URL when editing (and no new image chosen).
  String? _existingImageUrl;

  bool get _isEditMode => widget.editItem != null;

  final List<String> _conditions = ['New', 'Used - Like New', 'Used - Good', 'Used - Fair'];

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final item = widget.editItem!;
      _titleController.text       = item['title']?.toString()       ?? '';
      _priceController.text       = item['price']?.toString()       ?? '';
      _descriptionController.text = item['description']?.toString() ?? '';
      _stockController.text       = (item['stock'] ?? 1).toString();
      _sellerNameController.text  = item['sellerName']?.toString()  ?? '';
      _existingImageUrl           = item['imageUrl']?.toString();
      _sellerPhone                = item['sellerPhone']?.toString();
      _sellerEmail                = item['sellerEmail']?.toString();

      // Auto-verify seller if we already have their data
      if (_sellerNameController.text.isNotEmpty &&
          _sellerPhone != null && _sellerPhone!.isNotEmpty) {
        _sellerVerified = true;
      }

      final condition = item['condition']?.toString() ?? '';
      if (_conditions.contains(condition)) _selectedCondition = condition;
    }
     else {
  // ← ADD THIS
  _autoFillSellerFromSession();
}
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _stockController.dispose();
    _sellerNameController.dispose();
    super.dispose();
  }

  // ─── WhatsApp launcher ───────────────────────────────────────────────────

  Future<void> _openWhatsApp() async {
    if (_sellerPhone == null || _sellerPhone!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No phone number available for this seller")),
      );
      return;
    }
    final phone = _sellerPhone!.replaceAll(RegExp(r'\D'), '');
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid phone number")),
      );
      return;
    }
    final Uri whatsappUri = Uri.parse('https://wa.me/$phone');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("WhatsApp is not installed or the number is invalid"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ─── Seller lookup ───────────────────────────────────────────────────────

  Future<void> _lookupSeller() async {
    final name = _sellerNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter your seller name")));
      return;
    }
    setState(() { _isSearchingSeller = true; _sellerVerified = false; });
    try {
      final response = await http.post(
        Uri.parse('$firestoreUrl:runQuery'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'structuredQuery': {
            'from': [{'collectionId': 'sellers'}],
            'where': {'fieldFilter': {'field': {'fieldPath': 'name'}, 'op': 'EQUAL', 'value': {'stringValue': name}}},
            'limit': 1,
          }
        }),
      );
      if (response.statusCode == 200) {
        final results = jsonDecode(response.body) as List;
        final doc = results.isNotEmpty ? results[0]['document'] : null;
        if (doc != null) {
          final fields = doc['fields'] as Map<String, dynamic>;
          setState(() {
            _sellerVerified = true;
            _sellerPhone = fields['phone']?['stringValue'] ?? '';
            _sellerEmail = fields['email']?['stringValue'] ?? '';
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("No seller profile found. Please create one first."),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Seller lookup error: $e");
    } finally {
      if (mounted) setState(() => _isSearchingSeller = false);
    }
  }

  // ─── Image picker ────────────────────────────────────────────────────────

  Future<void> _pickImage() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text("Add Photo", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: GestureDetector(
                onTap: () async { Navigator.pop(ctx); await _getImage(ImageSource.camera); },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90E2).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Column(children: [
                    Icon(Icons.camera_alt_outlined, size: 36, color: Color(0xFF4A90E2)),
                    SizedBox(height: 8),
                    Text("Camera", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF4A90E2))),
                  ]),
                ),
              )),
              const SizedBox(width: 16),
              Expanded(child: GestureDetector(
                onTap: () async { Navigator.pop(ctx); await _getImage(ImageSource.gallery); },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF27AE60).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Column(children: [
                    Icon(Icons.photo_library_outlined, size: 36, color: Color(0xFF27AE60)),
                    SizedBox(height: 8),
                    Text("Gallery", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF27AE60))),
                  ]),
                ),
              )),
            ]),
          ]),
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source, imageQuality: 70);
    if (image != null) setState(() => _imageFile = File(image.path));
  }

  // ─── Supabase upload ─────────────────────────────────────────────────────

  Future<String?> _uploadToSupabase() async {
    if (_imageFile == null) return null;
    try {
      final supabase = Supabase.instance.client;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      await supabase.storage.from('products').upload(
        fileName,
        _imageFile!,
        fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
      );
      return supabase.storage.from('products').getPublicUrl(fileName);
    } catch (e) {
      debugPrint("Supabase upload error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Photo upload failed: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 6),
          ),
        );
      }
      return null;
    }
  }

  // ─── Stock controls ──────────────────────────────────────────────────────

  void _changeStock(int delta) {
    final current = int.tryParse(_stockController.text) ?? 1;
    setState(() => _stockController.text = (current + delta).clamp(0, 9999).toString());
  }

  // ─── Save (create or update) ─────────────────────────────────────────────

  Future<void> _saveProduct() async {
    if (!_sellerVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please verify your seller profile first")),
      );
      return;
    }
    if (_titleController.text.trim().isEmpty || _priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title and Price are required")),
      );
      return;
    }

    final int stock = int.tryParse(_stockController.text) ?? 0;
    setState(() => _isUploading = true);

    try {
      // Resolve final image URL
      String? photoUrl = _existingImageUrl; // keep old one by default

      if (_imageFile != null) {
        // User picked a new image — upload it
        final uploaded = await _uploadToSupabase();
        if (uploaded == null && mounted) {
          final continueAnyway = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text("Photo Upload Failed"),
              content: const Text("The photo could not be uploaded. Do you want to save the listing without the new photo?"),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A90E2)),
                  child: const Text("Save Anyway", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
          if (continueAnyway != true) {
            setState(() => _isUploading = false);
            return;
          }
          // Keep old URL if upload failed but user chose to continue
        } else {
          photoUrl = uploaded;
        }
      }

      final fields = {
        'title':            {'stringValue': _titleController.text.trim()},
        'price':            {'stringValue': _priceController.text.trim()},
        'description':      {'stringValue': _descriptionController.text.trim()},
        'category':         {'stringValue': widget.type},
        'parentCategory':   {'stringValue': widget.parentCategory?.label ?? ''},
        'parentCategoryId': {'stringValue': widget.parentCategory?.id ?? ''},
        'subCategory':      {'stringValue': widget.subCategory?.label ?? ''},
        'subCategoryId':    {'stringValue': widget.subCategory?.id ?? ''},
        'condition':        {'stringValue': _selectedCondition},
        'imageUrl':         {'stringValue': photoUrl ?? ''},
        'stock':  {'integerValue': stock.toString()},
        'status': {'stringValue': 'available'},
        'sellerName':       {'stringValue': _sellerNameController.text.trim()},
        'sellerPhone':      {'stringValue': _sellerPhone ?? ''},
        'sellerEmail':      {'stringValue': _sellerEmail ?? ''},
      };

      http.Response response;

      if (_isEditMode) {
        // ── PATCH existing document ──────────────────────────────────────
        final docId = widget.editItem!['id']?.toString() ?? '';
        final updateMask = fields.keys.map((k) => 'updateMask.fieldPaths=$k').join('&');
       final collection = widget.editItem!['collection']?.toString() ?? 'products';
final url = '$firestoreUrl/$collection/$docId?$updateMask';
        response = await http.patch(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'fields': fields}),
        );
      } else {
        // ── POST new document ────────────────────────────────────────────
        fields['createdAt'] = {'timestampValue': DateTime.now().toUtc().toIso8601String()};
        response = await http.post(
          Uri.parse('$firestoreUrl/products'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'fields': fields}),
        );
      }

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditMode ? "✅ Listing updated!" : "✅ Item published!"),
              backgroundColor: const Color(0xFF27AE60),
            ),
          );
          Navigator.pop(context, 'refresh');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed: ${response.statusCode} ${response.body}"),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Save error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final int stock = int.tryParse(_stockController.text) ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category breadcrumb
          if (widget.parentCategory != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.parentCategory!.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(widget.parentCategory!.icon, size: 14, color: widget.parentCategory!.color),
                const SizedBox(width: 6),
                Text(
                  (widget.subCategory != null && widget.subCategory!.id != widget.parentCategory!.id)
                      ? "${widget.parentCategory!.label} › ${widget.subCategory!.label}"
                      : widget.parentCategory!.label,
                  style: TextStyle(
                    color: widget.parentCategory!.color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ]),
            ),

          // ── Photo area ──────────────────────────────────────────────────
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 200, width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _imageFile != null
                  // New image picked by user
                  ? Stack(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_imageFile!, fit: BoxFit.cover, width: double.infinity, height: 200),
                      ),
                      Positioned(
                        top: 8, right: 8,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.black.withValues(alpha: 0.6),
                          child: const Icon(Icons.edit, size: 16, color: Colors.white),
                        ),
                      ),
                    ])
                  : (_existingImageUrl != null && _existingImageUrl!.isNotEmpty)
                      // Show existing remote image
                      ? Stack(children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _existingImageUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 200,
                              errorBuilder: (_, __, ___) => _photoPlaceholder(),
                            ),
                          ),
                          Positioned(
                            top: 8, right: 8,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.black.withValues(alpha: 0.6),
                              child: const Icon(Icons.edit, size: 16, color: Colors.white),
                            ),
                          ),
                          Positioned(
                            bottom: 8, left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.55),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text("Tap to change photo",
                                  style: TextStyle(color: Colors.white, fontSize: 11)),
                            ),
                          ),
                        ])
                      // No image at all
                      : _photoPlaceholder(),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: "Title", border: OutlineInputBorder()),
          ),
          const SizedBox(height: 15),

          // Price
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Price", prefixText: "\$ ", border: OutlineInputBorder()),
          ),
          const SizedBox(height: 15),

          // Stock
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(children: [
              const Text("Stock", style: TextStyle(fontSize: 16, color: Colors.black54)),
              const Spacer(),
              IconButton(
                onPressed: () => _changeStock(-1),
                icon: const Icon(Icons.remove_circle_outline),
                color: stock <= 0 ? Colors.grey : Colors.redAccent,
              ),
              SizedBox(
                width: 50,
                child: TextField(
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  onChanged: (v) => setState(() {}),
                  decoration: const InputDecoration(border: InputBorder.none),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: stock <= 0 ? Colors.red : Colors.black,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _changeStock(1),
                icon: const Icon(Icons.add_circle_outline),
                color: const Color(0xFF27AE60),
              ),
            ]),
          ),
          if (stock <= 0)
            const Padding(
              padding: EdgeInsets.only(top: 6, left: 4),
              child: Text(
                "⚠️ Stock is 0 — item won't appear in marketplace",
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          const SizedBox(height: 15),

          // Condition
          DropdownButtonFormField(
            initialValue: _selectedCondition,
            decoration: const InputDecoration(labelText: "Condition", border: OutlineInputBorder()),
            items: _conditions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (val) => setState(() => _selectedCondition = val as String),
          ),
          const SizedBox(height: 15),

          // Description
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: "Description", border: OutlineInputBorder()),
          ),
          const SizedBox(height: 20),

          // ─── Seller section ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF27AE60).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF27AE60).withValues(alpha: 0.3)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Icon(Icons.store_outlined, color: Color(0xFF27AE60), size: 20),
                SizedBox(width: 8),
                Text("Your Seller Profile",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
              ]),
              const SizedBox(height: 4),
              const Text("Enter your seller name to link this listing.",
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SellerProfilePage()),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  alignment: Alignment.centerLeft,
                ),
                child: const Text(
                  "Don't have a profile? Create one here",
                  style: TextStyle(
                    color: Color(0xFF27AE60),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Seller name + search button
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _sellerNameController,
                    decoration: const InputDecoration(
                      labelText: "Seller Name",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _isSearchingSeller ? null : _lookupSeller,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27AE60),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isSearchingSeller
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.search, color: Colors.white),
                ),
              ]),

              if (_sellerVerified)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27AE60).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        const Icon(Icons.check_circle, color: Color(0xFF27AE60), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Linked to ${_sellerNameController.text.trim()}\n📞 $_sellerPhone  ✉️ $_sellerEmail",
                            style: const TextStyle(fontSize: 12, color: Color(0xFF27AE60)),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _openWhatsApp,
                          icon: const Icon(Icons.chat, color: Colors.white, size: 18),
                          label: const Text("Contact on WhatsApp",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
            ]),
          ),
          const SizedBox(height: 25),

          // Save / Publish button
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: _isUploading ? null : _saveProduct,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A90E2)),
              child: _isUploading
                  ? const SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      _isEditMode ? "Save Changes" : "Publish",
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _photoPlaceholder() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.add_a_photo_outlined, size: 44, color: Colors.grey[500]),
      const SizedBox(height: 8),
      Text("Tap to add photo", style: TextStyle(color: Colors.grey[500], fontSize: 14)),
      Text("Camera or Gallery", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
    ]);
  }
}