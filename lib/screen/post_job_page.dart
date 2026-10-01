/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostJobPage extends StatefulWidget {
  const PostJobPage({super.key});

  @override
  State<PostJobPage> createState() => _PostJobPageState();
}

class _PostJobPageState extends State<PostJobPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedCategory;
  String? _selectedJobType;

  final List<String> jobTypes = [
    'Full-time', 'Part-time', 'Remote', 'Contract', 'Internship',
  ];

  final Map<String, String> categoryLabels = {
    'software-dev': 'Software Dev',
    'customer-support': 'Customer Support',
    'design': 'Design',
    'marketing': 'Marketing',
    'sales': 'Sales',
    'product': 'Product',
    'business': 'Business',
    'data': 'Data',
    'devops-sysadmin': 'DevOps / SysAdmin',
    'finance-legal': 'Finance & Legal',
    'hr': 'Human Resources',
    'qa': 'QA',
    'writing': 'Writing',
    'teaching': 'Teaching',
    'cyber-security': 'Cyber Security',
    'accounting': 'Accounting',
    'healthcare': 'Healthcare / Hospital',
    'engineering': 'Engineering',
    'administration': 'Administration',
  };

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitJob() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
     await FirebaseFirestore.instance.collection('jobs').add({
        'title': _titleController.text.trim(),
        'company': _companyController.text.trim(),
        'location': _locationController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory ?? 'business',
        'job_type': _selectedJobType ?? '',
        'salary': _salaryController.text.trim(),
        'job_url': '',
        'source': 'posted',
        'approved': 0,  // ✅ 0 = pending, 1 = approved
        'posted_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.hourglass_top, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your job has been submitted and will be posted after approval.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: Color(0xFF4D6EDB),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        );
        Navigator.pop(context, false); // ✅ false = don't refresh, job not approved yet
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post job: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7F9),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Post a Job',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.70,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // ─── HEADER CARD ──────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4D6EDB), Color(0xFF6EC1FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4D6EDB).withAlpha(80),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.work_outline, color: Colors.white, size: 22),
                            SizedBox(width: 10),
                            Text(
                              'New Job Posting',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Fill in the details below. Your job will be visible to all users immediately after posting.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ─── SECTION: JOB INFO ────────────────────────────
                  _sectionHeader('Job Information', Icons.info_outline),
                  const SizedBox(height: 14),

                  _buildField(
                    label: 'Job Title',
                    required: true,
                    child: _buildTextField(
                      controller: _titleController,
                      hint: 'e.g. Senior Software Engineer',
                      icon: Icons.work_outline,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Job title is required' : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildField(
                    label: 'Company Name',
                    required: true,
                    child: _buildTextField(
                      controller: _companyController,
                      hint: 'e.g. Google',
                      icon: Icons.business_outlined,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Company name is required' : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildField(
                    label: 'Location',
                    required: true,
                    child: _buildTextField(
                      controller: _locationController,
                      hint: 'e.g. Beirut, Lebanon',
                      icon: Icons.location_on_outlined,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Location is required' : null,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ─── SECTION: JOB DETAILS ─────────────────────────
                  _sectionHeader('Job Details', Icons.tune_outlined),
                  const SizedBox(height: 14),

                  // ─── CATEGORY + JOB TYPE SIDE BY SIDE ────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildField(
                          label: 'Category',
                          required: true,
                          child: _buildDropdown(
                            value: _selectedCategory,
                            hint: 'Select category',
                            icon: Icons.category_outlined,
                            items: categoryLabels.entries
                                .map((e) => DropdownMenuItem(
                                    value: e.key, child: Text(e.value,
                                    style: const TextStyle(fontSize: 13))))
                                .toList(),
                            onChanged: (v) => setState(() => _selectedCategory = v),
                            validator: (v) => v == null
                                ? 'Required' : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildField(
                          label: 'Job Type',
                          required: true,
                          child: _buildDropdown(
                            value: _selectedJobType,
                            hint: 'Select type',
                            icon: Icons.access_time_outlined,
                            items: jobTypes
                                .map((t) => DropdownMenuItem(
                                    value: t, child: Text(t,
                                    style: const TextStyle(fontSize: 13))))
                                .toList(),
                            onChanged: (v) => setState(() => _selectedJobType = v),
                            validator: (v) => v == null
                                ? 'Required' : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildField(
                    label: 'Salary',
                    required: false,
                    child: _buildTextField(
                      controller: _salaryController,
                      hint: 'e.g. \$2,000 - \$3,000 / month',
                      icon: Icons.attach_money_outlined,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ─── SECTION: DESCRIPTION ─────────────────────────
                  _sectionHeader('Job Description', Icons.description_outlined),
                  const SizedBox(height: 14),

                  _buildField(
                    label: 'Description',
                    required: true,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(10),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _descriptionController,
                        maxLines: 7,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Description is required' : null,
                        decoration: InputDecoration(
                          hintText:
                              'Describe responsibilities, requirements, benefits...',
                          hintStyle: TextStyle(
                              color: Colors.grey.shade400, fontSize: 13),
                          contentPadding: const EdgeInsets.all(16),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ─── CONFIRM BUTTON ───────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitJob,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4D6EDB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.cloud_upload_outlined, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Confirm & Post Job',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── SECTION HEADER ───────────────────────────────────────
  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF1FB),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF4D6EDB)),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.grey.shade200,
          ),
        ),
      ],
    );
  }

  // ─── FIELD WRAPPER WITH LABEL ─────────────────────────────
  Widget _buildField({
    required String label,
    required bool required,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (required) ...[
              const SizedBox(width: 3),
              const Text('*',
                  style: TextStyle(color: Color(0xFF4D6EDB), fontSize: 13)),
            ] else ...[
              const SizedBox(width: 6),
              Text('(optional)',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
            ],
          ],
        ),
        const SizedBox(height: 7),
        child,
      ],
    );
  }

  // ─── TEXT FIELD ───────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          prefixIcon: Icon(icon, color: const Color(0xFF4D6EDB).withAlpha(160), size: 18),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        ),
      ),
    );
  }

  // ─── DROPDOWN ─────────────────────────────────────────────
  Widget _buildDropdown({
    required String? value,
    required String hint,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        items: items,
        onChanged: onChanged,
        validator: validator,
        icon: const Icon(Icons.keyboard_arrow_down_rounded,
            color: Colors.grey, size: 20),
        decoration: InputDecoration(
          prefixIcon: Icon(icon,
              color: const Color(0xFF4D6EDB).withAlpha(160), size: 18),
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        ),
        dropdownColor: Colors.white,
        style: const TextStyle(color: Colors.black87, fontSize: 13),
        isExpanded: true,
      ),
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'shared_paywall.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

class PostJobPage extends StatefulWidget {
  const PostJobPage({super.key});

  @override
  State<PostJobPage> createState() => _PostJobPageState();
}

class _PostJobPageState extends State<PostJobPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _guardPayment();
  }

  Future<void> _guardPayment() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    bool paid = false;
    if (uid != null) {
      final snap = await FirebaseFirestore.instance.collection('sellers').doc(uid).get();
      paid = (snap.data()?['jobsAccess'] ?? false) as bool;
    }
    if (!paid && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pop(context);
        showPaywallDialog(context);
      });
    }
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedCategory;
  String? _selectedJobType;

  final List<String> jobTypes = [
    'Full-time', 'Part-time', 'Remote', 'Contract', 'Internship',
  ];

  final Map<String, String> categoryLabels = {
    'software-dev': 'Software Dev',
    'customer-support': 'Customer Support',
    'design': 'Design',
    'marketing': 'Marketing',
    'sales': 'Sales',
    'product': 'Product',
    'business': 'Business',
    'data': 'Data',
    'devops-sysadmin': 'DevOps / SysAdmin',
    'finance-legal': 'Finance & Legal',
    'hr': 'Human Resources',
    'qa': 'QA',
    'writing': 'Writing',
    'teaching': 'Teaching',
    'cyber-security': 'Cyber Security',
    'accounting': 'Accounting',
    'healthcare': 'Healthcare / Hospital',
    'engineering': 'Engineering',
    'administration': 'Administration',
  };

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ── Check profile before submitting ────────────────────────
  Future<void> _checkProfileAndSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('sellers')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final sellerName = doc['name'] ?? user.displayName ?? '';
        await _submitJob(sellerName: sellerName);
        return;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('session_seller_name') ?? '';

    if (savedName.isNotEmpty) {
      final query = await FirebaseFirestore.instance
          .collection('sellers')
          .where('name', isEqualTo: savedName)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        await _submitJob(sellerName: savedName);
        return;
      }
    }

    if (!mounted) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _SellerProfileSetupPage()),
    );

    if (result != null && result is String && result.isNotEmpty) {
      await _submitJob(sellerName: result);
    }
  }

  Future<void> _submitJob({required String sellerName}) async {
    setState(() => _isSubmitting = true);
    try {
      await FirebaseFirestore.instance.collection('jobs').add({
        'title': _titleController.text.trim(),
        'company': _companyController.text.trim(),
        'location': _locationController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory ?? 'business',
        'job_type': _selectedJobType ?? '',
        'salary': _salaryController.text.trim(),
        'job_url': '',
        'source': 'posted',
        'sellerName': sellerName,
        'approved': 0,
        'posted_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.hourglass_top, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your job has been submitted and will be posted after approval.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: Color(0xFF4D6EDB),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        );
        Navigator.pop(context, false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post job: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7F9),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Post a Job',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.70,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4D6EDB), Color(0xFF6EC1FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4D6EDB).withAlpha(80),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.work_outline, color: Colors.white, size: 22),
                            SizedBox(width: 10),
                            Text(
                              'New Job Posting',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Fill in the details below. Your job will be visible after approval.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _sectionHeader('Job Information', Icons.info_outline),
                  const SizedBox(height: 14),
                  _buildField(
                    label: 'Job Title',
                    required: true,
                    child: _buildTextField(
                      controller: _titleController,
                      hint: 'e.g. Senior Software Engineer',
                      icon: Icons.work_outline,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Job title is required' : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    label: 'Company Name',
                    required: true,
                    child: _buildTextField(
                      controller: _companyController,
                      hint: 'e.g. Google',
                      icon: Icons.business_outlined,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Company name is required' : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    label: 'Location',
                    required: true,
                    child: _buildTextField(
                      controller: _locationController,
                      hint: 'e.g. Beirut, Lebanon',
                      icon: Icons.location_on_outlined,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Location is required' : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _sectionHeader('Job Details', Icons.tune_outlined),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildField(
                          label: 'Category',
                          required: true,
                          child: _buildDropdown(
                            value: _selectedCategory,
                            hint: 'Select category',
                            icon: Icons.category_outlined,
                            items: categoryLabels.entries
                                .map((e) => DropdownMenuItem(
                                    value: e.key,
                                    child: Text(e.value,
                                        style: const TextStyle(fontSize: 13))))
                                .toList(),
                            onChanged: (v) => setState(() => _selectedCategory = v),
                            validator: (v) => v == null ? 'Required' : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildField(
                          label: 'Job Type',
                          required: true,
                          child: _buildDropdown(
                            value: _selectedJobType,
                            hint: 'Select type',
                            icon: Icons.access_time_outlined,
                            items: jobTypes
                                .map((t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(t,
                                        style: const TextStyle(fontSize: 13))))
                                .toList(),
                            onChanged: (v) => setState(() => _selectedJobType = v),
                            validator: (v) => v == null ? 'Required' : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    label: 'Salary',
                    required: false,
                    child: _buildTextField(
                      controller: _salaryController,
                      hint: 'e.g. \$2,000 - \$3,000 / month',
                      icon: Icons.attach_money_outlined,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _sectionHeader('Job Description', Icons.description_outlined),
                  const SizedBox(height: 14),
                  _buildField(
                    label: 'Description',
                    required: true,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(10),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _descriptionController,
                        maxLines: 7,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Description is required' : null,
                        decoration: InputDecoration(
                          hintText: 'Describe responsibilities, requirements, benefits...',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                          contentPadding: const EdgeInsets.all(16),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── CONFIRM BUTTON → now calls _checkProfileAndSubmit ──
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _checkProfileAndSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4D6EDB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.cloud_upload_outlined, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Confirm & Post Job',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF1FB),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF4D6EDB)),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        const SizedBox(width: 10),
        Expanded(child: Container(height: 1, color: Colors.grey.shade200)),
      ],
    );
  }

  Widget _buildField({
    required String label,
    required bool required,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87)),
            if (required) ...[
              const SizedBox(width: 3),
              const Text('*',
                  style: TextStyle(color: Color(0xFF4D6EDB), fontSize: 13)),
            ] else ...[
              const SizedBox(width: 6),
              Text('(optional)',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
            ],
          ],
        ),
        const SizedBox(height: 7),
        child,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          prefixIcon: Icon(icon,
              color: const Color(0xFF4D6EDB).withAlpha(160), size: 18),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        items: items,
        onChanged: onChanged,
        validator: validator,
        icon: const Icon(Icons.keyboard_arrow_down_rounded,
            color: Colors.grey, size: 20),
        decoration: InputDecoration(
          prefixIcon: Icon(icon,
              color: const Color(0xFF4D6EDB).withAlpha(160), size: 18),
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        ),
        dropdownColor: Colors.white,
        style: const TextStyle(color: Colors.black87, fontSize: 13),
        isExpanded: true,
      ),
    );
  }
}

// ─── SELLER PROFILE SETUP PAGE ────────────────────────────────────────────────

class _SellerProfileSetupPage extends StatefulWidget {
  const _SellerProfileSetupPage();

  @override
  State<_SellerProfileSetupPage> createState() => _SellerProfileSetupPageState();
}

class _SellerProfileSetupPageState extends State<_SellerProfileSetupPage> {
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

  Future<void> _searchProfile() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your seller name')));
      return;
    }
    setState(() { _isSearching = true; _searchDone = false; _profileFound = false; });
    try {
      final query = await FirebaseFirestore.instance
          .collection('sellers')
          .where('name', isEqualTo: name)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        setState(() {
          _existingDocId  = doc.id;
          _phoneCtrl.text = doc['phone'] ?? '';
          _emailCtrl.text = doc['email'] ?? '';
          _profileFound   = true;
          _searchDone     = true;
        });
        // Save to session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('session_seller_name', name);
      } else {
        setState(() {
          _profileFound  = false;
          _searchDone    = true;
          _existingDocId = null;
          _phoneCtrl.clear();
          _emailCtrl.clear();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Try again.')));
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _saveProfile() async {
    final name  = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final email = _emailCtrl.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and Phone are required')));
      return;
    }

    setState(() => _isSaving = true);
    try {
      final data = {
        'name':      name,
        'phone':     phone,
        'email':     email,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (_existingDocId != null) {
        await FirebaseFirestore.instance
            .collection('sellers')
            .doc(_existingDocId)
            .update(data);
      } else {
        await FirebaseFirestore.instance
            .collection('sellers')
            .add(data);
      }

      // Save to session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('session_seller_name', name);

      if (mounted) Navigator.pop(context, name); // return name to PostJobPage
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error saving profile')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7F9),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Seller Profile',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10)
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Row(children: [
                Icon(Icons.store_outlined, color: Color(0xFF4D6EDB)),
                SizedBox(width: 8),
                Text('Create / Update Profile',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50))),
              ]),
              const SizedBox(height: 8),
              const Text(
                'You need a seller profile to post jobs. Search your name or create a new one.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Name + Search
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Seller Name *',
                      prefixIcon: Icon(Icons.store_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _isSearching ? null : _searchProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4D6EDB),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isSearching
                      ? const SizedBox(
                          width: 20, height: 20,
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
                            : const Color(0xFF4D6EDB))
                        .withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: (_profileFound
                              ? const Color(0xFF27AE60)
                              : const Color(0xFF4D6EDB))
                          .withAlpha(80),
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
                          : const Color(0xFF4D6EDB),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _profileFound
                            ? 'Profile found! Tap confirm to continue.'
                            : 'No profile found. Fill details to create one.',
                        style: TextStyle(
                          fontSize: 13,
                          color: _profileFound
                              ? const Color(0xFF27AE60)
                              : const Color(0xFF4D6EDB),
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
                  labelText: 'WhatsApp / Phone *',
                  hintText: '+1 234 567 8900',
                  prefixIcon: Icon(Icons.phone_outlined,
                      color: Color(0xFF25D366)),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),

              // Email
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email (optional)',
                  hintText: 'you@example.com',
                  prefixIcon: Icon(Icons.email_outlined,
                      color: Color(0xFF4D6EDB)),
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
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(
                          _profileFound
                              ? 'Confirm & Continue'
                              : 'Create Profile & Continue',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4D6EDB),
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
}