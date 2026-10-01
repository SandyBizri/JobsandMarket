/*import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;
import 'seller_profile_page.dart';

const String _projectId = 'marketplaneproducts';
const String _firestoreUrl =
    'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents';

class VehicleCategory {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final String? parentId;
  final String? description;

  const VehicleCategory({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    this.parentId,
    this.description,
  });
}

const List<VehicleCategory> vehicleCategories = [
  VehicleCategory(id: 'cars',          label: 'Cars',              icon: Icons.directions_car_outlined,   color: Color(0xFF4A90E2), description: 'Sedans, SUVs, coupes & more'),
  VehicleCategory(id: 'sedan',         label: 'Sedan',             icon: Icons.directions_car_outlined,   color: Color(0xFF1E88E5), parentId: 'cars'),
  VehicleCategory(id: 'suv',           label: 'SUV / Crossover',   icon: Icons.directions_car_outlined,   color: Color(0xFF1976D2), parentId: 'cars'),
  VehicleCategory(id: 'coupe',         label: 'Coupe',             icon: Icons.directions_car_outlined,   color: Color(0xFF1565C0), parentId: 'cars'),
  VehicleCategory(id: 'hatchback',     label: 'Hatchback',         icon: Icons.directions_car_outlined,   color: Color(0xFF0D47A1), parentId: 'cars'),
  VehicleCategory(id: 'convertible',   label: 'Convertible',       icon: Icons.directions_car_outlined,   color: Color(0xFF283593), parentId: 'cars'),
  VehicleCategory(id: 'wagon',         label: 'Station Wagon',     icon: Icons.directions_car_outlined,   color: Color(0xFF3949AB), parentId: 'cars'),
  VehicleCategory(id: 'minivan',       label: 'Minivan',           icon: Icons.airport_shuttle_outlined,  color: Color(0xFF5C6BC0), parentId: 'cars'),
  VehicleCategory(id: 'pickup_car',    label: 'Pickup Truck',      icon: Icons.local_shipping_outlined,   color: Color(0xFF7986CB), parentId: 'cars'),
  VehicleCategory(id: 'electric_car',  label: 'Electric / Hybrid', icon: Icons.electric_car_outlined,     color: Color(0xFF4527A0), parentId: 'cars'),
  VehicleCategory(id: 'luxury_car',    label: 'Luxury & Sports',   icon: Icons.directions_car_outlined,   color: Color(0xFF1A237E), parentId: 'cars'),
  VehicleCategory(id: 'motorcycles',   label: 'Motorcycles',       icon: Icons.two_wheeler_outlined,      color: Color(0xFFE67E22), description: 'Sport, cruiser, scooters & more'),
  VehicleCategory(id: 'sport_bike',    label: 'Sport Bike',        icon: Icons.two_wheeler_outlined,      color: Color(0xFFD35400), parentId: 'motorcycles'),
  VehicleCategory(id: 'cruiser',       label: 'Cruiser',           icon: Icons.two_wheeler_outlined,      color: Color(0xFFBA4A00), parentId: 'motorcycles'),
  VehicleCategory(id: 'scooter',       label: 'Scooter / Moped',   icon: Icons.two_wheeler_outlined,      color: Color(0xFFA04000), parentId: 'motorcycles'),
  VehicleCategory(id: 'dirt_bike',     label: 'Dirt Bike / Off-Road', icon: Icons.two_wheeler_outlined,   color: Color(0xFF873600), parentId: 'motorcycles'),
  VehicleCategory(id: 'adventure',     label: 'Adventure / Touring', icon: Icons.two_wheeler_outlined,    color: Color(0xFFEB984E), parentId: 'motorcycles'),
  VehicleCategory(id: 'electric_moto', label: 'Electric Motorcycle', icon: Icons.electric_moped_outlined, color: Color(0xFFCA6F1E), parentId: 'motorcycles'),
  VehicleCategory(id: 'atv',           label: 'ATV / Quad',        icon: Icons.two_wheeler_outlined,      color: Color(0xFFF0A500), parentId: 'motorcycles'),
  VehicleCategory(id: 'trucks',        label: 'Trucks',            icon: Icons.local_shipping_outlined,   color: Color(0xFF27AE60), description: 'Pickups, heavy trucks & commercial'),
  VehicleCategory(id: 'light_pickup',  label: 'Light Pickup',      icon: Icons.local_shipping_outlined,   color: Color(0xFF2E7D32), parentId: 'trucks'),
  VehicleCategory(id: 'heavy_truck',   label: 'Heavy Truck',       icon: Icons.local_shipping_outlined,   color: Color(0xFF388E3C), parentId: 'trucks'),
  VehicleCategory(id: 'semi_truck',    label: 'Semi / 18-Wheeler', icon: Icons.local_shipping_outlined,   color: Color(0xFF43A047), parentId: 'trucks'),
  VehicleCategory(id: 'van_cargo',     label: 'Cargo Van',         icon: Icons.airport_shuttle_outlined,  color: Color(0xFF81C784), parentId: 'trucks'),
  VehicleCategory(id: 'boats',         label: 'Boats & Watercraft',icon: Icons.directions_boat_outlined,  color: Color(0xFF1ABC9C), description: 'Speedboats, sailboats, jet skis & more'),
  VehicleCategory(id: 'speedboat',     label: 'Speedboat',         icon: Icons.directions_boat_outlined,  color: Color(0xFF17A589), parentId: 'boats'),
  VehicleCategory(id: 'sailboat',      label: 'Sailboat',          icon: Icons.directions_boat_outlined,  color: Color(0xFF148F77), parentId: 'boats'),
  VehicleCategory(id: 'yacht',         label: 'Yacht',             icon: Icons.directions_boat_outlined,  color: Color(0xFF117A65), parentId: 'boats'),
  VehicleCategory(id: 'jet_ski',       label: 'Jet Ski / PWC',     icon: Icons.pool_outlined,             color: Color(0xFF0E6655), parentId: 'boats'),
  VehicleCategory(id: 'fishing_boat',  label: 'Fishing Boat',      icon: Icons.directions_boat_outlined,  color: Color(0xFF76D7C4), parentId: 'boats'),
  VehicleCategory(id: 'buses',         label: 'Buses & Vans',      icon: Icons.directions_bus_outlined,   color: Color(0xFF9B59B6), description: 'Minibuses, coaches, passenger vans'),
  VehicleCategory(id: 'minibus',       label: 'Minibus',           icon: Icons.directions_bus_outlined,   color: Color(0xFF8E44AD), parentId: 'buses'),
  VehicleCategory(id: 'coach_bus',     label: 'Coach / Full Bus',  icon: Icons.directions_bus_outlined,   color: Color(0xFF7D3C98), parentId: 'buses'),
  VehicleCategory(id: 'passenger_van', label: 'Passenger Van',     icon: Icons.airport_shuttle_outlined,  color: Color(0xFFBB8FCE), parentId: 'buses'),
  VehicleCategory(id: 'camper_van',    label: 'Camper / RV',       icon: Icons.airport_shuttle_outlined,  color: Color(0xFFA569BD), parentId: 'buses'),
  VehicleCategory(id: 'equipment',     label: 'Heavy Equipment',   icon: Icons.construction_outlined,    color: Color(0xFFE74C3C), description: 'Construction, farming & industrial'),
  VehicleCategory(id: 'excavator',     label: 'Excavator',         icon: Icons.construction_outlined,    color: Color(0xFFC0392B), parentId: 'equipment'),
  VehicleCategory(id: 'bulldozer',     label: 'Bulldozer',         icon: Icons.construction_outlined,    color: Color(0xFFAB2323), parentId: 'equipment'),
  VehicleCategory(id: 'forklift',      label: 'Forklift',          icon: Icons.construction_outlined,    color: Color(0xFF922B21), parentId: 'equipment'),
  VehicleCategory(id: 'tractor',       label: 'Tractor / Farm',    icon: Icons.agriculture_outlined,     color: Color(0xFFEC7063), parentId: 'equipment'),
  VehicleCategory(id: 'bicycles',      label: 'Bicycles & Micro',  icon: Icons.directions_bike_outlined,  color: Color(0xFF16A085), description: 'Bikes, e-bikes, scooters & skateboards'),
  VehicleCategory(id: 'road_bike',     label: 'Road Bike',         icon: Icons.directions_bike_outlined,  color: Color(0xFF138D75), parentId: 'bicycles'),
  VehicleCategory(id: 'mountain_bike', label: 'Mountain Bike',     icon: Icons.directions_bike_outlined,  color: Color(0xFF117A65), parentId: 'bicycles'),
  VehicleCategory(id: 'ebike',         label: 'Electric Bike',     icon: Icons.electric_bike_outlined,    color: Color(0xFF0E6655), parentId: 'bicycles'),
  VehicleCategory(id: 'electric_scooter', label: 'Electric Scooter', icon: Icons.electric_scooter_outlined, color: Color(0xFF76D7C4), parentId: 'bicycles'),
  VehicleCategory(id: 'kids_bike',     label: 'Kids Bicycle',      icon: Icons.directions_bike_outlined,  color: Color(0xFF48C9B0), parentId: 'bicycles'),
  VehicleCategory(id: 'other_vehicle', label: 'Other',             icon: Icons.commute_outlined,          color: Color(0xFF90A4AE), description: 'Anything else'),
  VehicleCategory(id: 'trailer',       label: 'Trailer',           icon: Icons.rv_hookup_outlined,        color: Color(0xFF78909C), parentId: 'other_vehicle'),
  VehicleCategory(id: 'golf_cart',     label: 'Golf Cart',         icon: Icons.electric_car_outlined,     color: Color(0xFF546E7A), parentId: 'other_vehicle'),
  VehicleCategory(id: 'other_misc',    label: 'Other Vehicle',     icon: Icons.commute_outlined,          color: Color(0xFFB0BEC5), parentId: 'other_vehicle'),
];

List<VehicleCategory> get parentVehicleCategories =>
    vehicleCategories.where((c) => c.parentId == null).toList();

List<VehicleCategory> vehicleSubcategoriesOf(String parentId) =>
    vehicleCategories.where((c) => c.parentId == parentId).toList();

// Parent categories that skip the subcategory step and open the form directly
const Set<String> _skipVehicleSubIds = {'other_vehicle'};

class AddVehiclePage extends StatefulWidget {
  const AddVehiclePage({super.key});

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  VehicleCategory? _selectedParent;
  VehicleCategory? _selectedSub;

  String get _appBarTitle {
    if (_selectedParent == null) return "Vehicle Type";
    if (_selectedSub == null) return _selectedParent!.label;
    return "New Vehicle Listing";
  }

  void _handleBack() {
    if (_selectedSub != null) {
      // If parent is a skip category, going back should clear both parent+sub
      if (_selectedParent != null &&
          _skipVehicleSubIds.contains(_selectedParent!.id)) {
        setState(() {
          _selectedSub = null;
          _selectedParent = null;
        });
      } else {
        setState(() => _selectedSub = null);
      }
    } else if (_selectedParent != null) {
      setState(() => _selectedParent = null);
    } else {
      Navigator.pop(context);
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
        leading: (_selectedParent != null)
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _handleBack)
            : IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_selectedParent == null) return _buildParentGrid();
    if (_selectedSub == null) return _buildSubGrid(_selectedParent!);
    return _VehicleForm(parent: _selectedParent!, sub: _selectedSub!);
  }

  Widget _buildParentGrid() {
    final parents = parentVehicleCategories;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("What are you selling?",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
        const SizedBox(height: 4),
        const Text("Select the type of vehicle.", style: TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 1.55),
          itemCount: parents.length,
          itemBuilder: (context, index) {
            final cat = parents[index];
            return GestureDetector(
              onTap: () {
                if (_skipVehicleSubIds.contains(cat.id)) {
                  setState(() {
                    _selectedParent = cat;
                    _selectedSub = cat;
                  });
                } else {
                  setState(() => _selectedParent = cat);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(color: cat.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                    child: Icon(cat.icon, color: cat.color, size: 28),
                  ),
                  const SizedBox(height: 10),
                  Text(cat.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
                  if (cat.description != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      child: Text(cat.description!, textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 10, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                ]),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSubGrid(VehicleCategory parent) {
    final subs = vehicleSubcategoriesOf(parent.id);
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
              width: 42, height: 42,
              decoration: BoxDecoration(color: parent.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: Icon(parent.icon, color: parent.color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(parent.label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: parent.color)),
              if (parent.description != null)
                Text(parent.description!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ])),
          ]),
        ),
        const Text("Select a type",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.9),
          itemCount: subs.length,
          itemBuilder: (context, index) {
            final sub = subs[index];
            return GestureDetector(
              onTap: () => setState(() => _selectedSub = sub),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(color: sub.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                    child: Icon(sub.icon, color: sub.color, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(sub.label, textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50)),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),
                ]),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ─── VEHICLE FORM ─────────────────────────────────────────────────────────────

class _VehicleForm extends StatefulWidget {
  final VehicleCategory parent;
  final VehicleCategory sub;
  const _VehicleForm({required this.parent, required this.sub});

  @override
  State<_VehicleForm> createState() => _VehicleFormState();
}

class _VehicleFormState extends State<_VehicleForm> {
  final _makeController        = TextEditingController();
  final _modelController       = TextEditingController();
  final _priceController       = TextEditingController();
  final _mileageController     = TextEditingController();
  final _locationController    = TextEditingController();
  final _descriptionController = TextEditingController();
  final _sellerNameController  = TextEditingController();
  final _engineController      = TextEditingController();
  final _vinController         = TextEditingController();

  File? _imageFile;
  int _stock = 1;
  String _selectedCondition    = 'Used - Good';
  String _selectedColor        = 'White';
  String _selectedYear         = DateTime.now().year.toString();
  String _selectedFuel         = 'Petrol';
  String _selectedTransmission = 'Automatic';
  String _selectedDrive        = 'FWD';
  bool _isUploading       = false;
  bool _isSearchingSeller = false;
  bool _sellerVerified    = false;
  String? _sellerPhone;
  String? _sellerEmail;

  final List<String> _conditions    = ['New', 'Used - Like New', 'Used - Good', 'Used - Fair', 'Salvage'];
  final List<String> _colors        = ['White', 'Black', 'Silver', 'Gray', 'Red', 'Blue', 'Green', 'Yellow', 'Orange', 'Brown', 'Gold', 'Beige', 'Other'];
  final List<String> _fuels         = ['Petrol', 'Diesel', 'Electric', 'Hybrid', 'LPG / CNG', 'Other'];
  final List<String> _transmissions = ['Automatic', 'Manual', 'Semi-Automatic', 'CVT'];
  final List<String> _drives        = ['FWD', 'RWD', 'AWD', '4WD'];

  bool get _showDriveFields => !['bicycles', 'other_vehicle'].contains(widget.parent.id) ||
      widget.sub.id == 'ebike' || widget.sub.id == 'electric_scooter';
  bool get _showFuelField => !['bicycles'].contains(widget.parent.id) ||
      widget.sub.id == 'ebike' || widget.sub.id == 'electric_scooter';

  List<String> get _years {
    final current = DateTime.now().year;
    return List.generate(current - 1969, (i) => (current - i).toString());
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _priceController.dispose();
    _mileageController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _sellerNameController.dispose();
    _engineController.dispose();
    _vinController.dispose();
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

    // Strip all non-digit characters (spaces, dashes, +, parentheses)
    final phone = _sellerPhone!.replaceAll(RegExp(r'\D'), '');

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid phone number")),
      );
      return;
    }

    // wa.me universal deep link — opens WhatsApp directly to a chat
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
        Uri.parse('$_firestoreUrl:runQuery'),
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
            if (_imageFile != null) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () { Navigator.pop(ctx); setState(() => _imageFile = null); },
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text("Remove Photo", style: TextStyle(color: Colors.red)),
              ),
            ],
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

  Future<String?> _uploadToSupabase() async {
    if (_imageFile == null) return null;
    try {
      final supabase = Supabase.instance.client;
      final fileName = 'vehicle_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await supabase.storage.from('products').upload(fileName, _imageFile!);
      return supabase.storage.from('products').getPublicUrl(fileName);
    } catch (e) {
      debugPrint("Supabase upload error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Photo upload failed: ${e.toString()}"), backgroundColor: Colors.orange),
        );
      }
      return null;
    }
  }

  // ─── Upload vehicle ──────────────────────────────────────────────────────

  Future<void> _uploadVehicle() async {
    final make  = _makeController.text.trim();
    final model = _modelController.text.trim();
    final price = _priceController.text.trim();

    if (!_sellerVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please verify your seller profile first")),
      );
      return;
    }
    if (make.isEmpty || model.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Make and Model are required")),
      );
      return;
    }
    if (price.isEmpty || double.tryParse(price) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid price")),
      );
      return;
    }

    setState(() => _isUploading = true);
    try {
      String? photoUrl;
      if (_imageFile != null) photoUrl = await _uploadToSupabase();

      final title = '$_selectedYear $make $model';
      final response = await http.post(
        Uri.parse('$_firestoreUrl/vehicles'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'fields': {
          'title':             {'stringValue': title},
          'make':              {'stringValue': make},
          'model':             {'stringValue': model},
          'year':              {'stringValue': _selectedYear},
          'price':             {'stringValue': price},
          'mileage':           {'stringValue': _mileageController.text.trim()},
          'color':             {'stringValue': _selectedColor},
          'condition':         {'stringValue': _selectedCondition},
          'fuelType':          {'stringValue': _selectedFuel},
          'transmission':      {'stringValue': _selectedTransmission},
          'driveType':         {'stringValue': _selectedDrive},
          'engineSize':        {'stringValue': _engineController.text.trim()},
          'vin':               {'stringValue': _vinController.text.trim()},
          'location':          {'stringValue': _locationController.text.trim()},
          'description':       {'stringValue': _descriptionController.text.trim()},
          'vehicleCategory':   {'stringValue': widget.parent.label},
          'vehicleType':       {'stringValue': widget.sub.label},
          'vehicleCategoryId': {'stringValue': widget.parent.id},
          'vehicleTypeId':     {'stringValue': widget.sub.id},
          'imageUrl':          {'stringValue': photoUrl ?? ''},
          'sellerName':        {'stringValue': _sellerNameController.text.trim()},
          'sellerPhone':       {'stringValue': _sellerPhone ?? ''},
          'sellerEmail':       {'stringValue': _sellerEmail ?? ''},
          'stock':             {'integerValue': _stock},
          'createdAt':         {'timestampValue': DateTime.now().toUtc().toIso8601String()},
        }}),
      );

      debugPrint("Firestore response: ${response.statusCode} ${response.body}");
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Vehicle listed successfully!"), backgroundColor: Color(0xFF27AE60)),
          );
          Navigator.pop(context, 'created');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed (${response.statusCode}): ${response.body}"),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 8),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Upload error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.parent.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(widget.parent.icon, size: 14, color: widget.parent.color),
              const SizedBox(width: 6),
              Text(
                  widget.parent.id == widget.sub.id
                      ? widget.parent.label
                      : "${widget.parent.label} › ${widget.sub.label}",
                  style: TextStyle(color: widget.parent.color, fontWeight: FontWeight.w600, fontSize: 13)),
            ]),
          ),

          // Photo
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

          _sectionHeader(Icons.info_outline, "Basic Information", const Color(0xFF4A90E2)),
          const SizedBox(height: 12),

          Row(children: [
            Expanded(child: TextField(
              controller: _makeController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: "Make", hintText: "e.g. Toyota", border: OutlineInputBorder()),
            )),
            const SizedBox(width: 12),
            Expanded(child: TextField(
              controller: _modelController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: "Model", hintText: "e.g. Camry", border: OutlineInputBorder()),
            )),
          ]),
          const SizedBox(height: 12),

          Row(children: [
            Expanded(child: DropdownButtonFormField<String>(
              initialValue: _selectedYear,
              decoration: const InputDecoration(labelText: "Year", border: OutlineInputBorder()),
              items: _years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
              onChanged: (val) => setState(() => _selectedYear = val!),
            )),
            const SizedBox(width: 12),
            Expanded(child: TextField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: "Price", prefixText: "\$ ", border: OutlineInputBorder()),
            )),
          ]),
          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            initialValue: _selectedCondition,
            decoration: const InputDecoration(labelText: "Condition", border: OutlineInputBorder()),
            items: _conditions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (val) => setState(() => _selectedCondition = val!),
          ),
          const SizedBox(height: 20),

          _sectionHeader(Icons.settings_outlined, "Vehicle Details", const Color(0xFF27AE60)),
          const SizedBox(height: 12),

          Row(children: [
            Expanded(child: TextField(
              controller: _mileageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Mileage", suffixText: "km", border: OutlineInputBorder()),
            )),
            const SizedBox(width: 12),
            Expanded(child: DropdownButtonFormField<String>(
              initialValue: _selectedColor,
              decoration: const InputDecoration(labelText: "Color", border: OutlineInputBorder()),
              items: _colors.map((c) => DropdownMenuItem(value: c, child: Row(children: [
                Container(
                  width: 16, height: 16, margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: _colorFromName(c),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                ),
                Text(c),
              ]))).toList(),
              onChanged: (val) => setState(() => _selectedColor = val!),
            )),
          ]),
          const SizedBox(height: 12),

          if (_showFuelField) ...[
            DropdownButtonFormField<String>(
              initialValue: _selectedFuel,
              decoration: const InputDecoration(labelText: "Fuel Type", border: OutlineInputBorder()),
              items: _fuels.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
              onChanged: (val) => setState(() => _selectedFuel = val!),
            ),
            const SizedBox(height: 12),
          ],

          if (_showDriveFields) ...[
            Row(children: [
              Expanded(child: DropdownButtonFormField<String>(
                initialValue: _selectedTransmission,
                decoration: const InputDecoration(labelText: "Transmission", border: OutlineInputBorder()),
                items: _transmissions.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (val) => setState(() => _selectedTransmission = val!),
              )),
              const SizedBox(width: 12),
              Expanded(child: DropdownButtonFormField<String>(
                initialValue: _selectedDrive,
                decoration: const InputDecoration(labelText: "Drive Type", border: OutlineInputBorder()),
                items: _drives.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (val) => setState(() => _selectedDrive = val!),
              )),
            ]),
            const SizedBox(height: 12),
          ],

          Row(children: [
            Expanded(child: TextField(
              controller: _engineController,
              decoration: const InputDecoration(labelText: "Engine Size (optional)", hintText: "e.g. 2.0L", border: OutlineInputBorder()),
            )),
            const SizedBox(width: 12),
            Expanded(child: TextField(
              controller: _vinController,
              decoration: const InputDecoration(labelText: "VIN (optional)", border: OutlineInputBorder()),
            )),
          ]),
          const SizedBox(height: 20),

          _sectionHeader(Icons.location_on_outlined, "Location & Description", const Color(0xFFE67E22)),
          const SizedBox(height: 12),

          TextField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: "Location",
              hintText: "e.g. Beirut, Lebanon",
              prefixIcon: Icon(Icons.location_on_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: const InputDecoration(labelText: "Description", border: OutlineInputBorder()),
          ),
          const SizedBox(height: 20),

          // Stock
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Icon(Icons.inventory_2_outlined, color: Color(0xFF4A90E2), size: 20),
                SizedBox(width: 8),
                Text("Stock Quantity",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
              ]),
              const SizedBox(height: 14),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                IconButton(
                  onPressed: () => setState(() => _stock = (_stock - 1).clamp(0, 9999)),
                  icon: const Icon(Icons.remove_circle_outline, size: 36),
                  color: _stock <= 0 ? Colors.grey : Colors.redAccent,
                ),
                const SizedBox(width: 16),
                Container(
                  width: 80, height: 60, alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _stock <= 0 ? Colors.red.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _stock <= 0 ? Colors.red : Colors.grey.shade300),
                  ),
                  child: Text('$_stock',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
                          color: _stock <= 0 ? Colors.red : Colors.black)),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () => setState(() => _stock = (_stock + 1).clamp(0, 9999)),
                  icon: const Icon(Icons.add_circle_outline, size: 36),
                  color: const Color(0xFF27AE60),
                ),
              ]),
              if (_stock <= 0)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Center(
                    child: Text("⚠️ Listing will be hidden from marketplace",
                        style: TextStyle(color: Colors.red, fontSize: 13)),
                  ),
                ),
            ]),
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
                Expanded(child: TextField(
                  controller: _sellerNameController,
                  decoration: const InputDecoration(
                    labelText: "Seller Name",
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                )),
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
                        // Verified info row
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

                        // WhatsApp button
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
                              backgroundColor: const Color(0xFF25D366), // Official WhatsApp green
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
            width: double.infinity, height: 52,
            child: ElevatedButton.icon(
              onPressed: _isUploading ? null : _uploadVehicle,
              icon: Icon(widget.parent.icon, color: Colors.white),
              label: _isUploading
                  ? const SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      "Publish Vehicle",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.parent.color,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title, Color color) {
    return Row(children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(width: 8),
      Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
      const SizedBox(width: 8),
      Expanded(child: Divider(color: color.withValues(alpha: 0.3))),
    ]);
  }

  Color _colorFromName(String name) {
    switch (name.toLowerCase()) {
      case 'white':  return Colors.white;
      case 'black':  return Colors.black;
      case 'silver': return Colors.grey.shade400;
      case 'gray':   return Colors.grey;
      case 'red':    return Colors.red;
      case 'blue':   return Colors.blue;
      case 'green':  return Colors.green;
      case 'yellow': return Colors.yellow;
      case 'orange': return Colors.orange;
      case 'brown':  return Colors.brown;
      case 'gold':   return const Color(0xFFFFD700);
      case 'beige':  return const Color(0xFFF5F5DC);
      default:       return Colors.grey.shade300;
    }
  }
}*/
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;
import 'seller_profile_page.dart';
import 'seller_session.dart';

