import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'job_details_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'post_job_page.dart';
import 'shared_paywall.dart';

class JobsPage extends StatefulWidget {
  final String uid;
  final bool paid;

  const JobsPage({super.key, required this.uid, required this.paid});

  @override
  JobsPageState createState() => JobsPageState();
}
class JobsPageState extends State<JobsPage> {
  List jobs = [];
  List filteredJobs = [];
  bool isLoading = true;
  String? selectedCountry;
  String? selectedCategory;
  bool _paid = false;
  int _searchAttempts = 0;

  // ─── SEARCH ───────────────────────────────────────────────
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  List<String> searchSuggestions = [];
  bool showSuggestions = false;

  final List<String> categories = [
    'software-dev',
    'customer-support',
    'design',
    'marketing',
    'sales',
    'product',
    'business',
    'data',
    'devops-sysadmin',
    'finance-legal',
    'hr',
    'qa',
    'writing',
    'teaching',
    'cyber-security',
    'accounting',
    'healthcare',
    'engineering',
    'administration',
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

  final List<Map<String, String>> lebanonQueries = [
    {'query': 'software developer Lebanon',  'category': 'software-dev'},
    {'query': 'customer support Lebanon',    'category': 'customer-support'},
    {'query': 'graphic designer Lebanon',    'category': 'design'},
    {'query': 'marketing Lebanon',           'category': 'marketing'},
    {'query': 'business analyst Lebanon',    'category': 'business'},
    {'query': 'data analyst Lebanon',        'category': 'data'},
    {'query': 'devops engineer Lebanon',     'category': 'devops-sysadmin'},
    {'query': 'finance accounting Lebanon',  'category': 'finance-legal'},
    {'query': 'human resources Lebanon',     'category': 'hr'},
    {'query': 'teacher Lebanon',             'category': 'teaching'},
    {'query': 'cyber security Lebanon',      'category': 'cyber-security'},
    {'query': 'nurse hospital Lebanon',      'category': 'healthcare'},
    {'query': 'engineer Lebanon',            'category': 'engineering'},
  ];

  final List<Map<String, String>> saudiQueries = [
    {'query': 'software developer Saudi Arabia',  'category': 'software-dev'},
    {'query': 'customer support Saudi Arabia',    'category': 'customer-support'},
    {'query': 'marketing Saudi Arabia',           'category': 'marketing'},
    {'query': 'business analyst Saudi Arabia',    'category': 'business'},
    {'query': 'data analyst Saudi Arabia',        'category': 'data'},
    {'query': 'finance accounting Saudi Arabia',  'category': 'finance-legal'},
    {'query': 'human resources Saudi Arabia',     'category': 'hr'},
    {'query': 'nurse hospital Saudi Arabia',      'category': 'healthcare'},
    {'query': 'engineer Saudi Arabia',            'category': 'engineering'},
  ];

  final List<Map<String, String>> qatarQueries = [
    {'query': 'software developer Qatar Doha',   'category': 'software-dev'},
    {'query': 'customer support Qatar Doha',     'category': 'customer-support'},
    {'query': 'marketing Qatar Doha',            'category': 'marketing'},
    {'query': 'business analyst Qatar Doha',     'category': 'business'},
    {'query': 'data analyst Qatar Doha',         'category': 'data'},
    {'query': 'finance accounting Qatar Doha',   'category': 'finance-legal'},
    {'query': 'human resources Qatar Doha',      'category': 'hr'},
    {'query': 'nurse hospital Qatar Doha',       'category': 'healthcare'},
    {'query': 'engineer Qatar Doha',             'category': 'engineering'},
  ];

  @override
  void initState() {
    super.initState();
    _paid = widget.paid;
    fetchAllJobs();
    _initAccessTracking();
  }

  Future<void> _initAccessTracking() async {
    final ref = FirebaseFirestore.instance.collection('sellers').doc(widget.uid);
    final snap = await ref.get();
    final attempts = (snap.data()?['jobsSearchAttempts'] ?? 0) as int;

    if (!_paid) {
      await ref.set(
        {'jobsPageVisits': FieldValue.increment(1)},
        SetOptions(merge: true),
      );
    }

    if (mounted) setState(() => _searchAttempts = attempts);
  }
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchAllJobs() async {
    List allJobs = [];

    // ─── REMOTIVE ─────────────────────────────────────────────
    try {
      for (var category in categories) {
        final url = Uri.parse(
          'https://remotive.com/api/remote-jobs?category=$category&limit=20',
        );
        try {
          final response = await http.get(url);
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final results = data['jobs'] ?? [];
            for (var job in results) {
              String description = job['description'] ?? 'No description available';
              description = _cleanHtml(description);
              allJobs.add({
                'title': job['title'] ?? 'No title',
                'company': job['company_name'] ?? 'Unknown company',
                'location': job['candidate_required_location'] ?? 'Worldwide',
                'description': description,
                'category': category,
                'job_type': job['job_type'] ?? '',
                'salary': job['salary'] ?? '',
                'job_url': job['url'] ?? '',
              });
            }
          }
        } catch (e) {
          debugPrint('Remotive error for $category: $e');
        }
        await Future.delayed(const Duration(milliseconds: 200));
      }
    } catch (e) {
      debugPrint('Remotive fetch error: $e');
    }

    // ─── ARBEITNOW ────────────────────────────────────────────
   /* try {
      final response = await http.get(
        Uri.parse('https://arbeitnow.com/api/job-board-api'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['data'] ?? [];
        for (var job in results) {
          final rawLocation = (job['location'] ?? '').toString();
          final tags = (job['tags'] as List?)
                  ?.map((t) => t.toString().toLowerCase())
                  .toList() ??
              [];
          final category = _mapTagsToCategory(tags);
          String description = job['description'] ?? 'No description';
          description = _cleanHtml(description);
          allJobs.add({
            'title': job['title'] ?? 'No title',
            'company': job['company_name'] ?? 'Unknown company',
            'location': rawLocation.isNotEmpty ? rawLocation : 'Worldwide',
            'description': description,
            'category': category,
            'job_type': (job['remote'] == true) ? 'Remote' : 'On-site',
            'salary': '',
            'job_url': job['url'] ?? '',
          });
        }
      }
    } catch (e) {
      debugPrint('Arbeitnow error: $e');
    } */

    // ─── JOBICY ───────────────────────────────────────────────
    try {
      final response = await http.get(
        Uri.parse('https://jobicy.com/api/v2/remote-jobs?count=50'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['jobs'] ?? [];
        for (var job in results) {
          final rawGeo = (job['jobGeo'] ?? '').toString();
          final jobTitle = (job['jobTitle'] ?? '').toString().toLowerCase();
          final category = _mapTitleToCategory(jobTitle);
          String description = job['jobDescription'] ?? 'No description available';
          description = _cleanHtml(description);
          allJobs.add({
            'title': job['jobTitle'] ?? 'No title',
            'company': job['companyName'] ?? 'Unknown company',
            'location': rawGeo.isNotEmpty ? rawGeo : 'Worldwide',
            'description': description,
            'category': category,
            'job_type': (job['jobType'] ?? '').toString(),
            'salary': job['annualSalaryMin'] != null
                ? '\$${job['annualSalaryMin']} - \$${job['annualSalaryMax']}'
                : '',
            'job_url': job['url'] ?? '',
          });
        }
      }
    } catch (e) {
      debugPrint('Jobicy error: $e');
    }

    // ─── LEBANON (JSearch) ────────────────────────────────────
    final lebanonJobs = await fetchCountryJobs(
      queries: lebanonQueries,
      countryLabel: 'Lebanon',
    );
    allJobs.addAll(lebanonJobs);

    // ─── SAUDI ARABIA (JSearch) ───────────────────────────────
    final saudiJobs = await fetchCountryJobs(
      queries: saudiQueries,
      countryLabel: 'Saudi Arabia',
    );
    allJobs.addAll(saudiJobs);

    // ─── QATAR (JSearch) ─────────────────────────────────────
    final qatarJobs = await fetchCountryJobs(
      queries: qatarQueries,
      countryLabel: 'Qatar',
    );
    allJobs.addAll(qatarJobs);

    // ─── POSTED JOBS (Firestore) ──────────────────────────
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('jobs')
          .where('approved', isEqualTo: 1)
          .orderBy('posted_at', descending: true)
          .get();

      final postedJobs = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'title': data['title'] ?? 'No title',
          'company': data['company'] ?? 'Unknown company',
          'location': data['location'] ?? 'Worldwide',
          'description': data['description'] ?? 'No description',
          'category': data['category'] ?? 'business',
          'job_type': data['job_type'] ?? '',
          'salary': data['salary'] ?? '',
          'job_url': data['job_url'] ?? '',
          'source': 'posted',
          'posted_at': data['posted_at'] != null
              ? (data['posted_at'] as Timestamp).toDate().toString().substring(0, 10)
              : '',
        };
      }).toList();

      allJobs.insertAll(0, postedJobs);
    } catch (e) {
      debugPrint('Firestore fetch error: $e');
    }

    setState(() {
      jobs = allJobs;
      filteredJobs = allJobs;
      isLoading = false;
    });
  }

  Future<void> fetchPostedJobs() async {
    try {
     final snapshot = await FirebaseFirestore.instance
          .collection('jobs')
          .where('approved', isEqualTo: 1)
          .orderBy('posted_at', descending: true)
          .get();

      final postedJobs = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'title': data['title'] ?? 'No title',
          'company': data['company'] ?? 'Unknown company',
          'location': data['location'] ?? 'Worldwide',
          'description': data['description'] ?? 'No description',
          'category': data['category'] ?? 'business',
          'job_type': data['job_type'] ?? '',
          'salary': data['salary'] ?? '',
          'job_url': data['job_url'] ?? '',
          'source': 'posted',
          'posted_at': data['posted_at'] != null
              ? (data['posted_at'] as Timestamp).toDate().toString().substring(0, 10)
              : '',
        };
      }).toList();


      setState(() {
        // Remove old posted jobs first to avoid duplicates
        jobs.removeWhere((j) => j['source'] == 'posted');
        jobs.insertAll(0, postedJobs);
        filteredJobs = jobs;
      });
    } catch (e) {
      debugPrint('Firestore fetch error: $e');
    }
  }

  // ─── FILTER + SEARCH LOGIC ────────────────────────────────

  void _runFilter() {
  filteredJobs = jobs.where((job) {
    final locationMatch = selectedCountry == null ||
        (job['location'] ?? '').toLowerCase().contains(selectedCountry!.toLowerCase());
    final categoryMatch = selectedCategory == null ||
        (job['category'] ?? '').toLowerCase() == selectedCategory!.toLowerCase();
    final searchMatch = searchQuery.isEmpty ||
        (job['title'] ?? '').toLowerCase().contains(searchQuery) ||
        (job['company'] ?? '').toLowerCase().contains(searchQuery) ||
        (job['location'] ?? '').toLowerCase().contains(searchQuery) ||
        (job['description'] ?? '').toLowerCase().contains(searchQuery) ||
        (categoryLabels[job['category']] ?? '').toLowerCase().contains(searchQuery);
    return locationMatch && categoryMatch && searchMatch;
  }).toList();
}
  void applyFilters({String? country, String? category}) {
    setState(() {
      if (country != null) selectedCountry = country;
      if (category != null) selectedCategory = category;
      _runFilter();
    });
  }

  void clearFilters() {
    setState(() {
      selectedCountry = null;
      selectedCategory = null;
      searchQuery = '';
      searchController.clear();
      showSuggestions = false;
      searchSuggestions = [];
      filteredJobs = jobs;
    });
  }

  void _onSearchChanged(String value) async {
  final query = value.toLowerCase().trim();

  if (!_paid && query.isNotEmpty && searchQuery.isEmpty) {
    if (_searchAttempts >= 2) {
      searchController.clear();
      showPaywallDialog(context);
      return;
    }
    _searchAttempts++;
    await FirebaseFirestore.instance
        .collection('sellers')
        .doc(widget.uid)
        .set({'jobsSearchAttempts': FieldValue.increment(1)}, SetOptions(merge: true));
  }

  setState(() {
    searchQuery = query;
    _runFilter();
    if (query.isEmpty) {
      showSuggestions = false;
      searchSuggestions = [];
    } else {
      final Set<String> seen = {};
      final List<String> suggestions = [];

      for (var job in jobs) {
        final title = (job['title'] ?? '').toString().trim();
        final company = (job['company'] ?? '').toString().trim();
        final location = (job['location'] ?? '').toString().trim();

        for (final candidate in [title, company, location]) {
          if (candidate.isEmpty) continue;
          final candidateLower = candidate.toLowerCase();
          // ✅ Skip if doesn't match query
          if (!candidateLower.contains(query)) continue;
          // ✅ Deduplicate: normalize to lowercase for comparison
          if (seen.contains(candidateLower)) continue;
          seen.add(candidateLower);
          suggestions.add(candidate);
          if (suggestions.length >= 5) break;
        }
        if (suggestions.length >= 5) break;
      }

      searchSuggestions = suggestions;
      showSuggestions = suggestions.isNotEmpty;
    }
  });
}

  void _onSuggestionTapped(String suggestion) {
    searchController.text = suggestion;
    setState(() {
      searchQuery = suggestion.toLowerCase();
      showSuggestions = false;
      searchSuggestions = [];
      _runFilter();
    });
  }

 /* String _mapTagsToCategory(List<String> tags) {
    if (tags.any((t) => t.contains('software') || t.contains('developer') || t.contains('frontend') || t.contains('backend'))) { return 'software-dev'; }
    if (tags.any((t) => t.contains('design') || t.contains('ui') || t.contains('ux'))) { return 'design'; }
    if (tags.any((t) => t.contains('marketing') || t.contains('seo'))) { return 'marketing'; }
    if (tags.any((t) => t.contains('data') || t.contains('analyst') || t.contains('analytics'))) { return 'data'; }
    if (tags.any((t) => t.contains('devops') || t.contains('cloud'))) { return 'devops-sysadmin'; }
    if (tags.any((t) => t.contains('cyber') || t.contains('security'))) { return 'cyber-security'; }
    if (tags.any((t) => t.contains('finance') || t.contains('legal'))) { return 'finance-legal'; }
    if (tags.any((t) => t.contains('accounting') || t.contains('accountant'))) { return 'accounting'; }
    if (tags.any((t) => t.contains('hr') || t.contains('human resources'))) { return 'hr'; }
    if (tags.any((t) => t.contains('sales') || t.contains('business development'))) { return 'sales'; }
    if (tags.any((t) => t.contains('engineer') || t.contains('engineering'))) { return 'engineering'; }
    if (tags.any((t) => t.contains('health') || t.contains('medical') || t.contains('nurse'))) { return 'healthcare'; }
    if (tags.any((t) => t.contains('product') || t.contains('project'))) { return 'product'; }
    if (tags.any((t) => t.contains('support') || t.contains('customer'))) { return 'customer-support'; }
    if (tags.any((t) => t.contains('admin') || t.contains('administration'))) { return 'administration'; }
    if (tags.any((t) => t.contains('writing') || t.contains('content') || t.contains('copy'))) { return 'writing'; }
    if (tags.any((t) => t.contains('teach') || t.contains('education'))) { return 'teaching'; }
    if (tags.any((t) => t.contains('qa') || t.contains('quality'))) { return 'qa'; }
    return 'business';
  }*/

  String _mapTitleToCategory(String title) {
    if (title.contains('software') || title.contains('developer') || title.contains('frontend') || title.contains('backend') || title.contains('fullstack')) { return 'software-dev'; }
    if (title.contains('design') || title.contains('ui') || title.contains('ux')) { return 'design'; }
    if (title.contains('market') || title.contains('seo') || title.contains('social media')) { return 'marketing'; }
    if (title.contains('data') || title.contains('analyst') || title.contains('analytics')) { return 'data'; }
    if (title.contains('devops') || title.contains('cloud')) { return 'devops-sysadmin'; }
    if (title.contains('cyber') || title.contains('security')) { return 'cyber-security'; }
    if (title.contains('financ') || title.contains('legal')) { return 'finance-legal'; }
    if (title.contains('account')) { return 'accounting'; }
    if (title.contains('hr') || title.contains('human resource') || title.contains('recruiter')) { return 'hr'; }
    if (title.contains('sales') || title.contains('business dev')) { return 'sales'; }
    if (title.contains('health') || title.contains('medical') || title.contains('nurse') || title.contains('doctor')) { return 'healthcare'; }
    if (title.contains('engineer')) { return 'engineering'; }
    if (title.contains('product') || title.contains('project manager')) { return 'product'; }
    if (title.contains('support') || title.contains('customer')) { return 'customer-support'; }
    if (title.contains('writ') || title.contains('content') || title.contains('copy')) { return 'writing'; }
    if (title.contains('teach') || title.contains('tutor') || title.contains('education')) { return 'teaching'; }
    if (title.contains('admin') || title.contains('administration') || title.contains('secretary')) { return 'administration'; }
    if (title.contains('qa') || title.contains('quality')) { return 'qa'; }
    return 'business';
  }

  Future<List> fetchCountryJobs({
    required List<Map<String, String>> queries,
    required String countryLabel,
  }) async {
    List allJobs = [];
    final Set<String> seenTitles = {};

    for (var item in queries) {
      final query = item['query']!;
      final category = item['category']!;

      try {
        final encodedQuery = Uri.encodeComponent(query);
        final url = Uri.parse(
          'https://jsearch.p.rapidapi.com/search-v2?query=$encodedQuery&num_pages=1&page=1',
        );
        final response = await http.get(url, headers: {
          
          'X-RapidAPI-Key': '',
          'X-RapidAPI-Host': 'jsearch.p.rapidapi.com',
        });

        /*if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (query == 'software developer Lebanon') {
            final preview = response.body.length > 500
                ? response.body.substring(0, 500)
                : response.body;
            debugPrint('=== JSEARCH PREVIEW START ===');
            debugPrint(preview);
            debugPrint('=== JSEARCH PREVIEW END ===');
          }
          final results = data['data'] ?? [];*/
          if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final results = data['data']?['jobs'] ?? [];
          for (var job in results) {
            final title = job['job_title'] ?? 'No title';
            final company = job['employer_name'] ?? 'Unknown company';
            final key = '$title-$company'.toLowerCase();
            if (seenTitles.contains(key)) continue;
            seenTitles.add(key);
            String description = job['job_description'] ?? 'No description available';
            description = _cleanHtml(description);
            allJobs.add({
              'title': title,
              'company': company,
              'location': countryLabel,
              'description': description,
              'category': category,
              'job_type': job['job_employment_type'] ?? '',
              'salary': '',
              'job_url': job['job_apply_link'] ?? '',
            });
          }
        } else {
          debugPrint('JSearch failed for "$query": ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        debugPrint('Fetch error for "$query": $e');
      }
      await Future.delayed(const Duration(milliseconds: 300));
    }
    return allJobs;
  }

  String _cleanHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .trim();
  }

  List<String> get availableCountries {
    final Set<String> countries = {};
    for (var job in jobs) {
      final location = (job['location'] ?? '').trim();
      if (location.isNotEmpty) countries.add(location);
    }
    countries.addAll(['Lebanon', 'Qatar', 'Saudi Arabia']);
    final list = countries.toList()..sort();
    return list;
  }

  void showCountryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Select a Country",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        if (selectedCountry != null)
                          TextButton.icon(
                            onPressed: () {
                              setState(() => selectedCountry = null);
                              applyFilters();
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.refresh, size: 16, color: Color(0xFF4D6EDB)),
                            label: const Text("Clear", style: TextStyle(color: Color(0xFF4D6EDB), fontWeight: FontWeight.w600)),
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: availableCountries.length,
                      separatorBuilder: (_, _) => const Divider(height: 1, indent: 20),
                      itemBuilder: (context, index) {
                        final country = availableCountries[index];
                        final isSelected = selectedCountry == country;
                        return ListTile(
                          onTap: () {
                            applyFilters(country: country);
                            Navigator.pop(context);
                          },
                          leading: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? const Color(0xFF4D6EDB) : Colors.transparent,
                              border: Border.all(
                                color: isSelected ? const Color(0xFF4D6EDB) : Colors.grey.shade400,
                                width: 2,
                              ),
                            ),
                            child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                          ),
                          title: Text(
                            country,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected ? const Color(0xFF4D6EDB) : Colors.black87,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Select a Category",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        if (selectedCategory != null)
                          TextButton.icon(
                            onPressed: () {
                              setState(() => selectedCategory = null);
                              applyFilters();
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.refresh, size: 16, color: Color(0xFF4D6EDB)),
                            label: const Text("Clear", style: TextStyle(color: Color(0xFF4D6EDB), fontWeight: FontWeight.w600)),
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: categories.length,
                      separatorBuilder: (_, _) => const Divider(height: 1, indent: 20),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final label = categoryLabels[category] ?? category;
                        final isSelected = selectedCategory == category;
                        return ListTile(
                          onTap: () {
                            applyFilters(category: category);
                            Navigator.pop(context);
                          },
                          leading: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? const Color(0xFF4D6EDB) : Colors.transparent,
                              border: Border.all(
                                color: isSelected ? const Color(0xFF4D6EDB) : Colors.grey.shade400,
                                width: 2,
                              ),
                            ),
                            child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                          ),
                          title: Text(
                            label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected ? const Color(0xFF4D6EDB) : Colors.black87,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // ✅ Dismiss suggestions when tapping outside
        if (showSuggestions) {
          setState(() => showSuggestions = false);
        }
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F9),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F7F9),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Job Opportunities",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        body: isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text("Fetching job opportunities...",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 6),
                    Text("This may take a few seconds.",
                        style: TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                ),
              )
            : jobs.isEmpty
                ? const Center(child: Text("No jobs available"))
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      children: [

                        // ─── SEARCH BAR ───────────────────────────────────
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: searchQuery.isNotEmpty
                                  ? const Color(0xFF4D6EDB)
                                  : Colors.grey.shade300,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(13),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search,
                                  color: searchQuery.isNotEmpty
                                      ? const Color(0xFF4D6EDB)
                                      : Colors.grey.shade400,
                                  size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: searchController,
                                  onChanged: _onSearchChanged,
                                  decoration: InputDecoration(
                                    hintText: 'Search jobs, companies, locations...',
                                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                ),
                              ),
                              if (searchQuery.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    searchController.clear();
                                    _onSearchChanged('');
                                  },
                                  child: Icon(Icons.close, color: Colors.grey.shade400, size: 18),
                                ),
                            ],
                          ),
                        ),

                        // ─── SUGGESTIONS DROPDOWN ─────────────────────────
                        if (showSuggestions)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(18),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: searchSuggestions.asMap().entries.map((entry) {
                                final index = entry.key;
                                final suggestion = entry.value;
                                final isLast = index == searchSuggestions.length - 1;
                                return InkWell(
                                  onTap: () => _onSuggestionTapped(suggestion),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                                    decoration: BoxDecoration(
                                      border: isLast
                                          ? null
                                          : Border(bottom: BorderSide(color: Colors.grey.shade100, width: 1)),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.history, size: 15, color: Colors.grey.shade400),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            suggestion,
                                            style: const TextStyle(fontSize: 13, color: Colors.black87),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Icon(Icons.north_west, size: 14, color: Colors.grey.shade400),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                        const SizedBox(height: 12),

                        // ─── POST + CATEGORIES ────────────────────────────
                        Row(
                          children: [
                           Expanded(
                             child: _actionButton("POST", () async {
                               if (!_paid) {
                                 showPaywallDialog(context);
                                 return;
                               }
                               final result = await Navigator.push(
                                  context,
                               MaterialPageRoute(builder: (context) => const PostJobPage()),
                                                                  );
                                  if (result == true) {
                                    setState(() => isLoading = true);
                                      await fetchPostedJobs();
                                      setState(() => isLoading = false);
                                                     }
                                            }),
                                    ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _actionButton(
                                selectedCategory == null
                                    ? "CATEGORIES"
                                    : categoryLabels[selectedCategory] ?? selectedCategory!,
                                showCategoryPicker,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),

                        // ─── ACTIVE FILTER CHIPS ──────────────────────────
                        if (selectedCountry != null || selectedCategory != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                if (selectedCountry != null)
                                  _filterChip(selectedCountry!, () {
                                    setState(() => selectedCountry = null);
                                    applyFilters();
                                  }),
                                if (selectedCountry != null && selectedCategory != null)
                                  const SizedBox(width: 8),
                                if (selectedCategory != null)
                                  _filterChip(
                                    categoryLabels[selectedCategory] ?? selectedCategory!,
                                    () {
                                      setState(() => selectedCategory = null);
                                      applyFilters();
                                    },
                                  ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: clearFilters,
                                  child: const Text(
                                    "Clear all",
                                    style: TextStyle(
                                      color: Color(0xFF4D6EDB),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // ─── COUNTRY DROPDOWN ─────────────────────────────
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.30,
                              child: GestureDetector(
                                onTap: showCountryPicker,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: selectedCountry == null ? Colors.white : const Color(0xFFEEF1FB),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: selectedCountry == null ? Colors.grey.shade300 : const Color(0xFF4D6EDB),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(13),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.public, size: 15,
                                          color: selectedCountry == null ? Colors.grey : const Color(0xFF4D6EDB)),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          selectedCountry ?? "Country",
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: selectedCountry == null ? Colors.grey.shade600 : const Color(0xFF4D6EDB),
                                            fontWeight: selectedCountry == null ? FontWeight.normal : FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Icon(Icons.keyboard_arrow_down_rounded,
                                          color: selectedCountry == null ? Colors.grey : const Color(0xFF4D6EDB),
                                          size: 18),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (selectedCountry != null) ...[
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  setState(() => selectedCountry = null);
                                  applyFilters();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: Colors.grey, size: 14),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 15),

                        // ─── JOB LIST ─────────────────────────────────────
                        Expanded(
                          child: filteredJobs.isEmpty
                              ? const Center(
                                  child: Text("No jobs found for this filter",
                                      style: TextStyle(color: Colors.grey)),
                                )
                              : ListView.builder(
                                  itemCount: filteredJobs.length,
                                  itemBuilder: (context, index) {
                                    return _jobCard(context, filteredJobs[index]);
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _filterChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF1FB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF4D6EDB), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF4D6EDB), fontWeight: FontWeight.w600)),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 14, color: Color(0xFF4D6EDB)),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String label, VoidCallback? onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6EC1FF),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label, overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _jobCard(BuildContext context, Map<String, dynamic> job) {
    const Color darkerBlue = Color(0xFF4D6EDB);
    final String title = job['title'] ?? 'No title';
    final String company = job['company'] ?? 'Unknown company';
    final String location = job['location'] ?? 'Worldwide';
    final String description = job['description'] ?? 'No description';
    final String category = job['category'] ?? '';
    final String jobType = job['job_type'] ?? '';
    final String salary = job['salary'] ?? '';
    final String postedAt = job['posted_at'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text("Company: $company"),
          Text("Location: $location"),
          if (category.isNotEmpty)
            Text("Category: ${categoryLabels[category] ?? category}",
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          if (jobType.isNotEmpty)
            Text("Type: $jobType", style: const TextStyle(color: Colors.grey, fontSize: 12)),
          if (salary.isNotEmpty)
            Text("Salary: $salary",
                style: const TextStyle(color: Color(0xFF4D6EDB), fontSize: 12, fontWeight: FontWeight.w500)),
          if (postedAt.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 12, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Text(
                    'Posted: $postedAt',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 15),
          OutlinedButton(
            onPressed: () {
              if (!_paid) {
                showPaywallDialog(context);
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JobDetailsPage(
                    job: {
                      'title': title,
                      'company': company,
                      'location': location,
                      'description': description,
                    },
                  ),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(width: 2, color: darkerBlue),
              foregroundColor: darkerBlue,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("View Job", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
