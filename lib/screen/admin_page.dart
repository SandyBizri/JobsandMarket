import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

const String _firestoreUrl =
    'https://firestore.googleapis.com/v1/projects/marketplaneproducts/databases/(default)/documents';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<Map<String, dynamic>> _pendingUsers = [];
  List<Map<String, dynamic>> _pendingJobs = [];
  bool _isLoading = true;
  int _totalUsers = 0;
  int _approvedUsers = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.wait([_loadUsers(), _loadJobs()]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadUsers() async {
    try {
      final res = await http.get(
        Uri.parse('$_firestoreUrl/sellers'),
        headers: {'Content-Type': 'application/json'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final docs = data['documents'] as List? ?? [];
        final List<Map<String, dynamic>> pending = [];
        int approved = 0;

        for (var doc in docs) {
          final fields = doc['fields'] as Map<String, dynamic>? ?? {};
          final docId = (doc['name'] as String).split('/').last;
          final jobsAccess = fields['jobsAccess']?['booleanValue'] ?? false;
          final name = fields['name']?['stringValue'] ?? 'Unknown';
          final email = fields['email']?['stringValue'] ?? '';
          final phone = fields['phone']?['stringValue'] ?? '';

          if (jobsAccess == true) {
            approved++;
          } else {
            pending.add({
              'uid': docId,
              'name': name,
              'email': email,
              'phone': phone,
              'jobsAccess': jobsAccess,
            });
          }
        }

        setState(() {
          _pendingUsers = pending;
          _totalUsers = docs.length;
          _approvedUsers = approved;
        });
      }
    } catch (e) {
      debugPrint('Load users error: $e');
    }
  }

  Future<void> _loadJobs() async {
    try {
      final res = await http.post(
        Uri.parse('$_firestoreUrl:runQuery'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'structuredQuery': {
            'from': [{'collectionId': 'jobs'}],
            'where': {
              'fieldFilter': {
                'field': {'fieldPath': 'approved'},
                'op': 'EQUAL',
                'value': {'integerValue': '0'},
              }
            },
          }
        }),
      );

      if (res.statusCode == 200) {
        final results = jsonDecode(res.body) as List;
        final List<Map<String, dynamic>> jobs = [];

        for (var item in results) {
          final doc = item['document'];
          if (doc == null) continue;
          final fields = doc['fields'] as Map<String, dynamic>? ?? {};
          final docId = (doc['name'] as String).split('/').last;

          jobs.add({
            'id': docId,
            'title': fields['title']?['stringValue'] ?? 'No title',
            'company': fields['company']?['stringValue'] ?? 'Unknown',
            'category': fields['category']?['stringValue'] ?? '',
            'postedBy': fields['postedBy']?['stringValue'] ?? '',
            'date': fields['posted_at'] != null
                ? (fields['posted_at']['timestampValue'] ?? '').toString().substring(0, 10)
                : '',
          });
        }

        setState(() => _pendingJobs = jobs);
      }
    } catch (e) {
      debugPrint('Load jobs error: $e');
    }
  }

  Future<void> _approveUser(String uid) async {
    try {
      await http.patch(
        Uri.parse('$_firestoreUrl/sellers/$uid?updateMask.fieldPaths=jobsAccess'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fields': {
            'jobsAccess': {'booleanValue': true},
          }
        }),
      );
      _snack('✅ User approved!', success: true);
      await _loadUsers();
    } catch (e) {
      _snack('Error approving user', error: true);
    }
  }

  Future<void> _approveJob(String jobId) async {
    try {
      await http.patch(
        Uri.parse('$_firestoreUrl/jobs/$jobId?updateMask.fieldPaths=approved'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fields': {
            'approved': {'integerValue': 1},
          }
        }),
      );
      _snack('✅ Job approved!', success: true);
      await _loadJobs();
    } catch (e) {
      _snack('Error approving job', error: true);
    }
  }

  Future<void> _rejectJob(String jobId) async {
    try {
      await http.delete(
        Uri.parse('$_firestoreUrl/jobs/$jobId'),
        headers: {'Content-Type': 'application/json'},
      );
      _snack('Job rejected and removed.');
      await _loadJobs();
    } catch (e) {
      _snack('Error rejecting job', error: true);
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _snack(String msg, {bool error = false, bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error
          ? Colors.red
          : success
              ? const Color(0xFF27AE60)
              : const Color(0xFF2B4EDB),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
              color: Color(0xFF1A1A2E),
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF2B4EDB)),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _signOut,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Stats Row ──────────────────────────
                    Row(
                      children: [
                        _statCard('Total Users', _totalUsers,
                            Icons.people, const Color(0xFF2B4EDB)),
                        const SizedBox(width: 10),
                        _statCard('Approved', _approvedUsers,
                            Icons.check_circle, const Color(0xFF27AE60)),
                        const SizedBox(width: 10),
                        _statCard('Pending', _pendingUsers.length,
                            Icons.hourglass_empty, const Color(0xFFE67E22)),
                        const SizedBox(width: 10),
                        _statCard('Pending Jobs', _pendingJobs.length,
                            Icons.work_outline, const Color(0xFF8E44AD)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Users Section ──────────────────────
                    const Text('Users Requesting Job Access',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      'Users who paid \$1 and are waiting for admin approval',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 12),

                    _pendingUsers.isEmpty
                        ? _emptyCard('No pending users')
                        : Container(
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
                              children: [
                                // Table header
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16)),
                                  ),
                                  child: const Row(
                                    children: [
                                      Expanded(flex: 3, child: Text('User', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                                      Expanded(flex: 3, child: Text('Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                                      Expanded(flex: 2, child: Text('Action', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1),
                                ..._pendingUsers.map((user) => _userRow(user)),
                              ],
                            ),
                          ),

                    const SizedBox(height: 24),

                    // ── Jobs Section ───────────────────────
                    const Text('Pending Job Posts',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      'Job posts waiting for admin approval',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 12),

                    _pendingJobs.isEmpty
                        ? _emptyCard('No pending job posts')
                        : Container(
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
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16)),
                                  ),
                                  child: const Row(
                                    children: [
                                      Expanded(flex: 3, child: Text('Title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                                      Expanded(flex: 2, child: Text('Company', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                                      Expanded(flex: 3, child: Text('Action', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1),
                                ..._pendingJobs.map((job) => _jobRow(job)),
                              ],
                            ),
                          ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _statCard(String label, int value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
            )
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text('$value',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color)),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _userRow(Map<String, dynamic> user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF2B4EDB).withValues(alpha: 0.1),
                  child: Text(
                    (user['name'] as String)[0].toUpperCase(),
                    style: const TextStyle(
                        color: Color(0xFF2B4EDB),
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    user['name'],
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              user['email'],
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () => _approveUser(user['uid']),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2B4EDB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text('Approve', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _jobRow(Map<String, dynamic> job) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job['title'],
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  job['category'],
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              job['company'],
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () => _approveJob(job['id']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27AE60),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text('Approve', style: TextStyle(fontSize: 11)),
                ),
                const SizedBox(width: 6),
                ElevatedButton(
                  onPressed: () => _rejectJob(job['id']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text('Reject', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey.shade500),
      ),
    );
  }
}