const String _projectId = 'marketplaneproducts';
const String _firestoreUrl =
    'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents';

class VehicleCategory {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final String? parentId;
  final String? description;

  const VehicleCategory({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    this.parentId,
    this.description,
  });
}

const List<VehicleCategory> vehicleCategories = [
  VehicleCategory(id: 'cars',          label: 'Cars',              icon: Icons.directions_car_outlined,   color: Color(0xFF4A90E2), description: 'Sedans, SUVs, coupes & more'),
  VehicleCategory(id: 'sedan',         label: 'Sedan',             icon: Icons.directions_car_outlined,   color: Color(0xFF1E88E5), parentId: 'cars'),
  VehicleCategory(id: 'suv',           label: 'SUV / Crossover',   icon: Icons.directions_car_outlined,   color: Color(0xFF1976D2), parentId: 'cars'),
  VehicleCategory(id: 'coupe',         label: 'Coupe',             icon: Icons.directions_car_outlined,   color: Color(0xFF1565C0), parentId: 'cars'),
  VehicleCategory(id: 'hatchback',     label: 'Hatchback',         icon: Icons.directions_car_outlined,   color: Color(0xFF0D47A1), parentId: 'cars'),
  VehicleCategory(id: 'convertible',   label: 'Convertible',       icon: Icons.directions_car_outlined,   color: Color(0xFF283593), parentId: 'cars'),
  VehicleCategory(id: 'wagon',         label: 'Station Wagon',     icon: Icons.directions_car_outlined,   color: Color(0xFF3949AB), parentId: 'cars'),
  VehicleCategory(id: 'minivan',       label: 'Minivan',           icon: Icons.airport_shuttle_outlined,  color: Color(0xFF5C6BC0), parentId: 'cars'),
  VehicleCategory(id: 'pickup_car',    label: 'Pickup Truck',      icon: Icons.local_shipping_outlined,   color: Color(0xFF7986CB), parentId: 'cars'),
  VehicleCategory(id: 'electric_car',  label: 'Electric / Hybrid', icon: Icons.electric_car_outlined,     color: Color(0xFF4527A0), parentId: 'cars'),
  VehicleCategory(id: 'luxury_car',    label: 'Luxury & Sports',   icon: Icons.directions_car_outlined,   color: Color(0xFF1A237E), parentId: 'cars'),
  VehicleCategory(id: 'motorcycles',   label: 'Motorcycles',       icon: Icons.two_wheeler_outlined,      color: Color(0xFFE67E22), description: 'Sport, cruiser, scooters & more'),
  VehicleCategory(id: 'sport_bike',    label: 'Sport Bike',        icon: Icons.two_wheeler_outlined,      color: Color(0xFFD35400), parentId: 'motorcycles'),
  VehicleCategory(id: 'cruiser',       label: 'Cruiser',           icon: Icons.two_wheeler_outlined,      color: Color(0xFFBA4A00), parentId: 'motorcycles'),
  VehicleCategory(id: 'scooter',       label: 'Scooter / Moped',   icon: Icons.two_wheeler_outlined,      color: Color(0xFFA04000), parentId: 'motorcycles'),
  VehicleCategory(id: 'dirt_bike',     label: 'Dirt Bike / Off-Road', icon: Icons.two_wheeler_outlined,   color: Color(0xFF873600), parentId: 'motorcycles'),
  VehicleCategory(id: 'adventure',     label: 'Adventure / Touring', icon: Icons.two_wheeler_outlined,    color: Color(0xFFEB984E), parentId: 'motorcycles'),
  VehicleCategory(id: 'electric_moto', label: 'Electric Motorcycle', icon: Icons.electric_moped_outlined, color: Color(0xFFCA6F1E), parentId: 'motorcycles'),
  VehicleCategory(id: 'atv',           label: 'ATV / Quad',        icon: Icons.two_wheeler_outlined,      color: Color(0xFFF0A500), parentId: 'motorcycles'),
  VehicleCategory(id: 'trucks',        label: 'Trucks',            icon: Icons.local_shipping_outlined,   color: Color(0xFF27AE60), description: 'Pickups, heavy trucks & commercial'),
  VehicleCategory(id: 'light_pickup',  label: 'Light Pickup',      icon: Icons.local_shipping_outlined,   color: Color(0xFF2E7D32), parentId: 'trucks'),
  VehicleCategory(id: 'heavy_truck',   label: 'Heavy Truck',       icon: Icons.local_shipping_outlined,   color: Color(0xFF388E3C), parentId: 'trucks'),
  VehicleCategory(id: 'semi_truck',    label: 'Semi / 18-Wheeler', icon: Icons.local_shipping_outlined,   color: Color(0xFF43A047), parentId: 'trucks'),
  VehicleCategory(id: 'van_cargo',     label: 'Cargo Van',         icon: Icons.airport_shuttle_outlined,  color: Color(0xFF81C784), parentId: 'trucks'),
  VehicleCategory(id: 'boats',         label: 'Boats & Watercraft',icon: Icons.directions_boat_outlined,  color: Color(0xFF1ABC9C), description: 'Speedboats, sailboats, jet skis & more'),
  VehicleCategory(id: 'speedboat',     label: 'Speedboat',         icon: Icons.directions_boat_outlined,  color: Color(0xFF17A589), parentId: 'boats'),
  VehicleCategory(id: 'sailboat',      label: 'Sailboat',          icon: Icons.directions_boat_outlined,  color: Color(0xFF148F77), parentId: 'boats'),
  VehicleCategory(id: 'yacht',         label: 'Yacht',             icon: Icons.directions_boat_outlined,  color: Color(0xFF117A65), parentId: 'boats'),
  VehicleCategory(id: 'jet_ski',       label: 'Jet Ski / PWC',     icon: Icons.pool_outlined,             color: Color(0xFF0E6655), parentId: 'boats'),
  VehicleCategory(id: 'fishing_boat',  label: 'Fishing Boat',      icon: Icons.directions_boat_outlined,  color: Color(0xFF76D7C4), parentId: 'boats'),
  VehicleCategory(id: 'buses',         label: 'Buses & Vans',      icon: Icons.directions_bus_outlined,   color: Color(0xFF9B59B6), description: 'Minibuses, coaches, passenger vans'),
  VehicleCategory(id: 'minibus',       label: 'Minibus',           icon: Icons.directions_bus_outlined,   color: Color(0xFF8E44AD), parentId: 'buses'),
  VehicleCategory(id: 'coach_bus',     label: 'Coach / Full Bus',  icon: Icons.directions_bus_outlined,   color: Color(0xFF7D3C98), parentId: 'buses'),
  VehicleCategory(id: 'passenger_van', label: 'Passenger Van',     icon: Icons.airport_shuttle_outlined,  color: Color(0xFFBB8FCE), parentId: 'buses'),
  VehicleCategory(id: 'camper_van',    label: 'Camper / RV',       icon: Icons.airport_shuttle_outlined,  color: Color(0xFFA569BD), parentId: 'buses'),
  VehicleCategory(id: 'equipment',     label: 'Heavy Equipment',   icon: Icons.construction_outlined,    color: Color(0xFFE74C3C), description: 'Construction, farming & industrial'),
  VehicleCategory(id: 'excavator',     label: 'Excavator',         icon: Icons.construction_outlined,    color: Color(0xFFC0392B), parentId: 'equipment'),
  VehicleCategory(id: 'bulldozer',     label: 'Bulldozer',         icon: Icons.construction_outlined,    color: Color(0xFFAB2323), parentId: 'equipment'),
  VehicleCategory(id: 'forklift',      label: 'Forklift',          icon: Icons.construction_outlined,    color: Color(0xFF922B21), parentId: 'equipment'),
  VehicleCategory(id: 'tractor',       label: 'Tractor / Farm',    icon: Icons.agriculture_outlined,     color: Color(0xFFEC7063), parentId: 'equipment'),
  VehicleCategory(id: 'bicycles',      label: 'Bicycles & Micro',  icon: Icons.directions_bike_outlined,  color: Color(0xFF16A085), description: 'Bikes, e-bikes, scooters & skateboards'),
  VehicleCategory(id: 'road_bike',     label: 'Road Bike',         icon: Icons.directions_bike_outlined,  color: Color(0xFF138D75), parentId: 'bicycles'),
  VehicleCategory(id: 'mountain_bike', label: 'Mountain Bike',     icon: Icons.directions_bike_outlined,  color: Color(0xFF117A65), parentId: 'bicycles'),
  VehicleCategory(id: 'ebike',         label: 'Electric Bike',     icon: Icons.electric_bike_outlined,    color: Color(0xFF0E6655), parentId: 'bicycles'),
  VehicleCategory(id: 'electric_scooter', label: 'Electric Scooter', icon: Icons.electric_scooter_outlined, color: Color(0xFF76D7C4), parentId: 'bicycles'),
  VehicleCategory(id: 'kids_bike',     label: 'Kids Bicycle',      icon: Icons.directions_bike_outlined,  color: Color(0xFF48C9B0), parentId: 'bicycles'),
  VehicleCategory(id: 'other_vehicle', label: 'Other',             icon: Icons.commute_outlined,          color: Color(0xFF90A4AE), description: 'Anything else'),
  VehicleCategory(id: 'trailer',       label: 'Trailer',           icon: Icons.rv_hookup_outlined,        color: Color(0xFF78909C), parentId: 'other_vehicle'),
  VehicleCategory(id: 'golf_cart',     label: 'Golf Cart',         icon: Icons.electric_car_outlined,     color: Color(0xFF546E7A), parentId: 'other_vehicle'),
  VehicleCategory(id: 'other_misc',    label: 'Other Vehicle',     icon: Icons.commute_outlined,          color: Color(0xFFB0BEC5), parentId: 'other_vehicle'),
];

