import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:lms_pro/ApiHelper/apihelper.dart';
import 'package:lms_pro/subject/subjectdetail.dart';

class CourseDetailPage extends StatefulWidget {
  final int courseId; // ✅ FIX: use int everywhere

  const CourseDetailPage({
    super.key,
    required this.courseId,
  });

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  bool loading = true;
  bool error = false;
  Map<String, dynamic>? course;

  List subjects = [];
  bool subjectsLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCourse();
    fetchSubjects();
  }

  // -----------------------------
  // FETCH COURSE DETAILS
  // -----------------------------
  Future<void> fetchCourse() async {
    try {
      final res = await ApiHelper().httpGet("courses/${widget.courseId}");

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);

        setState(() {
          course = decoded["data"];
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
          error = true;
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
        error = true;
      });
    }
  }

  // -----------------------------
  // FETCH SUBJECTS OF THE COURSE
  // -----------------------------
  Future<void> fetchSubjects() async {
    try {
      final res = await ApiHelper().httpGet(
        "subjects/courses/${widget.courseId}",
      );

      final decoded = json.decode(res.body);

      setState(() {
        subjects = decoded["data"] ?? [];
        subjectsLoading = false;
      });
    } catch (e) {
      setState(() {
        subjectsLoading = false;
      });
    }
  }

  // -----------------------------
  // SUBJECT CARD UI
  // -----------------------------
  Widget subjectCard(Map subject) {
    final subjectId =
        int.tryParse(subject["subject_id"]?.toString() ?? "") ?? 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SubjectDetailPage(
              courseId: widget.courseId,      // ✅ PASS COURSE ID
              subjectId: subjectId,            // ✅ PASS AS INT
              subjectName: subject["subject_name"],
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.book,
                color: Colors.deepPurple,
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject["subject_name"],
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subject["description"] ?? "No description",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(
              IconsaxPlusLinear.arrow_right_3,
              color: Colors.deepPurple,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error || course == null) {
      return const Scaffold(
        body: Center(child: Text("Failed to load course")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple,
                    Colors.deepPurple.shade400,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    course!["course_name"],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course!["course_description"],
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            // BODY
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Subjects in this course",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 14),
                    subjectsLoading
                        ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.deepPurple,
                      ),
                    )
                        : subjects.isEmpty
                        ? const Text("No subjects found")
                        : Column(
                      children: subjects
                          .map((sub) => subjectCard(sub))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
