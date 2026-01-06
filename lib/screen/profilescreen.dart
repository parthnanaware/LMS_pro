import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:http/http.dart' as http;
import 'package:lms_pro/singin/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart'; // for themeNotifier

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool loading = true;
  Map<String, dynamic>? profile;

  final String apiBase = "https://82e50f0ae86b.ngrok-free.app";

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");

      if (token == null) {
        loading = false;
        setState(() {});
        return;
      }

      final response = await http.get(
        Uri.parse("$apiBase/api/profile"),
        headers: {"Authorization": "Bearer $token"},
      );

      final data = jsonDecode(response.body);
      print("PROFILE RESPONSE → $data");

      if (response.statusCode == 200 && data["success"] == true) {
        profile = data["data"];
      }

      loading = false;
      setState(() {});
    } catch (e) {
      loading = false;
      setState(() {});
      print("Profile Error: $e");
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
          (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = themeNotifier.value == ThemeMode.dark;

    if (loading || profile == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: scheme.primary,
          ),
        ),
      );
    }

    String name = profile!["name"] ?? "User";
    String email = profile!["email"] ?? "";
    String role = (profile!["role"] ?? "student").toString().toUpperCase();
    String photo = profile!["photo_url"] ?? "";
    String userId = profile!["id"].toString();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(theme, scheme, name, email, role, photo),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _infoGrid(theme, scheme, userId),
                  const SizedBox(height: 20),

                  _darkModeTile(theme, scheme),
                  const SizedBox(height: 20),

                  _menuSection(theme, scheme),
                  const SizedBox(height: 20),

                  _logoutButton(theme, scheme),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // HEADER WITH GRADIENT
  // -------------------------------------------------------------------

  Widget _buildHeader(
      ThemeData theme,
      ColorScheme scheme,
      String name,
      String email,
      String role,
      String photo,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primary,
            scheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // BACK + TITLE + SETTINGS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _iconButton(IconsaxPlusLinear.arrow_left_2, () {
                Navigator.pop(context);
              }, Colors.white),

              const Text(
                "Profile",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              _iconButton(IconsaxPlusLinear.setting_2, () {}, Colors.white),
            ],
          ),

          const SizedBox(height: 20),

          // AVATAR
          CircleAvatar(
            radius: 52,
            backgroundColor: Colors.white,
            backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
            child: photo.isEmpty
                ? Text(
              name[0].toUpperCase(),
              style: TextStyle(
                fontSize: 40,
                color: scheme.primary,
                fontWeight: FontWeight.bold,
              ),
            )
                : null,
          ),

          const SizedBox(height: 16),

          // NAME / EMAIL
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            email,
            style: TextStyle(
              color: Colors.white.withOpacity(.9),
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 10),

          // ROLE PILL
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              role,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // INFO GRID
  // -------------------------------------------------------------------

  Widget _infoGrid(ThemeData theme, ColorScheme scheme, String userId) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _infoCard(theme, scheme, IconsaxPlusLinear.user_tag, "User ID", userId),
        _infoCard(theme, scheme, IconsaxPlusLinear.calendar, "Member Since", "2024"),
        _infoCard(theme, scheme, IconsaxPlusLinear.book, "Courses", "12"),
        _infoCard(theme, scheme, IconsaxPlusLinear.chart, "Progress", "85%"),
      ],
    );
  }

  Widget _infoCard(
      ThemeData theme,
      ColorScheme scheme,
      IconData icon,
      String title,
      String value,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: scheme.primary.withOpacity(.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: scheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // DARK MODE SWITCH
  // -------------------------------------------------------------------

  Widget _darkModeTile(ThemeData theme, ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            themeNotifier.value == ThemeMode.dark
                ? IconsaxPlusLinear.sun_1
                : IconsaxPlusLinear.moon,
            color: scheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "Dark Mode",
              style: theme.textTheme.titleMedium,
            ),
          ),
          Switch(
            value: themeNotifier.value == ThemeMode.dark,
            activeColor: scheme.secondary,
            onChanged: (v) {
              MyApp.setTheme(v);
            },
          )
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // MENU SECTION
  // -------------------------------------------------------------------

  Widget _menuSection(ThemeData theme, ColorScheme scheme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _menuItem(theme, scheme, IconsaxPlusLinear.user_edit, "Edit Profile", () {}),
          _divider(theme),
          _menuItem(theme, scheme, IconsaxPlusLinear.shield_tick, "Security", () {}),
          _divider(theme),
          _menuItem(theme, scheme, IconsaxPlusLinear.notification, "Notifications", () {}),
          _divider(theme),
          _menuItem(theme, scheme, IconsaxPlusLinear.message_question, "Support", () {}),
        ],
      ),
    );
  }

  Widget _menuItem(
      ThemeData theme, ColorScheme scheme, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: scheme.primary),
      title: Text(title, style: theme.textTheme.titleMedium),
      trailing: Icon(IconsaxPlusLinear.arrow_right_3,
          color: theme.colorScheme.onSurface.withOpacity(.4)),
    );
  }

  Widget _divider(ThemeData theme) {
    return Divider(color: theme.dividerColor.withOpacity(.3), height: 1);
  }

  // -------------------------------------------------------------------
  // LOGOUT BUTTON
  // -------------------------------------------------------------------

  Widget _logoutButton(ThemeData theme, ColorScheme scheme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: logout,
        icon: const Icon(IconsaxPlusLinear.logout),
        label: const Text(
          "Logout",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.25),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: color),
      ),
    );
  }
}
