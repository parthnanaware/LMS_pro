// lib/screens/subject_list_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lms_pro/ApiHelper/apihelper.dart';
import 'package:lms_pro/section/sectionlist.dart';

class SubjectListPage extends StatefulWidget {
  final int courseId; // ✅ FIX: use int

  const SubjectListPage({
    super.key,
    required this.courseId,
  });

  @override
  State<SubjectListPage> createState() => _SubjectListPageState();
}

class _SubjectListPageState extends State<SubjectListPage> {
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
      final res = await ApiHelper().httpGet(
        "subjects/courses/${widget.courseId}",
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        subjects = data["data"] ?? [];
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
      appBar: AppBar(title: const Text("Subjects")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error
          ? const Center(child: Text("Failed to load subjects"))
          : subjects.isEmpty
          ? const Center(child: Text("No subjects found"))
          : ListView.builder(
        itemCount: subjects.length,
        itemBuilder: (_, i) {
          final s = subjects[i];

          final subjectId = int.tryParse(
            s["subject_id"]?.toString() ?? "",
          ) ??
              0;

          return ListTile(
            title: Text(s["subject_name"] ?? "Unknown"),
            subtitle: Text(s["description"] ?? ""),
            trailing: const Icon(Icons.arrow_forward_ios),

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SectionListPage(
                    courseId: widget.courseId, // ✅ PASS COURSE ID
                    subjectId: subjectId,
                    subjectName: s["subject_name"],
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
