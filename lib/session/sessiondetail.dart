import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lms_pro/ApiHelper/apihelper.dart';
import 'package:lms_pro/pdf/pdfviwer.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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
  bool videoCompleted = false;

  Map<String, dynamic>? session;
  YoutubePlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    fetchSession();
  }

  Future<void> fetchSession() async {
    final res = await api.httpGet(
      '/api/sessions/${widget.sessionId}?user_id=${widget.userId}',
    );

    final decoded = json.decode(res.body);

    setState(() {
      session = decoded['data'];

      if (session?['type'] == 'video') {
        final videoUrl = session?['video']?.toString() ?? '';
        final videoId = YoutubePlayer.convertUrlToId(videoUrl);

        if (videoId != null && videoId.isNotEmpty) {
          _videoController = YoutubePlayerController(
            initialVideoId: videoId,
            flags: const YoutubePlayerFlags(
              autoPlay: false,
              mute: false,
            ),
          );
        }
      }

      loading = false;
    });
  }

  Future<void> markVideoComplete() async {
    await api.httpPost('/api/video-complete', {
      'user_id': widget.userId.toString(),
      'session_id': widget.sessionId.toString(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Video completed! Progress updated.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> uploadPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null) return;

    setState(() => uploading = true);

    await api.uploadFile(
      endpoint: '/api/session/upload-pdf',
      filePath: result.files.single.path!,
      fields: {
        'session_id': widget.sessionId.toString(),
        'user_id': widget.userId.toString(),
      },
    );

    setState(() => uploading = false);
    fetchSession();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading || session == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final String type = session?['type']?.toString() ?? '';
    final String title = session?['title']?.toString() ?? 'Session';
    final String pdfStatus = session?['pdf_status']?.toString() ?? '';
    final String rejectReason =
        session?['reject_reason']?.toString() ?? '';
    final String pdfUrl = session?['pdf_url']?.toString() ?? '';

    // If PDF is approved, open viewer directly
    if (type != 'video' && pdfStatus == 'approved' && pdfUrl.isNotEmpty) {
      return PdfViewerPage(
        pdfUrl: pdfUrl,
        title: title,
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // VIDEO PLAYER
            if (type == 'video' && _videoController != null)
              Container(
                height: 250,
                margin: const EdgeInsets.only(bottom: 16),
                child: YoutubePlayer(
                  controller: _videoController!,
                  showVideoProgressIndicator: true,
                  onEnded: (meta) {
                    if (!videoCompleted) {
                      videoCompleted = true;
                      markVideoComplete();
                    }
                  },
                ),
              ),

            // CONTENT
            if (session?['content'] != null &&
                session!['content'].toString().isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    session!['content'].toString(),
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                ),
              ),

            // PDF SECTION
            if (type != 'video')
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  children: [
                    if (pdfStatus == 'pending')
                      const Text(
                        'Your PDF is under review ⏳',
                        style: TextStyle(color: Colors.orange),
                      ),

                    // Rejected → backend sends pdf_status = locked + reject_reason
                    if (pdfStatus == 'locked' && rejectReason.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          "Rejected: $rejectReason",
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    if (pdfStatus != 'approved')
                      ElevatedButton.icon(
                        onPressed: uploading ? null : uploadPdf,
                        icon: const Icon(Icons.upload_file),
                        label: Text(
                          uploading ? 'Uploading...' : 'Upload PDF',
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
