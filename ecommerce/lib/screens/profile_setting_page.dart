import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileSettingPage extends StatefulWidget {
  const ProfileSettingPage({super.key});

  @override
  State<ProfileSettingPage> createState() => _ProfileSettingPageState();
}

class _ProfileSettingPageState extends State<ProfileSettingPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool isLoading = false;

  // 👇 For Chrome (localhost) or emulator (10.0.2.2)
  final String baseUrl = 'http://localhost:5000/api/profile';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // 🔹 Fetch profile from backend
  Future<void> _loadUserProfile() async {
    setState(() => isLoading = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token'); // if login token stored

      final response = await http.get(
        Uri.parse('$baseUrl/getById'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          final user = data['data'];
          setState(() {
            firstNameController.text = user['firstName'] ?? '';
            lastNameController.text = user['lastName'] ?? '';
            emailController.text = user['email'] ?? '';
            phoneController.text = user['phone'] ?? '';
          });
        }
      } else {
        print("⚠️ Failed to load profile: ${response.body}");
      }
    } catch (e) {
      print("❌ Error loading profile: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // 🔹 Update profile
  Future<void> _updateUserProfile() async {
    setState(() => isLoading = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('$baseUrl/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          "firstName": firstNameController.text,
          "lastName": lastNameController.text,
          "email": emailController.text,
          "phone": phoneController.text,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Profile updated successfully!')),
        );
        Navigator.pop(context); // back to ProfilePage
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ Update failed: ${data['message']}')),
        );
      }
    } catch (e) {
      print('❌ Error updating profile: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error updating profile')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      const CircleAvatar(
                        radius: 45,
                        backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/150?img=47',
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildTextField('First Name', firstNameController),
                  _buildTextField('Last Name', lastNameController),
                  _buildTextField('Email', emailController),
                  _buildTextField('Phone', phoneController),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: _updateUserProfile,
                    child: const Text(
                      'Save changes',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
        ),
      ),
    );
  }
}
