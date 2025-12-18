// lib/screens/subject_detail_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:lms_pro/ApiHelper/apihelper.dart';
import 'package:lms_pro/section/sectiondetail.dart';

class SubjectDetailPage extends StatefulWidget {
  final int courseId;        // ✅ ADD
  final int subjectId;       // ✅ FIX TYPE
  final String? subjectName;

  const SubjectDetailPage({
    super.key,
    required this.courseId,
    required this.subjectId,
    this.subjectName,
  });

  @override
  State<SubjectDetailPage> createState() => _SubjectDetailPageState();
}

class _SubjectDetailPageState extends State<SubjectDetailPage> {
  bool isLoading = true;
  bool isError = false;
  List sections = [];

  @override
  void initState() {
    super.initState();
    _fetchSections();
  }

  Color _getSubjectColor() {
    final colors = [
      const Color(0xFF667EEA),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
      const Color(0xFF06B6D4),
      const Color(0xFFEF4444),
    ];
    return colors[widget.subjectId.hashCode % colors.length];
  }

  Future<void> _fetchSections() async {
    try {
      final res = await ApiHelper().httpGet(
        "sections/by-subject/${widget.subjectId}",
      );

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        setState(() {
          sections = decoded["data"] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          isError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  Widget _buildSectionCard(Map<String, dynamic> section, int index) {
    final subjectColor = _getSubjectColor();
    final sectionName = section["section_name"] ?? "Section";
    final description =
        section["description"] ?? "Explore this section to learn more";

    final sectionId = int.tryParse(
      section["section_id"]?.toString() ??
          section["id"]?.toString() ??
          "",
    ) ??
        0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SectionDetailPage(
                  courseId: widget.courseId,      // ✅ PASS
                  subjectId: widget.subjectId,    // ✅ PASS
                  sectionId: sectionId.toString(),
                  sectionObject: section,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(color: Colors.grey[100]!),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        subjectColor,
                        subjectColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sectionName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                Icon(
                  IconsaxPlusLinear.arrow_right_3,
                  color: subjectColor,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subjectColor = _getSubjectColor();
    final subjectName = widget.subjectName ?? "Subject";

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (isError) {
      return const Scaffold(
        body: Center(child: Text("Failed to load sections")),
      );
    }

    if (sections.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("No sections available")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: subjectColor,
            pinned: true,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(subjectName),
              background: Container(color: subjectColor),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: List.generate(
                  sections.length,
                      (i) => _buildSectionCard(
                    Map<String, dynamic>.from(sections[i]),
                    i,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
