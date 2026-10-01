/*import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String _kSellerName = 'session_seller_name';
const String kFirestoreUrl =
    'https://firestore.googleapis.com/v1/projects/marketplaneproducts/databases/(default)/documents';

class SellerSession {
  /// Get logged-in seller name — null if not logged in
  static Future<String?> getSellerName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kSellerName);
  }

  // Static field for current user name
  static String currentUserName = 'User';

  // Call once at app startup
  static Future<void> init() async {
    final name = await getSellerName();
    if (name != null && name.isNotEmpty) {
      currentUserName = name;
    }
  }

  static Future<bool> isLoggedIn() async {
    final name = await getSellerName();
    return name != null && name.isNotEmpty;
  }

  /// Verify name + password against Firestore, then save to device on success
  static Future<LoginResult> login(String name, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$kFirestoreUrl:runQuery'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'structuredQuery': {
            'from': [{'collectionId': 'sellers'}],
            'where': {
              'compositeFilter': {
                'op': 'AND',
                'filters': [
                  {
                    'fieldFilter': {
                      'field': {'fieldPath': 'name'},
                      'op': 'EQUAL',
                      'value': {'stringValue': name.trim()},
                    }
                  },
                  {
                    'fieldFilter': {
                      'field': {'fieldPath': 'password'},
                      'op': 'EQUAL',
                      'value': {'stringValue': password.trim()},
                    }
                  },
                ]
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
          // ← FIXED: save the name exactly as stored in Firestore, not what user typed
          final actualName =
              doc['fields']['name']['stringValue'] as String? ?? name.trim();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_kSellerName, actualName);
          return LoginResult.success;
        }
        return LoginResult.wrongCredentials;
      }
      return LoginResult.networkError;
    } catch (e) {
      debugPrint("Login error: $e");
      return LoginResult.networkError;
    }
  }

  /// Clear session from device
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSellerName);
  }

  /// Check if logged-in seller owns this product
  static Future<bool> isOwnerOf(Map<String, dynamic> product) async {
    final localName = await getSellerName() ?? '';
    if (localName.isEmpty) return false;
    final productSeller = (product['sellerName'] ?? '').toString();
    return localName.toLowerCase() == productSeller.toLowerCase();
  }
}

enum LoginResult { success, wrongCredentials, networkError }*/
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class SellerSession {
  static String currentUserName = 'User';

  static Future<void> init() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserName = user.displayName ?? user.email ?? 'User';
    }
  }

  static Future<bool> isLoggedIn() async {
    return FirebaseAuth.instance.currentUser != null;
  }

  static Future<String?> getSellerName() async {
    final user = FirebaseAuth.instance.currentUser;
    return user?.displayName ?? user?.email;
  }

  static Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_seller_name');
    await prefs.remove('buyer_name');
  }

  static Future<bool> isOwnerOf(Map<String, dynamic> product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final productSeller = (product['sellerName'] ?? '').toString();
    final userName = user.displayName ?? user.email ?? '';
    return userName.toLowerCase() == productSeller.toLowerCase();
  }
}