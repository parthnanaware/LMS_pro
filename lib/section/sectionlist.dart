import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lms_pro/ApiHelper/apihelper.dart';
import 'package:lms_pro/session/sessionlist.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SectionListPage extends StatefulWidget {
  final int courseId;   // ✅ ADD
  final int subjectId;
  final String subjectName;

  const SectionListPage({
    super.key,
    required this.courseId,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  State<SectionListPage> createState() => _SectionListPageState();
}

class _SectionListPageState extends State<SectionListPage> {
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
      final res = await ApiHelper()
          .httpGet("subjects/${widget.subjectId}/sections");

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        sections = data["data"] ?? [];
      } else {
        error = true;
      }
    } catch (e) {
      error = true;
    }

    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.subjectName)),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error
          ? const Center(child: Text("Failed to load sections"))
          : sections.isEmpty
          ? const Center(child: Text("No sections found"))
          : ListView.builder(
        itemCount: sections.length,
        itemBuilder: (_, i) {
          final s = sections[i];

          return ListTile(
            title: Text(s["section_name"] ?? "Untitled"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {
              final prefs =
              await SharedPreferences.getInstance();
              final userId =
              int.parse(prefs.getString("userId") ?? "0");

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SessionListPage(
                    userId: userId,
                    courseId: widget.courseId,   // ✅ PASS
                    subjectId: widget.subjectId, // ✅ PASS
                    sectionId:
                    int.parse(s["section_id"].toString()),
                    sectionName: s["section_name"],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
