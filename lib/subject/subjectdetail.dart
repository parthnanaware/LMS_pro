import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lms_pro/ApiHelper/apihelper.dart';
import 'package:lms_pro/section/sectiondetail.dart';

class SubjectDetailPage extends StatefulWidget {
  final int courseId;
  final int subjectId;
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
  bool _isLoading = true;
  bool _isError = false;
  List<dynamic> _sections = [];

  double _subjectProgress = 0.0; // always stored as 0–100

  @override
  void initState() {
    super.initState();
    _fetchSections();
    _fetchSubjectProgress();
  }

  Color _getSubjectColor() {
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF06B6D4),
    ];
    return colors[widget.subjectId.hashCode % colors.length];
  }

  Future<void> _fetchSections() async {
    try {
      final res =
      await ApiHelper().httpGet("/api/sections/by-subject/${widget.subjectId}");

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        setState(() {
          _sections = decoded["data"] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isError = true;
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _isError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchSubjectProgress() async {
    try {
      final userId = await ApiHelper().getUserId();

      final res = await ApiHelper().httpGet(
        "/subject/${widget.subjectId}/progress?user_id=$userId",
      );

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        final raw = (decoded["subject_progress"] as num?)?.toDouble() ?? 0.0;

        setState(() {
          // Normalize: if API sends 0–1, convert to 0–100
          _subjectProgress = raw <= 1 ? raw * 100 : raw;
        });
      }
    } catch (_) {}
  }

  Widget _buildSectionCard(BuildContext context, int index) {
    final section = _sections[index];
    final subjectColor = _getSubjectColor();
    final theme = Theme.of(context);

    final String sectionName =
        section["section_name"]?.toString() ?? "Untitled Section";

    final int sectionId =
        (section["section_id"] as num?)?.toInt() ??
            (section["id"] as num?)?.toInt() ??
            0;

    final String duration = section["duration"]?.toString() ?? "0 min";

    final int totalItems = (section["total_items"] as num?)?.toInt() ?? 0;
    final int completedItems =
        (section["completed_items"] as num?)?.toInt() ?? 0;

    final double progress =
    totalItems > 0 ? completedItems / totalItems : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        color: theme.cardColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SectionDetailPage(
                  courseId: widget.courseId,
                  subjectId: widget.subjectId,
                  sectionId: sectionId,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 3,
                    backgroundColor: subjectColor.withOpacity(0.15),
                    valueColor:
                    AlwaysStoppedAnimation<Color>(subjectColor),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sectionName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "$completedItems / $totalItems items • $duration",
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final subjectColor = _getSubjectColor();
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            subjectColor,
            subjectColor.withOpacity(0.7),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.subjectName ?? "Subject",
            style: theme.textTheme.headlineMedium
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),

          // 🔥 Subject Progress Bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _subjectProgress / 100, // 0.0 – 1.0
                    minHeight: 8,
                    backgroundColor: Colors.white.withOpacity(0.25),
                    valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "${_subjectProgress.toInt()}%",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_isError) {
      return const Scaffold(
        body: Center(child: Text("Error loading data")),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: _getSubjectColor(),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(context),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildSectionCard(context, index),
              childCount: _sections.length,
            ),
          ),
        ],
      ),
    );
  }
}
