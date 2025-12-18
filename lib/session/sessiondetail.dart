import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax_plus/iconsax_plus.dart';

class SessionDetailPage extends StatefulWidget {
  final Map<String, dynamic> session;
  final int userId;

  final int? courseId;
  final int? subjectId;
  final int? sectionId;

  const SessionDetailPage({
    super.key,
    required this.session,
    required this.userId,
    this.courseId,
    this.subjectId,
    this.sectionId,
  });

  @override
  State<SessionDetailPage> createState() => _SessionDetailPageState();
}

class _SessionDetailPageState extends State<SessionDetailPage> {
  static const String baseUrl =
      "https://0fef2e6c7c31.ngrok-free.app"; // ✅ API BASE

  bool isUploading = false;

  // =====================================================
  // PDF UPLOAD (FIXED & SAFE)
  // =====================================================
  Future<void> uploadPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null || result.files.single.path == null) return;

    setState(() => isUploading = true);

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/session/upload-step'),
    );

    // ✅ REQUIRED FIELDS
    request.fields['user_id'] =
        widget.userId.toString();
    request.fields['session_id'] =
        widget.session['session_id'].toString();
    request.fields['step'] = 'pdf';

    // ✅ OPTIONAL IDS (ONLY IF PRESENT)
    if (widget.courseId != null) {
      request.fields['course_id'] =
          widget.courseId.toString();
    }
    if (widget.subjectId != null) {
      request.fields['subject_id'] =
          widget.subjectId.toString();
    }
    if (widget.sectionId != null) {
      request.fields['section_id'] =
          widget.sectionId.toString();
    }

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        result.files.single.path!,
      ),
    );

    final response = await request.send();

    if (!mounted) return;

    setState(() => isUploading = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ PDF uploaded successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Upload failed (${response.statusCode})"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =====================================================
  // UI
  // =====================================================
  @override
  Widget build(BuildContext context) {
    final unlock = widget.session['unlock'] ?? {};
    final pdfUnlocked = unlock['pdf'] == true;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.session['title'] ?? 'Session'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // SESSION INFO
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: const Icon(IconsaxPlusBold.book_1),
                title: Text(
                  widget.session['title'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "Type: ${widget.session['type']}",
                ),
              ),
            ),

            const SizedBox(height: 24),

            // PDF SECTION
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.picture_as_pdf,
                  color: pdfUnlocked ? Colors.green : Colors.red,
                ),
                title: const Text("PDF Material"),
                subtitle: Text(
                  pdfUnlocked
                      ? "Unlocked"
                      : "Upload PDF to unlock (Admin approval required)",
                ),
                trailing: isUploading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : pdfUnlocked
                    ? IconButton(
                  icon: const Icon(Icons.open_in_new),
                  onPressed: () {
                    // TODO: open pdf viewer
                  },
                )
                    : ElevatedButton(
                  onPressed: uploadPdf,
                  child: const Text("Upload PDF"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
