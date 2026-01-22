import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lms_pro/ApiHelper/apihelper.dart';

import 'subject_section_page.dart';

/// 🔥 SINGLE API SOURCE (without https://)
final String apiUrl = '${ApiHelper.baseUrl}';

class CourseSubjectPage extends StatefulWidget {
  final String courseId;

  const CourseSubjectPage({
    super.key,
    required this.courseId,
  });

  @override
  State<CourseSubjectPage> createState() => _CourseSubjectPageState();
}

class _CourseSubjectPageState extends State<CourseSubjectPage> {
  bool loading = true;
  bool error = false;
  List subjects = [];

  @override
  void initState() {
    super.initState();
    fetchSubjects();
  }

  Future<void> fetchSubjects() async {
    try {
      final url = Uri.parse(
        '${ApiHelper.baseUrl}/api/subjects/courses/${widget.courseId}',
      );

      final res = await http.get(
        url,
        headers: {"Accept": "application/json"},
      );

      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body);
        setState(() {
          subjects = jsonData["data"] ?? [];
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

  Widget subjectCard(Map s) {
    final subjectId = (s["subject_id"] ?? s["id"]).toString();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SubjectSectionPage(
              subjectId: subjectId,
              subjectName: s["subject_name"] ?? "Subject",
            ),
          ),
        );
      },
      child: Container(
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
              Icons.book,
              size: 28,
              color: isDark ? Colors.deepPurpleAccent : Colors.deepPurple,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s["subject_name"] ?? "Subject",
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xfff5f5f5),
      appBar: AppBar(
        title: const Text("Course Subjects"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error
          ? const Center(child: Text("Failed to load subjects"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: subjects.length,
        itemBuilder: (_, i) => subjectCard(subjects[i]),
      ),
    );
  }
}