List<VehicleCategory> get parentVehicleCategories =>
    vehicleCategories.where((c) => c.parentId == null).toList();

List<VehicleCategory> vehicleSubcategoriesOf(String parentId) =>
    vehicleCategories.where((c) => c.parentId == parentId).toList();

const Set<String> _skipVehicleSubIds = {'other_vehicle'};

class AddVehiclePage extends StatefulWidget {
  /// Pass an existing item map to enter edit mode.
  final Map<String, dynamic>? existingItem;

  const AddVehiclePage({super.key, this.existingItem});

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  VehicleCategory? _selectedParent;
  VehicleCategory? _selectedSub;

  bool get _isEditing => widget.existingItem != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final item = widget.existingItem!;
      final parentId = item['vehicleCategoryId'] as String? ?? '';
      final subId    = item['vehicleTypeId']     as String? ?? '';
      _selectedParent = vehicleCategories.where((c) => c.id == parentId).firstOrNull
          ?? vehicleCategories.first;
      _selectedSub    = vehicleCategories.where((c) => c.id == subId).firstOrNull
          ?? _selectedParent;
    }
  }

  String get _appBarTitle {
    if (_isEditing) return 'Edit Vehicle';
    if (_selectedParent == null) return "Vehicle Type";
    if (_selectedSub == null) return _selectedParent!.label;
    return "New Vehicle Listing";
  }

  void _handleBack() {
    if (_isEditing) { Navigator.pop(context); return; }
    if (_selectedSub != null) {
      if (_selectedParent != null && _skipVehicleSubIds.contains(_selectedParent!.id)) {
        setState(() { _selectedSub = null; _selectedParent = null; });
      } else {
        setState(() => _selectedSub = null);
      }
    } else if (_selectedParent != null) {
      setState(() => _selectedParent = null);
    } else {
      Navigator.pop(context);
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
        leading: (_selectedParent != null || _isEditing)
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _handleBack)
            : IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isEditing) {
      return _VehicleForm(
        parent: _selectedParent!,
        sub: _selectedSub!,
        existingItem: widget.existingItem,
      );
    }
    if (_selectedParent == null) return _buildParentGrid();
    if (_selectedSub == null) return _buildSubGrid(_selectedParent!);
    return _VehicleForm(parent: _selectedParent!, sub: _selectedSub!);
  }

  Widget _buildParentGrid() {
    final parents = parentVehicleCategories;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("What are you selling?",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
        const SizedBox(height: 4),
        const Text("Select the type of vehicle.", style: TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 1.55),
          itemCount: parents.length,
          itemBuilder: (context, index) {
            final cat = parents[index];
            return GestureDetector(
              onTap: () {
                if (_skipVehicleSubIds.contains(cat.id)) {
                  setState(() { _selectedParent = cat; _selectedSub = cat; });
                } else {
                  setState(() => _selectedParent = cat);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(color: cat.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                    child: Icon(cat.icon, color: cat.color, size: 28),
                  ),
                  const SizedBox(height: 10),
                  Text(cat.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
                  if (cat.description != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      child: Text(cat.description!, textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 10, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                ]),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSubGrid(VehicleCategory parent) {
    final subs = vehicleSubcategoriesOf(parent.id);
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
              width: 42, height: 42,
              decoration: BoxDecoration(color: parent.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: Icon(parent.icon, color: parent.color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(parent.label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: parent.color)),
              if (parent.description != null)
                Text(parent.description!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ])),
          ]),
        ),
        const Text("Select a type",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.9),
          itemCount: subs.length,
          itemBuilder: (context, index) {
            final sub = subs[index];
            return GestureDetector(
              onTap: () => setState(() => _selectedSub = sub),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(color: sub.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                    child: Icon(sub.icon, color: sub.color, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(sub.label, textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50)),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),
                ]),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ─── VEHICLE FORM ─────────────────────────────────────────────────────────────

class _VehicleForm extends StatefulWidget {
  final VehicleCategory parent;
  final VehicleCategory sub;
  final Map<String, dynamic>? existingItem;

  const _VehicleForm({required this.parent, required this.sub, this.existingItem});

  @override
  State<_VehicleForm> createState() => _VehicleFormState();
}

class _VehicleFormState extends State<_VehicleForm> {
  final _makeController        = TextEditingController();
  final _modelController       = TextEditingController();
  final _priceController       = TextEditingController();
  final _mileageController     = TextEditingController();
  final _locationController    = TextEditingController();
  final _descriptionController = TextEditingController();
  final _sellerNameController  = TextEditingController();
  final _engineController      = TextEditingController();
  final _vinController         = TextEditingController();

  File? _imageFile;
  int _stock = 1;
  String _selectedCondition    = 'Used - Good';
  String _selectedColor        = 'White';
  String _selectedYear         = DateTime.now().year.toString();
  String _selectedFuel         = 'Petrol';
  String _selectedTransmission = 'Automatic';
  String _selectedDrive        = 'FWD';
  bool _isUploading       = false;
  bool _isSearchingSeller = false;
  bool _sellerVerified    = false;
  String? _sellerPhone;
  String? _sellerEmail;
  String? _existingImageUrl;

  bool get _isEditing => widget.existingItem != null;
  String get _docId => widget.existingItem?['id'] ?? '';
  String get _collection => widget.existingItem?['collection'] ?? 'vehicles';

  final List<String> _conditions    = ['New', 'Used - Like New', 'Used - Good', 'Used - Fair', 'Salvage'];
  final List<String> _colors        = ['White', 'Black', 'Silver', 'Gray', 'Red', 'Blue', 'Green', 'Yellow', 'Orange', 'Brown', 'Gold', 'Beige', 'Other'];
  final List<String> _fuels         = ['Petrol', 'Diesel', 'Electric', 'Hybrid', 'LPG / CNG', 'Other'];
  final List<String> _transmissions = ['Automatic', 'Manual', 'Semi-Automatic', 'CVT'];
  final List<String> _drives        = ['FWD', 'RWD', 'AWD', '4WD'];

  bool get _showDriveFields => !['bicycles', 'other_vehicle'].contains(widget.parent.id) ||
      widget.sub.id == 'ebike' || widget.sub.id == 'electric_scooter';
  bool get _showFuelField => !['bicycles'].contains(widget.parent.id) ||
      widget.sub.id == 'ebike' || widget.sub.id == 'electric_scooter';

  List<String> get _years {
    final current = DateTime.now().year;
    return List.generate(current - 1969, (i) => (current - i).toString());
  }

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final item = widget.existingItem!;
      _makeController.text        = item['make']        ?? '';
      _modelController.text       = item['model']       ?? '';
      _priceController.text       = item['price']?.toString() ?? '';
      _mileageController.text     = item['mileage']     ?? '';
      _locationController.text    = item['location']    ?? '';
      _descriptionController.text = item['description'] ?? '';
      _sellerNameController.text  = item['sellerName']  ?? '';
      _engineController.text      = item['engineSize']  ?? '';
      _vinController.text         = item['vin']         ?? '';
      _stock                      = int.tryParse(item['stock']?.toString() ?? '1') ?? 1;
      _existingImageUrl           = item['imageUrl']    as String?;
      _sellerPhone                = item['sellerPhone'] as String?;
      _sellerEmail                = item['sellerEmail'] as String?;
      if (_conditions.contains(item['condition']))    _selectedCondition    = item['condition'];
      if (_colors.contains(item['color']))            _selectedColor        = item['color'];
      if (_fuels.contains(item['fuelType']))          _selectedFuel         = item['fuelType'];
      if (_transmissions.contains(item['transmission'])) _selectedTransmission = item['transmission'];
      if (_drives.contains(item['driveType']))        _selectedDrive        = item['driveType'];
      if (_years.contains(item['year']))              _selectedYear         = item['year'];
      if ((_sellerPhone ?? '').isNotEmpty)            _sellerVerified       = true;
    } else {
      // ← ADD THIS
      _autoFillSellerFromSession();
    }
  }
Future<void> _autoFillSellerFromSession() async {
    final name = await SellerSession.getSellerName();
    if (name != null && name.isNotEmpty && mounted) {
      setState(() => _sellerNameController.text = name);
      await _lookupSeller();
    }
  }
  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _priceController.dispose();
    _mileageController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _sellerNameController.dispose();
    _engineController.dispose();
    _vinController.dispose();
    super.dispose();
  }

  // ─── WhatsApp ────────────────────────────────────────────────────────────

  Future<void> _openWhatsApp() async {
    if (_sellerPhone == null || _sellerPhone!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No phone number available")));
      return;
    }
    final phone = _sellerPhone!.replaceAll(RegExp(r'\D'), '');
    final Uri uri = Uri.parse('https://wa.me/$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("WhatsApp not available"), backgroundColor: Colors.red));
    }
  }

  // ─── Seller lookup ───────────────────────────────────────────────────────

  Future<void> _lookupSeller() async {
    final name = _sellerNameController.text.trim();
    if (name.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter your seller name"))); return; }
    setState(() { _isSearchingSeller = true; _sellerVerified = false; });
    try {
      final response = await http.post(
        Uri.parse('$_firestoreUrl:runQuery'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'structuredQuery': {
          'from': [{'collectionId': 'sellers'}],
          'where': {'fieldFilter': {'field': {'fieldPath': 'name'}, 'op': 'EQUAL', 'value': {'stringValue': name}}},
          'limit': 1,
        }}),
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
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No seller profile found."), backgroundColor: Colors.orange));
        }
      }
    } catch (e) { debugPrint("Seller lookup error: $e"); }
    finally { if (mounted) setState(() => _isSearchingSeller = false); }
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
                child: Container(padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(color: const Color(0xFF4A90E2).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                  child: const Column(children: [Icon(Icons.camera_alt_outlined, size: 36, color: Color(0xFF4A90E2)), SizedBox(height: 8), Text("Camera", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF4A90E2)))]),
                ),
              )),
              const SizedBox(width: 16),
              Expanded(child: GestureDetector(
                onTap: () async { Navigator.pop(ctx); await _getImage(ImageSource.gallery); },
                child: Container(padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(color: const Color(0xFF27AE60).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                  child: const Column(children: [Icon(Icons.photo_library_outlined, size: 36, color: Color(0xFF27AE60)), SizedBox(height: 8), Text("Gallery", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF27AE60)))]),
                ),
              )),
            ]),
            if (_imageFile != null) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () { Navigator.pop(ctx); setState(() => _imageFile = null); },
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text("Remove Photo", style: TextStyle(color: Colors.red)),
              ),
            ],
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

  Future<String?> _uploadToSupabase() async {
    if (_imageFile == null) return null;
    try {
      final supabase = Supabase.instance.client;
      final fileName = 'vehicle_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await supabase.storage.from('products').upload(fileName, _imageFile!);
      return supabase.storage.from('products').getPublicUrl(fileName);
    } catch (e) {
      debugPrint("Supabase upload error: $e");
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Photo upload failed: $e"), backgroundColor: Colors.orange));
      return null;
    }
  }

  // ─── Save ────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    final make  = _makeController.text.trim();
    final model = _modelController.text.trim();
    final price = _priceController.text.trim();

    if (!_sellerVerified) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please verify your seller profile first"))); return; }
    if (make.isEmpty || model.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Make and Model are required"))); return; }
    if (price.isEmpty || double.tryParse(price) == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a valid price"))); return; }

    setState(() => _isUploading = true);
    try {
      String? photoUrl = _existingImageUrl;
      if (_imageFile != null) {
        final uploaded = await _uploadToSupabase();
        if (uploaded != null) photoUrl = uploaded;
      }

      final title = '$_selectedYear $make $model';
      final fields = {
        'title':             {'stringValue': title},
        'make':              {'stringValue': make},
        'model':             {'stringValue': model},
        'year':              {'stringValue': _selectedYear},
        'price':             {'stringValue': price},
        'mileage':           {'stringValue': _mileageController.text.trim()},
        'color':             {'stringValue': _selectedColor},
        'condition':         {'stringValue': _selectedCondition},
        'fuelType':          {'stringValue': _selectedFuel},
        'transmission':      {'stringValue': _selectedTransmission},
        'driveType':         {'stringValue': _selectedDrive},
        'engineSize':        {'stringValue': _engineController.text.trim()},
        'vin':               {'stringValue': _vinController.text.trim()},
        'location':          {'stringValue': _locationController.text.trim()},
        'description':       {'stringValue': _descriptionController.text.trim()},
        'vehicleCategory':   {'stringValue': widget.parent.label},
        'vehicleType':       {'stringValue': widget.sub.label},
        'vehicleCategoryId': {'stringValue': widget.parent.id},
        'vehicleTypeId':     {'stringValue': widget.sub.id},
        'imageUrl':          {'stringValue': photoUrl ?? ''},
        'sellerName':        {'stringValue': _sellerNameController.text.trim()},
        'sellerPhone':       {'stringValue': _sellerPhone ?? ''},
        'sellerEmail':       {'stringValue': _sellerEmail ?? ''},
        'stock':  {'integerValue': _stock.toString()},
'status': {'stringValue': 'available'},

      };

      http.Response response;
      if (_isEditing) {
        final updateMask = fields.keys.map((k) => 'updateMask.fieldPaths=$k').join('&');
        final url = '$_firestoreUrl/$_collection/$_docId?$updateMask';
        response = await http.patch(Uri.parse(url), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'fields': fields}));
      } else {
        fields['createdAt'] = {'timestampValue': DateTime.now().toUtc().toIso8601String()};
        response = await http.post(Uri.parse('$_firestoreUrl/vehicles'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'fields': fields}));
      }

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(_isEditing ? "✅ Vehicle updated!" : "✅ Vehicle listed successfully!"),
            backgroundColor: const Color(0xFF27AE60),
          ));
          Navigator.pop(context, 'refresh');
        }
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed (${response.statusCode}): ${response.body}"), backgroundColor: Colors.red, duration: const Duration(seconds: 8)));
      }
    } catch (e) {
      debugPrint("Save error: $e");
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bool showExistingImage = _imageFile == null && (_existingImageUrl ?? '').isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: widget.parent.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(widget.parent.icon, size: 14, color: widget.parent.color),
              const SizedBox(width: 6),
              Text(
                widget.parent.id == widget.sub.id ? widget.parent.label : "${widget.parent.label} › ${widget.sub.label}",
                style: TextStyle(color: widget.parent.color, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ]),
          ),

          // Photo
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 200, width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
              child: _imageFile != null
                  ? Stack(children: [
                      ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_imageFile!, fit: BoxFit.cover, width: double.infinity, height: 200)),
                      Positioned(top: 8, right: 8, child: CircleAvatar(radius: 16, backgroundColor: Colors.black.withValues(alpha: 0.6), child: const Icon(Icons.edit, size: 16, color: Colors.white))),
                    ])
                  : showExistingImage
                      ? Stack(children: [
                          ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(_existingImageUrl!, fit: BoxFit.cover, width: double.infinity, height: 200, errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.image, size: 60, color: Colors.grey)))),
                          Positioned(top: 8, right: 8, child: CircleAvatar(radius: 16, backgroundColor: Colors.black.withValues(alpha: 0.6), child: const Icon(Icons.edit, size: 16, color: Colors.white))),
                        ])
                      : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.add_a_photo_outlined, size: 44, color: Colors.grey[500]),
                          const SizedBox(height: 8),
                          Text("Tap to add photo", style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                          Text("Camera or Gallery", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                        ]),
            ),
          ),
          const SizedBox(height: 20),

          _sectionHeader(Icons.info_outline, "Basic Information", const Color(0xFF4A90E2)),
          const SizedBox(height: 12),

          Row(children: [
            Expanded(child: TextField(controller: _makeController, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: "Make", hintText: "e.g. Toyota", border: OutlineInputBorder()))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: _modelController, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: "Model", hintText: "e.g. Camry", border: OutlineInputBorder()))),
          ]),
          const SizedBox(height: 12),

          Row(children: [
            Expanded(child: DropdownButtonFormField<String>(
              initialValue: _selectedYear,
              decoration: const InputDecoration(labelText: "Year", border: OutlineInputBorder()),
              items: _years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
              onChanged: (val) => setState(() => _selectedYear = val!),
            )),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: _priceController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: "Price", prefixText: "\$ ", border: OutlineInputBorder()))),
          ]),
          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            initialValue: _selectedCondition,
            decoration: const InputDecoration(labelText: "Condition", border: OutlineInputBorder()),
            items: _conditions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (val) => setState(() => _selectedCondition = val!),
          ),
          const SizedBox(height: 20),

          _sectionHeader(Icons.settings_outlined, "Vehicle Details", const Color(0xFF27AE60)),
          const SizedBox(height: 12),

          Row(children: [
            Expanded(child: TextField(controller: _mileageController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Mileage", suffixText: "km", border: OutlineInputBorder()))),
            const SizedBox(width: 12),
            Expanded(child: DropdownButtonFormField<String>(
              initialValue: _selectedColor,
              decoration: const InputDecoration(labelText: "Color", border: OutlineInputBorder()),
              items: _colors.map((c) => DropdownMenuItem(value: c, child: Row(children: [
                Container(width: 16, height: 16, margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(color: _colorFromName(c), shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300))),
                Text(c),
              ]))).toList(),
              onChanged: (val) => setState(() => _selectedColor = val!),
            )),
          ]),
          const SizedBox(height: 12),

          if (_showFuelField) ...[
            DropdownButtonFormField<String>(
              initialValue: _selectedFuel,
              decoration: const InputDecoration(labelText: "Fuel Type", border: OutlineInputBorder()),
              items: _fuels.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
              onChanged: (val) => setState(() => _selectedFuel = val!),
            ),
            const SizedBox(height: 12),
          ],

          if (_showDriveFields) ...[
            Row(children: [
              Expanded(child: DropdownButtonFormField<String>(
                initialValue: _selectedTransmission,
                decoration: const InputDecoration(labelText: "Transmission", border: OutlineInputBorder()),
                items: _transmissions.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (val) => setState(() => _selectedTransmission = val!),
              )),
              const SizedBox(width: 12),
              Expanded(child: DropdownButtonFormField<String>(
                initialValue: _selectedDrive,
                decoration: const InputDecoration(labelText: "Drive Type", border: OutlineInputBorder()),
                items: _drives.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (val) => setState(() => _selectedDrive = val!),
              )),
            ]),
            const SizedBox(height: 12),
          ],

          Row(children: [
            Expanded(child: TextField(controller: _engineController, decoration: const InputDecoration(labelText: "Engine Size (optional)", hintText: "e.g. 2.0L", border: OutlineInputBorder()))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: _vinController, decoration: const InputDecoration(labelText: "VIN (optional)", border: OutlineInputBorder()))),
          ]),
          const SizedBox(height: 20),

          _sectionHeader(Icons.location_on_outlined, "Location & Description", const Color(0xFFE67E22)),
          const SizedBox(height: 12),

          TextField(controller: _locationController, decoration: const InputDecoration(labelText: "Location", hintText: "e.g. Beirut, Lebanon", prefixIcon: Icon(Icons.location_on_outlined), border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _descriptionController, maxLines: 4, decoration: const InputDecoration(labelText: "Description", border: OutlineInputBorder())),
          const SizedBox(height: 20),

          // Stock
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Icon(Icons.inventory_2_outlined, color: Color(0xFF4A90E2), size: 20),
                SizedBox(width: 8),
                Text("Stock Quantity", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
              ]),
              const SizedBox(height: 14),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                IconButton(onPressed: () => setState(() => _stock = (_stock - 1).clamp(0, 9999)), icon: const Icon(Icons.remove_circle_outline, size: 36), color: _stock <= 0 ? Colors.grey : Colors.redAccent),
                const SizedBox(width: 16),
                Container(
                  width: 80, height: 60, alignment: Alignment.center,
                  decoration: BoxDecoration(color: _stock <= 0 ? Colors.red.shade50 : Colors.grey.shade100, borderRadius: BorderRadius.circular(12), border: Border.all(color: _stock <= 0 ? Colors.red : Colors.grey.shade300)),
                  child: Text('$_stock', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _stock <= 0 ? Colors.red : Colors.black)),
                ),
                const SizedBox(width: 16),
                IconButton(onPressed: () => setState(() => _stock = (_stock + 1).clamp(0, 9999)), icon: const Icon(Icons.add_circle_outline, size: 36), color: const Color(0xFF27AE60)),
              ]),
              if (_stock <= 0)
                const Padding(padding: EdgeInsets.only(top: 8), child: Center(child: Text("⚠️ Listing will be hidden from marketplace", style: TextStyle(color: Colors.red, fontSize: 13)))),
            ]),
          ),
          const SizedBox(height: 20),

          // Seller section
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
                Text("Your Seller Profile", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
              ]),
              const SizedBox(height: 4),
              const Text("Enter your seller name to link this listing.", style: TextStyle(fontSize: 12, color: Colors.grey)),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerProfilePage())),
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 30), tapTargetSize: MaterialTapTargetSize.shrinkWrap, alignment: Alignment.centerLeft),
                child: const Text("Don't have a profile? Create one here", style: TextStyle(color: Color(0xFF27AE60), fontSize: 12, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
              ),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: TextField(controller: _sellerNameController, decoration: const InputDecoration(labelText: "Seller Name", border: OutlineInputBorder(), isDense: true))),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _isSearchingSeller ? null : _lookupSeller,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF27AE60), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: _isSearchingSeller ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.search, color: Colors.white),
                ),
              ]),
              if (_sellerVerified)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFF27AE60).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        const Icon(Icons.check_circle, color: Color(0xFF27AE60), size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text("Linked to ${_sellerNameController.text.trim()}\n📞 $_sellerPhone  ✉️ $_sellerEmail", style: const TextStyle(fontSize: 12, color: Color(0xFF27AE60)))),
                      ]),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _openWhatsApp,
                          icon: const Icon(Icons.chat, color: Colors.white, size: 18),
                          label: const Text("Contact on WhatsApp", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(vertical: 12)),
                        ),
                      ),
                    ]),
                  ),
                ),
            ]),
          ),
          const SizedBox(height: 25),

          // Save button
          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton.icon(
              onPressed: _isUploading ? null : _save,
              icon: Icon(widget.parent.icon, color: Colors.white),
              label: _isUploading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(_isEditing ? "Update Vehicle" : "Publish Vehicle",
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: widget.parent.color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title, Color color) {
    return Row(children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(width: 8),
      Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
      const SizedBox(width: 8),
      Expanded(child: Divider(color: color.withValues(alpha: 0.3))),
    ]);
  }

  Color _colorFromName(String name) {
    switch (name.toLowerCase()) {
      case 'white':  return Colors.white;
      case 'black':  return Colors.black;
      case 'silver': return Colors.grey.shade400;
      case 'gray':   return Colors.grey;
      case 'red':    return Colors.red;
      case 'blue':   return Colors.blue;
      case 'green':  return Colors.green;
      case 'yellow': return Colors.yellow;
      case 'orange': return Colors.orange;
      case 'brown':  return Colors.brown;
      case 'gold':   return const Color(0xFFFFD700);
      case 'beige':  return const Color(0xFFF5F5DC);
      default:       return Colors.grey.shade300;
    }
  }
}