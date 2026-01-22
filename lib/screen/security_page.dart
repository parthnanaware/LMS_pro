import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:http/http.dart' as http;
import 'package:lms_pro/ApiHelper/apihelper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lms_pro/main.dart';

import 'privacy_policy_page.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final String apiBase = '${ApiHelper.baseUrl}';

  bool loading = true;
  bool twoFactorEnabled = false;
  List sessions = [];

  bool get isDark => themeNotifier.value == ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    loadSessions();
  }

  /* ================= DEVICE ================= */

  Future<String> getRealUserAgent() async {
    final info = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final a = await info.androidInfo;
      return "Android ${a.brand} ${a.model}";
    }
    if (Platform.isIOS) {
      final i = await info.iosInfo;
      return "iPhone ${i.name}";
    }
    return "Unknown Device";
  }

  String getDeviceName(String? ua) {
    if (ua == null) return "Unknown Device";
    final a = ua.toLowerCase();
    if (a.contains("android")) return "Android Phone";
    if (a.contains("iphone")) return "iPhone";
    if (a.contains("windows")) return "Windows PC";
    if (a.contains("mac")) return "Mac";
    if (a.contains("linux")) return "Linux";
    return "Smart Device";
  }

  IconData getDeviceIcon(String? ua) {
    if (ua == null) return IconsaxPlusLinear.devices;
    final a = ua.toLowerCase();
    if (a.contains("android")) return IconsaxPlusBold.mobile;
    if (a.contains("iphone")) return IconsaxPlusBold.mobile;
    if (a.contains("windows")) return IconsaxPlusBold.devices;
    if (a.contains("mac")) return IconsaxPlusBold.mobile;
    if (a.contains("linux")) return IconsaxPlusBold.cpu;
    return IconsaxPlusBold.devices;
  }

  Color getDeviceColor(String? ua) {
    if (ua == null) return Color(0xFF6366F1);
    final a = ua.toLowerCase();
    if (a.contains("android")) return Color(0xFF10B981);
    if (a.contains("iphone")) return Color(0xFF3B82F6);
    if (a.contains("windows")) return Color(0xFF6366F1);
    if (a.contains("mac")) return Color(0xFF6B7280);
    return Color(0xFF8B5CF6);
  }

  /* ================= API ================= */

  Future<void> loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    if (token == null) {
      setState(() => loading = false);
      return;
    }

    final ua = await getRealUserAgent();

    try {
      final res = await http.get(
        Uri.parse("$apiBase/api/sessions"),
        headers: {
          "Authorization": "Bearer $token",
          "User-Agent": ua,
        },
      );

      if (res.statusCode == 200) {
        sessions = jsonDecode(res.body)["data"] ?? [];
      }
    } catch (_) {}

    setState(() => loading = false);
  }

  Future<void> logoutSession(int id) async {
    HapticFeedback.lightImpact();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: isDark ? Color(0xFF1E293B) : Colors.white,
        title: Text(
          "Logout Device",
          style: TextStyle(
            color: isDark ? Colors.white : Color(0xFF1E293B),
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          "Are you sure you want to logout from this device?",
          style: TextStyle(
            color: isDark ? Color(0xFF94A3B8) : Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(
                color: Color(0xFF6366F1),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final prefs = await SharedPreferences.getInstance();
              final token = prefs.getString("auth_token");
              if (token == null) return;

              await http.delete(
                Uri.parse("$apiBase/api/sessions/$id"),
                headers: {"Authorization": "Bearer $token"},
              );

              setState(() => sessions.removeWhere((s) => s["id"] == id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFEF4444),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              "Logout",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> logoutAllSessions() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: isDark ? Color(0xFF1E293B) : Colors.white,
        title: Text(
          "Logout All Devices",
          style: TextStyle(
            color: isDark ? Colors.white : Color(0xFF1E293B),
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          "This will logout all devices except this one. Continue?",
          style: TextStyle(
            color: isDark ? Color(0xFF94A3B8) : Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(
                color: Color(0xFF6366F1),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final prefs = await SharedPreferences.getInstance();
              final token = prefs.getString("auth_token");
              if (token == null) return;

              try {
                await http.post(
                  Uri.parse("$apiBase/api/logout-all"),
                  headers: {"Authorization": "Bearer $token"},
                );

                // Reload sessions
                await loadSessions();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Logged out from all other devices"),
                    backgroundColor: Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Failed to logout devices"),
                    backgroundColor: Color(0xFFEF4444),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              "Logout All",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> changePassword(
      String current,
      String newPass,
      String confirm,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");
    if (token == null) return;

    try {
      final res = await http.post(
        Uri.parse("$apiBase/api/change-password"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
        body: {
          "current_password": current,
          "new_password": newPass,
          "new_password_confirmation": confirm,
        },
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data["success"] == true) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: isDark ? Color(0xFF1E293B) : Colors.white,
            icon: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Color(0xFF10B981).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                IconsaxPlusLinear.tick_circle,
                color: Color(0xFF10B981),
                size: 32,
              ),
            ),
            title: Text(
              "Password Changed",
              style: TextStyle(
                color: isDark ? Colors.white : Color(0xFF1E293B),
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            content: Text(
              "Your password has been changed successfully. You will be logged out from all devices for security.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Color(0xFF94A3B8) : Color(0xFF64748B),
              ),
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // Logout from all devices
                    await http.post(
                      Uri.parse("$apiBase/api/logout-all"),
                      headers: {"Authorization": "Bearer $token"},
                    );

                    // Clear local token
                    await prefs.remove("auth_token");

                    if (!mounted) return;

                    Navigator.of(context).pushNamedAndRemoveUntil(
                      "/login",
                          (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Continue to Login",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"] ?? "Something went wrong"),
            backgroundColor: Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Network error. Please try again."),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> showChangePasswordDialog() async {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    bool showCurrent = false;
    bool showNew = false;
    bool showConfirm = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 60,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Color(0xFF334155) : Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Change Password",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Update your account password",
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Color(0xFF94A3B8) : Color(0xFF64748B),
                      ),
                    ),
                    SizedBox(height: 24),
                    _passwordField(
                      controller: currentCtrl,
                      label: "Current Password",
                      showPassword: showCurrent,
                      onToggleVisibility: () => setState(() => showCurrent = !showCurrent),
                    ),
                    SizedBox(height: 16),
                    _passwordField(
                      controller: newCtrl,
                      label: "New Password",
                      showPassword: showNew,
                      onToggleVisibility: () => setState(() => showNew = !showNew),
                    ),
                    SizedBox(height: 16),
                    _passwordField(
                      controller: confirmCtrl,
                      label: "Confirm Password",
                      showPassword: showConfirm,
                      onToggleVisibility: () => setState(() => showConfirm = !showConfirm),
                    ),
                    SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              side: BorderSide(
                                color: isDark ? Color(0xFF334155) : Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: isDark ? Colors.white : Color(0xFF1E293B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(ctx);
                              await changePassword(
                                currentCtrl.text,
                                newCtrl.text,
                                confirmCtrl.text,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              "Update",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool showPassword,
    required VoidCallback onToggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF0F172A) : Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Color(0xFF334155) : Color(0xFFE2E8F0),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: !showPassword,
        style: TextStyle(
          color: isDark ? Colors.white : Color(0xFF1E293B),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? Color(0xFF94A3B8) : Color(0xFF64748B),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          suffixIcon: IconButton(
            onPressed: onToggleVisibility,
            icon: Icon(
              showPassword ? IconsaxPlusLinear.eye : IconsaxPlusLinear.eye_slash,
              color: isDark ? Color(0xFF94A3B8) : Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? Color(0xFF0F172A) : Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            expandedHeight: 160,
            backgroundColor: isDark ? Color(0xFF1E293B) : Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              expandedTitleScale: 1.5,
              centerTitle: true,
              title: Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  "Security",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Color(0xFF1E293B),
                  ),
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [Color(0xFF1E293B), Color(0xFF0F172A)]
                        : [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            sliver: loading ? _buildShimmer() : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return SliverList(
      delegate: SliverChildListDelegate([
        SizedBox(height: 20),
        Shimmer.fromColors(
          baseColor: isDark ? Color(0xFF334155) : Colors.grey.shade300,
          highlightColor: isDark ? Color(0xFF475569) : Colors.grey.shade100,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: isDark ? Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        SizedBox(height: 20),
        Shimmer.fromColors(
          baseColor: isDark ? Color(0xFF334155) : Colors.grey.shade300,
          highlightColor: isDark ? Color(0xFF475569) : Colors.grey.shade100,
          child: Container(
            height: 400,
            decoration: BoxDecoration(
              color: isDark ? Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildContent() {
    return SliverList(
      delegate: SliverChildListDelegate([
        SizedBox(height: 10),
        _buildSecurityOptions(),
        SizedBox(height: 30),
        _buildActiveSessions(),
        SizedBox(height: 40),
      ]),
    );
  }

  Widget _buildSecurityOptions() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black12 : Color(0xFFE2E8F0),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isDark ? Color(0xFF334155) : Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _securityOption(
            icon: IconsaxPlusLinear.lock_1,
            title: "Change Password",
            subtitle: "Update your account password",
            color: Color(0xFF6366F1),
            onTap: showChangePasswordDialog,
          ),
          Divider(
            height: 24,
            color: isDark ? Color(0xFF334155) : Color(0xFFE2E8F0),
          ),
          _securityOption(
            icon: IconsaxPlusLinear.shield_tick,
            title: "Two-Factor Authentication",
            subtitle: "Extra security for your account",
            color: Color(0xFF10B981),
            trailing: Container(
              width: 40,
              height: 24,
              decoration: BoxDecoration(
                gradient: twoFactorEnabled
                    ? LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF34D399)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
                    : null,
                color: twoFactorEnabled ? null : Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: AnimatedAlign(
                duration: Duration(milliseconds: 200),
                alignment: twoFactorEnabled ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  margin: EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            onTap: () => setState(() => twoFactorEnabled = !twoFactorEnabled),
          ),
          Divider(
            height: 24,
            color: isDark ? Color(0xFF334155) : Color(0xFFE2E8F0),
          ),
          _securityOption(
            icon: IconsaxPlusLinear.info_circle,
            title: "Privacy Policy",
            subtitle: "How we protect your data",
            color: Color(0xFF3B82F6),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _securityOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Color(0xFF94A3B8) : Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null)
                trailing
              else
                Icon(
                  IconsaxPlusLinear.arrow_right_3,
                  color: isDark ? Color(0xFF94A3B8) : Color(0xFF64748B),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveSessions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Active Sessions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : Color(0xFF1E293B),
              ),
            ),
            if (sessions.length > 1)
              TextButton(
                onPressed: logoutAllSessions,
                child: Text(
                  "Logout All",
                  style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 12),
        Text(
          "Devices currently logged into your account",
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Color(0xFF94A3B8) : Color(0xFF64748B),
          ),
        ),
        SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black12 : Color(0xFFE2E8F0),
                blurRadius: 15,
                offset: Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: isDark ? Color(0xFF334155) : Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          child: Column(
            children: sessions.map((session) {
              final index = sessions.indexOf(session);
              final isCurrent = session["is_current"] ?? false;
              return Column(
                children: [
                  _sessionTile(session, isCurrent),
                  if (index < sessions.length - 1)
                    Divider(
                      height: 1,
                      color: isDark ? Color(0xFF334155) : Color(0xFFE2E8F0),
                      indent: 20,
                      endIndent: 20,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _sessionTile(dynamic session, bool isCurrent) {
    final ua =
        session["user_agent"] ?? session["agent"] ?? session["device"] ?? "";
    final ip =
        session["ip_address"] ?? session["ip"] ?? "IP Unknown";
    final last =
        session["last_active"] ??
            session["last_activity"] ??
            session["last_active_at"] ??
            "Recently";

    final deviceName = getDeviceName(ua);
    final deviceIcon = getDeviceIcon(ua);
    final deviceColor = getDeviceColor(ua);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isCurrent ? null : () => logoutSession(session["id"]),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: deviceColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(deviceIcon, color: deviceColor, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          deviceName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Color(0xFF1E293B),
                          ),
                        ),
                        if (isCurrent)
                          Container(
                            margin: EdgeInsets.only(left: 8),
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Current",
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      "$ip • $last",
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Color(0xFF94A3B8) : Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isCurrent)
                IconButton(
                  onPressed: () => logoutSession(session["id"]),
                  icon: Icon(
                    IconsaxPlusLinear.logout,
                    color: Color(0xFFEF4444),
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

}