import 'package:flutter/material.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("About App"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor:
                    isDark ? Colors.deepPurpleAccent : Colors.deepPurple,
                    child: const Icon(
                      Icons.school,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "LMS Pro",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Version 1.0.0",
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            _infoTile(
              context,
              title: "About",
              description:
              "LMS Pro is a modern learning management system designed to provide students with structured courses, subjects, and sections in a simple and user-friendly way.",
            ),
            const SizedBox(height: 16),

            _infoTile(
              context,
              title: "Features",
              description:
              "• Course & Subject Management\n"
                  "• Section-wise Learning\n"
                  "• Secure Authentication\n"
                  "• Dark Mode Support\n"
                  "• Fast & Reliable API",
            ),
            const SizedBox(height: 16),

            _infoTile(
              context,
              title: "Developer",
              description: "Developed by Parth Nanaware",
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(
      BuildContext context, {
        required String title,
        required String description,
      }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
