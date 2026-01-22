import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section(
              IconsaxPlusLinear.shield_tick,
              "Your Privacy",
                "We respect your privacy and protect your personal information at all times.",
            ),
            _section(
              IconsaxPlusLinear.user,
              "Information We Collect",
              "• Name and Email\n• Login sessions\n• Device and IP address",
            ),
            _section(
              IconsaxPlusLinear.lock,
              "Security",
              "Your data is encrypted and never shared with third parties.",
            ),
            _section(
              IconsaxPlusLinear.trash,
              "Data Removal",
              "You may request account deletion at any time.",
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                "Last updated: January 2026",
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(IconData icon, String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
