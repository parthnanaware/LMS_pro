import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:lms_pro/ApiHelper/apihelper.dart';
import 'package:lms_pro/coursedetail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnrollmentPage extends StatefulWidget {
  const EnrollmentPage({super.key});

  @override
  State<EnrollmentPage> createState() => _EnrollmentPageState();
}

class _EnrollmentPageState extends State<EnrollmentPage> {
  String? authToken;
  List<Map<String, dynamic>> enrollments = [];
  bool isLoading = true;
  bool isError = false;
  String? cancellingId;
  int _selectedFilter = 0;
  final List<String> _filterOptions = ['All', 'In Progress', 'Completed'];

  @override
  void initState() {
    super.initState();
    _loadToken().then((_) => _fetchEnrollments());
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString('auth_token');
  }

  Map<String, String> _headers() {
    final h = {'Accept': 'application/json'};
    if (authToken != null && authToken!.isNotEmpty) {
      h['Authorization'] = 'Bearer $authToken';
    }
    return h;
  }

  Future<void> _fetchEnrollments() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      final resp = await ApiHelper().httpGet("enrolments/my");

      if (resp.statusCode == 200) {
        final body = json.decode(resp.body);
        final List raw = body['data'] ?? [];

        final normalized = raw.map<Map<String, dynamic>>((item) {
          final m = Map<String, dynamic>.from(item);

          m['enrollment_id'] = m['id'] ?? m['enroll_id'];
          m['course_id'] = m['course']?['id'] ?? m['course']?['course_id'];
          m['course_name'] = m['course']?['course_name'] ?? m['course']?['name'] ?? "Untitled Course";
          m['progress'] = m['progress'] ?? 0;
          m['enrolled_at'] = m['created_at'] ?? m['enrolled_at'];
          m['course_object'] = m['course'];
          m['instructor'] = m['course']?['instructor'] ?? 'Instructor';
          m['duration'] = m['course']?['duration'] ?? 'Self-paced';
          m['level'] = m['course']?['level'] ?? 'All Levels';
          m['thumbnail'] = m['course']?['thumbnail'] ?? m['course']?['image_url'];
          m['category'] = m['course']?['category'] ?? 'General';

          return m;
        }).toList();

        if (mounted) {
          setState(() {
            enrollments = normalized;
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isError = true;
            isLoading = false;
          });
        }
        _showSnack("Failed to load courses");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isError = true;
          isLoading = false;
        });
      }
      _showSnack("Connection error");
    }
  }

  Future<void> _cancelEnrollment(dynamic enrollmentId) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Cancel Enrollment",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Text(
          "You won't be able to access this course after cancellation.",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "Keep",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text("Cancel Course"),
          ),
        ],
      ),
    );

    if (shouldCancel != true) return;

    setState(() {
      cancellingId = enrollmentId.toString();
    });

    try {
      final resp = await ApiHelper().httpDelete("enrolments/$enrollmentId");

      if (mounted) {
        setState(() {
          cancellingId = null;
        });
      }

      if (resp.statusCode == 200 || resp.statusCode == 204) {
        if (mounted) {
          setState(() {
            enrollments.removeWhere(
                  (e) => e['enrollment_id'].toString() == enrollmentId.toString(),
            );
          });
        }
        _showSnack("Enrollment removed", isError: false);
      } else {
        _showSnack("Failed to cancel");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          cancellingId = null;
        });
      }
      _showSnack("Network error");
    }
  }

  List<Map<String, dynamic>> get _filteredEnrollments {
    if (_selectedFilter == 0) return enrollments;
    if (_selectedFilter == 1) {
      return enrollments.where((e) => (e['progress'] ?? 0) < 100).toList();
    }
    return enrollments.where((e) => (e['progress'] ?? 0) >= 100).toList();
  }

  Color _getProgressColor(BuildContext context, int progress) {
    final theme = Theme.of(context);
    if (progress == 0) return theme.colorScheme.outline.withOpacity(0.5);
    if (progress < 50) return theme.colorScheme.primary.withOpacity(0.7);
    if (progress < 80) return theme.colorScheme.primary;
    if (progress < 100) return theme.colorScheme.tertiary;
    return theme.colorScheme.secondary;
  }

  Widget _buildProgressBar(BuildContext context, int progress) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: progress / 100,
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        color: _getProgressColor(context, progress),
        minHeight: 6,
      ),
    );
  }

  void _showSnack(String msg, {bool isError = true}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.fixed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Loading courses...",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              "Unable to load courses",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Please check your connection and try again",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _fetchEnrollments,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text("Try Again"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              IconsaxPlusLinear.book_1,
              size: 80,
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              "No courses yet",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Browse available courses and start learning",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_filterOptions.length, (index) {
            return Padding(
              padding: EdgeInsets.only(right: index < _filterOptions.length - 1 ? 8 : 0),
              child: FilterChip(
                label: Text(_filterOptions[index]),
                selected: _selectedFilter == index,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = index;
                  });
                },
                selectedColor: Theme.of(context).colorScheme.primary,
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                labelStyle: TextStyle(
                  color: _selectedFilter == index
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                showCheckmark: false,
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    final total = enrollments.length;
    final completed = enrollments.where((e) => (e['progress'] ?? 0) >= 100).length;
    final inProgress = total - completed;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            total,
            "Total",
            IconsaxPlusLinear.book_1,
          ),
          _buildStatItem(
            context,
            inProgress,
            "In Progress",
            Icons.timeline_rounded,
          ),
          _buildStatItem(
            context,
            completed,
            "Completed",
            Icons.check_circle_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context,
      int count,
      String label,
      IconData icon,
      ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 22,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildEnrollmentCard(BuildContext context, Map enrollment) {
    final progress = (enrollment["progress"] as num).toInt();
    final courseName = enrollment["course_name"];
    final instructor = enrollment["instructor"];
    final duration = enrollment["duration"];
    final thumbnail = enrollment["thumbnail"];
    final level = enrollment["level"];
    final category = enrollment["category"];
    final isCancelling = cancellingId == enrollment["enrollment_id"].toString();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course thumbnail and progress
            Stack(
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    image: thumbnail != null && thumbnail.toString().isNotEmpty
                        ? DecorationImage(
                      image: NetworkImage(thumbnail.toString()),
                      fit: BoxFit.cover,
                    )
                        : null,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  ),
                  child: thumbnail == null || thumbnail.toString().isEmpty
                      ? Center(
                    child: Icon(
                      IconsaxPlusLinear.book_1,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                  )
                      : null,
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.background.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          category ?? "General",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        courseName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Instructor and level
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          instructor,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.bar_chart_rounded,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        level,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Progress section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Progress",
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            "$progress%",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _getProgressColor(context, progress),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildProgressBar(context, progress),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: isCancelling
                              ? null
                              : () {
                            final id = enrollment["course_id"];
                            if (id == null) {
                              _showSnack("Course unavailable");
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CourseDetailPage(
                                  courseId: int.parse(id.toString()),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.play_arrow_rounded, size: 20),
                          label: Text(progress == 0 ? "Start" : "Continue"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: isCancelling
                            ? null
                            : () => _cancelEnrollment(enrollment["enrollment_id"]),
                        icon: isCancelling
                            ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        )
                            : Icon(
                          Icons.more_vert_rounded,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor:
                          Theme.of(context).colorScheme.surfaceVariant,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Courses",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _fetchEnrollments,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Refresh",
          ),
        ],
      ),
      body: isLoading
          ? _buildLoadingState(context)
          : isError
          ? _buildErrorState(context)
          : enrollments.isEmpty
          ? _buildEmptyState(context)
          : RefreshIndicator(
        onRefresh: _fetchEnrollments,
        color: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.background,
        child: Column(
          children: [
            _buildStatsCard(context),
            _buildFilterChips(context),
            const SizedBox(height: 4),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredEnrollments.length,
                padding: const EdgeInsets.only(bottom: 16),
                itemBuilder: (context, index) => _buildEnrollmentCard(
                  context,
                  _filteredEnrollments[index],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}