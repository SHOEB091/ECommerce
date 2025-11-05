import 'package:flutter/material.dart';
import 'profile_page.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  bool showSearch = false;
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, String>> categories = [
    {
      'title': 'Clothing',
      'image': 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246',
    },
    {
      'title': 'Accessories',
      'image': 'https://images.unsplash.com/photo-1519744792095-2f2205e87b6f',
    },
    {
      'title': 'Shoes',
      'image': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff',
    },
    {
      'title': 'Collection',
      'image': 'https://images.unsplash.com/photo-1521334884684-d80222895322',
    },
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Discover',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child:
            showSearch ? _buildSearchView(isTablet) : _buildDiscoverView(isTablet),
      ),

      // 🔽 Bottom Navigation Bar with Profile navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
        ],
      ),
    );
  }

  // 🔍 Search bar widget
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {},
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        onTap: () {
          setState(() {
            showSearch = true;
          });
        },
      ),
    );
  }

  // 🏷️ Discover grid view
  Widget _buildDiscoverView(bool isTablet) {
    final crossAxisCount = isTablet ? 2 : 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: crossAxisCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: isTablet ? 2.5 : 1.9,
            children:
                categories.map((category) => _buildCategoryCard(category)).toList(),
          ),
        ],
      ),
    );
  }

  // 🔍 Search result / popular section
  Widget _buildSearchView(bool isTablet) {
    final recentSearches = ["Sunglasses", "Sweater", "Hoodie"];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                  onPressed: () => setState(() => showSearch = false),
                ),
                Expanded(child: _buildSearchBar()),
              ],
            ),
            const SizedBox(height: 10),
            const Text('Recent Searches',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: recentSearches
                  .map((item) => Chip(
                        label: Text(item),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {},
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Popular this week',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Show all', style: TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: isTablet ? 3 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: isTablet ? 0.9 : 0.8,
              children: [
                _buildPopularItem('Lihua Tunic White', '\$53.00',
                    'https://images.unsplash.com/photo-1554568218-0f1715e72254'),
                _buildPopularItem('Denim Jacket', '\$45.00',
                    'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c'),
                _buildPopularItem('Casual Shirt', '\$29.00',
                    'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91'),
                _buildPopularItem('Blue Sweater', '\$39.00',
                    'https://images.unsplash.com/photo-1521334884684-d80222895322'),
                _buildPopularItem('Skirt Dress', '\$34.00',
                    'https://images.unsplash.com/photo-1551024601-bec78aea704b')
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🛍️ Popular item card
  static Widget _buildPopularItem(String name, String price, String imageUrl) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child:
                  Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 13)),
                Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // 🧭 Category Card with image
  Widget _buildCategoryCard(Map<String, String> category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CategoryDetailPage(title: category['title']!)),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(category['image']!),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.black.withOpacity(0.4), Colors.transparent],
            ),
          ),
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              category['title']!.toUpperCase(),
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

// 👇 Keep your CategoryDetailPage (same as before)
class CategoryDetailPage extends StatelessWidget {
  final String title;
  const CategoryDetailPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    final Map<String, List<Map<String, dynamic>>> categoryItems = {
      'Clothing': [
        {
          'name': 'Jacket',
          'count': 128,
          'image': 'https://images.unsplash.com/photo-1521335629791-ce4aec67dd47',
          'desc': 'Stay warm and stylish with our trendy jackets.'
        },
        {
          'name': 'Skirts',
          'count': 40,
          'image': 'https://images.unsplash.com/photo-1512436991641-6745cdb1723f',
          'desc': 'Elegant skirts perfect for all occasions.'
        },
        {
          'name': 'Dresses',
          'count': 36,
          'image': 'https://images.unsplash.com/photo-1521335629791-ce4aec67dd47',
          'desc': 'Chic dresses to elevate your wardrobe.'
        },
        {
          'name': 'Sweaters',
          'count': 24,
          'image': 'https://images.unsplash.com/photo-1503341455253-b2e723bb3dbb',
          'desc': 'Soft and cozy sweaters for comfort and warmth.'
        },
      ],
      'Shoes': [
        {
          'name': 'Sneakers',
          'count': 58,
          'image': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff',
          'desc': 'Comfortable and stylish sneakers for daily use.'
        },
        {
          'name': 'Heels',
          'count': 42,
          'image': 'https://images.unsplash.com/photo-1519741497674-611481863552',
          'desc': 'Elegant heels to complete your outfit.'
        },
      ],
    };

    final items = categoryItems[title] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: isTablet ? screenWidth * 0.1 : 10),
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 1.5,
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    item['image'],
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(item['name'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Text(item['desc'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
                trailing: Text('${item['count']} items',
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, color: Colors.black54)),
                onTap: () {},
              ),
            );
          },
        ),
      ),
    );
  }
}
