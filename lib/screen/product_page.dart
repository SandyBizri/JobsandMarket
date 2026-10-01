/*import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'add_item.dart';
import 'product_detail_page.dart';
import 'vehicle_detailed_page.dart';
import 'home_detailed_page.dart';
import 'seller_profile_page.dart';
import 'chat_inbox_page.dart';
import '../screen/seller_session.dart';

const String projectId = 'marketplaneproducts';
const String firestoreUrl =
    'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents';

// ─── FILTER MODELS ────────────────────────────────────────────────────────────

class _FilterCategory {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final String section; // 'all' | 'item' | 'vehicle' | 'home'

  const _FilterCategory({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.section,
  });
}

const _FilterCategory _kAllFilter = _FilterCategory(
  id: 'all', label: 'All', icon: Icons.apps_outlined,
  color: Color(0xFF4A90E2), section: 'all',
);

// ── Item categories ────────────────────────────────────────────────────────────
const List<_FilterCategory> _itemFilters = [
  _FilterCategory(id: 'electronics',        label: 'Electronics',            icon: Icons.devices_outlined,             color: Color(0xFF4A90E2), section: 'item'),
  _FilterCategory(id: 'phones_tablets',     label: 'Phones & Tablets',       icon: Icons.smartphone_outlined,          color: Color(0xFF1E88E5), section: 'item'),
  _FilterCategory(id: 'computers',          label: 'Computers & Laptops',    icon: Icons.laptop_outlined,              color: Color(0xFF1976D2), section: 'item'),
  _FilterCategory(id: 'cameras',            label: 'Cameras',                icon: Icons.camera_alt_outlined,          color: Color(0xFF1565C0), section: 'item'),
  _FilterCategory(id: 'audio',              label: 'Audio & Headphones',     icon: Icons.headphones_outlined,          color: Color(0xFF0D47A1), section: 'item'),
  _FilterCategory(id: 'gaming',             label: 'Gaming & Consoles',      icon: Icons.sports_esports_outlined,      color: Color(0xFF5E35B1), section: 'item'),
  _FilterCategory(id: 'tv_video',           label: 'TVs & Video',            icon: Icons.tv_outlined,                  color: Color(0xFF283593), section: 'item'),
  _FilterCategory(id: 'wearables',          label: 'Wearables',              icon: Icons.watch_outlined,               color: Color(0xFF3949AB), section: 'item'),
  _FilterCategory(id: 'networking',         label: 'Networking & WiFi',      icon: Icons.router_outlined,              color: Color(0xFF1A237E), section: 'item'),
  _FilterCategory(id: 'cables_accessories', label: 'Cables & Accessories',   icon: Icons.usb_outlined,                 color: Color(0xFF4527A0), section: 'item'),
  _FilterCategory(id: 'clothing',           label: 'Clothing & Fashion',     icon: Icons.checkroom_outlined,           color: Color(0xFFE91E8C), section: 'item'),
  _FilterCategory(id: 'mens_clothing',      label: "Men's Clothing",         icon: Icons.person_outlined,              color: Color(0xFFD81B60), section: 'item'),
  _FilterCategory(id: 'womens_clothing',    label: "Women's Clothing",       icon: Icons.people_outlined,              color: Color(0xFFC2185B), section: 'item'),
  _FilterCategory(id: 'kids_clothing',      label: "Kids' Clothing",         icon: Icons.child_care_outlined,          color: Color(0xFFAD1457), section: 'item'),
  _FilterCategory(id: 'shoes',              label: 'Shoes & Footwear',       icon: Icons.directions_walk_outlined,     color: Color(0xFF880E4F), section: 'item'),
  _FilterCategory(id: 'bags',               label: 'Bags & Luggage',         icon: Icons.luggage_outlined,             color: Color(0xFFF06292), section: 'item'),
  _FilterCategory(id: 'jewelry',            label: 'Jewelry & Watches',      icon: Icons.diamond_outlined,             color: Color(0xFFE91E63), section: 'item'),
  _FilterCategory(id: 'sportswear',         label: 'Sportswear',             icon: Icons.directions_run_outlined,      color: Color(0xFFEC407A), section: 'item'),
  _FilterCategory(id: 'hats_scarves',       label: 'Hats, Scarves & Gloves', icon: Icons.accessibility_outlined,       color: Color(0xFFF48FB1), section: 'item'),
  _FilterCategory(id: 'furniture',          label: 'Furniture & Home',       icon: Icons.chair_outlined,               color: Color(0xFF8D6E63), section: 'item'),
  _FilterCategory(id: 'living_room',        label: 'Living Room',            icon: Icons.weekend_outlined,             color: Color(0xFF6D4C41), section: 'item'),
  _FilterCategory(id: 'bedroom',            label: 'Bedroom',                icon: Icons.bed_outlined,                 color: Color(0xFF5D4037), section: 'item'),
  _FilterCategory(id: 'office_furniture',   label: 'Office Furniture',       icon: Icons.desk_outlined,                color: Color(0xFF4E342E), section: 'item'),
  _FilterCategory(id: 'outdoor_furniture',  label: 'Outdoor & Garden',       icon: Icons.outdoor_grill_outlined,       color: Color(0xFF3E2723), section: 'item'),
  _FilterCategory(id: 'lighting',           label: 'Lighting',               icon: Icons.light_outlined,               color: Color(0xFFA1887F), section: 'item'),
  _FilterCategory(id: 'home_decor',         label: 'Home Decor',             icon: Icons.format_paint_outlined,        color: Color(0xFFBCAAA4), section: 'item'),
  _FilterCategory(id: 'storage',            label: 'Storage & Organization', icon: Icons.inventory_2_outlined,         color: Color(0xFF795548), section: 'item'),
  _FilterCategory(id: 'books',              label: 'Books & Media',          icon: Icons.menu_book_outlined,           color: Color(0xFF26A69A), section: 'item'),
  _FilterCategory(id: 'fiction',            label: 'Fiction',                icon: Icons.book_outlined,                color: Color(0xFF00897B), section: 'item'),
  _FilterCategory(id: 'non_fiction',        label: 'Non-Fiction',            icon: Icons.library_books_outlined,       color: Color(0xFF00796B), section: 'item'),
  _FilterCategory(id: 'textbooks',          label: 'Textbooks & Education',  icon: Icons.school_outlined,              color: Color(0xFF00695C), section: 'item'),
  _FilterCategory(id: 'sports',             label: 'Sports & Outdoors',      icon: Icons.sports_soccer_outlined,       color: Color(0xFF27AE60), section: 'item'),
  _FilterCategory(id: 'fitness',            label: 'Gym & Fitness',          icon: Icons.fitness_center_outlined,      color: Color(0xFF2E7D32), section: 'item'),
  _FilterCategory(id: 'cycling',            label: 'Cycling',                icon: Icons.directions_bike_outlined,     color: Color(0xFF388E3C), section: 'item'),
  _FilterCategory(id: 'camping_hiking',     label: 'Camping & Hiking',       icon: Icons.terrain_outlined,             color: Color(0xFF43A047), section: 'item'),
  _FilterCategory(id: 'toys',               label: 'Toys & Games',           icon: Icons.toys_outlined,                color: Color(0xFFFF7043), section: 'item'),
  _FilterCategory(id: 'board_games',        label: 'Board Games & Puzzles',  icon: Icons.extension_outlined,           color: Color(0xFFE64A19), section: 'item'),
  _FilterCategory(id: 'video_games',        label: 'Video Games',            icon: Icons.videogame_asset_outlined,     color: Color(0xFFDD2C00), section: 'item'),
  _FilterCategory(id: 'beauty',             label: 'Beauty & Health',        icon: Icons.spa_outlined,                 color: Color(0xFFAB47BC), section: 'item'),
  _FilterCategory(id: 'skincare',           label: 'Skincare',               icon: Icons.face_outlined,                color: Color(0xFF8E24AA), section: 'item'),
  _FilterCategory(id: 'makeup',             label: 'Makeup & Cosmetics',     icon: Icons.brush_outlined,               color: Color(0xFF7B1FA2), section: 'item'),
  _FilterCategory(id: 'kitchen',            label: 'Kitchen & Dining',       icon: Icons.kitchen_outlined,             color: Color(0xFFE67E22), section: 'item'),
  _FilterCategory(id: 'cookware',           label: 'Cookware & Bakeware',    icon: Icons.soup_kitchen_outlined,        color: Color(0xFFD35400), section: 'item'),
  _FilterCategory(id: 'small_appliances',   label: 'Small Appliances',       icon: Icons.microwave_outlined,           color: Color(0xFFBA4A00), section: 'item'),
  _FilterCategory(id: 'tools',              label: 'Tools & DIY',            icon: Icons.handyman_outlined,            color: Color(0xFF546E7A), section: 'item'),
  _FilterCategory(id: 'power_tools',        label: 'Power Tools',            icon: Icons.construction_outlined,        color: Color(0xFF455A64), section: 'item'),
  _FilterCategory(id: 'hand_tools',         label: 'Hand Tools',             icon: Icons.hardware_outlined,            color: Color(0xFF37474F), section: 'item'),
  _FilterCategory(id: 'baby',               label: 'Baby & Kids',            icon: Icons.child_care_outlined,          color: Color(0xFFEC407A), section: 'item'),
  _FilterCategory(id: 'baby_gear',          label: 'Strollers & Car Seats',  icon: Icons.accessible_outlined,          color: Color(0xFFC2185B), section: 'item'),
  _FilterCategory(id: 'music_instruments',  label: 'Music & Instruments',    icon: Icons.music_note_outlined,          color: Color(0xFF5C6BC0), section: 'item'),
  _FilterCategory(id: 'guitars',            label: 'Guitars & Bass',         icon: Icons.music_note_outlined,          color: Color(0xFF3949AB), section: 'item'),
  _FilterCategory(id: 'art',                label: 'Art & Collectibles',     icon: Icons.palette_outlined,             color: Color(0xFFD4AC0D), section: 'item'),
  _FilterCategory(id: 'paintings_prints',   label: 'Paintings & Prints',     icon: Icons.image_outlined,               color: Color(0xFFB7950B), section: 'item'),
  _FilterCategory(id: 'pets',               label: 'Pet Supplies',           icon: Icons.pets_outlined,                color: Color(0xFF795548), section: 'item'),
  _FilterCategory(id: 'dog_supplies',       label: 'Dog Supplies',           icon: Icons.pets_outlined,                color: Color(0xFF6D4C41), section: 'item'),
  _FilterCategory(id: 'other',              label: 'Other',                  icon: Icons.category_outlined,            color: Color(0xFF90A4AE), section: 'item'),
  _FilterCategory(id: 'office_supplies',    label: 'Office Supplies',        icon: Icons.business_center_outlined,     color: Color(0xFF78909C), section: 'item'),
  _FilterCategory(id: 'services',           label: 'Services & Rentals',     icon: Icons.miscellaneous_services_outlined, color: Color(0xFFB0BEC5), section: 'item'),
];

// ── Vehicle categories ─────────────────────────────────────────────────────────
const List<_FilterCategory> _vehicleFilters = [
  _FilterCategory(id: 'v_all',           label: 'All Vehicles',       icon: Icons.commute_outlined,             color: Color(0xFF27AE60), section: 'vehicle'),
  _FilterCategory(id: 'cars',            label: 'Cars',               icon: Icons.directions_car_outlined,      color: Color(0xFF4A90E2), section: 'vehicle'),
  _FilterCategory(id: 'sedan',           label: 'Sedan',              icon: Icons.directions_car_outlined,      color: Color(0xFF1E88E5), section: 'vehicle'),
  _FilterCategory(id: 'suv',             label: 'SUV / Crossover',    icon: Icons.directions_car_outlined,      color: Color(0xFF1976D2), section: 'vehicle'),
  _FilterCategory(id: 'coupe',           label: 'Coupe',              icon: Icons.directions_car_outlined,      color: Color(0xFF1565C0), section: 'vehicle'),
  _FilterCategory(id: 'hatchback',       label: 'Hatchback',          icon: Icons.directions_car_outlined,      color: Color(0xFF0D47A1), section: 'vehicle'),
  _FilterCategory(id: 'convertible',     label: 'Convertible',        icon: Icons.directions_car_outlined,      color: Color(0xFF283593), section: 'vehicle'),
  _FilterCategory(id: 'wagon',           label: 'Station Wagon',      icon: Icons.directions_car_outlined,      color: Color(0xFF3949AB), section: 'vehicle'),
  _FilterCategory(id: 'minivan',         label: 'Minivan',            icon: Icons.airport_shuttle_outlined,     color: Color(0xFF5C6BC0), section: 'vehicle'),
  _FilterCategory(id: 'pickup_car',      label: 'Pickup Truck',       icon: Icons.local_shipping_outlined,      color: Color(0xFF7986CB), section: 'vehicle'),
  _FilterCategory(id: 'electric_car',    label: 'Electric / Hybrid',  icon: Icons.electric_car_outlined,        color: Color(0xFF4527A0), section: 'vehicle'),
  _FilterCategory(id: 'luxury_car',      label: 'Luxury & Sports',    icon: Icons.directions_car_outlined,      color: Color(0xFF1A237E), section: 'vehicle'),
  _FilterCategory(id: 'motorcycles',     label: 'Motorcycles',        icon: Icons.two_wheeler_outlined,         color: Color(0xFFE67E22), section: 'vehicle'),
  _FilterCategory(id: 'sport_bike',      label: 'Sport Bike',         icon: Icons.two_wheeler_outlined,         color: Color(0xFFD35400), section: 'vehicle'),
  _FilterCategory(id: 'cruiser',         label: 'Cruiser',            icon: Icons.two_wheeler_outlined,         color: Color(0xFFBA4A00), section: 'vehicle'),
  _FilterCategory(id: 'scooter',         label: 'Scooter / Moped',    icon: Icons.two_wheeler_outlined,         color: Color(0xFFA04000), section: 'vehicle'),
  _FilterCategory(id: 'dirt_bike',       label: 'Dirt Bike',          icon: Icons.two_wheeler_outlined,         color: Color(0xFF873600), section: 'vehicle'),
  _FilterCategory(id: 'adventure',       label: 'Adventure / Touring',icon: Icons.two_wheeler_outlined,         color: Color(0xFFEB984E), section: 'vehicle'),
  _FilterCategory(id: 'electric_moto',   label: 'Electric Moto',      icon: Icons.electric_moped_outlined,      color: Color(0xFFCA6F1E), section: 'vehicle'),
  _FilterCategory(id: 'atv',             label: 'ATV / Quad',         icon: Icons.two_wheeler_outlined,         color: Color(0xFFF0A500), section: 'vehicle'),
  _FilterCategory(id: 'trucks',          label: 'Trucks',             icon: Icons.local_shipping_outlined,      color: Color(0xFF27AE60), section: 'vehicle'),
  _FilterCategory(id: 'light_pickup',    label: 'Light Pickup',       icon: Icons.local_shipping_outlined,      color: Color(0xFF2E7D32), section: 'vehicle'),
  _FilterCategory(id: 'heavy_truck',     label: 'Heavy Truck',        icon: Icons.local_shipping_outlined,      color: Color(0xFF388E3C), section: 'vehicle'),
  _FilterCategory(id: 'semi_truck',      label: 'Semi / 18-Wheeler',  icon: Icons.local_shipping_outlined,      color: Color(0xFF43A047), section: 'vehicle'),
  _FilterCategory(id: 'van_cargo',       label: 'Cargo Van',          icon: Icons.airport_shuttle_outlined,     color: Color(0xFF81C784), section: 'vehicle'),
  _FilterCategory(id: 'boats',           label: 'Boats & Watercraft', icon: Icons.directions_boat_outlined,     color: Color(0xFF1ABC9C), section: 'vehicle'),
  _FilterCategory(id: 'speedboat',       label: 'Speedboat',          icon: Icons.directions_boat_outlined,     color: Color(0xFF17A589), section: 'vehicle'),
  _FilterCategory(id: 'sailboat',        label: 'Sailboat',           icon: Icons.directions_boat_outlined,     color: Color(0xFF148F77), section: 'vehicle'),
  _FilterCategory(id: 'yacht',           label: 'Yacht',              icon: Icons.directions_boat_outlined,     color: Color(0xFF117A65), section: 'vehicle'),
  _FilterCategory(id: 'jet_ski',         label: 'Jet Ski / PWC',      icon: Icons.pool_outlined,                color: Color(0xFF0E6655), section: 'vehicle'),
  _FilterCategory(id: 'fishing_boat',    label: 'Fishing Boat',       icon: Icons.directions_boat_outlined,     color: Color(0xFF76D7C4), section: 'vehicle'),
  _FilterCategory(id: 'buses',           label: 'Buses & Vans',       icon: Icons.directions_bus_outlined,      color: Color(0xFF9B59B6), section: 'vehicle'),
  _FilterCategory(id: 'minibus',         label: 'Minibus',            icon: Icons.directions_bus_outlined,      color: Color(0xFF8E44AD), section: 'vehicle'),
  _FilterCategory(id: 'coach_bus',       label: 'Coach / Full Bus',   icon: Icons.directions_bus_outlined,      color: Color(0xFF7D3C98), section: 'vehicle'),
  _FilterCategory(id: 'passenger_van',   label: 'Passenger Van',      icon: Icons.airport_shuttle_outlined,     color: Color(0xFFBB8FCE), section: 'vehicle'),
  _FilterCategory(id: 'camper_van',      label: 'Camper / RV',        icon: Icons.airport_shuttle_outlined,     color: Color(0xFFA569BD), section: 'vehicle'),
  _FilterCategory(id: 'equipment',       label: 'Heavy Equipment',    icon: Icons.construction_outlined,        color: Color(0xFFE74C3C), section: 'vehicle'),
  _FilterCategory(id: 'excavator',       label: 'Excavator',          icon: Icons.construction_outlined,        color: Color(0xFFC0392B), section: 'vehicle'),
  _FilterCategory(id: 'bulldozer',       label: 'Bulldozer',          icon: Icons.construction_outlined,        color: Color(0xFFAB2323), section: 'vehicle'),
  _FilterCategory(id: 'forklift',        label: 'Forklift',           icon: Icons.construction_outlined,        color: Color(0xFF922B21), section: 'vehicle'),
  _FilterCategory(id: 'tractor',         label: 'Tractor / Farm',     icon: Icons.agriculture_outlined,         color: Color(0xFFEC7063), section: 'vehicle'),
  _FilterCategory(id: 'bicycles',        label: 'Bicycles & Micro',   icon: Icons.directions_bike_outlined,     color: Color(0xFF16A085), section: 'vehicle'),
  _FilterCategory(id: 'road_bike',       label: 'Road Bike',          icon: Icons.directions_bike_outlined,     color: Color(0xFF138D75), section: 'vehicle'),
  _FilterCategory(id: 'mountain_bike',   label: 'Mountain Bike',      icon: Icons.directions_bike_outlined,     color: Color(0xFF117A65), section: 'vehicle'),
  _FilterCategory(id: 'ebike',           label: 'Electric Bike',      icon: Icons.electric_bike_outlined,       color: Color(0xFF0E6655), section: 'vehicle'),
  _FilterCategory(id: 'electric_scooter',label: 'Electric Scooter',   icon: Icons.electric_scooter_outlined,    color: Color(0xFF76D7C4), section: 'vehicle'),
  _FilterCategory(id: 'kids_bike',       label: 'Kids Bicycle',       icon: Icons.directions_bike_outlined,     color: Color(0xFF48C9B0), section: 'vehicle'),
  _FilterCategory(id: 'other_vehicle',   label: 'Other Vehicle',      icon: Icons.commute_outlined,             color: Color(0xFF90A4AE), section: 'vehicle'),
  _FilterCategory(id: 'trailer',         label: 'Trailer',            icon: Icons.rv_hookup_outlined,           color: Color(0xFF78909C), section: 'vehicle'),
  _FilterCategory(id: 'golf_cart',       label: 'Golf Cart',          icon: Icons.electric_car_outlined,        color: Color(0xFF546E7A), section: 'vehicle'),
  _FilterCategory(id: 'other_misc',      label: 'Other Vehicle',      icon: Icons.commute_outlined,             color: Color(0xFFB0BEC5), section: 'vehicle'),
];

// ── Home / property categories ─────────────────────────────────────────────────
const List<_FilterCategory> _homeFilters = [
  _FilterCategory(id: 'h_all_sell',      label: 'All For Sale',       icon: Icons.sell_outlined,                color: Color(0xFFE67E22), section: 'home'),
  _FilterCategory(id: 'h_all_rent',      label: 'All For Rent',       icon: Icons.key_outlined,                 color: Color(0xFF5C6BC0), section: 'home'),
  _FilterCategory(id: 'residential',     label: 'Residential',        icon: Icons.home_outlined,                color: Color(0xFFE67E22), section: 'home'),
  _FilterCategory(id: 'apartment',       label: 'Apartment',          icon: Icons.apartment_outlined,           color: Color(0xFFD35400), section: 'home'),
  _FilterCategory(id: 'house',           label: 'House',              icon: Icons.house_outlined,               color: Color(0xFFBA4A00), section: 'home'),
  _FilterCategory(id: 'villa',           label: 'Villa',              icon: Icons.villa_outlined,               color: Color(0xFFA04000), section: 'home'),
  _FilterCategory(id: 'studio',          label: 'Studio',             icon: Icons.meeting_room_outlined,        color: Color(0xFF873600), section: 'home'),
  _FilterCategory(id: 'duplex',          label: 'Duplex / Triplex',   icon: Icons.layers_outlined,              color: Color(0xFFEB984E), section: 'home'),
  _FilterCategory(id: 'penthouse',       label: 'Penthouse',          icon: Icons.roofing_outlined,             color: Color(0xFFCA6F1E), section: 'home'),
  _FilterCategory(id: 'townhouse',       label: 'Townhouse',          icon: Icons.holiday_village_outlined,     color: Color(0xFFF0A500), section: 'home'),
  _FilterCategory(id: 'chalet',          label: 'Chalet / Cabin',     icon: Icons.cabin_outlined,               color: Color(0xFFE59866), section: 'home'),
  _FilterCategory(id: 'room_shared',     label: 'Room / Shared',      icon: Icons.bed_outlined,                 color: Color(0xFFF5CBA7), section: 'home'),
  _FilterCategory(id: 'commercial',      label: 'Commercial',         icon: Icons.business_outlined,            color: Color(0xFF5C6BC0), section: 'home'),
  _FilterCategory(id: 'office',          label: 'Office',             icon: Icons.business_center_outlined,     color: Color(0xFF3949AB), section: 'home'),
  _FilterCategory(id: 'shop',            label: 'Shop / Retail',      icon: Icons.storefront_outlined,          color: Color(0xFF303F9F), section: 'home'),
  _FilterCategory(id: 'showroom',        label: 'Showroom',           icon: Icons.store_outlined,               color: Color(0xFF283593), section: 'home'),
  _FilterCategory(id: 'restaurant_space',label: 'Restaurant Space',   icon: Icons.restaurant_outlined,          color: Color(0xFF1A237E), section: 'home'),
  _FilterCategory(id: 'coworking',       label: 'Co-working Space',   icon: Icons.people_outlined,              color: Color(0xFF7986CB), section: 'home'),
  _FilterCategory(id: 'industrial',      label: 'Industrial',         icon: Icons.factory_outlined,             color: Color(0xFF546E7A), section: 'home'),
  _FilterCategory(id: 'warehouse',       label: 'Warehouse',          icon: Icons.warehouse_outlined,           color: Color(0xFF455A64), section: 'home'),
  _FilterCategory(id: 'factory',         label: 'Factory / Workshop', icon: Icons.precision_manufacturing_outlined, color: Color(0xFF37474F), section: 'home'),
  _FilterCategory(id: 'storage_unit',    label: 'Storage Unit',       icon: Icons.inventory_2_outlined,         color: Color(0xFF263238), section: 'home'),
  _FilterCategory(id: 'garage_space',    label: 'Garage / Parking',   icon: Icons.garage_outlined,              color: Color(0xFF607D8B), section: 'home'),
  _FilterCategory(id: 'land',            label: 'Land & Plots',       icon: Icons.landscape_outlined,           color: Color(0xFF27AE60), section: 'home'),
  _FilterCategory(id: 'residential_land',label: 'Residential Plot',   icon: Icons.crop_square_outlined,         color: Color(0xFF2E7D32), section: 'home'),
  _FilterCategory(id: 'commercial_land', label: 'Commercial Plot',    icon: Icons.business_outlined,            color: Color(0xFF388E3C), section: 'home'),
  _FilterCategory(id: 'farm_land',       label: 'Farm / Agricultural',icon: Icons.agriculture_outlined,         color: Color(0xFF43A047), section: 'home'),
  _FilterCategory(id: 'coastal_land',    label: 'Coastal / Waterfront',icon: Icons.water_outlined,              color: Color(0xFF66BB6A), section: 'home'),
  _FilterCategory(id: 'hospitality',     label: 'Hospitality',        icon: Icons.hotel_outlined,               color: Color(0xFF1ABC9C), section: 'home'),
  _FilterCategory(id: 'hotel',           label: 'Hotel / Motel',      icon: Icons.hotel_outlined,               color: Color(0xFF17A589), section: 'home'),
  _FilterCategory(id: 'resort',          label: 'Resort',             icon: Icons.beach_access_outlined,        color: Color(0xFF148F77), section: 'home'),
  _FilterCategory(id: 'guesthouse',      label: 'Guesthouse / B&B',   icon: Icons.house_outlined,               color: Color(0xFF117A65), section: 'home'),
  _FilterCategory(id: 'holiday_home',    label: 'Holiday Home',       icon: Icons.home_work_outlined,           color: Color(0xFF76D7C4), section: 'home'),
  _FilterCategory(id: 'other_property',  label: 'Other Property',     icon: Icons.category_outlined,            color: Color(0xFF90A4AE), section: 'home'),
  _FilterCategory(id: 'mixed_use',       label: 'Mixed Use',          icon: Icons.domain_outlined,              color: Color(0xFF78909C), section: 'home'),
  _FilterCategory(id: 'parking_lot',     label: 'Parking Lot',        icon: Icons.local_parking_outlined,       color: Color(0xFF607D8B), section: 'home'),
  _FilterCategory(id: 'other_prop_misc', label: 'Other Property',     icon: Icons.more_horiz_outlined,          color: Color(0xFFB0BEC5), section: 'home'),
];

// ─── GROUP MODELS ─────────────────────────────────────────────────────────────

class _CategoryGroup {
  final String label;
  final IconData icon;
  final Color color;
  final List<_FilterCategory> items;

  const _CategoryGroup({
    required this.label,
    required this.icon,
    required this.color,
    required this.items,
  });
}

// Item groups
final List<_CategoryGroup> _itemGroups = [
  _CategoryGroup(label: 'Electronics', icon: Icons.devices_outlined, color: const Color(0xFF4A90E2),
    items: _itemFilters.where((f) => ['electronics','phones_tablets','computers','cameras','audio','gaming','tv_video','wearables','networking','cables_accessories'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Clothing & Fashion', icon: Icons.checkroom_outlined, color: const Color(0xFFE91E8C),
    items: _itemFilters.where((f) => ['clothing','mens_clothing','womens_clothing','kids_clothing','shoes','bags','jewelry','sportswear','hats_scarves'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Furniture & Home', icon: Icons.chair_outlined, color: const Color(0xFF8D6E63),
    items: _itemFilters.where((f) => ['furniture','living_room','bedroom','office_furniture','outdoor_furniture','lighting','home_decor','storage'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Books & Media', icon: Icons.menu_book_outlined, color: const Color(0xFF26A69A),
    items: _itemFilters.where((f) => ['books','fiction','non_fiction','textbooks'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Sports & Outdoors', icon: Icons.sports_soccer_outlined, color: const Color(0xFF27AE60),
    items: _itemFilters.where((f) => ['sports','fitness','cycling','camping_hiking'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Toys & Games', icon: Icons.toys_outlined, color: const Color(0xFFFF7043),
    items: _itemFilters.where((f) => ['toys','board_games','video_games'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Beauty & Health', icon: Icons.spa_outlined, color: const Color(0xFFAB47BC),
    items: _itemFilters.where((f) => ['beauty','skincare','makeup'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Kitchen & Dining', icon: Icons.kitchen_outlined, color: const Color(0xFFE67E22),
    items: _itemFilters.where((f) => ['kitchen','cookware','small_appliances'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Tools & DIY', icon: Icons.handyman_outlined, color: const Color(0xFF546E7A),
    items: _itemFilters.where((f) => ['tools','power_tools','hand_tools'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Baby & Kids', icon: Icons.child_care_outlined, color: const Color(0xFFEC407A),
    items: _itemFilters.where((f) => ['baby','baby_gear'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Music & Instruments', icon: Icons.music_note_outlined, color: const Color(0xFF5C6BC0),
    items: _itemFilters.where((f) => ['music_instruments','guitars'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Art & Collectibles', icon: Icons.palette_outlined, color: const Color(0xFFD4AC0D),
    items: _itemFilters.where((f) => ['art','paintings_prints'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Pet Supplies', icon: Icons.pets_outlined, color: const Color(0xFF795548),
    items: _itemFilters.where((f) => ['pets','dog_supplies'].contains(f.id)).toList()),
];

// Vehicle groups
final List<_CategoryGroup> _vehicleGroups = [
  _CategoryGroup(label: 'All Vehicles', icon: Icons.commute_outlined, color: const Color(0xFF27AE60),
    items: _vehicleFilters.where((f) => ['v_all'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Cars', icon: Icons.directions_car_outlined, color: const Color(0xFF4A90E2),
    items: _vehicleFilters.where((f) => ['cars','sedan','suv','coupe','hatchback','convertible','wagon','minivan','pickup_car','electric_car','luxury_car'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Motorcycles', icon: Icons.two_wheeler_outlined, color: const Color(0xFFE67E22),
    items: _vehicleFilters.where((f) => ['motorcycles','sport_bike','cruiser','scooter','dirt_bike','adventure','electric_moto','atv'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Trucks', icon: Icons.local_shipping_outlined, color: const Color(0xFF27AE60),
    items: _vehicleFilters.where((f) => ['trucks','light_pickup','heavy_truck','semi_truck','van_cargo'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Boats & Watercraft', icon: Icons.directions_boat_outlined, color: const Color(0xFF1ABC9C),
    items: _vehicleFilters.where((f) => ['boats','speedboat','sailboat','yacht','jet_ski','fishing_boat'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Buses & Vans', icon: Icons.directions_bus_outlined, color: const Color(0xFF9B59B6),
    items: _vehicleFilters.where((f) => ['buses','minibus','coach_bus','passenger_van','camper_van'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Heavy Equipment', icon: Icons.construction_outlined, color: const Color(0xFFE74C3C),
    items: _vehicleFilters.where((f) => ['equipment','excavator','bulldozer','forklift','tractor'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Bicycles & Micro', icon: Icons.directions_bike_outlined, color: const Color(0xFF16A085),
    items: _vehicleFilters.where((f) => ['bicycles','road_bike','mountain_bike','ebike','electric_scooter','kids_bike'].contains(f.id)).toList()),
];

// Home groups
final List<_CategoryGroup> _homeGroups = [
  _CategoryGroup(label: 'Quick Filter', icon: Icons.filter_list_outlined, color: const Color(0xFF4A90E2),
    items: _homeFilters.where((f) => ['h_all_sell','h_all_rent'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Residential', icon: Icons.home_outlined, color: const Color(0xFFE67E22),
    items: _homeFilters.where((f) => ['residential','apartment','house','villa','studio','duplex','penthouse','townhouse','chalet','room_shared'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Commercial', icon: Icons.business_outlined, color: const Color(0xFF5C6BC0),
    items: _homeFilters.where((f) => ['commercial','office','shop','showroom','restaurant_space','coworking'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Industrial', icon: Icons.factory_outlined, color: const Color(0xFF546E7A),
    items: _homeFilters.where((f) => ['industrial','warehouse','factory','storage_unit','garage_space'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Land & Plots', icon: Icons.landscape_outlined, color: const Color(0xFF27AE60),
    items: _homeFilters.where((f) => ['land','residential_land','commercial_land','farm_land','coastal_land'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Hospitality', icon: Icons.hotel_outlined, color: const Color(0xFF1ABC9C),
    items: _homeFilters.where((f) => ['hospitality','hotel','resort','guesthouse','holiday_home'].contains(f.id)).toList()),
];

// ─── PAGE ─────────────────────────────────────────────────────────────────────

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<Map<String, dynamic>> _products = [];
  bool _loading = true;
  _FilterCategory _activeFilter = _kAllFilter;

  // ── SEARCH ────────────────────────────────────────────────────────────────
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchAllListings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<String> _resolveCurrentUserName() async {
    final sellerName = await SellerSession.getSellerName();
    if (sellerName != null && sellerName.isNotEmpty) return sellerName;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('buyer_name') ?? '';
  }

  Future<void> _fetchAllListings() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        http.get(Uri.parse('$firestoreUrl/products')),
        http.get(Uri.parse('$firestoreUrl/vehicles')),
        http.get(Uri.parse('$firestoreUrl/homes')),
      ]);

      final List<Map<String, dynamic>> allListings = [];

      for (int i = 0; i < results.length; i++) {
        final response  = results[i];
        final isVehicle = i == 1;
        final isHome    = i == 2;

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final docs = (data['documents'] as List? ?? []);

          for (final doc in docs) {
            final fields  = doc['fields'] as Map<String, dynamic>;
            final docName = doc['name'] as String;
            final docId   = docName.split('/').last;

            final createdAtStr = fields['createdAt']?['timestampValue'] as String?;
            final createdAt = createdAtStr != null ? DateTime.tryParse(createdAtStr) : null;

            if (isHome) {
              allListings.add({
                'id':               docId,
                'isVehicle':        false,
                'isHome':           true,
                'title':            fields['title']?['stringValue'] ?? 'Untitled Property',
                'price':            fields['price']?['stringValue'] ?? '0',
                'description':      fields['description']?['stringValue'] ?? '',
                'location':         fields['location']?['stringValue'] ?? '',
                'area':             fields['area']?['stringValue'] ?? '',
                'rooms':            fields['rooms']?['stringValue'] ?? '',
                'baths':            fields['baths']?['stringValue'] ?? '',
                'floor':            fields['floor']?['stringValue'] ?? '',
                'furnished':        fields['furnished']?['booleanValue'] ?? false,
                'intent':           fields['intent']?['stringValue'] ?? '',
                'propertyCategoryId': fields['propertyCategoryId']?['stringValue'] ?? '',
                'subCategoryId':    fields['subCategoryId']?['stringValue'] ?? '',
                'subCategory':      fields['subCategory']?['stringValue'] ?? '',
                'category':         'Home',
                'imageUrl':         fields['imageUrl']?['stringValue'] ?? '',
                'stock':            1,
                'password':         fields['password']?['stringValue'] ?? '',
                'sellerName':       fields['sellerName']?['stringValue'] ?? '',
                'sellerPhone':      fields['sellerPhone']?['stringValue'] ?? '',
                'sellerEmail':  fields['sellerEmail']?['stringValue'] ?? '',
                'status':       fields['status']?['stringValue'] ?? 'available',
                'createdAt':    createdAt,
              });
              continue;
            }

            final stock = int.tryParse(
                    (fields['stock']?['integerValue'] ??
                            fields['stock']?['doubleValue'] ??
                            '1')
                        .toString()) ??
                1;
            if (stock <= 0) continue;

            if (isVehicle) {
              allListings.add({
                'id':                docId,
                'isVehicle':         true,
                'isHome':            false,
                'title':             fields['title']?['stringValue'] ?? 'Untitled Vehicle',
                'price':             fields['price']?['stringValue'] ?? '0',
                'description':       fields['description']?['stringValue'] ?? '',
                'condition':         fields['condition']?['stringValue'] ?? '',
                'imageUrl':          fields['imageUrl']?['stringValue'] ?? '',
                'vehicleType':       fields['vehicleType']?['stringValue'] ?? '',
                'vehicleCategoryId': fields['vehicleCategoryId']?['stringValue'] ?? '',
                'vehicleTypeId':     fields['vehicleTypeId']?['stringValue'] ?? '',
                'make':              fields['make']?['stringValue'] ?? '',
                'model':             fields['model']?['stringValue'] ?? '',
                'year':              fields['year']?['stringValue'] ?? '',
                'mileage':           fields['mileage']?['stringValue'] ?? '',
                'color':             fields['color']?['stringValue'] ?? '',
                'location':          fields['location']?['stringValue'] ?? '',
                'stock':             stock,
                'password':          fields['password']?['stringValue'] ?? '',
                'sellerName':        fields['sellerName']?['stringValue'] ?? '',
                'sellerPhone':       fields['sellerPhone']?['stringValue'] ?? '',
                'sellerEmail':       fields['sellerEmail']?['stringValue'] ?? '',
                'createdAt':         createdAt,
              });
            } else {
              allListings.add({
                'id':               docId,
                'isVehicle':        false,
                'isHome':           false,
                'title':            fields['title']?['stringValue'] ?? 'Untitled',
                'price':            fields['price']?['stringValue'] ?? '0',
                'description':      fields['description']?['stringValue'] ?? '',
                'category':         fields['category']?['stringValue'] ?? '',
                'parentCategoryId': fields['parentCategoryId']?['stringValue'] ?? '',
                'subCategoryId':    fields['subCategoryId']?['stringValue'] ?? '',
                'subCategory':      fields['subCategory']?['stringValue'] ?? '',
                'condition':        fields['condition']?['stringValue'] ?? '',
                'imageUrl':         fields['imageUrl']?['stringValue'] ?? '',
                'stock':            stock,
                'password':         fields['password']?['stringValue'] ?? '',
                'sellerName':       fields['sellerName']?['stringValue'] ?? '',
                'sellerPhone':      fields['sellerPhone']?['stringValue'] ?? '',
                'sellerEmail':      fields['sellerEmail']?['stringValue'] ?? '',
                'createdAt':        createdAt,
              });
            }
          }
        }
      }

      allListings.sort((a, b) {
        final aTime = a['createdAt'] as DateTime?;
        final bTime = b['createdAt'] as DateTime?;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime);
      });

      setState(() { _products = allListings; _loading = false; });
    } catch (e) {
      debugPrint('Fetch error: $e');
      setState(() => _loading = false);
    }
  }

  // ── Filter logic ──────────────────────────────────────────────────────────
  List<Map<String, dynamic>> get _filteredProducts {
    final id = _activeFilter.id;
    final query = _searchQuery.toLowerCase().trim();

    List<Map<String, dynamic>> result = _products;

    // Apply category filter
    if (id != 'all') {
      result = result.where((item) {
        final bool isVehicle = item['isVehicle'] == true;
        final bool isHome    = item['isHome'] == true;

        if (_activeFilter.section == 'vehicle') {
          if (!isVehicle) return false;
          if (id == 'v_all') return true;
          final catId  = (item['vehicleCategoryId'] ?? '').toString();
          final typeId = (item['vehicleTypeId']     ?? '').toString();
          return catId == id || typeId == id;
        }

        if (_activeFilter.section == 'home') {
          if (!isHome) return false;
          if (id == 'h_all_sell') return item['intent'] == 'Sell';
          if (id == 'h_all_rent') return item['intent'] == 'Rent';
          final propCatId = (item['propertyCategoryId'] ?? '').toString();
          final subCatId  = (item['subCategoryId']      ?? '').toString();
          return propCatId == id || subCatId == id;
        }

        if (_activeFilter.section == 'item') {
          if (isVehicle || isHome) return false;
          final parentId = (item['parentCategoryId'] ?? '').toString();
          final subId    = (item['subCategoryId']    ?? '').toString();
          return parentId == id || subId == id;
        }

        return false;
      }).toList();
    }

    // Apply search query filter
    if (query.isNotEmpty) {
      result = result.where((item) {
        final title       = (item['title']       ?? '').toString().toLowerCase();
        final description = (item['description'] ?? '').toString().toLowerCase();
        final category    = (item['category']    ?? '').toString().toLowerCase();
        final location    = (item['location']    ?? '').toString().toLowerCase();
        final make        = (item['make']        ?? '').toString().toLowerCase();
        final model       = (item['model']       ?? '').toString().toLowerCase();
        return title.contains(query) ||
               description.contains(query) ||
               category.contains(query) ||
               location.contains(query) ||
               make.contains(query) ||
               model.contains(query);
      }).toList();
    }

    return result;
  }

  void _showCategorySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CategoryFilterSheet(
        activeFilter: _activeFilter,
        onSelected: (filter) {
          setState(() => _activeFilter = filter);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  Future<void> _openDetail(Map<String, dynamic> data) async {
    final bool isVehicle = data['isVehicle'] == true;
    final bool isHome    = data['isHome'] == true;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => isVehicle
            ? VehicleDetailPage(vehicle: data)
            : isHome
                ? HomeDetailPage(home: data)
                : ProductDetailPage(product: data),
      ),
    );
    if (result == 'deleted') _fetchAllListings();
  }

  @override
  Widget build(BuildContext context) {
    final bool isFiltered = _activeFilter.id != 'all';
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        // ── CHANGE 1: Title row moved up + search bar placed in AppBar ──
        titleSpacing: 0,
        toolbarHeight: 100,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 4, right: 4, top: 4, bottom: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: title + action icons
              Row(
                children: [
                  const Text(
                    'Marketplace',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.mail_outline, color: Color(0xFF2C3E50)),
                    tooltip: 'My Chats',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () async {
                      final currentName = await _resolveCurrentUserName();
                      if (!mounted) return;
                      if (currentName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter your name first.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatInboxPage(currentUserName: currentName),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFF2C3E50)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: _fetchAllListings,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.store_outlined, color: Color(0xFF4A90E2)),
                    tooltip: 'Seller Profile',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SellerProfilePage()),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
              const SizedBox(height: 6),
              // ── SEARCH BAR ──────────────────────────────────────────────
              SizedBox(
                height: 38,
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v.trim()),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: 'Search listings...',
                    hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey, size: 18),
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(children: [
        _buildTopButtons(isFiltered),
        if (isFiltered || _searchQuery.isNotEmpty) _buildActiveFilterBar(),
        const Divider(height: 1, thickness: 0.5),
        _buildProductGrid(),
      ]),
    );
  }

  Widget _buildActiveFilterBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(children: [
        if (_activeFilter.id != 'all') ...[
          Icon(_activeFilter.icon, size: 14, color: _activeFilter.color),
          const SizedBox(width: 6),
          Text(_activeFilter.label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _activeFilter.color)),
        ],
        if (_searchQuery.isNotEmpty) ...[
          if (_activeFilter.id != 'all') const SizedBox(width: 8),
          const Icon(Icons.search, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Flexible(
            child: Text('"$_searchQuery"',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                overflow: TextOverflow.ellipsis),
          ),
        ],
        const Spacer(),
        GestureDetector(
          onTap: () {
            setState(() {
              _activeFilter = _kAllFilter;
              _searchQuery = '';
              _searchController.clear();
            });
          },
          child: const Row(children: [
            Icon(Icons.close, size: 14, color: Colors.grey),
            SizedBox(width: 4),
            Text('Clear', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildTopButtons(bool isFiltered) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(children: [
        Expanded(
          child: _topButton(
            Icons.edit, 'Sell', const Color(0xFF4A90E2),
            () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddItemPage()));
              _fetchAllListings();
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _topButton(
            isFiltered ? _activeFilter.icon : Icons.category_outlined,
            isFiltered ? _activeFilter.label : 'Categories',
            isFiltered ? _activeFilter.color : const Color(0xFF4A90E2),
            _showCategorySheet,
          ),
        ),
      ]),
    );
  }

  Widget _buildProductGrid() {
    if (_loading) return const Expanded(child: Center(child: CircularProgressIndicator()));

    final filtered = _filteredProducts;
    if (filtered.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.storefront_outlined, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No results for "$_searchQuery"'
                  : _activeFilter.id == 'all'
                      ? 'No listings available'
                      : 'No listings in "${_activeFilter.label}"',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => setState(() {
                _activeFilter = _kAllFilter;
                _searchQuery = '';
                _searchController.clear();
              }),
              child: const Text('Show all listings'),
            ),
          ]),
        ),
      );
    }

    return Expanded(
      child: RefreshIndicator(
        onRefresh: _fetchAllListings,
        child: GridView.builder(
          padding: const EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            // Fixed height: image 160 + title/price area 54 = 214px total, no extra space
            mainAxisExtent: 214,
          ),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final data            = filtered[index];
            final String imageUrl = data['imageUrl'] ?? '';
            final bool isVehicle  = data['isVehicle'] == true;
            final bool isHome     = data['isHome'] == true;
            final int stock       = data['stock'] ?? 1;

            Color badgeColor = isVehicle
                ? const Color(0xFF27AE60).withValues(alpha: 0.85)
                : isHome
                    ? (data['intent'] == 'Rent' ? const Color(0xFF5C6BC0) : const Color(0xFFE67E22)).withValues(alpha: 0.85)
                    : Colors.black.withValues(alpha: 0.6);

            IconData badgeIcon = isVehicle
                ? Icons.directions_car_outlined
                : isHome
                    ? (data['intent'] == 'Rent' ? Icons.key_outlined : Icons.home_outlined)
                    : Icons.inventory_2_outlined;

            String badgeLabel = isVehicle
                ? (data['vehicleType'] ?? 'Vehicle')
                : isHome ? (data['intent'] ?? 'Home') : '$stock';

            Color priceColor = isVehicle
                ? const Color(0xFF27AE60)
                : isHome
                    ? (data['intent'] == 'Rent' ? const Color(0xFF5C6BC0) : const Color(0xFFE67E22))
                    : Colors.blueAccent;

            return GestureDetector(
              onTap: () => _openDetail(data),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // ── CHANGE 3 cont: mainAxisSize.min so no extra vertical stretch ──
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 160,
                      child: Stack(fit: StackFit.expand, children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Container(
                            color: Colors.grey[100],
                            child: imageUrl.isNotEmpty
                                ? Image.network(
                                    imageUrl,
                                    fit: BoxFit.contain,
                                    width: double.infinity,
                                    height: double.infinity,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      );
                                    },
                                    errorBuilder: (_, __, ___) => Container(
                                      color: Colors.grey[200],
                                      child: Icon(
                                        isVehicle
                                            ? Icons.directions_car_outlined
                                            : isHome
                                                ? Icons.home_outlined
                                                : Icons.image,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: Colors.grey[200],
                                    child: Icon(
                                      isVehicle
                                          ? Icons.directions_car_outlined
                                          : isHome
                                              ? Icons.home_outlined
                                              : Icons.image,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: badgeColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(badgeIcon, size: 10, color: Colors.white),
                              const SizedBox(width: 3),
                              Text(
                                badgeLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ]),
                          ),
                        ),
                      ]),
                    ),
                    // ── Title + price row — tight padding, no extra space ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            data['title'] ?? 'Untitled',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isHome && data['intent'] == 'Rent'
                                ? '\$${data['price']}/mo'
                                : '\$${data['price']}',
                            style: TextStyle(
                              color: priceColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _topButton(IconData icon, String label, Color color, VoidCallback action) {
    return ElevatedButton.icon(
      onPressed: action,
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        overflow: TextOverflow.ellipsis,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      ),
    );
  }
}

// ─── CATEGORY FILTER BOTTOM SHEET ────────────────────────────────────────────

class _CategoryFilterSheet extends StatefulWidget {
  final _FilterCategory activeFilter;
  final void Function(_FilterCategory) onSelected;
  const _CategoryFilterSheet({required this.activeFilter, required this.onSelected});

  @override
  State<_CategoryFilterSheet> createState() => _CategoryFilterSheetState();
}

class _CategoryFilterSheetState extends State<_CategoryFilterSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    int initialTab = 0;
    if (widget.activeFilter.section == 'item')    initialTab = 1;
    if (widget.activeFilter.section == 'vehicle') initialTab = 2;
    if (widget.activeFilter.section == 'home')    initialTab = 3;
    _tabController = TabController(length: 4, vsync: this, initialIndex: initialTab);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<_FilterCategory> _searchAllFilters(String query) {
    final q = query.toLowerCase();
    final all = [..._itemFilters, ..._vehicleFilters, ..._homeFilters];
    return all.where((f) => f.label.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      expand: false,
      builder: (ctx, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(children: [
                const Text('Filter by Category',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
                const Spacer(),
                if (widget.activeFilter.id != 'all')
                  TextButton(
                    onPressed: () => widget.onSelected(_kAllFilter),
                    child: const Text('Clear', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                  ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v.trim()),
                decoration: InputDecoration(
                  hintText: 'Search categories...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          })
                      : null,
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(height: 4),
            if (_searchQuery.isEmpty) ...[
              TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF4A90E2),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF4A90E2),
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(icon: Icon(Icons.apps_outlined, size: 18), text: 'All'),
                  Tab(icon: Icon(Icons.shopping_bag_outlined, size: 18), text: 'Items'),
                  Tab(icon: Icon(Icons.directions_car_outlined, size: 18), text: 'Vehicles'),
                  Tab(icon: Icon(Icons.home_outlined, size: 18), text: 'Homes'),
                ],
              ),
              const Divider(height: 1),
            ],
            Expanded(
              child: _searchQuery.isNotEmpty
                  ? _buildSearchResults(scrollController)
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildAllTab(scrollController),
                        _buildGroupedList(_itemGroups, scrollController),
                        _buildGroupedList(_vehicleGroups, scrollController),
                        _buildGroupedList(_homeGroups, scrollController),
                      ],
                    ),
            ),
          ]),
        );
      },
    );
  }

  Widget _buildSearchResults(ScrollController controller) {
    final results = _searchAllFilters(_searchQuery);
    if (results.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text('No categories found for "$_searchQuery"',
              style: TextStyle(color: Colors.grey[500], fontSize: 14)),
        ]),
      );
    }
    return GridView.builder(
      controller: controller,
      padding: const EdgeInsets.all(14),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.88),
      itemCount: results.length,
      itemBuilder: (context, index) => _buildFilterTile(results[index]),
    );
  }

  Widget _buildAllTab(ScrollController controller) {
    return SingleChildScrollView(
      controller: controller,
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: () => widget.onSelected(_kAllFilter),
          child: _bigTile(_kAllFilter),
        ),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 12),
        const Text('Browse by type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: GestureDetector(
            onTap: () => widget.onSelected(_vehicleFilters.first),
            child: _bigTile(_vehicleFilters.first),
          )),
          const SizedBox(width: 12),
          Expanded(child: GestureDetector(
            onTap: () => widget.onSelected(_homeFilters[0]),
            child: _bigTile(_homeFilters[0]),
          )),
          const SizedBox(width: 12),
          Expanded(child: GestureDetector(
            onTap: () => widget.onSelected(_homeFilters[1]),
            child: _bigTile(_homeFilters[1]),
          )),
        ]),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 12),
        const Text('Popular categories', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.88),
          itemCount: _itemGroups.length,
          itemBuilder: (context, index) {
            final group = _itemGroups[index];
            final rep = group.items.first;
            return _buildFilterTile(rep);
          },
        ),
      ]),
    );
  }

  Widget _buildGroupedList(List<_CategoryGroup> groups, ScrollController controller) {
    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        return _GroupSection(
          group: groups[index],
          activeFilter: widget.activeFilter,
          onSelected: widget.onSelected,
        );
      },
    );
  }

  Widget _bigTile(_FilterCategory filter) {
    final bool isSelected = widget.activeFilter.id == filter.id;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isSelected ? filter.color.withValues(alpha: 0.12) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isSelected ? filter.color : Colors.grey.shade200, width: isSelected ? 2 : 1),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(filter.icon, color: filter.color, size: 30),
        const SizedBox(height: 8),
        Text(filter.label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                color: isSelected ? filter.color : const Color(0xFF2C3E50))),
      ]),
    );
  }

  Widget _buildFilterTile(_FilterCategory filter) {
    final isSelected = widget.activeFilter.id == filter.id;
    return GestureDetector(
      onTap: () => widget.onSelected(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: isSelected ? filter.color.withValues(alpha: 0.11) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? filter.color : Colors.grey.shade200, width: isSelected ? 1.5 : 1),
          boxShadow: isSelected
              ? [BoxShadow(color: filter.color.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 3))]
              : [],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: isSelected ? filter.color.withValues(alpha: 0.18) : filter.color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(filter.icon, color: filter.color, size: 22),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(filter.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? filter.color : const Color(0xFF2C3E50),
                ),
                maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
        ]),
      ),
    );
  }
}

// ─── GROUP SECTION WIDGET ─────────────────────────────────────────────────────

class _GroupSection extends StatefulWidget {
  final _CategoryGroup group;
  final _FilterCategory activeFilter;
  final void Function(_FilterCategory) onSelected;

  const _GroupSection({
    required this.group,
    required this.activeFilter,
    required this.onSelected,
  });

  @override
  State<_GroupSection> createState() => _GroupSectionState();
}

class _GroupSectionState extends State<_GroupSection> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.group.items.any((f) => f.id == widget.activeFilter.id);
    if (!_expanded && widget.group.items.isNotEmpty) {
      _expanded = widget.group.items.first.id == widget.activeFilter.id;
    }
  }

  bool get _hasActiveChild =>
      widget.group.items.any((f) => f.id == widget.activeFilter.id);

  @override
  Widget build(BuildContext context) {
    final color = widget.group.color;
    final bool isSingleItem = widget.group.items.length == 1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: _hasActiveChild ? color.withValues(alpha: 0.04) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _hasActiveChild ? color.withValues(alpha: 0.35) : Colors.grey.shade200,
          width: _hasActiveChild ? 1.5 : 1,
        ),
      ),
      child: Column(children: [
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            if (isSingleItem) {
              widget.onSelected(widget.group.items.first);
            } else {
              setState(() => _expanded = !_expanded);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.group.icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(widget.group.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _hasActiveChild ? color : const Color(0xFF2C3E50),
                    )),
              ),
              if (isSingleItem)
                Icon(Icons.arrow_forward_ios, size: 14, color: _hasActiveChild ? color : Colors.grey)
              else ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${widget.group.items.length}',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.keyboard_arrow_down,
                      color: _expanded ? color : Colors.grey, size: 20),
                ),
              ],
            ]),
          ),
        ),
        if (!isSingleItem)
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.9),
                itemCount: widget.group.items.length,
                itemBuilder: (context, index) {
                  final filter = widget.group.items[index];
                  final isSelected = widget.activeFilter.id == filter.id;
                  return GestureDetector(
                    onTap: () => widget.onSelected(filter),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      decoration: BoxDecoration(
                        color: isSelected ? filter.color.withValues(alpha: 0.11) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? filter.color : Colors.grey.shade200,
                          width: isSelected ? 1.5 : 1,
                        ),
                        boxShadow: isSelected
                            ? [BoxShadow(color: filter.color.withValues(alpha: 0.15), blurRadius: 6, offset: const Offset(0, 2))]
                            : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 1))],
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(
                            color: isSelected ? filter.color.withValues(alpha: 0.18) : filter.color.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(filter.icon, color: filter.color, size: 20),
                        ),
                        const SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Text(filter.label,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? filter.color : const Color(0xFF2C3E50),
                              ),
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                        ),
                      ]),
                    ),
                  );
                },
              ),
            ),
            crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
      ]),
    );
  }
}*/
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'add_item.dart';
import 'product_detail_page.dart';
import 'vehicle_detailed_page.dart';
import 'home_detailed_page.dart';
import 'seller_profile_page.dart';
import 'chat_inbox_page.dart';
import 'seller_session.dart';
import 'my_listings_page.dart'; // ← NEW
//import 'dart:math';

