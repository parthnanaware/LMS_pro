import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// 🔥 SINGLE API SOURCE  remove https://
const String API_HOST = "82e50f0ae86b.ngrok-free.app";

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
      final url = Uri.https(
        API_HOST,
        "/api/subjects/courses/${widget.courseId}",
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
    final imageUrl =
    (s["subject_img"] != null && s["subject_img"].toString().isNotEmpty)
        ? s["subject_img"]
        : "https://via.placeholder.com/65";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 12),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              imageUrl,
              width: 65,
              height: 65,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
              const Icon(Icons.image_not_supported),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s["subject_name"] ?? "Subject",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  s["description"] ?? "",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        title: const Text("Course Subjects"),
        backgroundColor: Colors.deepPurple,
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
