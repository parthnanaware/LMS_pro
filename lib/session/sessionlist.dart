import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lms_pro/ApiHelper/apihelper.dart';
import 'package:lms_pro/session/sessiondetail.dart';

class SessionListPage extends StatefulWidget {
  final int sectionId;
  final int courseId;
  final int subjectId;
  final int userId;
  final String? sectionName;

  const SessionListPage({
    super.key,
    required this.sectionId,
    required this.courseId,
    required this.subjectId,
    required this.userId,
    this.sectionName,
  });

  @override
  State<SessionListPage> createState() => _SessionListPageState();
}

class _SessionListPageState extends State<SessionListPage> {
  final ApiHelper api = ApiHelper();

  bool isLoading = true;
  bool isError = false;
  String errorMessage = '';
  List<Map<String, dynamic>> sessions = [];

  @override
  void initState() {
    super.initState();
    _fetchSessions();
  }

  // =====================================================
  // FETCH ALL SESSIONS OF THIS SECTION
  // =====================================================
  Future<void> _fetchSessions() async {
    setState(() {
      isLoading = true;
      isError = false;
      errorMessage = '';
    });

    try {
      final response = await api.httpGet(
        'sections/${widget.sectionId}/sessions?user_id=${widget.userId}',
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List list =
        decoded is Map ? (decoded['data'] ?? []) : decoded;

        setState(() {
          sessions =
              list.map((e) => Map<String, dynamic>.from(e)).toList();
        });
      } else {
        isError = true;
        errorMessage = 'Server error (${response.statusCode})';
      }
    } catch (e) {
      isError = true;
      errorMessage = 'Network error. Please try again.';
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // =====================================================
  // SINGLE SESSION TILE
  // =====================================================
  Widget _sessionTile(Map<String, dynamic> session) {
    final title = session['title'] ?? session['titel'] ?? 'Untitled';
    final unlock = session['unlock'] as Map<String, dynamic>? ?? {};

    final unlockedCount = [
      unlock['video'] == true,
      unlock['pdf'] == true,
      unlock['task'] == true,
      unlock['exam'] == true,
    ].where((e) => e).length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: const Icon(Icons.picture_as_pdf),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text('$unlockedCount / 4 unlocked'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SessionDetailPage(
                session: session,
                userId: widget.userId,
                courseId: widget.courseId,
                subjectId: widget.subjectId,
                sectionId: widget.sectionId,
              ),
            ),
          );

          // Refresh list when coming back
          _fetchSessions();
        },
      ),
    );
  }

  // =====================================================
  // UI
  // =====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sectionName ?? 'Sessions'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchSessions,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : isError
            ? Center(child: Text(errorMessage))
            : sessions.isEmpty
            ? const Center(child: Text('No sessions found'))
            : ListView.builder(
          itemCount: sessions.length,
          itemBuilder: (_, i) =>
              _sessionTile(sessions[i]),
        ),
      ),
    );
  }
}