const String projectId = 'marketplaneproducts';
const String firestoreUrl =
    'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents';

// ─── FILTER MODELS ────────────────────────────────────────────────────────────

class _FilterCategory {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final String section; // 'all' | 'item' | 'vehicle' | 'home'

  const _FilterCategory({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.section,
  });
}

const _FilterCategory _kAllFilter = _FilterCategory(
  id: 'all', label: 'All', icon: Icons.apps_outlined,
  color: Color(0xFF4A90E2), section: 'all',
);

// ── Item categories ────────────────────────────────────────────────────────────
const List<_FilterCategory> _itemFilters = [
  _FilterCategory(id: 'electronics',        label: 'Electronics',            icon: Icons.devices_outlined,             color: Color(0xFF4A90E2), section: 'item'),
  _FilterCategory(id: 'phones_tablets',     label: 'Phones & Tablets',       icon: Icons.smartphone_outlined,          color: Color(0xFF1E88E5), section: 'item'),
  _FilterCategory(id: 'computers',          label: 'Computers & Laptops',    icon: Icons.laptop_outlined,              color: Color(0xFF1976D2), section: 'item'),
  _FilterCategory(id: 'cameras',            label: 'Cameras',                icon: Icons.camera_alt_outlined,          color: Color(0xFF1565C0), section: 'item'),
  _FilterCategory(id: 'audio',              label: 'Audio & Headphones',     icon: Icons.headphones_outlined,          color: Color(0xFF0D47A1), section: 'item'),
  _FilterCategory(id: 'gaming',             label: 'Gaming & Consoles',      icon: Icons.sports_esports_outlined,      color: Color(0xFF5E35B1), section: 'item'),
  _FilterCategory(id: 'tv_video',           label: 'TVs & Video',            icon: Icons.tv_outlined,                  color: Color(0xFF283593), section: 'item'),
  _FilterCategory(id: 'wearables',          label: 'Wearables',              icon: Icons.watch_outlined,               color: Color(0xFF3949AB), section: 'item'),
  _FilterCategory(id: 'networking',         label: 'Networking & WiFi',      icon: Icons.router_outlined,              color: Color(0xFF1A237E), section: 'item'),
  _FilterCategory(id: 'cables_accessories', label: 'Cables & Accessories',   icon: Icons.usb_outlined,                 color: Color(0xFF4527A0), section: 'item'),
  _FilterCategory(id: 'clothing',           label: 'Clothing & Fashion',     icon: Icons.checkroom_outlined,           color: Color(0xFFE91E8C), section: 'item'),
  _FilterCategory(id: 'mens_clothing',      label: "Men's Clothing",         icon: Icons.person_outlined,              color: Color(0xFFD81B60), section: 'item'),
  _FilterCategory(id: 'womens_clothing',    label: "Women's Clothing",       icon: Icons.people_outlined,              color: Color(0xFFC2185B), section: 'item'),
  _FilterCategory(id: 'kids_clothing',      label: "Kids' Clothing",         icon: Icons.child_care_outlined,          color: Color(0xFFAD1457), section: 'item'),
  _FilterCategory(id: 'shoes',              label: 'Shoes & Footwear',       icon: Icons.directions_walk_outlined,     color: Color(0xFF880E4F), section: 'item'),
  _FilterCategory(id: 'bags',               label: 'Bags & Luggage',         icon: Icons.luggage_outlined,             color: Color(0xFFF06292), section: 'item'),
  _FilterCategory(id: 'jewelry',            label: 'Jewelry & Watches',      icon: Icons.diamond_outlined,             color: Color(0xFFE91E63), section: 'item'),
  _FilterCategory(id: 'sportswear',         label: 'Sportswear',             icon: Icons.directions_run_outlined,      color: Color(0xFFEC407A), section: 'item'),
  _FilterCategory(id: 'hats_scarves',       label: 'Hats, Scarves & Gloves', icon: Icons.accessibility_outlined,       color: Color(0xFFF48FB1), section: 'item'),
  _FilterCategory(id: 'furniture',          label: 'Furniture & Home',       icon: Icons.chair_outlined,               color: Color(0xFF8D6E63), section: 'item'),
  _FilterCategory(id: 'living_room',        label: 'Living Room',            icon: Icons.weekend_outlined,             color: Color(0xFF6D4C41), section: 'item'),
  _FilterCategory(id: 'bedroom',            label: 'Bedroom',                icon: Icons.bed_outlined,                 color: Color(0xFF5D4037), section: 'item'),
  _FilterCategory(id: 'office_furniture',   label: 'Office Furniture',       icon: Icons.desk_outlined,                color: Color(0xFF4E342E), section: 'item'),
  _FilterCategory(id: 'outdoor_furniture',  label: 'Outdoor & Garden',       icon: Icons.outdoor_grill_outlined,       color: Color(0xFF3E2723), section: 'item'),
  _FilterCategory(id: 'lighting',           label: 'Lighting',               icon: Icons.light_outlined,               color: Color(0xFFA1887F), section: 'item'),
  _FilterCategory(id: 'home_decor',         label: 'Home Decor',             icon: Icons.format_paint_outlined,        color: Color(0xFFBCAAA4), section: 'item'),
  _FilterCategory(id: 'storage',            label: 'Storage & Organization', icon: Icons.inventory_2_outlined,         color: Color(0xFF795548), section: 'item'),
  _FilterCategory(id: 'books',              label: 'Books & Media',          icon: Icons.menu_book_outlined,           color: Color(0xFF26A69A), section: 'item'),
  _FilterCategory(id: 'fiction',            label: 'Fiction',                icon: Icons.book_outlined,                color: Color(0xFF00897B), section: 'item'),
  _FilterCategory(id: 'non_fiction',        label: 'Non-Fiction',            icon: Icons.library_books_outlined,       color: Color(0xFF00796B), section: 'item'),
  _FilterCategory(id: 'textbooks',          label: 'Textbooks & Education',  icon: Icons.school_outlined,              color: Color(0xFF00695C), section: 'item'),
  _FilterCategory(id: 'sports',             label: 'Sports & Outdoors',      icon: Icons.sports_soccer_outlined,       color: Color(0xFF27AE60), section: 'item'),
  _FilterCategory(id: 'fitness',            label: 'Gym & Fitness',          icon: Icons.fitness_center_outlined,      color: Color(0xFF2E7D32), section: 'item'),
  _FilterCategory(id: 'cycling',            label: 'Cycling',                icon: Icons.directions_bike_outlined,     color: Color(0xFF388E3C), section: 'item'),
  _FilterCategory(id: 'camping_hiking',     label: 'Camping & Hiking',       icon: Icons.terrain_outlined,             color: Color(0xFF43A047), section: 'item'),
  _FilterCategory(id: 'toys',               label: 'Toys & Games',           icon: Icons.toys_outlined,                color: Color(0xFFFF7043), section: 'item'),
  _FilterCategory(id: 'board_games',        label: 'Board Games & Puzzles',  icon: Icons.extension_outlined,           color: Color(0xFFE64A19), section: 'item'),
  _FilterCategory(id: 'video_games',        label: 'Video Games',            icon: Icons.videogame_asset_outlined,     color: Color(0xFFDD2C00), section: 'item'),
  _FilterCategory(id: 'beauty',             label: 'Beauty & Health',        icon: Icons.spa_outlined,                 color: Color(0xFFAB47BC), section: 'item'),
  _FilterCategory(id: 'skincare',           label: 'Skincare',               icon: Icons.face_outlined,                color: Color(0xFF8E24AA), section: 'item'),
  _FilterCategory(id: 'makeup',             label: 'Makeup & Cosmetics',     icon: Icons.brush_outlined,               color: Color(0xFF7B1FA2), section: 'item'),
  _FilterCategory(id: 'kitchen',            label: 'Kitchen & Dining',       icon: Icons.kitchen_outlined,             color: Color(0xFFE67E22), section: 'item'),
  _FilterCategory(id: 'cookware',           label: 'Cookware & Bakeware',    icon: Icons.soup_kitchen_outlined,        color: Color(0xFFD35400), section: 'item'),
  _FilterCategory(id: 'small_appliances',   label: 'Small Appliances',       icon: Icons.microwave_outlined,           color: Color(0xFFBA4A00), section: 'item'),
  _FilterCategory(id: 'tools',              label: 'Tools & DIY',            icon: Icons.handyman_outlined,            color: Color(0xFF546E7A), section: 'item'),
  _FilterCategory(id: 'power_tools',        label: 'Power Tools',            icon: Icons.construction_outlined,        color: Color(0xFF455A64), section: 'item'),
  _FilterCategory(id: 'hand_tools',         label: 'Hand Tools',             icon: Icons.hardware_outlined,            color: Color(0xFF37474F), section: 'item'),
  _FilterCategory(id: 'baby',               label: 'Baby & Kids',            icon: Icons.child_care_outlined,          color: Color(0xFFEC407A), section: 'item'),
  _FilterCategory(id: 'baby_gear',          label: 'Strollers & Car Seats',  icon: Icons.accessible_outlined,          color: Color(0xFFC2185B), section: 'item'),
  _FilterCategory(id: 'music_instruments',  label: 'Music & Instruments',    icon: Icons.music_note_outlined,          color: Color(0xFF5C6BC0), section: 'item'),
  _FilterCategory(id: 'guitars',            label: 'Guitars & Bass',         icon: Icons.music_note_outlined,          color: Color(0xFF3949AB), section: 'item'),
  _FilterCategory(id: 'art',                label: 'Art & Collectibles',     icon: Icons.palette_outlined,             color: Color(0xFFD4AC0D), section: 'item'),
  _FilterCategory(id: 'paintings_prints',   label: 'Paintings & Prints',     icon: Icons.image_outlined,               color: Color(0xFFB7950B), section: 'item'),
  _FilterCategory(id: 'pets',               label: 'Pet Supplies',           icon: Icons.pets_outlined,                color: Color(0xFF795548), section: 'item'),
  _FilterCategory(id: 'dog_supplies',       label: 'Dog Supplies',           icon: Icons.pets_outlined,                color: Color(0xFF6D4C41), section: 'item'),
  _FilterCategory(id: 'other',              label: 'Other',                  icon: Icons.category_outlined,            color: Color(0xFF90A4AE), section: 'item'),
  _FilterCategory(id: 'office_supplies',    label: 'Office Supplies',        icon: Icons.business_center_outlined,     color: Color(0xFF78909C), section: 'item'),
  _FilterCategory(id: 'services',           label: 'Services & Rentals',     icon: Icons.miscellaneous_services_outlined, color: Color(0xFFB0BEC5), section: 'item'),
];

