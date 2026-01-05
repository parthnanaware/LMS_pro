import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:lms_pro/ApiHelper/apihelper.dart';
import 'package:lms_pro/subject/subjectdetail.dart';

class CourseDetailPage extends StatefulWidget {
  final int courseId;

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
  final List<Color> _subjectColors = [
    const Color(0xFF667EEA),
    const Color(0xFF10B981),
    const Color(0xFFF59E0B),
    const Color(0xFF8B5CF6),
    const Color(0xFFEC4899),
    const Color(0xFF3B82F6),
    const Color(0xFF6366F1),
    const Color(0xFF14B8A6),
  ];

  @override
  void initState() {
    super.initState();
    fetchCourse();
    fetchSubjects();
  }

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

  Widget _subjectCard(Map subject, int index) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final subjectId = int.tryParse(subject["subject_id"]?.toString() ?? "") ?? 0;
    final colorIndex = index % _subjectColors.length;
    final color = _subjectColors[colorIndex];
    final iconList = [
      IconsaxPlusLinear.book_1,
      IconsaxPlusLinear.calculator,
      IconsaxPlusLinear.language_circle,
      IconsaxPlusLinear.glass,
      IconsaxPlusLinear.cpu,
      IconsaxPlusLinear.chart,
      IconsaxPlusLinear.music,
      IconsaxPlusLinear.paperclip,
    ];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SubjectDetailPage(
              courseId: widget.courseId,
              subjectId: subjectId,
              subjectName: subject["subject_name"],
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isDarkMode ? null : [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
          border: isDarkMode ? Border.all(color: Colors.grey[800]!) : null,
        ),
        child: Row(
          children: [
            // Icon/Image Container
            Container(
              width: 80,
              height: 100,
              margin: EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color,
                    color.withOpacity(0.8),
                  ],
                ),
                boxShadow: isDarkMode ? null : [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  iconList[colorIndex],
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subject header with number
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Subject ${index + 1}",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ),
                        Spacer(),
                        Icon(
                          IconsaxPlusLinear.arrow_right_3,
                          size: 18,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ],
                    ),

                    SizedBox(height: 10),

                    // Subject name
                    Text(
                      subject["subject_name"] ?? "Subject",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 6),

                    // Description
                    Text(
                      subject["description"] ?? "No description available",
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 12),

                    // Topics count
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                IconsaxPlusLinear.document_text,
                                color: color,
                                size: 14,
                              ),
                              SizedBox(width: 6),
                              Text(
                                "12 Topics", // Replace with actual topic count
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Beginner",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildHeaderStats(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDarkMode ? Border.all(color: Colors.grey[800]!) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            IconsaxPlusLinear.book,
            "${subjects.length}",
            "Subjects",
          ),
          Container(height: 30, width: 1, color: isDarkMode ? Colors.grey[800] : Colors.grey[200]),
          _buildStatItem(
            context,
            IconsaxPlusLinear.clock,
            "48",
            "Hours",
          ),
          Container(height: 30, width: 1, color: isDarkMode ? Colors.grey[800] : Colors.grey[200]),
          _buildStatItem(
            context,
            IconsaxPlusLinear.profile_2user,
            "4.8",
            "Rating",
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String value, String label) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Icon(icon, color: Colors.deepPurple, size: 22),
        SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (loading) {
      return Scaffold(
        backgroundColor: isDarkMode ? Color(0xFF121212) : Color(0xFFF4F5FA),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Colors.deepPurple,
              ),
              SizedBox(height: 20),
              Text(
                "Loading Course Details",
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (error || course == null) {
      return Scaffold(
        backgroundColor: isDarkMode ? Color(0xFF121212) : Color(0xFFF4F5FA),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red,
              ),
              SizedBox(height: 20),
              Text(
                "Failed to load course",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: fetchCourse,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: Text("Try Again"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF121212) : Color(0xFFF4F5FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkMode
                      ? [
                    Colors.deepPurple.shade900,
                    Colors.deepPurple.shade800,
                    Colors.deepPurple.shade700,
                  ]
                      : [
                    Colors.deepPurple.shade800,
                    Colors.deepPurple.shade600,
                    Colors.deepPurple.shade400,
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Course title
                  Text(
                    course!["course_name"] ?? "Course",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 8),
                  // Course description
                  Text(
                    course!["course_description"] ?? "",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Stats card
            _buildHeaderStats(context),

            // Subjects header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Course Subjects",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.deepPurple.withOpacity(0.2) : Colors.deepPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${subjects.length} subjects",
                      style: TextStyle(
                        color: isDarkMode ? Colors.deepPurple[300] : Colors.deepPurple,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 8),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Explore all subjects included in this course",
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),

            SizedBox(height: 20),

            // Subjects list
            Expanded(
              child: subjectsLoading
                  ? Center(
                child: CircularProgressIndicator(
                  color: Colors.deepPurple,
                ),
              )
                  : subjects.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      IconsaxPlusLinear.book,
                      size: 80,
                      color: isDarkMode ? Colors.grey[700] : Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      "No subjects available",
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
                  : RefreshIndicator(
                color: Colors.deepPurple,
                onRefresh: fetchSubjects,
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: subjects.length,
                  itemBuilder: (context, index) =>
                      _subjectCard(subjects[index], index),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}