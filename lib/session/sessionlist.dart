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

  // ================= STATUS TEXT =================
  Widget buildStatus(Map session) {
    final String type = session['type']?.toString() ?? '';
    final int isLocked = session['is_locked'] ?? 0;
    final String pdfStatus =
    session['pdf_status'] == null ? 'none' : session['pdf_status'];

    // 🎥 VIDEO (ALWAYS UNLOCKED)
    if (type == 'video') {
      return const Text(
        '▶ Video (Always Unlocked)',
        style: TextStyle(color: Colors.green),
      );
    }

    // 📄 OTHER SESSIONS
    if (isLocked == 0) {
      return const Text(
        '🔒 Locked',
        style: TextStyle(color: Colors.red),
      );
    }

    if (pdfStatus == 'pending') {
      return const Text(
        '🕒 Waiting for Admin',
        style: TextStyle(color: Colors.orange),
      );
    }

    if (pdfStatus == 'approved') {
      return const Text(
        '✅ Approved',
        style: TextStyle(color: Colors.green),
      );
    }

    return const Text(
      '📄 Upload PDF',
      style: TextStyle(color: Colors.blue),
    );
  }

  // ================= TAP LOGIC =================
  void handleTap(Map session) async {
    final String type = session['type']?.toString() ?? '';
    final int isLocked = session['is_locked'] ?? 0;

    // ❌ Block NON-video sessions if locked
    if (type != 'video' && isLocked == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This session is locked'),
        ),
      );
      return;
    }

    // ✅ Allow:
    // - ALL video sessions
    // - Other sessions only if unlocked
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sessions')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: sessions.length,
        itemBuilder: (_, index) {
          final session = sessions[index];

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: Icon(
                session['type'] == 'video'
                    ? Icons.play_circle
                    : Icons.picture_as_pdf,
                color: Colors.deepPurple,
              ),
              title:
              Text(session['title']?.toString() ?? 'Session'),
              subtitle: buildStatus(session),
              onTap: () => handleTap(session),
            ),
          );
        },
      ),
    );
  }
}