// ── Vehicle categories ─────────────────────────────────────────────────────────
const List<_FilterCategory> _vehicleFilters = [
  _FilterCategory(id: 'v_all',           label: 'All Vehicles',       icon: Icons.commute_outlined,             color: Color(0xFF27AE60), section: 'vehicle'),
  _FilterCategory(id: 'cars',            label: 'Cars',               icon: Icons.directions_car_outlined,      color: Color(0xFF4A90E2), section: 'vehicle'),
  _FilterCategory(id: 'sedan',           label: 'Sedan',              icon: Icons.directions_car_outlined,      color: Color(0xFF1E88E5), section: 'vehicle'),
  _FilterCategory(id: 'suv',             label: 'SUV / Crossover',    icon: Icons.directions_car_outlined,      color: Color(0xFF1976D2), section: 'vehicle'),
  _FilterCategory(id: 'coupe',           label: 'Coupe',              icon: Icons.directions_car_outlined,      color: Color(0xFF1565C0), section: 'vehicle'),
  _FilterCategory(id: 'hatchback',       label: 'Hatchback',          icon: Icons.directions_car_outlined,      color: Color(0xFF0D47A1), section: 'vehicle'),
  _FilterCategory(id: 'convertible',     label: 'Convertible',        icon: Icons.directions_car_outlined,      color: Color(0xFF283593), section: 'vehicle'),
  _FilterCategory(id: 'wagon',           label: 'Station Wagon',      icon: Icons.directions_car_outlined,      color: Color(0xFF3949AB), section: 'vehicle'),
  _FilterCategory(id: 'minivan',         label: 'Minivan',            icon: Icons.airport_shuttle_outlined,     color: Color(0xFF5C6BC0), section: 'vehicle'),
  _FilterCategory(id: 'pickup_car',      label: 'Pickup Truck',       icon: Icons.local_shipping_outlined,      color: Color(0xFF7986CB), section: 'vehicle'),
  _FilterCategory(id: 'electric_car',    label: 'Electric / Hybrid',  icon: Icons.electric_car_outlined,        color: Color(0xFF4527A0), section: 'vehicle'),
  _FilterCategory(id: 'luxury_car',      label: 'Luxury & Sports',    icon: Icons.directions_car_outlined,      color: Color(0xFF1A237E), section: 'vehicle'),
  _FilterCategory(id: 'motorcycles',     label: 'Motorcycles',        icon: Icons.two_wheeler_outlined,         color: Color(0xFFE67E22), section: 'vehicle'),
  _FilterCategory(id: 'sport_bike',      label: 'Sport Bike',         icon: Icons.two_wheeler_outlined,         color: Color(0xFFD35400), section: 'vehicle'),
  _FilterCategory(id: 'cruiser',         label: 'Cruiser',            icon: Icons.two_wheeler_outlined,         color: Color(0xFFBA4A00), section: 'vehicle'),
  _FilterCategory(id: 'scooter',         label: 'Scooter / Moped',    icon: Icons.two_wheeler_outlined,         color: Color(0xFFA04000), section: 'vehicle'),
  _FilterCategory(id: 'dirt_bike',       label: 'Dirt Bike',          icon: Icons.two_wheeler_outlined,         color: Color(0xFF873600), section: 'vehicle'),
  _FilterCategory(id: 'adventure',       label: 'Adventure / Touring',icon: Icons.two_wheeler_outlined,         color: Color(0xFFEB984E), section: 'vehicle'),
  _FilterCategory(id: 'electric_moto',   label: 'Electric Moto',      icon: Icons.electric_moped_outlined,      color: Color(0xFFCA6F1E), section: 'vehicle'),
  _FilterCategory(id: 'atv',             label: 'ATV / Quad',         icon: Icons.two_wheeler_outlined,         color: Color(0xFFF0A500), section: 'vehicle'),
  _FilterCategory(id: 'trucks',          label: 'Trucks',             icon: Icons.local_shipping_outlined,      color: Color(0xFF27AE60), section: 'vehicle'),
  _FilterCategory(id: 'light_pickup',    label: 'Light Pickup',       icon: Icons.local_shipping_outlined,      color: Color(0xFF2E7D32), section: 'vehicle'),
  _FilterCategory(id: 'heavy_truck',     label: 'Heavy Truck',        icon: Icons.local_shipping_outlined,      color: Color(0xFF388E3C), section: 'vehicle'),
  _FilterCategory(id: 'semi_truck',      label: 'Semi / 18-Wheeler',  icon: Icons.local_shipping_outlined,      color: Color(0xFF43A047), section: 'vehicle'),
  _FilterCategory(id: 'van_cargo',       label: 'Cargo Van',          icon: Icons.airport_shuttle_outlined,     color: Color(0xFF81C784), section: 'vehicle'),
  _FilterCategory(id: 'boats',           label: 'Boats & Watercraft', icon: Icons.directions_boat_outlined,     color: Color(0xFF1ABC9C), section: 'vehicle'),
  _FilterCategory(id: 'speedboat',       label: 'Speedboat',          icon: Icons.directions_boat_outlined,     color: Color(0xFF17A589), section: 'vehicle'),
  _FilterCategory(id: 'sailboat',        label: 'Sailboat',           icon: Icons.directions_boat_outlined,     color: Color(0xFF148F77), section: 'vehicle'),
  _FilterCategory(id: 'yacht',           label: 'Yacht',              icon: Icons.directions_boat_outlined,     color: Color(0xFF117A65), section: 'vehicle'),
  _FilterCategory(id: 'jet_ski',         label: 'Jet Ski / PWC',      icon: Icons.pool_outlined,                color: Color(0xFF0E6655), section: 'vehicle'),
  _FilterCategory(id: 'fishing_boat',    label: 'Fishing Boat',       icon: Icons.directions_boat_outlined,     color: Color(0xFF76D7C4), section: 'vehicle'),
  _FilterCategory(id: 'buses',           label: 'Buses & Vans',       icon: Icons.directions_bus_outlined,      color: Color(0xFF9B59B6), section: 'vehicle'),
  _FilterCategory(id: 'minibus',         label: 'Minibus',            icon: Icons.directions_bus_outlined,      color: Color(0xFF8E44AD), section: 'vehicle'),
  _FilterCategory(id: 'coach_bus',       label: 'Coach / Full Bus',   icon: Icons.directions_bus_outlined,      color: Color(0xFF7D3C98), section: 'vehicle'),
  _FilterCategory(id: 'passenger_van',   label: 'Passenger Van',      icon: Icons.airport_shuttle_outlined,     color: Color(0xFFBB8FCE), section: 'vehicle'),
  _FilterCategory(id: 'camper_van',      label: 'Camper / RV',        icon: Icons.airport_shuttle_outlined,     color: Color(0xFFA569BD), section: 'vehicle'),
  _FilterCategory(id: 'equipment',       label: 'Heavy Equipment',    icon: Icons.construction_outlined,        color: Color(0xFFE74C3C), section: 'vehicle'),
  _FilterCategory(id: 'excavator',       label: 'Excavator',          icon: Icons.construction_outlined,        color: Color(0xFFC0392B), section: 'vehicle'),
  _FilterCategory(id: 'bulldozer',       label: 'Bulldozer',          icon: Icons.construction_outlined,        color: Color(0xFFAB2323), section: 'vehicle'),
  _FilterCategory(id: 'forklift',        label: 'Forklift',           icon: Icons.construction_outlined,        color: Color(0xFF922B21), section: 'vehicle'),
  _FilterCategory(id: 'tractor',         label: 'Tractor / Farm',     icon: Icons.agriculture_outlined,         color: Color(0xFFEC7063), section: 'vehicle'),
  _FilterCategory(id: 'bicycles',        label: 'Bicycles & Micro',   icon: Icons.directions_bike_outlined,     color: Color(0xFF16A085), section: 'vehicle'),
  _FilterCategory(id: 'road_bike',       label: 'Road Bike',          icon: Icons.directions_bike_outlined,     color: Color(0xFF138D75), section: 'vehicle'),
  _FilterCategory(id: 'mountain_bike',   label: 'Mountain Bike',      icon: Icons.directions_bike_outlined,     color: Color(0xFF117A65), section: 'vehicle'),
  _FilterCategory(id: 'ebike',           label: 'Electric Bike',      icon: Icons.electric_bike_outlined,       color: Color(0xFF0E6655), section: 'vehicle'),
  _FilterCategory(id: 'electric_scooter',label: 'Electric Scooter',   icon: Icons.electric_scooter_outlined,    color: Color(0xFF76D7C4), section: 'vehicle'),
  _FilterCategory(id: 'kids_bike',       label: 'Kids Bicycle',       icon: Icons.directions_bike_outlined,     color: Color(0xFF48C9B0), section: 'vehicle'),
  _FilterCategory(id: 'other_vehicle',   label: 'Other Vehicle',      icon: Icons.commute_outlined,             color: Color(0xFF90A4AE), section: 'vehicle'),
  _FilterCategory(id: 'trailer',         label: 'Trailer',            icon: Icons.rv_hookup_outlined,           color: Color(0xFF78909C), section: 'vehicle'),
  _FilterCategory(id: 'golf_cart',       label: 'Golf Cart',          icon: Icons.electric_car_outlined,        color: Color(0xFF546E7A), section: 'vehicle'),
  _FilterCategory(id: 'other_misc',      label: 'Other Vehicle',      icon: Icons.commute_outlined,             color: Color(0xFFB0BEC5), section: 'vehicle'),
];

