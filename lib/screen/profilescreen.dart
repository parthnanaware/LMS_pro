import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:http/http.dart' as http;
import 'package:lms_pro/screen/AboutAppPage.dart';
import 'package:lms_pro/singin/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lms_pro/main.dart';

import 'security_page.dart';
import 'privacy_policy_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool loading = true;
  Map<String, dynamic>? profile;

  final String apiBase = "https://9dbee0c9f126.ngrok-free.app";
  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    if (token == null) {
      setState(() => loading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("$apiBase/api/profile"),
        headers: {"Authorization": "Bearer $token"},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        profile = data["data"];
      }
    } catch (e) {
      debugPrint("Profile error: $e");
    }

    setState(() => loading = false);
  }

  Future<void> logout() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: isDark ? Color(0xFF1E293B) : Colors.white,
        title: Text(
          "Logout",
          style: TextStyle(
            color: isDark ? Colors.white : Color(0xFF1E293B),
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          "Are you sure you want to logout?",
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
              await prefs.clear();

              if (!mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
                    (_) => false,
              );
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

  bool get isDark => themeNotifier.value == ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (loading) {
      return Scaffold(
        backgroundColor: isDark ? Color(0xFF0F172A) : Color(0xFFF8FAFC),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Color(0xFF6366F1),
                strokeWidth: 2,
              ),
              SizedBox(height: 16),
              Text(
                "Loading profile...",
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (profile == null) {
      return Scaffold(
        backgroundColor: isDark ? Color(0xFF0F172A) : Color(0xFFF8FAFC),
        body: Center(
          child: ElevatedButton(
            onPressed: loadProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              "Retry Loading Profile",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF0F172A) : Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            expandedHeight: 200,
            backgroundColor: isDark ? Color(0xFF1E293B) : Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              expandedTitleScale: 1.5,
              centerTitle: true,
              title: Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  "Profile",
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
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SizedBox(height: 10),
                _buildProfileHeader(),
                SizedBox(height: 30),
                _buildStatsSection(),
                SizedBox(height: 30),
                _buildAccountSettings(),
                SizedBox(height: 30),
                _buildAppSettings(),
                SizedBox(height: 30),
                _buildSupportSection(),
                SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final name = profile!["name"];
    final email = profile!["email"];
    final initials = name.substring(0, 2).toUpperCase();

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
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: isDark ? Color(0xFF1E293B) : Colors.white,
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF6366F1),
                ),
              ),
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Color(0xFF94A3B8) : Color(0xFF64748B),
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(IconsaxPlusLinear.verify, size: 14, color: Color(0xFF10B981)),
                      SizedBox(width: 6),
                      Text(
                        "Verified Account",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    final stats = [
      {"label": "Courses", "value": "12", "icon": IconsaxPlusLinear.book_1, "color": Color(0xFF6366F1)},
      {"label": "Hours", "value": "36h", "icon": IconsaxPlusLinear.clock, "color": Color(0xFF10B981)},
      {"label": "Certificates", "value": "3", "icon": IconsaxPlusLinear.award, "color": Color(0xFFF59E0B)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            "Learning Stats",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Color(0xFF1E293B),
            ),
          ),
        ),
        Row(
          children: stats.map((stat) {
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: stats.indexOf(stat) < stats.length - 1 ? 12 : 0),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black12 : Color(0xFFE2E8F0),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: isDark ? Color(0xFF334155) : Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: (stat["color"] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        stat["icon"] as IconData,
                        color: stat["color"] as Color,
                        size: 20,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      stat["value"] as String,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      stat["label"] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Color(0xFF94A3B8) : Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAccountSettings() {
    final accountItems = [
      {
        "icon": IconsaxPlusLinear.shield_tick,
        "label": "Security",
        "color": Color(0xFF6366F1),
        "onTap": () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SecurityPage()),
          );
        },
      },
      {
        "icon": IconsaxPlusLinear.lock,
        "label": "Privacy",
        "color": Color(0xFF10B981),
        "onTap": () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
          );
        },
      },
      {
        "icon": IconsaxPlusLinear.notification,
        "label": "Notifications",
        "color": Color(0xFFF59E0B),
        "onTap": () {},
      },
      {
        "icon": IconsaxPlusLinear.message,
        "label": "Messages",
        "color": Color(0xFFEC4899),
        "onTap": () {},
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            "Account Settings",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Color(0xFF1E293B),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
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
            children: accountItems.map((item) {
              final index = accountItems.indexOf(item);
              return Column(
                children: [
                  _settingsTile(
                    icon: item["icon"] as IconData,
                    label: item["label"] as String,
                    color: item["color"] as Color,
                    onTap: item["onTap"] as VoidCallback,
                  ),
                  if (index < accountItems.length - 1)
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

  Widget _buildAppSettings() {
    final appItems = [
      {
        "icon": IconsaxPlusLinear.moon,
        "label": "Dark Mode",
        "color": Color(0xFF8B5CF6),
        "trailing": Switch(
          value: isDark,
          onChanged: (value) => MyApp.setTheme(value),
          activeColor: Color(0xFF6366F1),
        ),
        "onTap": () => MyApp.setTheme(!isDark),
      },
      {
        "icon": IconsaxPlusLinear.language_square,
        "label": "Language",
        "color": Color(0xFF3B82F6),
        "trailing": Text(
          "English",
          style: TextStyle(
            color: isDark ? Color(0xFF94A3B8) : Color(0xFF64748B),
          ),
        ),
        "onTap": () {},
      },
      {
        "icon": IconsaxPlusLinear.setting_2,
        "label": "General Settings",
        "color": Color(0xFF6B7280),
        "onTap": () {},
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            "App Settings",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Color(0xFF1E293B),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
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
            children: appItems.map((item) {
              final index = appItems.indexOf(item);
              return Column(
                children: [
                  _settingsTile(
                    icon: item["icon"] as IconData,
                    label: item["label"] as String,
                    color: item["color"] as Color,
                    trailing: item["trailing"] as Widget?,
                    onTap: item["onTap"] as VoidCallback,
                  ),
                  if (index < appItems.length - 1)
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

  Widget _buildSupportSection() {
    final supportItems = [
      {
        "icon": IconsaxPlusLinear.headphone,
        "label": "Help & Support",
        "color": Color(0xFF059669),
        "onTap": () {},
      },
      {
        "icon": IconsaxPlusLinear.info_circle,
        "label": "About App",
        "color": Color(0xFF3B82F6),
        "onTap": () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AboutAppPage()),
          );
        },
      },
      {
        "icon": IconsaxPlusLinear.logout,
        "label": "Logout",
        "color": Color(0xFFEF4444),
        "onTap": logout,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            "Support",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Color(0xFF1E293B),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
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
            children: supportItems.map((item) {
              final index = supportItems.indexOf(item);
              return Column(
                children: [
                  _settingsTile(
                    icon: item["icon"] as IconData,
                    label: item["label"] as String,
                    color: item["color"] as Color,
                    onTap: item["onTap"] as VoidCallback,
                    isLogout: item["label"] == "Logout",
                  ),
                  if (index < supportItems.length - 1)
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

  Widget _settingsTile({
    required IconData icon,
    required String label,
    required Color color,
    Widget? trailing,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isLogout ? Color(0xFFEF4444) : (isDark ? Colors.white : Color(0xFF1E293B)),
                  ),
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
}