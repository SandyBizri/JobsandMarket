import 'package:flutter/material.dart';
const List<String> premiumFeatures = [
  '✓ Search jobs by job title, company, or location',
  '✓ Post a job vacancy',
  '✓ View full job details for every listing',
  '✓ Browse jobs from 25+ countries worldwide',
  '✓ Filter by 19+ job categories',
  '✓ See salary, job type, and posting date details',
  '✓ jobs updates continously',
];

void showPaywallDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.lock_outline, color: Color(0xFF2B4EDB)),
          SizedBox(width: 8),
          Text('Premium Access',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
      content: SingleChildScrollView(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF3FC),
              borderRadius: BorderRadius.circular(12),
            ),
            child:  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('💰 Premium Access: \$4/month',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                SizedBox(height: 10),
                // ─── FEATURE LIST (NEW — placed before "Pay through") ───
                  ...premiumFeatures.map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(f, style: const TextStyle(fontSize: 13)),
                    ),
                  ),
                  const SizedBox(height: 6),
                Text('Pay through:', style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Text('• OMT\n• Wish Money\n• Western Union'),
                SizedBox(height: 10),
                Text('Recipient Name:', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('Mohamad Alwan'),
                SizedBox(height: 10),
                Text('Wallet account of the Number:', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('+961 71 108 823'),
                SizedBox(height: 10),
                Text('After payment, send screenshot to:',
                  style: TextStyle(fontWeight: FontWeight.w600)),
                Text('WhatsApp: +961 71 108 823'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '⏳ Your access will be activated after payment verification.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close', style: TextStyle(color: Colors.grey)),
        ),
      ],
    ),
  );
}