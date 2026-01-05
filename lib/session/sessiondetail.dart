import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lms_pro/ApiHelper/apihelper.dart';
import 'package:lms_pro/video/videoplayer.dart';

class SessionDetailPage extends StatefulWidget {
  final int sessionId;
  final int userId;

  const SessionDetailPage({
    super.key,
    required this.sessionId,
    required this.userId,
  });

  @override
  State<SessionDetailPage> createState() => _SessionDetailPageState();
}

class _SessionDetailPageState extends State<SessionDetailPage> {
  final ApiHelper api = ApiHelper();

  bool loading = true;
  bool uploading = false;
  Map<String, dynamic>? session;

  @override
  void initState() {
    super.initState();
    fetchSession();
  }

  // ================= FETCH SESSION =================
  Future<void> fetchSession() async {
    final res = await api.httpGet(
      'sessions/${widget.sessionId}?user_id=${widget.userId}',
    );

    final decoded = json.decode(res.body);

    setState(() {
      session = decoded['data'];
      loading = false;
    });
  }

  // ================= UPLOAD PDF =================
  Future<void> uploadPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null) return;

    setState(() => uploading = true);

    await api.uploadFile(
      endpoint: 'session/upload-pdf',
      filePath: result.files.single.path!,
      fields: {
        'session_id': widget.sessionId.toString(),
        'user_id': widget.userId.toString(),
      },
    );

    setState(() => uploading = false);

    fetchSession(); // 🔁 refresh status
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (session == null) {
      return const Scaffold(
        body: Center(child: Text('Failed to load session')),
      );
    }

    final bool videoDone = session!['video_unlocked'] == true;
    final String pdfStatus = session!['pdf_status'] ?? 'locked';

    return Scaffold(
      appBar: AppBar(title: Text(session!['title'] ?? 'Session')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🎥 VIDEO
            Expanded(
              child: YoutubePlayerPage(
                videoUrl: session!['video'],
              ),
            ),

            const SizedBox(height: 20),

            // 📄 PDF FLOW
            if (!videoDone)
              const Text(
                'Complete video to unlock PDF upload',
                style: TextStyle(color: Colors.orange),
              ),

            if (videoDone && pdfStatus == 'locked')
              ElevatedButton(
                onPressed: uploading ? null : uploadPdf,
                child: Text(uploading ? 'Uploading...' : 'Upload PDF'),
              ),

            if (pdfStatus == 'pending')
              const Text(
                'PDF submitted. Waiting for admin approval',
                style: TextStyle(color: Colors.orange),
              ),

            if (pdfStatus == 'approved')
              const Text(
                'PDF approved. Session completed ✅',
                style: TextStyle(color: Colors.green),
              ),
          ],
        ),
      ),
    );
  }
}
