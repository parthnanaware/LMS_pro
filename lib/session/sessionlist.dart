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
  late ColorScheme _colors;
  late ThemeData _theme;

  @override
  void initState() {
    super.initState();
    fetchSessions();
  }

  Future<void> fetchSessions() async {
    setState(() => loading = true);

    final res = await api.httpGet(
      'sections/${widget.sectionId}/sessions?user_id=${widget.userId}',
    );

    final decoded = json.decode(res.body);

    setState(() {
      sessions = decoded['data'] ?? [];
      loading = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _theme = Theme.of(context);
    _colors = _theme.colorScheme;
  }

  Widget buildStatus(Map session) {
    final String type = session['type']?.toString() ?? '';
    final int isLocked = session['is_locked'] ?? 0;
    final String pdfStatus =
    session['pdf_status'] == null ? 'none' : session['pdf_status'];

    // 🎥 VIDEO (ALWAYS UNLOCKED)
    if (type == 'video') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _colors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.videocam, size: 14, color: _colors.primary),
            const SizedBox(width: 4),
            Text(
              'Video Session',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _colors.primary,
              ),
            ),
          ],
        ),
      );
    }

    if (isLocked == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock, size: 14, color: Colors.red),
            const SizedBox(width: 4),
            Text(
              'Locked',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
          ],
        ),
      );
    }

    if (pdfStatus == 'pending') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hourglass_empty, size: 14, color: Colors.orange[700]),
            const SizedBox(width: 4),
            Text(
              'Pending Review',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.orange[700],
              ),
            ),
          ],
        ),
      );
    }

    if (pdfStatus == 'approved') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 14, color: Colors.green),
            const SizedBox(width: 4),
            Text(
              'Approved',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.green,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.upload_file, size: 14, color: Colors.blue),
          const SizedBox(width: 4),
          Text(
            'Upload PDF',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  // ================= TAP LOGIC =================
  void handleTap(Map session) async {
    final String type = session['type']?.toString() ?? '';
    final int isLocked = session['is_locked'] ?? 0;

    if (type != 'video' && isLocked == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.lock, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'This session is locked. Complete previous sessions to unlock.',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
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
          sessionId: session['session_id'],
          userId: widget.userId,
        ),
      ),
    );

    fetchSessions();
  }

  Widget _buildSessionCard(Map session, int index) {
    final String type = session['type']?.toString() ?? '';
    final int isLocked = session['is_locked'] ?? 0;
    final bool isUnlocked = type == 'video' || isLocked == 1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        color: isUnlocked ? Colors.white : Colors.grey[50],
        elevation: isUnlocked ? 2 : 0,
        child: InkWell(
          onTap: () => handleTap(session),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isUnlocked
                    ? Colors.grey.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.1),
                width: 1,
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
                      buildStatus(session),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Course Sessions',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: _colors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: loading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading sessions...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      )
          : sessions.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No sessions available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new content',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      )
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
            child: Row(
              children: [
                Icon(Icons.info_outline, color: _colors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Complete sessions sequentially to unlock more content',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

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