// ── Home / property categories ─────────────────────────────────────────────────
const List<_FilterCategory> _homeFilters = [
  _FilterCategory(id: 'h_all_sell',      label: 'All For Sale',       icon: Icons.sell_outlined,                color: Color(0xFFE67E22), section: 'home'),
  _FilterCategory(id: 'h_all_rent',      label: 'All For Rent',       icon: Icons.key_outlined,                 color: Color(0xFF5C6BC0), section: 'home'),
  _FilterCategory(id: 'residential',     label: 'Residential',        icon: Icons.home_outlined,                color: Color(0xFFE67E22), section: 'home'),
  _FilterCategory(id: 'apartment',       label: 'Apartment',          icon: Icons.apartment_outlined,           color: Color(0xFFD35400), section: 'home'),
  _FilterCategory(id: 'house',           label: 'House',              icon: Icons.house_outlined,               color: Color(0xFFBA4A00), section: 'home'),
  _FilterCategory(id: 'villa',           label: 'Villa',              icon: Icons.villa_outlined,               color: Color(0xFFA04000), section: 'home'),
  _FilterCategory(id: 'studio',          label: 'Studio',             icon: Icons.meeting_room_outlined,        color: Color(0xFF873600), section: 'home'),
  _FilterCategory(id: 'duplex',          label: 'Duplex / Triplex',   icon: Icons.layers_outlined,              color: Color(0xFFEB984E), section: 'home'),
  _FilterCategory(id: 'penthouse',       label: 'Penthouse',          icon: Icons.roofing_outlined,             color: Color(0xFFCA6F1E), section: 'home'),
  _FilterCategory(id: 'townhouse',       label: 'Townhouse',          icon: Icons.holiday_village_outlined,     color: Color(0xFFF0A500), section: 'home'),
  _FilterCategory(id: 'chalet',          label: 'Chalet / Cabin',     icon: Icons.cabin_outlined,               color: Color(0xFFE59866), section: 'home'),
  _FilterCategory(id: 'room_shared',     label: 'Room / Shared',      icon: Icons.bed_outlined,                 color: Color(0xFFF5CBA7), section: 'home'),
  _FilterCategory(id: 'commercial',      label: 'Commercial',         icon: Icons.business_outlined,            color: Color(0xFF5C6BC0), section: 'home'),
  _FilterCategory(id: 'office',          label: 'Office',             icon: Icons.business_center_outlined,     color: Color(0xFF3949AB), section: 'home'),
  _FilterCategory(id: 'shop',            label: 'Shop / Retail',      icon: Icons.storefront_outlined,          color: Color(0xFF303F9F), section: 'home'),
  _FilterCategory(id: 'showroom',        label: 'Showroom',           icon: Icons.store_outlined,               color: Color(0xFF283593), section: 'home'),
  _FilterCategory(id: 'restaurant_space',label: 'Restaurant Space',   icon: Icons.restaurant_outlined,          color: Color(0xFF1A237E), section: 'home'),
  _FilterCategory(id: 'coworking',       label: 'Co-working Space',   icon: Icons.people_outlined,              color: Color(0xFF7986CB), section: 'home'),
  _FilterCategory(id: 'industrial',      label: 'Industrial',         icon: Icons.factory_outlined,             color: Color(0xFF546E7A), section: 'home'),
  _FilterCategory(id: 'warehouse',       label: 'Warehouse',          icon: Icons.warehouse_outlined,           color: Color(0xFF455A64), section: 'home'),
  _FilterCategory(id: 'factory',         label: 'Factory / Workshop', icon: Icons.precision_manufacturing_outlined, color: Color(0xFF37474F), section: 'home'),
  _FilterCategory(id: 'storage_unit',    label: 'Storage Unit',       icon: Icons.inventory_2_outlined,         color: Color(0xFF263238), section: 'home'),
  _FilterCategory(id: 'garage_space',    label: 'Garage / Parking',   icon: Icons.garage_outlined,              color: Color(0xFF607D8B), section: 'home'),
  _FilterCategory(id: 'land',            label: 'Land & Plots',       icon: Icons.landscape_outlined,           color: Color(0xFF27AE60), section: 'home'),
  _FilterCategory(id: 'residential_land',label: 'Residential Plot',   icon: Icons.crop_square_outlined,         color: Color(0xFF2E7D32), section: 'home'),
  _FilterCategory(id: 'commercial_land', label: 'Commercial Plot',    icon: Icons.business_outlined,            color: Color(0xFF388E3C), section: 'home'),
  _FilterCategory(id: 'farm_land',       label: 'Farm / Agricultural',icon: Icons.agriculture_outlined,         color: Color(0xFF43A047), section: 'home'),
  _FilterCategory(id: 'coastal_land',    label: 'Coastal / Waterfront',icon: Icons.water_outlined,              color: Color(0xFF66BB6A), section: 'home'),
  _FilterCategory(id: 'hospitality',     label: 'Hospitality',        icon: Icons.hotel_outlined,               color: Color(0xFF1ABC9C), section: 'home'),
  _FilterCategory(id: 'hotel',           label: 'Hotel / Motel',      icon: Icons.hotel_outlined,               color: Color(0xFF17A589), section: 'home'),
  _FilterCategory(id: 'resort',          label: 'Resort',             icon: Icons.beach_access_outlined,        color: Color(0xFF148F77), section: 'home'),
  _FilterCategory(id: 'guesthouse',      label: 'Guesthouse / B&B',   icon: Icons.house_outlined,               color: Color(0xFF117A65), section: 'home'),
  _FilterCategory(id: 'holiday_home',    label: 'Holiday Home',       icon: Icons.home_work_outlined,           color: Color(0xFF76D7C4), section: 'home'),
  _FilterCategory(id: 'other_property',  label: 'Other Property',     icon: Icons.category_outlined,            color: Color(0xFF90A4AE), section: 'home'),
  _FilterCategory(id: 'mixed_use',       label: 'Mixed Use',          icon: Icons.domain_outlined,              color: Color(0xFF78909C), section: 'home'),
  _FilterCategory(id: 'parking_lot',     label: 'Parking Lot',        icon: Icons.local_parking_outlined,       color: Color(0xFF607D8B), section: 'home'),
  _FilterCategory(id: 'other_prop_misc', label: 'Other Property',     icon: Icons.more_horiz_outlined,          color: Color(0xFFB0BEC5), section: 'home'),
];

