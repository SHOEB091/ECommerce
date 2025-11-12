import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddressManager extends StatefulWidget {
  const AddressManager({super.key});

  @override
  State<AddressManager> createState() => _AddressManagerState();
}

class _AddressManagerState extends State<AddressManager> {
  // ✅ Use 127.0.0.1 instead of localhost (works in Chrome/web)
  final String apiUrl = 'http://127.0.0.1:5000/api/address';
  List<Map<String, dynamic>> addresses = [];

  @override
  void initState() {
    super.initState();
    fetchAddresses();
  }

  // ✅ Fetch all saved addresses
  Future<void> fetchAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return;

      final res = await http.get(Uri.parse(apiUrl), headers: {
        'Authorization': 'Bearer $token',
      });

      if (res.statusCode == 200) {
        setState(() {
          addresses = List<Map<String, dynamic>>.from(jsonDecode(res.body));
        });
      } else {
        print('❌ Failed to fetch addresses: ${res.statusCode} -> ${res.body}');
      }
    } catch (e) {
      print('⚠️ Error fetching addresses: $e');
    }
  }

  // ✅ Add or Edit Address
  void addOrEditAddress({Map<String, dynamic>? addr}) {
    final nameController = TextEditingController(text: addr?['name'] ?? '');
    final streetController = TextEditingController(text: addr?['street'] ?? '');
    final cityController = TextEditingController(text: addr?['city'] ?? '');
    final stateController = TextEditingController(text: addr?['state'] ?? '');
    final zipController = TextEditingController(text: addr?['zip'] ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(addr == null ? 'Add Address' : 'Edit Address'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: streetController, decoration: const InputDecoration(labelText: 'Street')),
              TextField(controller: cityController, decoration: const InputDecoration(labelText: 'City')),
              TextField(controller: stateController, decoration: const InputDecoration(labelText: 'State')),
              TextField(controller: zipController, decoration: const InputDecoration(labelText: 'Zip')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final prefs = await SharedPreferences.getInstance();
                final token = prefs.getString('token');
                if (token == null) return;

                final body = jsonEncode({
                  'name': nameController.text.trim(),
                  'street': streetController.text.trim(),
                  'city': cityController.text.trim(),
                  'state': stateController.text.trim(),
                  'zip': zipController.text.trim(),
                });

                final url = addr == null
                    ? Uri.parse(apiUrl)
                    : Uri.parse('$apiUrl/${addr['_id']}');

                final res = await (addr == null
                    ? http.post(url,
                        headers: {
                          'Content-Type': 'application/json',
                          'Authorization': 'Bearer $token'
                        },
                        body: body)
                    : http.put(url,
                        headers: {
                          'Content-Type': 'application/json',
                          'Authorization': 'Bearer $token'
                        },
                        body: body));

                if (res.statusCode == 200 || res.statusCode == 201) {
                  print("✅ Address saved successfully: ${res.body}");
                  if (mounted) {
                    Navigator.pop(context);
                    fetchAddresses();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Address saved successfully!')),
                    );
                  }
                } else {
                  print("❌ Failed to save address: ${res.statusCode} -> ${res.body}");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to save: ${res.body}')),
                  );
                }
              } catch (e) {
                print('⚠️ Error saving address: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ✅ Delete Address
  Future<void> deleteAddress(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return;

      final res = await http.delete(
        Uri.parse('$apiUrl/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        print("🗑️ Address deleted successfully");
        fetchAddresses();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address deleted')),
        );
      } else {
        print("❌ Delete failed: ${res.statusCode} -> ${res.body}");
      }
    } catch (e) {
      print('⚠️ Error deleting address: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Addresses')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addOrEditAddress(),
        child: const Icon(Icons.add),
      ),
      body: addresses.isEmpty
          ? const Center(child: Text('No addresses yet'))
          : ListView.builder(
              itemCount: addresses.length,
              itemBuilder: (_, i) {
                final a = addresses[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  elevation: 3,
                  child: ListTile(
                    title: Text(a['name'] ?? ''),
                    subtitle: Text('${a['street']}, ${a['city']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => addOrEditAddress(addr: a),
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () => deleteAddress(a['_id']),
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
