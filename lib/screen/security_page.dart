import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final String apiBase = "https://abcf1818992c.ngrok-free.app";
  bool loading = true;
  List sessions = [];

  @override
  void initState() {
    super.initState();
    loadSessions();
  }

  Future<void> loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    final res = await http.get(
      Uri.parse("$apiBase/api/sessions"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    final data = jsonDecode(res.body);
    sessions = data["data"] ?? [];

    setState(() => loading = false);
  }

  Future<void> logoutSession(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    await http.delete(
      Uri.parse("$apiBase/api/sessions/$id"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    loadSessions();
  }

  Future<void> logoutAll() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    await http.post(
      Uri.parse("$apiBase/api/logout-all"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    loadSessions();
  }

  void openChangePasswordSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ChangePasswordSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Security")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListTile(
            leading: const Icon(IconsaxPlusLinear.lock),
            title: const Text("Change Password"),
            trailing: const Icon(IconsaxPlusLinear.arrow_right_3),
            onTap: openChangePasswordSheet,
          ),
          const SizedBox(height: 20),
          const Text(
            "Active Sessions",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          ...sessions.map((s) {
            return ListTile(
              leading: const Icon(IconsaxPlusLinear.mobile),
              title: Text(s["name"] ?? "Device"),
              subtitle:
              Text("Last active: ${s["last_used_at"] ?? "Now"}"),
              trailing: IconButton(
                icon: const Icon(IconsaxPlusLinear.logout,
                    color: Colors.red),
                onPressed: () => logoutSession(s["id"]),
              ),
            );
          }).toList(),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            icon: const Icon(IconsaxPlusLinear.logout),
            label: const Text("Logout From All Devices"),
            onPressed: logoutAll,
          ),
        ],
      ),
    );
  }
}

// =====================================================
// CHANGE PASSWORD SHEET
// =====================================================

class ChangePasswordSheet extends StatefulWidget {
  const ChangePasswordSheet({super.key});

  @override
  State<ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<ChangePasswordSheet> {
  final currentCtrl = TextEditingController();
  final newCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  final String apiBase = "https://abcf1818992c.ngrok-free.app";
  bool loading = false;

  Future<void> changePassword() async {
    if (newCtrl.text != confirmCtrl.text) {
      showMsg("Passwords do not match");
      return;
    }

    setState(() => loading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    final res = await http.post(
      Uri.parse("$apiBase/api/change-password"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
      body: {
        "current_password": currentCtrl.text,
        "new_password": newCtrl.text,
        "new_password_confirmation": confirmCtrl.text,
      },
    );

    setState(() => loading = false);

    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data["success"] == true) {
      Navigator.pop(context);
      showMsg("Password updated successfully");
    } else {
      showMsg(data["message"] ?? "Password update failed");
    }
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Change Password",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: currentCtrl,
            obscureText: true,
            decoration:
            const InputDecoration(labelText: "Current Password"),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: newCtrl,
            obscureText: true,
            decoration: const InputDecoration(labelText: "New Password"),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: confirmCtrl,
            obscureText: true,
            decoration:
            const InputDecoration(labelText: "Confirm New Password"),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: loading ? null : changePassword,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Update Password"),
            ),
          ),
        ],
      ),
    );
  }
}
