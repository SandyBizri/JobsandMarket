import 'package:flutter/material.dart';

class JobDetailsPage extends StatelessWidget {
  final Map<String, dynamic> job;

  const JobDetailsPage({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final String title = job['title'] ?? 'Job Title';

    String company = "Unknown company";
    if (job['company'] != null) {
      company = job['company'] is Map
          ? job['company']['display_name'] ?? "Unknown company"
          : job['company'];
    }

    String location = "Unknown location";
    if (job['location'] != null) {
      location = job['location'] is Map
          ? job['location']['display_name'] ?? "Unknown location"
          : job['location'];
    }

    final String rawDescription =
        job['description'] ?? 'No description provided.';

    final List<String> paragraphs = rawDescription
        .split(RegExp(r'\n{1,}'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F6FA),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Job Details",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.75, // ✅ 75% width
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Header Card
                Container(
                  width: double.infinity,
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
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        company,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 18, color: Colors.grey),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              location,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // Job Description
                _sectionTitle("Job Description"),
                const SizedBox(height: 12),

                ...paragraphs.map((paragraph) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 6,
                          )
                        ],
                      ),
                      child: Text(
                        paragraph,
                        textAlign: TextAlign.justify,
                        style:
                            const TextStyle(height: 1.6, fontSize: 14),
                      ),
                    )),

                const SizedBox(height: 15),

                // Required Skills
                _sectionTitle("Required Skills"),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                      )
                    ],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkillRow(text: "Strong communication skills"),
                      _SkillRow(text: "Ability to work in a team"),
                      _SkillRow(text: "Time management"),
                      _SkillRow(text: "Problem-solving mindset"),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // Your Role
                _sectionTitle("Your Role"),
                const SizedBox(height: 12),
                _infoCard(
                  "You will collaborate with teams, contribute to projects, "
                  "and ensure professional task execution.",
                ),

                const SizedBox(height: 25),

                // Your Career
                _sectionTitle("Your Career"),
                const SizedBox(height: 12),
                _infoCard(
                  "This position offers growth opportunities, skill development, "
                  "and long-term career advancement.",
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _infoCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
          )
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.justify,
        style: const TextStyle(height: 1.6, fontSize: 14),
      ),
    );
  }
}

class _SkillRow extends StatelessWidget {
  final String text;
  const _SkillRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline,
              size: 18, color: Color(0xFF4D6EDB)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}