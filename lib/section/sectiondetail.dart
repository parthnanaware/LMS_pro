import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lms_pro/ApiHelper/apihelper.dart';
import 'package:lms_pro/session/sessiondetail.dart';
import 'package:lms_pro/session/sessionlist.dart';

class SectionDetailPage extends StatefulWidget {
  final int courseId;
  final int subjectId;
  final int sectionId;

  const SectionDetailPage({
    super.key,
    required this.courseId,
    required this.subjectId,
    required this.sectionId,
  });

  @override
  State<SectionDetailPage> createState() => _SectionDetailPageState();
}

class _SectionDetailPageState extends State<SectionDetailPage> {
  final ApiHelper api = ApiHelper();

  int totalSessions = 0;
  int completedSessions = 0;
  double progress = 0;

  @override
  void initState() {
    super.initState();
    fetchProgress();
  }

  Future<void> fetchProgress() async {
    final res = await api.httpGet(
      'sections/${widget.sectionId}/sessions?user_id=1',
    );

    final decoded = json.decode(res.body);
    final List sessions = decoded['data'] ?? [];

    setState(() {
      totalSessions = sessions.length;
      completedSessions =
          sessions.where((s) => s['is_completed'] == true).length;
      progress =
      totalSessions > 0 ? completedSessions / totalSessions : 0;
    });
  }

  Future<void> startLearning() async {
    final res = await api.httpGet(
      'sections/${widget.sectionId}/sessions?user_id=1',
    );

    final decoded = json.decode(res.body);
    final List sessions = decoded['data'] ?? [];

    if (sessions.isEmpty) return;

    final unlocked = sessions.firstWhere(
          (s) => s['is_locked'] == false,
      orElse: () => null,
    );

    if (unlocked == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All sessions are locked')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SessionDetailPage(
          sessionId: unlocked['session_id'], // ✅ PASS ONLY ID
          userId: 1,
        ),
      ),
    );

  }

  void openAllSessions() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SessionListPage(
          sectionId: widget.sectionId,
          userId: 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Section Detail')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 20),
            Text('$completedSessions / $totalSessions completed'),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: startLearning,
              child: const Text('Start Learning'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: openAllSessions,
              child: const Text('View All Sessions'),
            ),
          ],
        ),
      ),
    );
  }
}
