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

  @override
  void initState() {
    super.initState();
    _fetchSections();
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
      await ApiHelper().httpGet("sections/by-subject/${widget.subjectId}");

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        setState(() {
          _sections = decoded["data"] ?? [];
          _isLoading = false;
        });
      } else {
        _isError = true;
        _isLoading = false;
      }
    } catch (_) {
      _isError = true;
      _isLoading = false;
    }
  }

  // =========================
  // SECTION CARD
  // =========================
  Widget _buildSectionCard(BuildContext context, int index) {
    final section = _sections[index];
    final subjectColor = _getSubjectColor();
    final theme = Theme.of(context);

    final String sectionName =
        section["section_name"]?.toString() ?? "Untitled Section";
    final String description =
        section["description"]?.toString() ?? "No description";

    final int sectionId =
        (section["section_id"] as num?)?.toInt() ??
            (section["id"] as num?)?.toInt() ??
            0;

    final String duration = section["duration"]?.toString() ?? "0 min";
    final bool isCompleted = section["is_completed"] == true;

    /// 🔥 FIXED TYPES
    final int totalItems =
        (section["total_items"] as num?)?.toInt() ?? 0;

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
                  // sectionObject: section,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // PROGRESS
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

                // CONTENT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              sectionName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (isCompleted)
                            const Icon(Icons.check_circle,
                                color: Colors.green, size: 18),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
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

  // =========================
  // HEADER
  // =========================
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
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
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
          const SizedBox(height: 8),
          Text(
            "${_sections.length} Sections",
            style: TextStyle(color: Colors.white.withOpacity(0.9)),
          ),
          const SizedBox(height: 20),

          /// 🔥 OVERFLOW FIX
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatItem(
                    _calculateTotalDuration(), "Time", Icons.timer),
                const SizedBox(width: 16),
                _buildStatItem(
                    _calculateCompletionRate(), "Progress", Icons.trending_up),
                const SizedBox(width: 16),
                _buildStatItem(
                    _calculateCompletedSections(), "Completed", Icons.check),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        Text(label,
            style: TextStyle(color: Colors.white.withOpacity(0.8))),
      ],
    );
  }

  // =========================
  // CALCULATIONS
  // =========================
  String _calculateTotalDuration() {
    int totalMinutes = 0;
    for (var s in _sections) {
      final match =
      RegExp(r'(\d+)').firstMatch(s["duration"]?.toString() ?? "");
      if (match != null) {
        totalMinutes += int.tryParse(match.group(1)!) ?? 0;
      }
    }
    return totalMinutes >= 60
        ? "${totalMinutes ~/ 60}h"
        : "${totalMinutes}m";
  }

  String _calculateCompletionRate() {
    int total = 0, done = 0;
    for (var s in _sections) {
      total += (s["total_items"] as num?)?.toInt() ?? 0;
      done += (s["completed_items"] as num?)?.toInt() ?? 0;
    }
    if (total == 0) return "0%";
    return "${((done / total) * 100).toInt()}%";
  }

  String _calculateCompletedSections() {
    final completed =
        _sections.where((e) => e["is_completed"] == true).length;
    return "$completed/${_sections.length}";
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }
    if (_isError) {
      return const Scaffold(body: Center(child: Text("Error loading data")));
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
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
