import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api.dart';
import '../widgets/custom_textfield.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  bool loading = false;

  // Basic helper to perform a PUT request; replace baseUrl with your API host if needed.
  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('http://localhost:5000$path');
    final resp = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return {'status': resp.statusCode, 'body': resp.body};
  }

  Future<void> updateProfile() async {
    setState(() => loading = true);
    final res = await put("/profile/update", {
      "id": "673d4b12fc9f73e45a4a27f0", // apna actual MongoDB _id lagao
      "firstName": _firstName.text,
      "lastName": _lastName.text,
      "email": _email.text,
      "phone": _phone.text,
    });

    setState(() => loading = false);

    if (res['status'] == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Profile updated successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed: ${res['body']}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CustomTextField(controller: _firstName, hint: "First Name"),
            const SizedBox(height: 10),
            CustomTextField(controller: _lastName, hint: "Last Name"),
            const SizedBox(height: 10),
            CustomTextField(controller: _email, hint: "Email"),
            const SizedBox(height: 10),
            CustomTextField(controller: _phone, hint: "Phone"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : updateProfile,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
