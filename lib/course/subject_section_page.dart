import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Same API host without https://
const String API_HOST = "f71ed3300e16.ngrok-free.app";

class SubjectSectionPage extends StatefulWidget {
  final String subjectId;
  final String subjectName;

  const SubjectSectionPage({
    super.key,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  State<SubjectSectionPage> createState() => _SubjectSectionPageState();
}

class _SubjectSectionPageState extends State<SubjectSectionPage> {
  bool loading = true;
  bool error = false;
  List sections = [];

  @override
  void initState() {
    super.initState();
    fetchSections();
  }

  Future<void> fetchSections() async {
    try {
      final url = Uri.https(
        API_HOST,
        "/api/sections/by-subject/${widget.subjectId}",
      );

      final res = await http.get(url, headers: {
        "Accept": "application/json",
      });

      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body);
        setState(() {
          sections = jsonData["data"] ?? [];
          loading = false;
        });
      } else {
        setState(() {
          error = true;
          loading = false;
        });
      }
    } catch (_) {
      setState(() {
        error = true;
        loading = false;
      });
    }
  }

  Widget sectionCard(Map s) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : const [
          BoxShadow(color: Colors.black12, blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.menu_book,
            size: 28,
            color: isDark ? Colors.deepPurpleAccent : Colors.deepPurple,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s["section_name"] ?? "Section",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  s["description"] ?? "",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: isDark ? Colors.white54 : Colors.black54,
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xfff5f5f5),
      appBar: AppBar(
        title: Text(widget.subjectName),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error
          ? const Center(child: Text("Failed to load sections"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sections.length,
        itemBuilder: (_, i) => sectionCard(sections[i]),
      ),
    );
  }
}
