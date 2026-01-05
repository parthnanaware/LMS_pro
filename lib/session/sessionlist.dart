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

  // ================= FETCH SESSIONS =================
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

  // ================= LOCK MESSAGE =================
  void showLockedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This session is locked'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ================= FLOW BUILDER =================
  List<Widget> buildFlow(Map session) {
    // 🔒 LOCKED SESSION
    if (session['is_locked'] == true) {
      return const [
        Text(
          '🔒 Locked',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
      ];
    }

    final List<Widget> flow = [];

    // 🎥 STEP 1: VIDEO
    if (session['video_unlocked'] == true) {
      flow.add(
        const Text(
          '✅ Video Completed',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    } else {
      flow.add(
        const Text(
          '⏳ Watch Video',
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.w500,
          ),
        ),
      );

      // ⛔ Stop flow until video is completed
      return flow;
    }

    // 📄 STEP 2: PDF (ONLY AFTER VIDEO)
    final String pdfStatus =
    (session['pdf_status'] ?? 'locked').toString();

    if (pdfStatus == 'approved') {
      flow.add(
        const Text(
          '✅ PDF Approved',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    } else if (pdfStatus == 'pending') {
      flow.add(
        const Text(
          '🕒 PDF Pending Approval',
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    } else {
      flow.add(
        const Text(
          '⏳ Upload PDF',
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return flow;
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Sessions')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: sessions.length,
        itemBuilder: (_, index) {
          final session = sessions[index];
          final bool locked = session['is_locked'] == true;

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: Icon(
                locked ? Icons.lock : Icons.lock_open,
                color: locked ? Colors.red : Colors.green,
              ),
              title: Text(session['title'] ?? 'Session'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: buildFlow(session),
              ),
              onTap: () async {
                if (locked) {
                  showLockedMessage();
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

                // 🔁 Refresh after returning
                fetchSessions();
              },
            ),
          );
        },
      ),
    );
  }
}
