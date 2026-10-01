import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screen/product_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'screen/seller_session.dart';

const String kBuyerNameKey = 'buyer_name';

class NameEntryPage extends StatefulWidget {
  const NameEntryPage({super.key});

  @override
  State<NameEntryPage> createState() => _NameEntryPageState();
}

class _NameEntryPageState extends State<NameEntryPage> {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

Future<void> _continue() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _saving = true);

  final name = _nameController.text.trim();

  // Save buyer name locally
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(kBuyerNameKey, name.toLowerCase());

  // Auto-search if seller profile exists and save session
  try {
    final response = await http.post(
      Uri.parse('https://firestore.googleapis.com/v1/projects/marketplaneproducts/databases/(default)/documents:runQuery'),
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

    if (response.statusCode == 200) {
      final results = jsonDecode(response.body) as List;
      final doc = results.isNotEmpty ? results[0]['document'] : null;
      if (doc != null) {
        // Seller profile found — save session automatically
        await prefs.setString('session_seller_name', name);
      }
    }
  } catch (e) {
    debugPrint('Auto seller lookup error: $e');
  }

  if (mounted) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ProductPage()),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A90E2).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.storefront_outlined,
                      size: 48,
                      color: Color(0xFF4A90E2),
                    ),
                  ),
                  const SizedBox(height: 28),

                  const Text(
                    'Welcome to Marketplace',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Enter your name to get started.\nThis is how buyers and sellers will identify you.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 36),

                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Your Name',
                      hintText: 'e.g. John Smith',
                      prefixIcon: const Icon(Icons.person_outline,
                          color: Color(0xFF4A90E2)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFF4A90E2), width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      if (value.trim().length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _continue(),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _continue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A90E2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}