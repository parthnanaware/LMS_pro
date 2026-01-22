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
  bool isLoading = false;

  int totalSessions = 0;
  int completedSessions = 0;
  double progress = 0;

  @override
  void initState() {
    super.initState();
    fetchProgress();
  }

  Future<void> fetchProgress() async {
    setState(() => isLoading = true);

    try {
      final res = await api.httpGet(
        '/api/sections/${widget.sectionId}/'
            'sessions?user_id=1',
      );

      final decoded = json.decode(res.body);
      final List sessions = decoded['data'] ?? [];

      setState(() {
        totalSessions = sessions.length;
        completedSessions =
            sessions.where((s) => s['is_completed'] == true).length;
        progress = totalSessions > 0 ? completedSessions / totalSessions : 0;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> startLearning() async {
    setState(() => isLoading = true);

    try {
      final res = await api.httpGet(
        '/api/sections/${widget.sectionId}/sessions?user_id=1',
      );

      final decoded = json.decode(res.body);
      final List sessions = decoded['data'] ?? [];

      if (sessions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No sessions available'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final unlocked = sessions.firstWhere(
            (s) => s['is_locked'] == false,
        orElse: () => null,
      );

      if (unlocked == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.lock, color: Colors.white),
                SizedBox(width: 8),
                Text('All sessions are currently locked'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SessionDetailPage(
            sessionId: unlocked['session_id'],
            userId: 1,
          ),
        ),
      );

      // Refresh progress after returning from session
      await fetchProgress();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
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
    ).then((_) => fetchProgress());
  }

  Widget _buildProgressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [
            Color(0xFF667eea),
            Color(0xFF764ba2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Progress bar with animation
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Completed',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    '$completedSessions/$totalSessions',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Stack(
                children: [
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOut,
                    height: 10,
                    width: MediaQuery.of(context).size.width * 0.7 * progress,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.white.withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (completedSessions == totalSessions && totalSessions > 0)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[300], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Section Completed! 🎉',
                    style: TextStyle(
                      color: Colors.green[100],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String text, VoidCallback onTap, Color color) {
    return Material(
      borderRadius: BorderRadius.circular(15),
      color: color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(18),
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 12),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Section Overview',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Color(0xFF667eea)),
            ),
            SizedBox(height: 16),
            Text(
              'Loading section details...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: fetchProgress,
        color: const Color(0xFF667eea),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressCard(),
              const SizedBox(height: 24),

              Row(
                children: [
                  _buildStatCard(
                    Icons.library_books,
                    'Total Sessions',
                    '$totalSessions',
                    const Color(0xFF667eea),
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    Icons.check_circle,
                    'Completed',
                    '$completedSessions',
                    Colors.green,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    Icons.hourglass_empty,
                    'Pending',
                    '${totalSessions - completedSessions}',
                    Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200), // Fixed: use .shade200
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        totalSessions == 0
                            ? 'No sessions available in this section.'
                            : progress == 1
                            ? 'Congratulations! You have completed all sessions in this section.'
                            : 'Complete sessions sequentially to unlock more content.',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Column(
                children: [

                  const SizedBox(height: 12),
                  _buildActionButton(
                    Icons.list_alt_rounded,
                    'All Sessions',
                    openAllSessions,
                    Colors.grey.shade800, // Fixed: use .shade800
                  ),
                ],
              ),

              const SizedBox(height: 20),

              if (completedSessions < totalSessions && totalSessions > 0)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50, // Fixed: use .shade50
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber.shade200), // Fixed: use .shade200
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: Colors.amber.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Quick Tip',
                            style: TextStyle(
                              color: Colors.amber.shade900,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try to complete at least one session per day to maintain consistency in your learning journey.',
                        style: TextStyle(
                          color: Colors.amber.shade800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}