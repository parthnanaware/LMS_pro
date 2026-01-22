import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lms_pro/ApiHelper/apihelper.dart';
import 'package:lms_pro/session/sessiondetail.dart';

class SessionListPage extends StatefulWidget {
  final int sectionId;
  final int userId;

  const SessionListPage({
    super.key,
    required this.sectionId,
    required this.userId,
  });

  @override
  State<SessionListPage> createState() => _SessionListPageState();
}

class _SessionListPageState extends State<SessionListPage> {
  final ApiHelper api = ApiHelper();
  bool loading = true;
  List sessions = [];
  double progress = 0;

  late ColorScheme _colors;
  late ThemeData _theme;

  @override
  void initState() {
    super.initState();
    fetchSessions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _theme = Theme.of(context);
    _colors = _theme.colorScheme;
  }

  Future<void> fetchSessions() async {
    setState(() => loading = true);

    final res = await api.httpGet(
      '/api/sections/${widget.sectionId}/sessions?user_id=${widget.userId}',
    );

    final decoded = json.decode(res.body);

    setState(() {
      sessions = decoded['data'] ?? [];
      progress = (decoded['progress'] ?? 0).toDouble();
      loading = false;
    });
  }

  // ===== SEQUENTIAL UNLOCK LOGIC =====
  bool isSessionUnlocked(int index) {
    if (index == 0) return true;

    final prev = sessions[index - 1];
    final String prevType = prev['type']?.toString() ?? '';
    final String prevStatus = prev['pdf_status']?.toString() ?? '';

    if (prevType == 'video') return true;
    return prevStatus == 'approved';
  }

  // ================= STATUS UI =================

  Widget buildStatus(Map session, int index) {
    final String type = session['type']?.toString() ?? '';
    final String pdfStatus = session['pdf_status']?.toString() ?? '';
    final bool unlocked = isSessionUnlocked(index) || type == 'video';

    if (type == 'video') {
      return _chip(Icons.videocam, 'Video Session', _colors.primary);
    }

    if (!unlocked) {
      return _chip(Icons.lock, 'Locked', Colors.red);
    }

    if (pdfStatus == 'pending') {
      return _chip(Icons.hourglass_empty, 'Pending Review', Colors.orange);
    }

    if (pdfStatus == 'approved') {
      return _chip(Icons.check_circle, 'Approved', Colors.green);
    }

    return _chip(Icons.upload_file, 'Upload PDF', Colors.blue);
  }

  Widget _chip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color),
          ),
        ],
      ),
    );
  }

  // ================= TAP LOGIC =================

  void handleTap(Map session, int index) async {
    final String type = session['type']?.toString() ?? '';
    final bool unlocked = isSessionUnlocked(index) || type == 'video';

    if (!unlocked && type != 'video') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.lock, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Complete the previous session first.',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SessionDetailPage(
          sessionId: session['session_id'],
          userId: widget.userId,
        ),
      ),
    );

    fetchSessions();
  }

  // ================= CARD UI =================

  Widget _buildSessionCard(Map session, int index) {
    final String type = session['type']?.toString() ?? '';
    final bool isUnlocked = isSessionUnlocked(index) || type == 'video';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        color: isUnlocked ? Colors.white : Colors.grey[50],
        elevation: isUnlocked ? 2 : 0,
        child: InkWell(
          onTap: () => handleTap(session, index),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isUnlocked
                    ? Colors.grey.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? _colors.primary.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isUnlocked ? _colors.primary : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            type == 'video'
                                ? Icons.play_circle_filled
                                : Icons.picture_as_pdf,
                            size: 20,
                            color: type == 'video'
                                ? Colors.red
                                : Colors.deepOrange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              session['title']?.toString() ?? 'Session',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                                decoration: isUnlocked
                                    ? TextDecoration.none
                                    : TextDecoration.lineThrough,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      buildStatus(session, index),
                    ],
                  ),
                ),
                Icon(
                  isUnlocked ? Icons.arrow_forward_ios : Icons.lock_outline,
                  size: 18,
                  color: isUnlocked ? _colors.primary : Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= PAGE =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Sessions', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: _colors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : sessions.isEmpty
          ? const Center(child: Text('No sessions available'))
          : Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _colors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _colors.primary.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.trending_up, color: _colors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your Progress: ${progress.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(_colors.primary),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Upload and get approval to increase your progress',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: fetchSessions,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: sessions.length,
                itemBuilder: (_, index) =>
                    _buildSessionCard(sessions[index], index),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
