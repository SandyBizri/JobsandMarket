/*import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String kFirestoreUrl =
    'https://firestore.googleapis.com/v1/projects/marketplaneproducts/databases/(default)/documents';

class SellerProfilePage extends StatefulWidget {
  const SellerProfilePage({super.key});

  @override
  State<SellerProfilePage> createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends State<SellerProfilePage> {
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  bool _isSaving    = false;
  bool _isSearching = false;
  bool _profileFound = false;
  bool _searchDone  = false;
  String? _existingDocId;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  // ── Search existing profile ──────────────────────────────────────────────

  Future<void> _searchProfile() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      _snack("Enter a seller name to search");
      return;
    }
    setState(() {
      _isSearching = true;
      _searchDone = false;
      _profileFound = false;
    });

    try {
      final res = await http.post(
        Uri.parse('$kFirestoreUrl:runQuery'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'structuredQuery': {
            'from': [{'collectionId': 'sellers'}],
            'where': {
              'fieldFilter': {
                'field': {'fieldPath': 'name'},
                'op': 'EQUAL',
                'value': {'stringValue': name},
              }
            },
            'limit': 1,
          }
        }),
      );

      if (res.statusCode == 200) {
        final results = jsonDecode(res.body) as List;
        final doc = results.isNotEmpty ? results[0]['document'] : null;
        if (doc != null) {
          final fields = doc['fields'] as Map<String, dynamic>;
          setState(() {
            _existingDocId = (doc['name'] as String).split('/').last;
            _phoneCtrl.text = fields['phone']?['stringValue'] ?? '';
            _emailCtrl.text = fields['email']?['stringValue'] ?? '';
            _profileFound = true;
            _searchDone = true;
          });
        } else {
          setState(() {
            _profileFound = false;
            _searchDone = true;
            _existingDocId = null;
            _phoneCtrl.clear();
            _emailCtrl.clear();
          });
        }
      }
    } catch (e) {
      _snack("Network error. Try again.");
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  // ── Save / create profile ────────────────────────────────────────────────

  Future<void> _saveProfile() async {
    final name  = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final email = _emailCtrl.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      _snack("Name and Phone are required");
      return;
    }
    if (email.isNotEmpty && (!email.contains('@') || !email.contains('.'))) {
      _snack("Enter a valid email or leave it blank");
      return;
    }

    setState(() => _isSaving = true);

    try {
      final body = jsonEncode({
        'fields': {
          'name':      {'stringValue': name},
          'phone':     {'stringValue': phone},
          'email':     {'stringValue': email},
          'updatedAt': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
        }
      });

      http.Response res;
      if (_existingDocId != null) {
  res = await http.patch(
    Uri.parse('$kFirestoreUrl/sellers/$_existingDocId?updateMask.fieldPaths=name&updateMask.fieldPaths=phone&updateMask.fieldPaths=email&updateMask.fieldPaths=updatedAt'),
    headers: {'Content-Type': 'application/json'},
    body: body,
  );
      } else {
        res = await http.post(
          Uri.parse('$kFirestoreUrl/sellers'),
          headers: {'Content-Type': 'application/json'},
          body: body,
        );
      }

     if (res.statusCode == 200) {
  // ← ADD THIS: save name to device session
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('session_seller_name', name);
  
  if (mounted) {
    _snack(
      _profileFound ? "✅ Profile updated!" : "✅ Profile created!",
      success: true,
    );
    Navigator.pop(context, name);
  }

      } else {
        _snack("Failed to save. Try again.");
      }
    } catch (e) {
      _snack("Error saving profile");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _snack(String msg, {bool error = false, bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error
          ? Colors.red
          : success
              ? const Color(0xFF27AE60)
              : null,
      behavior: SnackBarBehavior.floating,
    ));
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Seller Profile",
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Row(children: [
                Icon(Icons.store_outlined, color: Color(0xFF4A90E2)),
                SizedBox(width: 8),
                Text(
                  "Create / Update Profile",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ]),
              const SizedBox(height: 16),

              // Name + Search button
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: "Seller Name *",
                      hintText: "e.g. John's Shop",
                      prefixIcon: Icon(Icons.store_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _isSearching ? null : _searchProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isSearching
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.search, color: Colors.white),
                ),
              ]),

              // Search result banner
              if (_searchDone) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: (_profileFound
                            ? const Color(0xFF27AE60)
                            : const Color(0xFF4A90E2))
                        .withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: (_profileFound
                              ? const Color(0xFF27AE60)
                              : const Color(0xFF4A90E2))
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(children: [
                    Icon(
                      _profileFound
                          ? Icons.check_circle_outline
                          : Icons.person_add_outlined,
                      size: 16,
                      color: _profileFound
                          ? const Color(0xFF27AE60)
                          : const Color(0xFF4A90E2),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _profileFound
                            ? "Profile found. You can update your details below."
                            : "No profile found. Fill in details to create one.",
                        style: TextStyle(
                          fontSize: 13,
                          color: _profileFound
                              ? const Color(0xFF27AE60)
                              : const Color(0xFF4A90E2),
                        ),
                      ),
                    ),
                  ]),
                ),
              ],

              const SizedBox(height: 14),

              // Phone
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "WhatsApp / Phone *",
                  hintText: "+1 234 567 8900",
                  prefixIcon: Icon(Icons.phone_outlined, color: Color(0xFF25D366)),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),

              // Email
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email (optional)",
                  hintText: "you@example.com",
                  prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF4A90E2)),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveProfile,
                  icon: const Icon(Icons.save_outlined, color: Colors.white),
                  label: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(
                          _profileFound ? "Update Profile" : "Create Profile",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String kFirestoreUrl =
    'https://firestore.googleapis.com/v1/projects/marketplaneproducts/databases/(default)/documents';

class SellerProfilePage extends StatefulWidget {
  const SellerProfilePage({super.key});

  @override
  State<SellerProfilePage> createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends State<SellerProfilePage> {
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  bool _isSaving    = false;
  bool _isLoading   = true;
  bool _profileFound = false;
  String? _existingDocId;

  @override
  void initState() {
    super.initState();
    _loadFromFirebaseAuth();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  // ── Auto-load user info from Firebase Auth ──────────────────────────────
  Future<void> _loadFromFirebaseAuth() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _nameCtrl.text  = user.displayName ?? '';
      _emailCtrl.text = user.email ?? '';
      // Try to load existing Firestore profile
      await _loadExistingProfile(user.uid);
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadExistingProfile(String uid) async {
    try {
      final res = await http.get(
        Uri.parse('$kFirestoreUrl/sellers/$uid'),
        headers: {'Content-Type': 'application/json'},
      );
      if (res.statusCode == 200) {
        final doc = jsonDecode(res.body);
        final fields = doc['fields'] as Map<String, dynamic>;
        setState(() {
          _existingDocId = uid;
          _phoneCtrl.text = fields['phone']?['stringValue'] ?? '';
          if ((fields['name']?['stringValue'] ?? '').isNotEmpty) {
            _nameCtrl.text = fields['name']['stringValue'];
          }
          _profileFound = true;
        });
      }
    } catch (e) {
      debugPrint('Profile load error: $e');
    }
  }

  // ── Save profile ────────────────────────────────────────────────────────
  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _snack("Please sign in first", error: true);
      return;
    }

    final name  = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final email = _emailCtrl.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      _snack("Name and Phone are required");
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Update Firebase Auth display name
      await user.updateDisplayName(name);

      // Save to Firestore using UID as document ID
      final body = jsonEncode({
        'fields': {
          'name':      {'stringValue': name},
          'phone':     {'stringValue': phone},
          'email':     {'stringValue': email},
          'uid':       {'stringValue': user.uid},
          'jobsAccess':{'booleanValue':false},
          'updatedAt': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
        }
      });

      final res = await http.patch(
        Uri.parse('$kFirestoreUrl/sellers/${user.uid}?'
            'updateMask.fieldPaths=name&updateMask.fieldPaths=phone&'
            'updateMask.fieldPaths=email&updateMask.fieldPaths=uid&'
            'updateMask.fieldPaths=updatedAt'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (res.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('session_seller_name', name);
        if (mounted) {
          _snack(_profileFound ? "✅ Profile updated!" : "✅ Profile created!", 
                 success: true);
          setState(() {
            _profileFound = true;
            _existingDocId = user.uid;
          });
        }
      } else {
        _snack("Failed to save. Try again.");
      }
    } catch (e) {
      _snack("Error saving profile");
      debugPrint('Save error: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_seller_name');
    if (mounted) Navigator.pop(context);
  }

  void _snack(String msg, {bool error = false, bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error
          ? Colors.red
          : success
              ? const Color(0xFF27AE60)
              : null,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Seller Profile",
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (user != null)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.red),
              onPressed: _signOut,
              tooltip: 'Sign Out',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // ── User Avatar ──────────────────────────────────────
                  if (user != null) ...[
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xFF4A90E2),
                      backgroundImage: user.photoURL != null
                          ? NetworkImage(user.photoURL!)
                          : null,
                      child: user.photoURL == null
                          ? Text(
                              (user.displayName ?? 'U')[0].toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 32, color: Colors.white),
                            )
                          : null,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.displayName ?? user.email ?? 'User',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Profile Form ─────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(children: [
                          Icon(Icons.store_outlined, color: Color(0xFF4A90E2)),
                          SizedBox(width: 8),
                          Text(
                            "Your Seller Profile",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 16),

                        // Name
                        TextField(
                          controller: _nameCtrl,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: "Seller Name *",
                            prefixIcon: Icon(Icons.store_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Phone
                        TextField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: "WhatsApp / Phone *",
                            hintText: "+1 234 567 8900",
                            prefixIcon: Icon(Icons.phone_outlined,
                                color: Color(0xFF25D366)),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Email (read only if from Google)
                        TextField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          readOnly: user?.providerData
                                  .any((p) => p.providerId == 'google.com') ??
                              false,
                          decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: const Icon(Icons.email_outlined,
                                color: Color(0xFF4A90E2)),
                            border: const OutlineInputBorder(),
                            filled: user?.providerData
                                    .any((p) => p.providerId == 'google.com') ??
                                false,
                            fillColor: Colors.grey[100],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Save button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _isSaving ? null : _saveProfile,
                            icon: const Icon(Icons.save_outlined,
                                color: Colors.white),
                            label: _isSaving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : Text(
                                    _profileFound
                                        ? "Update Profile"
                                        : "Create Profile",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A90E2),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}