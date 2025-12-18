import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lms_pro/ApiHelper/apihelper.dart';
import 'package:lms_pro/session/sessiondetail.dart';
import 'package:lms_pro/session/sessionlist.dart';

class SectionDetailPage extends StatefulWidget {
  final int courseId;
  final int subjectId;
  final String? sectionId;
  final Map<String, dynamic>? sectionObject;

  const SectionDetailPage({
    super.key,
    required this.courseId,
    required this.subjectId,
    this.sectionId,
    this.sectionObject,
  });

  @override
  State<SectionDetailPage> createState() => _SectionDetailPageState();
}

class _SectionDetailPageState extends State<SectionDetailPage> {
  bool isLoading = false;
  bool isError = false;
  Map<String, dynamic>? section;

  @override
  void initState() {
    super.initState();
    if (widget.sectionObject != null) {
      section = Map<String, dynamic>.from(widget.sectionObject!);
    } else if (widget.sectionId != null) {
      _fetchSection();
    }
  }

  Future<void> _fetchSection() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      final resp = await ApiHelper().httpGet("sections/${widget.sectionId}");

      if (resp.statusCode == 200) {
        final body = json.decode(resp.body);
        final data =
        body is Map && body['data'] != null ? body['data'] : body;

        section = Map<String, dynamic>.from(data);
      } else {
        isError = true;
      }
    } catch (_) {
      isError = true;
    }

    if (mounted) setState(() => isLoading = false);
  }

  // =====================================================
  // START LEARNING → OPEN FIRST SESSION
  // =====================================================
  Future<void> _openSessionsDirectly() async {
    final secId = int.tryParse(
      section?['section_id']?.toString() ??
          section?['id']?.toString() ??
          widget.sectionId ??
          '',
    );

    if (secId == null) return;

    final resp = await ApiHelper().httpGet("sections/$secId/sessions");

    if (resp.statusCode == 200) {
      final body = json.decode(resp.body);
      final list = body['data'] ?? body;

      if (list is List && list.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SessionDetailPage(
              session: Map<String, dynamic>.from(list.first),
              userId: 1, // TODO: replace with logged-in user id
              courseId: widget.courseId,
              subjectId: widget.subjectId,
              sectionId: secId,
            ),
          ),
        );
        return;
      }
    }

    // fallback
    _openSessionListPage();
  }

  // =====================================================
  // VIEW ALL → SESSION LIST PAGE (FINAL & CORRECT)
  // =====================================================
  void _openSessionListPage() {
    final secId = int.tryParse(
      section?['section_id']?.toString() ??
          section?['id']?.toString() ??
          widget.sectionId ??
          '',
    );

    if (secId == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SessionListPage(
          userId: 1, // TODO: replace with logged-in user id
          courseId: widget.courseId,
          subjectId: widget.subjectId,
          sectionId: secId,
          sectionName: section?['section_name'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (isError) {
      return const Scaffold(
        body: Center(child: Text("Failed to load section")),
      );
    }

    final sectionName = section?['section_name'] ?? 'Section';
    final description = section?['description'] ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(sectionName)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 30),

            // START LEARNING
            ElevatedButton(
              onPressed: _openSessionsDirectly,
              child: const Text("Start Learning"),
            ),

            const SizedBox(height: 20),

            // VIEW ALL SESSIONS ✅ FIXED
            TextButton(
              onPressed: _openSessionListPage,
              child: const Text(
                "View All Sessions",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
