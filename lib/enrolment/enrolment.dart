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
  int _selectedFilter = 0; // 0: All, 1: In Progress, 2: Completed
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
          m['course_name'] = m['course']?['course_name'] ?? m['course']?['name'] ?? "Course";
          m['progress'] = m['progress'] ?? 0;
          m['enrolled_at'] = m['created_at'] ?? m['enrolled_at'];
          m['course_object'] = m['course'];
          m['instructor'] = m['course']?['instructor'] ?? 'Unknown Instructor';
          m['duration'] = m['course']?['duration'] ?? '12 weeks';
          m['level'] = m['course']?['level'] ?? 'Beginner';
          m['thumbnail'] = m['course']?['thumbnail'] ?? m['course']?['image_url'];
          m['category'] = m['course']?['category'] ?? 'General';

          return m;
        }).toList();

        setState(() {
          enrollments = normalized;
          isLoading = false;
        });
      } else {
        setState(() {
          isError = true;
          isLoading = false;
        });
        _showSnack("Failed to load enrollments");
      }
    } catch (e) {
      setState(() {
        isError = true;
        isLoading = false;
      });
      _showSnack("Network error");
    }
  }

  Future<bool> _cancelEnrollment(dynamic enrollmentId) async {
    setState(() {
      cancellingId = enrollmentId.toString();
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Cancel Enrollment"),
        content: Text("Are you sure you want to cancel this enrollment?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("No", style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final resp = await ApiHelper().httpDelete("enrolments/$enrollmentId");
                cancellingId = null;

                if (resp.statusCode == 200 || resp.statusCode == 204) {
                  setState(() {
                    enrollments.removeWhere(
                          (e) => e['enrollment_id'].toString() == enrollmentId.toString(),
                    );
                  });
                  _showSnack("Enrollment cancelled", isError: false);
                } else {
                  _showSnack("Failed to cancel");
                }
              } catch (e) {
                _showSnack("Network error");
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text("Yes, Cancel"),
          ),
        ],
      ),
    );

    return false;
  }

  List<Map<String, dynamic>> get _filteredEnrollments {
    if (_selectedFilter == 0) return enrollments;
    if (_selectedFilter == 1) return enrollments.where((e) => (e['progress'] ?? 0) < 100).toList();
    return enrollments.where((e) => (e['progress'] ?? 0) >= 100).toList();
  }

  String _getProgressStatus(int progress) {
    if (progress == 0) return 'Not Started';
    if (progress < 50) return 'Beginner';
    if (progress < 80) return 'Intermediate';
    if (progress < 100) return 'Almost Done';
    return 'Completed';
  }

  Color _getProgressColor(int progress) {
    if (progress == 0) return Colors.grey;
    if (progress < 50) return Colors.orange;
    if (progress < 80) return Colors.blue;
    if (progress < 100) return Colors.green;
    return Colors.deepPurple;
  }

  Widget _buildProgressBar(int progress) {
    return Container(
      height: 6,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(3),
      ),
      child: Stack(
        children: [
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _getProgressColor(progress),
              borderRadius: BorderRadius.circular(3),
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * (progress / 100),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
          ),
          SizedBox(height: 20),
          Text(
            "Loading your courses...",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 64,
          ),
          SizedBox(height: 16),
          Text(
            "Failed to load enrollments",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Please check your internet connection",
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchEnrollments,
            icon: Icon(Icons.refresh),
            label: Text("Try Again"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            IconsaxPlusBold.book_1,
            color: Colors.grey[400],
            size: 80,
          ),
          SizedBox(height: 16),
          Text(
            "No enrollments yet",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Explore courses and start learning!",
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filterOptions.length,
        separatorBuilder: (_, __) => SizedBox(width: 8),
        itemBuilder: (context, index) {
          return FilterChip(
            label: Text(_filterOptions[index]),
            selected: _selectedFilter == index,
            onSelected: (selected) {
              setState(() {
                _selectedFilter = index;
              });
            },
            selectedColor: Colors.deepPurple[50],
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: _selectedFilter == index ? Colors.deepPurple : Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            shape: StadiumBorder(
              side: BorderSide(
                color: _selectedFilter == index ? Colors.deepPurple : Colors.grey[300]!,
              ),
            ),
            showCheckmark: false,
          );
        },
      ),
    );
  }

  Widget _buildStatsCard() {
    final total = enrollments.length;
    final completed = enrollments.where((e) => (e['progress'] ?? 0) >= 100).length;
    final inProgress = total - completed;

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.deepPurple, Colors.purple],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(total, "Total", IconsaxPlusBold.book_1),
          _buildStatItem(inProgress, "In Progress", Icons.timeline),
          _buildStatItem(completed, "Completed", Icons.check_circle),
        ],
      ),
    );
  }

  Widget _buildStatItem(int count, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          count.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEnrollmentCard(Map enrollment, int index) {
    final progress = (enrollment["progress"] as num).toInt();
    final status = _getProgressStatus(progress);
    final courseName = enrollment["course_name"];
    final instructor = enrollment["instructor"];
    final duration = enrollment["duration"];
    final thumbnail = enrollment["thumbnail"];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // Course Header with Thumbnail
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              image: thumbnail != null
                  ? DecorationImage(
                image: NetworkImage(thumbnail),
                fit: BoxFit.cover,
              )
                  : null,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.deepPurple[300]!, Colors.purple[300]!],
              ),
            ),
            child: Stack(
              children: [
                // Overlay
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getProgressColor(progress).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        courseName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 3,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.person_outline, color: Colors.white70, size: 14),
                          SizedBox(width: 4),
                          Text(
                            instructor,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
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

          // Course Details
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Progress",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "$progress%",
                      style: TextStyle(
                        fontSize: 16,
                        color: _getProgressColor(progress),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                _buildProgressBar(progress),

                SizedBox(height: 16),
                // Course Info
                Row(
                  children: [
                    _buildInfoItem(Icons.timer_outlined, duration),
                    SizedBox(width: 16),
                    _buildInfoItem(IconsaxPlusBold.ranking, enrollment["level"]),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        enrollment["category"] ?? "General",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final id = enrollment["course_id"];
                          if (id == null) {
                            _showSnack("Course id missing");
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_circle_outline, size: 20),
                            SizedBox(width: 8),
                            Text(
                              progress == 0 ? "Start Course" : "Continue",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _cancelEnrollment(enrollment["enrollment_id"]),
                      icon: Icon(Icons.more_vert),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
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
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 16),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Courses",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _fetchEnrollments,
            icon: Icon(Icons.refresh),
            color: Colors.grey[700],
          ),
        ],
      ),
      backgroundColor: Color(0xFFF8FAFC),
      body: isLoading
          ? _buildLoadingState()
          : isError
          ? _buildErrorState()
          : enrollments.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
        onRefresh: _fetchEnrollments,
        color: Colors.deepPurple,
        backgroundColor: Colors.white,
        child: Column(
          children: [
            _buildStatsCard(),
            _buildFilterChips(),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredEnrollments.length,
                padding: EdgeInsets.only(bottom: 16),
                itemBuilder: (_, i) =>
                    _buildEnrollmentCard(_filteredEnrollments[i], i),
              ),
            ),
          ],
        ),
      ),
    );
  }
}