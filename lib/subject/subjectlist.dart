import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lms_pro/ApiHelper/apihelper.dart';

class SubjectListPage extends StatefulWidget {
  final int courseId;
  final String? courseName;

  const SubjectListPage({
    super.key,
    required this.courseId,
    this.courseName,
  });

  @override
  State<SubjectListPage> createState() => _SubjectListPageState();
}

class _SubjectListPageState extends State<SubjectListPage> {
  bool _loading = true;
  bool _error = false;
  List<dynamic> _subjects = [];
  final List<Color> _subjectColors = [
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.pinkAccent,
    Colors.tealAccent,
  ];

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  Future<void> _fetchSubjects() async {
    try {
      final res = await ApiHelper().httpGet(
        "subjects/courses/${widget.courseId}",
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          _subjects = data["data"] ?? [];
          _loading = false;
        });
      } else {
        setState(() {
          _error = true;
          _loading = false;
        });
        _showSnack("Failed to load subjects");
      }
    } catch (e) {
      setState(() {
        _error = true;
        _loading = false;
      });
      _showSnack("Network error");
    }
  }

  void _showSnack(String message, {bool isError = true}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Color _getSubjectColor(int index) {
    return _subjectColors[index % _subjectColors.length];
  }

  Widget _buildSubjectCard(int index, BuildContext context) {
    final subject = _subjects[index];
    final subjectId = int.tryParse(subject["subject_id"]?.toString() ?? "") ?? 0;
    final subjectName = subject["subject_name"] ?? "Untitled Subject";
    final description = subject["description"] ?? "";
    final subjectColor = _getSubjectColor(index);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigator.push(
            //   context,
            //   // MaterialPageRoute(
            //   //   builder: (_) => SectionListPage(
            //   //     courseId: widget.courseId,
            //   //     subjectId: subjectId,
            //   //     subjectName: subjectName,
            //   //   ),
            //   // ),
            // );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Subject Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: subjectColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      _getSubjectIcon(index),
                      size: 28,
                      color: subjectColor,
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Subject Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subjectName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onBackground,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Arrow Icon
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getSubjectIcon(int index) {
    final icons = [
      Icons.library_books_rounded,
      Icons.code_rounded,
      Icons.calculate_rounded,
      Icons.language_rounded,
      Icons.science_rounded,
      Icons.history_rounded,
      Icons.business_rounded,
      Icons.psychology_rounded,
      Icons.brush_rounded,
      Icons.music_note_rounded,
    ];
    return icons[index % icons.length];
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.book_rounded,
                size: 24,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                "Subjects",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          if (widget.courseName != null) ...[
            Text(
              widget.courseName!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
              ),
            ),
          ],

          const SizedBox(height: 4),

          Text(
            "${_subjects.length} subject${_subjects.length != 1 ? 's' : ''} available",
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer.withOpacity(0.6),
            ),
          ),
        ],
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
            "Loading subjects...",
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
              "Unable to load subjects",
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
              onPressed: _fetchSubjects,
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
              Icons.menu_book_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              "No subjects yet",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Subjects will appear here once they're added",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: _fetchSubjects,
              child: const Text("Refresh"),
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
          "Subjects",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _fetchSubjects,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Refresh",
          ),
        ],
      ),
      body: _loading
          ? _buildLoadingState(context)
          : _error
          ? _buildErrorState(context)
          : _subjects.isEmpty
          ? _buildEmptyState(context)
          : RefreshIndicator(
        onRefresh: _fetchSubjects,
        color: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.background,
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _subjects.length,
                itemBuilder: (context, index) =>
                    _buildSubjectCard(index, context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}