// ─── GROUP MODELS ─────────────────────────────────────────────────────────────

class _CategoryGroup {
  final String label;
  final IconData icon;
  final Color color;
  final List<_FilterCategory> items;

  const _CategoryGroup({
    required this.label,
    required this.icon,
    required this.color,
    required this.items,
  });
}

// Item groups
final List<_CategoryGroup> _itemGroups = [
  _CategoryGroup(label: 'Electronics', icon: Icons.devices_outlined, color: const Color(0xFF4A90E2),
    items: _itemFilters.where((f) => ['electronics','phones_tablets','computers','cameras','audio','gaming','tv_video','wearables','networking','cables_accessories'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Clothing & Fashion', icon: Icons.checkroom_outlined, color: const Color(0xFFE91E8C),
    items: _itemFilters.where((f) => ['clothing','mens_clothing','womens_clothing','kids_clothing','shoes','bags','jewelry','sportswear','hats_scarves'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Furniture & Home', icon: Icons.chair_outlined, color: const Color(0xFF8D6E63),
    items: _itemFilters.where((f) => ['furniture','living_room','bedroom','office_furniture','outdoor_furniture','lighting','home_decor','storage'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Books & Media', icon: Icons.menu_book_outlined, color: const Color(0xFF26A69A),
    items: _itemFilters.where((f) => ['books','fiction','non_fiction','textbooks'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Sports & Outdoors', icon: Icons.sports_soccer_outlined, color: const Color(0xFF27AE60),
    items: _itemFilters.where((f) => ['sports','fitness','cycling','camping_hiking'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Toys & Games', icon: Icons.toys_outlined, color: const Color(0xFFFF7043),
    items: _itemFilters.where((f) => ['toys','board_games','video_games'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Beauty & Health', icon: Icons.spa_outlined, color: const Color(0xFFAB47BC),
    items: _itemFilters.where((f) => ['beauty','skincare','makeup'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Kitchen & Dining', icon: Icons.kitchen_outlined, color: const Color(0xFFE67E22),
    items: _itemFilters.where((f) => ['kitchen','cookware','small_appliances'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Tools & DIY', icon: Icons.handyman_outlined, color: const Color(0xFF546E7A),
    items: _itemFilters.where((f) => ['tools','power_tools','hand_tools'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Baby & Kids', icon: Icons.child_care_outlined, color: const Color(0xFFEC407A),
    items: _itemFilters.where((f) => ['baby','baby_gear'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Music & Instruments', icon: Icons.music_note_outlined, color: const Color(0xFF5C6BC0),
    items: _itemFilters.where((f) => ['music_instruments','guitars'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Art & Collectibles', icon: Icons.palette_outlined, color: const Color(0xFFD4AC0D),
    items: _itemFilters.where((f) => ['art','paintings_prints'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Pet Supplies', icon: Icons.pets_outlined, color: const Color(0xFF795548),
    items: _itemFilters.where((f) => ['pets','dog_supplies'].contains(f.id)).toList()),
];

// Vehicle groups
final List<_CategoryGroup> _vehicleGroups = [
  _CategoryGroup(label: 'All Vehicles', icon: Icons.commute_outlined, color: const Color(0xFF27AE60),
    items: _vehicleFilters.where((f) => ['v_all'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Cars', icon: Icons.directions_car_outlined, color: const Color(0xFF4A90E2),
    items: _vehicleFilters.where((f) => ['cars','sedan','suv','coupe','hatchback','convertible','wagon','minivan','pickup_car','electric_car','luxury_car'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Motorcycles', icon: Icons.two_wheeler_outlined, color: const Color(0xFFE67E22),
    items: _vehicleFilters.where((f) => ['motorcycles','sport_bike','cruiser','scooter','dirt_bike','adventure','electric_moto','atv'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Trucks', icon: Icons.local_shipping_outlined, color: const Color(0xFF27AE60),
    items: _vehicleFilters.where((f) => ['trucks','light_pickup','heavy_truck','semi_truck','van_cargo'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Boats & Watercraft', icon: Icons.directions_boat_outlined, color: const Color(0xFF1ABC9C),
    items: _vehicleFilters.where((f) => ['boats','speedboat','sailboat','yacht','jet_ski','fishing_boat'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Buses & Vans', icon: Icons.directions_bus_outlined, color: const Color(0xFF9B59B6),
    items: _vehicleFilters.where((f) => ['buses','minibus','coach_bus','passenger_van','camper_van'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Heavy Equipment', icon: Icons.construction_outlined, color: const Color(0xFFE74C3C),
    items: _vehicleFilters.where((f) => ['equipment','excavator','bulldozer','forklift','tractor'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Bicycles & Micro', icon: Icons.directions_bike_outlined, color: const Color(0xFF16A085),
    items: _vehicleFilters.where((f) => ['bicycles','road_bike','mountain_bike','ebike','electric_scooter','kids_bike'].contains(f.id)).toList()),
];

// Home groups
final List<_CategoryGroup> _homeGroups = [
  _CategoryGroup(label: 'Quick Filter', icon: Icons.filter_list_outlined, color: const Color(0xFF4A90E2),
    items: _homeFilters.where((f) => ['h_all_sell','h_all_rent'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Residential', icon: Icons.home_outlined, color: const Color(0xFFE67E22),
    items: _homeFilters.where((f) => ['residential','apartment','house','villa','studio','duplex','penthouse','townhouse','chalet','room_shared'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Commercial', icon: Icons.business_outlined, color: const Color(0xFF5C6BC0),
    items: _homeFilters.where((f) => ['commercial','office','shop','showroom','restaurant_space','coworking'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Industrial', icon: Icons.factory_outlined, color: const Color(0xFF546E7A),
    items: _homeFilters.where((f) => ['industrial','warehouse','factory','storage_unit','garage_space'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Land & Plots', icon: Icons.landscape_outlined, color: const Color(0xFF27AE60),
    items: _homeFilters.where((f) => ['land','residential_land','commercial_land','farm_land','coastal_land'].contains(f.id)).toList()),
  _CategoryGroup(label: 'Hospitality', icon: Icons.hotel_outlined, color: const Color(0xFF1ABC9C),
    items: _homeFilters.where((f) => ['hospitality','hotel','resort','guesthouse','holiday_home'].contains(f.id)).toList()),
];

// ─── PAGE ─────────────────────────────────────────────────────────────────────

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<Map<String, dynamic>> _products = [];

  bool _loading = true;
  _FilterCategory _activeFilter = _kAllFilter;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchAllListings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<String> _resolveCurrentUserName() async {
    final sellerName = await SellerSession.getSellerName();
    if (sellerName != null && sellerName.isNotEmpty) return sellerName;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('buyer_name') ?? '';
  }

  Future<void> _fetchAllListings() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        http.get(Uri.parse('$firestoreUrl/products')),
        http.get(Uri.parse('$firestoreUrl/vehicles')),
        http.get(Uri.parse('$firestoreUrl/homes')),
      ]);
      debugPrint('=== FETCH RESULTS ===');
debugPrint('Products status: ${results[0].statusCode}');
debugPrint('Vehicles status: ${results[1].statusCode}');
debugPrint('Homes status: ${results[2].statusCode}');
      

      final List<Map<String, dynamic>> allListings = [];

      for (int i = 0; i < results.length; i++) {
        final response  = results[i];
        final isVehicle = i == 1;
        final isHome    = i == 2;

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final docs = (data['documents'] as List? ?? []);

          for (final doc in docs) {
            final fields  = doc['fields'] as Map<String, dynamic>;
            final docName = doc['name'] as String;
            final docId   = docName.split('/').last;

            final createdAtStr = fields['createdAt']?['timestampValue'] as String?;
            final createdAt = createdAtStr != null ? DateTime.tryParse(createdAtStr) : null;

            if (isHome) {
              allListings.add({
                'id':               docId,
                'isVehicle':        false,
                'isHome':           true,
                'title':            fields['title']?['stringValue'] ?? 'Untitled Property',
                'price':            fields['price']?['stringValue'] ?? '0',
                'description':      fields['description']?['stringValue'] ?? '',
                'location':         fields['location']?['stringValue'] ?? '',
                'area':             fields['area']?['stringValue'] ?? '',
                'rooms':            fields['rooms']?['stringValue'] ?? '',
                'baths':            fields['baths']?['stringValue'] ?? '',
                'floor':            fields['floor']?['stringValue'] ?? '',
                'furnished':        fields['furnished']?['booleanValue'] ?? false,
                'intent':           fields['intent']?['stringValue'] ?? '',
                'propertyCategoryId': fields['propertyCategoryId']?['stringValue'] ?? '',
                'subCategoryId':    fields['subCategoryId']?['stringValue'] ?? '',
                'subCategory':      fields['subCategory']?['stringValue'] ?? '',
                'category':         'Home',
                'imageUrl':         fields['imageUrl']?['stringValue'] ?? '',
                'stock':            1,
                'password':         fields['password']?['stringValue'] ?? '',
                'sellerName':       fields['sellerName']?['stringValue'] ?? '',
                'sellerPhone':      fields['sellerPhone']?['stringValue'] ?? '',
       'sellerEmail':  fields['sellerEmail']?['stringValue'] ?? '',
'status':       fields['status']?['stringValue'] ?? 'available',
'createdAt':    createdAt,
              });
              continue;
            }

            final stock = int.tryParse(
                    (fields['stock']?['integerValue'] ??
                            fields['stock']?['doubleValue'] ??
                            '1')
                        .toString()) ??
                1;
            
            if (isVehicle) {
              allListings.add({
                'id':                docId,
                'isVehicle':         true,
                'isHome':            false,
                'title':             fields['title']?['stringValue'] ?? 'Untitled Vehicle',
                'price':             fields['price']?['stringValue'] ?? '0',
                'description':       fields['description']?['stringValue'] ?? '',
                'condition':         fields['condition']?['stringValue'] ?? '',
                'imageUrl':          fields['imageUrl']?['stringValue'] ?? '',
                'vehicleType':       fields['vehicleType']?['stringValue'] ?? '',
                'vehicleCategoryId': fields['vehicleCategoryId']?['stringValue'] ?? '',
                'vehicleTypeId':     fields['vehicleTypeId']?['stringValue'] ?? '',
                'make':              fields['make']?['stringValue'] ?? '',
                'model':             fields['model']?['stringValue'] ?? '',
                'year':              fields['year']?['stringValue'] ?? '',
                'mileage':           fields['mileage']?['stringValue'] ?? '',
                'color':             fields['color']?['stringValue'] ?? '',
                'location':          fields['location']?['stringValue'] ?? '',
                'stock':             stock,
                'password':          fields['password']?['stringValue'] ?? '',
                'sellerName':        fields['sellerName']?['stringValue'] ?? '',
                'sellerPhone':       fields['sellerPhone']?['stringValue'] ?? '',
                'sellerEmail':       fields['sellerEmail']?['stringValue'] ?? '',
'status':            fields['status']?['stringValue'] ?? 'available',
'createdAt':         createdAt,
              });
            } else {
              allListings.add({
                'id':               docId,
                'isVehicle':        false,
                'isHome':           false,
                'title':            fields['title']?['stringValue'] ?? 'Untitled',
                'price':            fields['price']?['stringValue'] ?? '0',
                'description':      fields['description']?['stringValue'] ?? '',
                'category':         fields['category']?['stringValue'] ?? '',
                'parentCategoryId': fields['parentCategoryId']?['stringValue'] ?? '',
                'subCategoryId':    fields['subCategoryId']?['stringValue'] ?? '',
                'subCategory':      fields['subCategory']?['stringValue'] ?? '',
                'condition':        fields['condition']?['stringValue'] ?? '',
                'imageUrl':         fields['imageUrl']?['stringValue'] ?? '',
                'stock':            stock,
                'password':         fields['password']?['stringValue'] ?? '',
                'sellerName':       fields['sellerName']?['stringValue'] ?? '',
                'sellerPhone':      fields['sellerPhone']?['stringValue'] ?? '',
                'sellerEmail':  fields['sellerEmail']?['stringValue'] ?? '',
'status':       fields['status']?['stringValue'] ?? 'available',
'createdAt':    createdAt,
              });
            }
          }
        }
      }

      allListings.sort((a, b) {
        final aTime = a['createdAt'] as DateTime?;
        final bTime = b['createdAt'] as DateTime?;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime);
      });
      debugPrint('Total after fetch: ${allListings.length}');

      setState(() { _products = allListings; _loading = false; });
    } catch (e) {
      debugPrint('Fetch error: $e');
      setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredProducts {
    final id = _activeFilter.id;
    final query = _searchQuery.toLowerCase().trim();

    List<Map<String, dynamic>> result = _products;

// Hide sold and pending items from the public feed
result = result.where((item) {
  final status = (item['status'] ?? 'available').toString().toLowerCase();
  return status != 'sold';
}).toList();
debugPrint('After status filter: ${result.length}');

    if (id != 'all') {
      result = result.where((item) {
        final bool isVehicle = item['isVehicle'] == true;
        final bool isHome    = item['isHome'] == true;

        if (_activeFilter.section == 'vehicle') {
          if (!isVehicle) return false;
          if (id == 'v_all') return true;
          final catId  = (item['vehicleCategoryId'] ?? '').toString();
          final typeId = (item['vehicleTypeId']     ?? '').toString();
          return catId == id || typeId == id;
        }

        if (_activeFilter.section == 'home') {
          if (!isHome) return false;
          if (id == 'h_all_sell') return item['intent'] == 'Sell';
          if (id == 'h_all_rent') return item['intent'] == 'Rent';
          final propCatId = (item['propertyCategoryId'] ?? '').toString();
          final subCatId  = (item['subCategoryId']      ?? '').toString();
          return propCatId == id || subCatId == id;
        }

        if (_activeFilter.section == 'item') {
          if (isVehicle || isHome) return false;
          final parentId = (item['parentCategoryId'] ?? '').toString();
          final subId    = (item['subCategoryId']    ?? '').toString();
          return parentId == id || subId == id;
        }

        return false;
      }).toList();
    }

    if (query.isNotEmpty) {
      result = result.where((item) {
        final title       = (item['title']       ?? '').toString().toLowerCase();
        final description = (item['description'] ?? '').toString().toLowerCase();
        final category    = (item['category']    ?? '').toString().toLowerCase();
        final location    = (item['location']    ?? '').toString().toLowerCase();
        final make        = (item['make']        ?? '').toString().toLowerCase();
        final model       = (item['model']       ?? '').toString().toLowerCase();
        return title.contains(query) ||
               description.contains(query) ||
               category.contains(query) ||
               location.contains(query) ||
               make.contains(query) ||
               model.contains(query);
      }).toList();
    }

    return result;
  }

  void _showCategorySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CategoryFilterSheet(
        activeFilter: _activeFilter,
        onSelected: (filter) {
          setState(() => _activeFilter = filter);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  Future<void> _openDetail(Map<String, dynamic> data) async {
    final bool isVehicle = data['isVehicle'] == true;
    final bool isHome    = data['isHome'] == true;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => isVehicle
            ? VehicleDetailPage(vehicle: data)
            : isHome
                ? HomeDetailPage(home: data)
                : ProductDetailPage(product: data),
      ),
    );
    if (result == 'deleted') _fetchAllListings();
  }

  @override
  Widget build(BuildContext context) {
    final bool isFiltered = _activeFilter.id != 'all';
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        toolbarHeight: 100,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 4, right: 4, top: 4, bottom: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top row: title + action icons ──────────────────────────
              Row(
              
                children: [
                  IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.pop(context),
                ),
                  const SizedBox(width: 4),
                  const Text(
                    'Marketplace',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(),
                  // Chat inbox
                  IconButton(
                    icon: const Icon(Icons.mail_outline, color: Color(0xFF2C3E50)),
                    tooltip: 'My Chats',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () async {
                      final currentName = await _resolveCurrentUserName();
                      if (!mounted) return;
                      if (currentName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter your name first.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatInboxPage(currentUserName: currentName),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  // Refresh
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFF2C3E50)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: _fetchAllListings,
                  ),
                  const SizedBox(width: 8),
                  // ── NEW: Your Listings ────────────────────────────────
                  IconButton(
                    icon: const Icon(Icons.list_alt_outlined, color: Color(0xFF4A90E2)),
                    tooltip: 'Your Listings',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyListingsPage()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Seller Profile
                  IconButton(
                    icon: const Icon(Icons.store_outlined, color: Color(0xFF4A90E2)),
                    tooltip: 'Seller Profile',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SellerProfilePage()),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
              const SizedBox(height: 6),
              // ── Search bar ─────────────────────────────────────────────
              SizedBox(
                height: 38,
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v.trim()),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: 'Search listings...',
                    hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey, size: 18),
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(children: [
        _buildTopButtons(isFiltered),
        if (isFiltered || _searchQuery.isNotEmpty) _buildActiveFilterBar(),
        const Divider(height: 1, thickness: 0.5),
        _buildProductGrid(),
      ]),
    );
  }

  Widget _buildActiveFilterBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(children: [
        if (_activeFilter.id != 'all') ...[
          Icon(_activeFilter.icon, size: 14, color: _activeFilter.color),
          const SizedBox(width: 6),
          Text(_activeFilter.label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _activeFilter.color)),
        ],
        if (_searchQuery.isNotEmpty) ...[
          if (_activeFilter.id != 'all') const SizedBox(width: 8),
          const Icon(Icons.search, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Flexible(
            child: Text('"$_searchQuery"',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                overflow: TextOverflow.ellipsis),
          ),
        ],
        const Spacer(),
        GestureDetector(
          onTap: () {
            setState(() {
              _activeFilter = _kAllFilter;
              _searchQuery = '';
              _searchController.clear();
            });
          },
          child: const Row(children: [
            Icon(Icons.close, size: 14, color: Colors.grey),
            SizedBox(width: 4),
            Text('Clear', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildTopButtons(bool isFiltered) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(children: [
        Expanded(
          child: _topButton(
            Icons.edit, 'Sell', const Color(0xFF4A90E2),
            () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddItemPage()));
              _fetchAllListings();
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _topButton(
            isFiltered ? _activeFilter.icon : Icons.category_outlined,
            isFiltered ? _activeFilter.label : 'Categories',
            isFiltered ? _activeFilter.color : const Color(0xFF4A90E2),
            _showCategorySheet,
          ),
        ),
      ]),
    );
  }

  Widget _buildProductGrid() {
    if (_loading) return const Expanded(child: Center(child: CircularProgressIndicator()));

    final filtered = _filteredProducts;
    if (filtered.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.storefront_outlined, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No results for "$_searchQuery"'
                  : _activeFilter.id == 'all'
                      ? 'No listings available'
                      : 'No listings in "${_activeFilter.label}"',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => setState(() {
                _activeFilter = _kAllFilter;
                _searchQuery = '';
                _searchController.clear();
              }),
              child: const Text('Show all listings'),
            ),
          ]),
        ),
      );
    }

    return Expanded(
      child: RefreshIndicator(
        onRefresh: _fetchAllListings,
        child: GridView.builder(
          padding: const EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            mainAxisExtent: 214,
          ),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final data            = filtered[index];
            final String imageUrl = data['imageUrl'] ?? '';
            final bool isVehicle  = data['isVehicle'] == true;
            final bool isHome     = data['isHome'] == true;
            final int stock       = data['stock'] ?? 1;

            Color badgeColor = isVehicle
                ? const Color(0xFF27AE60).withValues(alpha: 0.85)
                : isHome
                    ? (data['intent'] == 'Rent' ? const Color(0xFF5C6BC0) : const Color(0xFFE67E22)).withValues(alpha: 0.85)
                    : Colors.black.withValues(alpha: 0.6);

            IconData badgeIcon = isVehicle
                ? Icons.directions_car_outlined
                : isHome
                    ? (data['intent'] == 'Rent' ? Icons.key_outlined : Icons.home_outlined)
                    : Icons.inventory_2_outlined;

            String badgeLabel = isVehicle
                ? (data['vehicleType'] ?? 'Vehicle')
                : isHome ? (data['intent'] ?? 'Home') : '$stock';

            Color priceColor = isVehicle
                ? const Color(0xFF27AE60)
                : isHome
                    ? (data['intent'] == 'Rent' ? const Color(0xFF5C6BC0) : const Color(0xFFE67E22))
                    : Colors.blueAccent;

            return GestureDetector(
              onTap: () => _openDetail(data),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 160,
                      child: Stack(fit: StackFit.expand, children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Container(
                            color: Colors.grey[100],
                            child: imageUrl.isNotEmpty
                                ? Image.network(
                                    imageUrl,
                                    fit: BoxFit.contain,
                                    width: double.infinity,
                                    height: double.infinity,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      );
                                    },
                                    errorBuilder: (_, __, ___) => Container(
                                      color: Colors.grey[200],
                                      child: Icon(
                                        isVehicle
                                            ? Icons.directions_car_outlined
                                            : isHome
                                                ? Icons.home_outlined
                                                : Icons.image,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: Colors.grey[200],
                                    child: Icon(
                                      isVehicle
                                          ? Icons.directions_car_outlined
                                          : isHome
                                              ? Icons.home_outlined
                                              : Icons.image,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: badgeColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(badgeIcon, size: 10, color: Colors.white),
                              const SizedBox(width: 3),
                              Text(
                                badgeLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ]),
                          ),
                        ),
                        if ((data['status'] ?? '').toString().toLowerCase() == 'pending')
  Positioned(
    top: 6,
    right: 6,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.orange.shade600.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Pending',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ),
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            data['title'] ?? 'Untitled',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isHome && data['intent'] == 'Rent'
                                ? '\$${data['price']}/mo'
                                : '\$${data['price']}',
                            style: TextStyle(
                              color: priceColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _topButton(IconData icon, String label, Color color, VoidCallback action) {
    return ElevatedButton.icon(
      onPressed: action,
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        overflow: TextOverflow.ellipsis,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      ),
    );
  }
}

// ─── CATEGORY FILTER BOTTOM SHEET ────────────────────────────────────────────

class _CategoryFilterSheet extends StatefulWidget {
  final _FilterCategory activeFilter;
  final void Function(_FilterCategory) onSelected;
  const _CategoryFilterSheet({required this.activeFilter, required this.onSelected});

  @override
  State<_CategoryFilterSheet> createState() => _CategoryFilterSheetState();
}

class _CategoryFilterSheetState extends State<_CategoryFilterSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    int initialTab = 0;
    if (widget.activeFilter.section == 'item')    initialTab = 1;
    if (widget.activeFilter.section == 'vehicle') initialTab = 2;
    if (widget.activeFilter.section == 'home')    initialTab = 3;
    _tabController = TabController(length: 4, vsync: this, initialIndex: initialTab);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<_FilterCategory> _searchAllFilters(String query) {
    final q = query.toLowerCase();
    final all = [..._itemFilters, ..._vehicleFilters, ..._homeFilters];
    return all.where((f) => f.label.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      expand: false,
      builder: (ctx, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(children: [
                const Text('Filter by Category',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
                const Spacer(),
                if (widget.activeFilter.id != 'all')
                  TextButton(
                    onPressed: () => widget.onSelected(_kAllFilter),
                    child: const Text('Clear', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                  ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v.trim()),
                decoration: InputDecoration(
                  hintText: 'Search categories...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          })
                      : null,
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(height: 4),
            if (_searchQuery.isEmpty) ...[
              TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF4A90E2),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF4A90E2),
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(icon: Icon(Icons.apps_outlined, size: 18), text: 'All'),
                  Tab(icon: Icon(Icons.shopping_bag_outlined, size: 18), text: 'Items'),
                  Tab(icon: Icon(Icons.directions_car_outlined, size: 18), text: 'Vehicles'),
                  Tab(icon: Icon(Icons.home_outlined, size: 18), text: 'Homes'),
                ],
              ),
              const Divider(height: 1),
            ],
            Expanded(
              child: _searchQuery.isNotEmpty
                  ? _buildSearchResults(scrollController)
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildAllTab(scrollController),
                        _buildGroupedList(_itemGroups, scrollController),
                        _buildGroupedList(_vehicleGroups, scrollController),
                        _buildGroupedList(_homeGroups, scrollController),
                      ],
                    ),
            ),
          ]),
        );
      },
    );
  }

  Widget _buildSearchResults(ScrollController controller) {
    final results = _searchAllFilters(_searchQuery);
    if (results.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text('No categories found for "$_searchQuery"',
              style: TextStyle(color: Colors.grey[500], fontSize: 14)),
        ]),
      );
    }
    return GridView.builder(
      controller: controller,
      padding: const EdgeInsets.all(14),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.88),
      itemCount: results.length,
      itemBuilder: (context, index) => _buildFilterTile(results[index]),
    );
  }

  Widget _buildAllTab(ScrollController controller) {
    return SingleChildScrollView(
      controller: controller,
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: () => widget.onSelected(_kAllFilter),
          child: _bigTile(_kAllFilter),
        ),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 12),
        const Text('Browse by type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: GestureDetector(
            onTap: () => widget.onSelected(_vehicleFilters.first),
            child: _bigTile(_vehicleFilters.first),
          )),
          const SizedBox(width: 12),
          Expanded(child: GestureDetector(
            onTap: () => widget.onSelected(_homeFilters[0]),
            child: _bigTile(_homeFilters[0]),
          )),
          const SizedBox(width: 12),
          Expanded(child: GestureDetector(
            onTap: () => widget.onSelected(_homeFilters[1]),
            child: _bigTile(_homeFilters[1]),
          )),
        ]),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 12),
        const Text('Popular categories', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.88),
          itemCount: _itemGroups.length,
          itemBuilder: (context, index) {
            final group = _itemGroups[index];
            final rep = group.items.first;
            return _buildFilterTile(rep);
          },
        ),
      ]),
    );
  }

  Widget _buildGroupedList(List<_CategoryGroup> groups, ScrollController controller) {
    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        return _GroupSection(
          group: groups[index],
          activeFilter: widget.activeFilter,
          onSelected: widget.onSelected,
        );
      },
    );
  }

  Widget _bigTile(_FilterCategory filter) {
    final bool isSelected = widget.activeFilter.id == filter.id;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isSelected ? filter.color.withValues(alpha: 0.12) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isSelected ? filter.color : Colors.grey.shade200, width: isSelected ? 2 : 1),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(filter.icon, color: filter.color, size: 30),
        const SizedBox(height: 8),
        Text(filter.label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                color: isSelected ? filter.color : const Color(0xFF2C3E50))),
      ]),
    );
  }

  Widget _buildFilterTile(_FilterCategory filter) {
    final isSelected = widget.activeFilter.id == filter.id;
    return GestureDetector(
      onTap: () => widget.onSelected(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: isSelected ? filter.color.withValues(alpha: 0.11) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? filter.color : Colors.grey.shade200, width: isSelected ? 1.5 : 1),
          boxShadow: isSelected
              ? [BoxShadow(color: filter.color.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 3))]
              : [],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: isSelected ? filter.color.withValues(alpha: 0.18) : filter.color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(filter.icon, color: filter.color, size: 22),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(filter.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? filter.color : const Color(0xFF2C3E50),
                ),
                maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
        ]),
      ),
    );
  }
}

// ─── GROUP SECTION WIDGET ─────────────────────────────────────────────────────

class _GroupSection extends StatefulWidget {
  final _CategoryGroup group;
  final _FilterCategory activeFilter;
  final void Function(_FilterCategory) onSelected;

  const _GroupSection({
    required this.group,
    required this.activeFilter,
    required this.onSelected,
  });

  @override
  State<_GroupSection> createState() => _GroupSectionState();
}

class _GroupSectionState extends State<_GroupSection> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.group.items.any((f) => f.id == widget.activeFilter.id);
    if (!_expanded && widget.group.items.isNotEmpty) {
      _expanded = widget.group.items.first.id == widget.activeFilter.id;
    }
  }

  bool get _hasActiveChild =>
      widget.group.items.any((f) => f.id == widget.activeFilter.id);

  @override
  Widget build(BuildContext context) {
    final color = widget.group.color;
    final bool isSingleItem = widget.group.items.length == 1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: _hasActiveChild ? color.withValues(alpha: 0.04) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _hasActiveChild ? color.withValues(alpha: 0.35) : Colors.grey.shade200,
          width: _hasActiveChild ? 1.5 : 1,
        ),
      ),
      child: Column(children: [
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            if (isSingleItem) {
              widget.onSelected(widget.group.items.first);
            } else {
              setState(() => _expanded = !_expanded);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.group.icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(widget.group.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _hasActiveChild ? color : const Color(0xFF2C3E50),
                    )),
              ),
              if (isSingleItem)
                Icon(Icons.arrow_forward_ios, size: 14, color: _hasActiveChild ? color : Colors.grey)
              else ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${widget.group.items.length}',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.keyboard_arrow_down,
                      color: _expanded ? color : Colors.grey, size: 20),
                ),
              ],
            ]),
          ),
        ),
        if (!isSingleItem)
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.9),
                itemCount: widget.group.items.length,
                itemBuilder: (context, index) {
                  final filter = widget.group.items[index];
                  final isSelected = widget.activeFilter.id == filter.id;
                  return GestureDetector(
                    onTap: () => widget.onSelected(filter),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      decoration: BoxDecoration(
                        color: isSelected ? filter.color.withValues(alpha: 0.11) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? filter.color : Colors.grey.shade200,
                          width: isSelected ? 1.5 : 1,
                        ),
                        boxShadow: isSelected
                            ? [BoxShadow(color: filter.color.withValues(alpha: 0.15), blurRadius: 6, offset: const Offset(0, 2))]
                            : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 1))],
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(
                            color: isSelected ? filter.color.withValues(alpha: 0.18) : filter.color.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(filter.icon, color: filter.color, size: 20),
                        ),
                        const SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Text(filter.label,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? filter.color : const Color(0xFF2C3E50),
                              ),
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                        ),
                      ]),
                    ),
                  );
                },
              ),
            ),
            crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
      ]),
    );
  }
}