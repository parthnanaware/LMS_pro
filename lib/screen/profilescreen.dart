import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:http/http.dart' as http;
import 'package:lms_pro/singin/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import 'security_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool loading = true;
  Map<String, dynamic>? profile;

  final String apiBase = "https://abcf1818992c.ngrok-free.app";

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
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

    if (response.statusCode == 200 && data["success"] == true) {
      profile = data["data"];
    }

    loading = false;
    setState(() {});
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

    if (loading || profile == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: scheme.primary),
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(theme, scheme),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _menuSection(theme, scheme),
                  const SizedBox(height: 20),
                  _logoutButton(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.secondary],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          const Text(
            "Profile",
            style: TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Text(
              profile!["name"][0].toUpperCase(),
              style: TextStyle(
                fontSize: 40,
                color: scheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            profile!["name"],
            style: const TextStyle(color: Colors.white, fontSize: 22),
          ),
          Text(
            profile!["email"],
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _menuSection(ThemeData theme, ColorScheme scheme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          _menuItem(IconsaxPlusLinear.user_edit, "Edit Profile", () {}),
          _divider(),
          _menuItem(IconsaxPlusLinear.shield_tick, "Security", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SecurityPage()),
            );
          }),
          _divider(),
          _menuItem(IconsaxPlusLinear.notification, "Notifications", () {}),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(IconsaxPlusLinear.arrow_right_3),
      onTap: onTap,
    );
  }

  Widget _divider() => const Divider(height: 1);

  Widget _logoutButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: logout,
        icon: const Icon(IconsaxPlusLinear.logout),
        label: const Text("Logout"),
      ),
    );
  }
}
