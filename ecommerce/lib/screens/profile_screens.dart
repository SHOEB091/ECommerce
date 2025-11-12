import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Section
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.04,
                vertical: height * 0.02,
              ),
              color: Colors.white,
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundImage: AssetImage('assets/sample9.jpg'),
                  ),
                  SizedBox(width: width * 0.04),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Shivam",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Hey there! I am using Flutter.",
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.qr_code, color: Colors.green.shade600),
                      const SizedBox(width: 15),
                      Icon(Icons.add_circle_outline,
                          color: Colors.green.shade600),
                    ],
                  )
                ],
              ),
            ),
            const Divider(height: 1),

            // Settings Options
            buildSection(context, [
              buildListTile(Icons.key, "Account",
                  "Security notifications, change number"),
              buildListTile(Icons.lock, "Privacy",
                  "Block contacts, disappearing messages"),
              buildListTile(Icons.face, "Avatar",
                  "Create, edit, profile photo"),
            ]),

            buildSection(context, [
              buildListTile(Icons.list_alt, "Lists",
                  "Manage people and groups"),
              buildListTile(Icons.chat, "Chats",
                  "Theme, wallpapers, chat history"),
              buildListTile(Icons.broadcast_on_home, "Broadcasts",
                  "Manage lists and send broadcasts"),
            ]),

            buildSection(context, [
              buildListTile(Icons.notifications, "Notifications",
                  "Message, group & call tones"),
              buildListTile(Icons.data_usage, "Storage and data",
                  "Network usage, auto-download"),
            ]),

            buildSection(context, [
              buildListTile(Icons.help_outline, "Help",
                  "Help center, contact us, privacy policy"),
            ]),

            const SizedBox(height: 15),
            const Text(
              "from",
              style: TextStyle(color: Colors.grey),
            ),
            const Text(
              "Flutter UI",
              style: TextStyle(
                  color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
      backgroundColor: const Color(0xfff5f5f5),
    );
  }

  // Helper widgets
  Widget buildSection(BuildContext context, List<Widget> tiles) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 10),
      child: Column(children: tiles),
    );
  }

  Widget buildListTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade700),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.grey, fontSize: 14),
      ),
    );
  }
}
