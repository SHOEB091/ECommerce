import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = [
      {'icon': Icons.language, 'label': 'Language'},
      {'icon': Icons.notifications_none, 'label': 'Notification'},
      {'icon': Icons.description_outlined, 'label': 'Terms of Use'},
      {'icon': Icons.info_outline, 'label': 'Privacy Policy'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Setting',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.separated(
          itemCount: settings.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = settings[index];
            return ListTile(
              leading: Icon(item['icon'] as IconData, color: Colors.black87),
              title: Text(
                item['label'] as String,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.black54),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item['label']} tapped')),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
