<<<<<<< HEAD
import 'package:ecommerce/screens/settings_page.dart';
=======
// lib/screens/home_screen.dart
>>>>>>> 2b7753b0dca027aa15ac7ca508e40b69ad39c346
import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'notifications_screen.dart';
import 'discover_page.dart';
import 'admin/admin_panel.dart';
import 'mens_product_list_screen.dart';
import 'womens_product_list_screen.dart';
import 'accessories_product_list_screen.dart';
import 'category_detail_page.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategory = 0;
  int _bottomIndex = 0;

  static const String promo = 'assets/promo.png';
  static const String p1 = 'assets/product1.png';
  static const String p2 = 'assets/product2.png';
  static const String p3 = 'assets/product3.png';
  static const String p4 = 'assets/product4.png';
  static const String t1 = 'assets/product_thumb1.png';
  static const String t2 = 'assets/product_thumb2.png';

  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.female, 'label': 'Women'},
    {'icon': Icons.male, 'label': 'Men'},
    {'icon': Icons.watch, 'label': 'Watches'},
    {'icon': Icons.tag, 'label': 'Accessories'},
    {'icon': Icons.grid_view, 'label': 'All'},
    {'icon': Icons.admin_panel_settings, 'label': 'Admin'}, // admin action
  ];

  final List<Map<String, String>> _feature = [
    {'img': p1, 'title': 'Turtleneck Sweater', 'price': '\$39.99'},
    {'img': p2, 'title': 'Long Sleeve Dress', 'price': '\$45.00'},
    {'img': p3, 'title': 'Sportwear', 'price': '\$80.00'},
    {'img': p4, 'title': 'Casual Jacket', 'price': '\$64.00'},
  ];

  final List<Map<String, String>> _recommended = [
    {'img': t1, 'title': 'White fashion hoodie', 'price': '\$29.00'},
    {'img': t2, 'title': 'Cotton shirt', 'price': '\$30.00'},
    {'img': t1, 'title': 'Striped tee', 'price': '\$20.00'},
  ];

  Widget _imageFallback({double? height}) {
    return Container(
      height: height,
      color: Colors.grey[100],
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 34, color: Colors.grey),
      ),
    );
  }

<<<<<<< HEAD
 Widget _categoryTile(int index) {
  final item = _categories[index];
  final selected = _selectedCategory == index;

  return GestureDetector(
    onTap: () {
      setState(() => _selectedCategory = index);

      // ✅ Handle navigation based on label
      switch (item['label']) {
        case 'All':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DiscoverPage()),
          );
          break;

        default:
          // For any other category, you can define logic here if needed
          debugPrint('Selected category: ${item['label']}');
      }
    },
    child: Container(
      width: 72,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFF3EDE9) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : null,
=======
  // ---------- NAV HELPERS ----------
  void _openProduct(Map<String, String> product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProductDetails(product: product)),
    );
  }

  void _openCategory(String label) {
    switch (label) {
      case 'Women':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const WomenProductListScreen()));
        break;
      case 'Men':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const MensProductListScreen()));
        break;
      case 'Watches':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryDetailPage(title: 'Watches')));
        break;
      case 'Accessories':
        Navigator.push(context, MaterialPageRoute(builder: (_) => AccessoriesProductListScreen()));
        break;
      case 'All':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const DiscoverPage()));
        break;
      case 'Admin':
        Navigator.push(context, MaterialPageRoute(builder: (_) => AdminPanel()));
        break;
      default:
        break;
    }
  }
  // ---------- NAV HELPERS END ----------

  Widget _categoryTile(int index, {double size = 72}) {
    final item = _categories[index];
    final selected = _selectedCategory == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedCategory = index);
        _openCategory(item['label'] as String);
      },
      child: Container(
        width: size,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFF3EDE9) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: selected
                    ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 3))]
                    : null,
              ),
              child: Icon(item['icon'] as IconData, color: Colors.black54, size: 22),
>>>>>>> 2b7753b0dca027aa15ac7ca508e40b69ad39c346
            ),
            child: Icon(
              item['icon'] as IconData,
              color: Colors.black54,
              size: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item['label'] as String,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    ),
  );
}


  Widget _featureCard(Map<String, String> item, {double? width, double imageHeight = 140}) {
    final heroTag = 'hero-${item['title']}';
    return InkWell(
      onTap: () => _openProduct(item),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: width,
        margin: const EdgeInsets.only(right: 14, bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: imageHeight,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.hardEdge,
              child: Hero(
                tag: heroTag,
                child: Image.asset(
                  item['img']!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _imageFallback(height: imageHeight),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(item['title']!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(item['price']!, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const Spacer(),
          if (onSeeAll != null) GestureDetector(onTap: onSeeAll, child: const Text('Show all', style: TextStyle(color: Colors.blue))),
        ],
      ),
    );
  }

  void _onBottomTap(int idx) {
    setState(() => _bottomIndex = idx);
    if (idx == 0) return;
    final text = idx == 1 ? 'Search' : idx == 2 ? 'Bag' : 'Account';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Widget _productThumb(Map<String, String> item) {
    final heroTag = 'hero-${item['title']}';
    return InkWell(
      onTap: () => _openProduct(item),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey[200]),
              clipBehavior: Clip.hardEdge,
              child: Hero(
                tag: heroTag,
                child: Image.asset(item['img']!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _imageFallback()),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item['title']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(item['price']!, style: const TextStyle(color: Colors.grey)),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallTile(String title, String asset) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey[100]),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('Browse', style: TextStyle(color: Colors.grey)),
            ]),
          ),
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey[200]),
            clipBehavior: Clip.hardEdge,
            child: Image.asset(asset, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _imageFallback()),
          ),
        ],
      ),
    );
  }

  Widget _drawerContent() {
    return SafeArea(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(bottomRight: Radius.circular(18)),
            ),
            child: Row(
              children: [
                const CircleAvatar(radius: 30, backgroundColor: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                    Text('Hello, Guest', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    SizedBox(height: 4),
                    Text('guest@example.com', style: TextStyle(color: Colors.grey)),
                  ]),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.edit, size: 20, color: Colors.black54)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                ListTile(leading: const Icon(Icons.person_outline), title: const Text('Profile'), onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile tapped')));
                }),
                ListTile(leading: const Icon(Icons.favorite_border), title: const Text('Wishlist'), onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wishlist tapped')));
                }),
                ListTile(leading: const Icon(Icons.shopping_bag_outlined), title: const Text('Orders'), onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Orders tapped')));
                }),
                const Divider(),
                ListTile(leading: const Icon(Icons.settings_outlined), title: const Text('Settings'), onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings tapped')));
                }),
                ListTile(leading: const Icon(Icons.help_outline), title: const Text('Help & Support'), onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Help tapped')));
                }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.login_outlined),
                    label: const Text('Sign In'),
                    onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign In tapped'))); },
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Log out tapped'))); },
                  icon: const Icon(Icons.logout),
                  tooltip: 'Log out',
                )
              ],
            ),
<<<<<<< HEAD

            const SizedBox(height: 8),

            // menu items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  ListTile(leading: const Icon(Icons.person_outline), title: const Text('Profile'), onTap: () {
                    // navigate or handle
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile tapped')));
                  }),
                  ListTile(leading: const Icon(Icons.favorite_border), title: const Text('Wishlist'), onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wishlist tapped')));
                  }),
                  ListTile(leading: const Icon(Icons.shopping_bag_outlined), title: const Text('Orders'), onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Orders tapped')));
                  }),
                  const Divider(),
                 ListTile(
                     leading: const Icon(Icons.settings_outlined),
                       title: const Text('Settings'),
                         onTap: () {
                           Navigator.pop(context); // close drawer first
                              Navigator.push(
                                 context,
                                    MaterialPageRoute(builder: (context) => const SettingsPage()),
                                        );
                              },
                          ),

                  ListTile(leading: const Icon(Icons.help_outline), title: const Text('Help & Support'), onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Help tapped')));
                  }),
                ],
              ),
            ),

            // bottom actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.login_outlined),
                      label: const Text('Sign In'),
                      onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign In tapped'))); },
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Log out tapped'))); },
                    icon: const Icon(Icons.logout),
                    tooltip: 'Log out',
                  )
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
=======
          ),
          const SizedBox(height: 8),
        ],
>>>>>>> 2b7753b0dca027aa15ac7ca508e40b69ad39c346
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double horizontalPad = 18.0;
    final double bottomPadding = MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight + 16;

    return LayoutBuilder(builder: (context, constraints) {
      final double width = constraints.maxWidth;
      final bool isDesktop = width >= 800;

      Widget content = SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isDesktop) ...[
                SizedBox(
                  height: 92,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 8),
                    itemCount: _categories.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, i) => _categoryTile(i),
                  ),
                ),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 12),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: List.generate(_categories.length, (i) => _categoryTile(i, size: 96)),
                  ),
                ),
              ],
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: horizontalPad),
                child: Container(
                  height: isDesktop ? 240 : 140,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: Colors.grey[100]),
                  clipBehavior: Clip.hardEdge,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        promo,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: Colors.grey[100], child: const Center(child: Icon(Icons.local_offer_outlined, size: 44, color: Colors.grey))),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withOpacity(0.28), Colors.transparent]),
                        ),
                        padding: const EdgeInsets.all(14),
                        alignment: Alignment.bottomLeft,
                        child: const Text('Autumn Collection\n2021', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _sectionHeader('Feature Products', onSeeAll: () {}),
              const SizedBox(height: 12),
              if (!isDesktop) ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: horizontalPad),
                  child: Row(children: _feature.map((f) => _featureCard(f)).toList()),
                ),
              ] else ...[
                LayoutBuilder(builder: (context, inner) {
                  final contentWidth = inner.maxWidth - horizontalPad * 2;
                  final int columns = (contentWidth ~/ 220).clamp(2, 6);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: horizontalPad),
                    child: GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: columns,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.72,
                      children: _feature.map((f) => _featureCard(f, width: double.infinity, imageHeight: 160)).toList(),
                    ),
                  );
                }),
              ],
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: horizontalPad),
                child: Container(
                  height: 92,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey[100]),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                          Text('NEW COLLECTION', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          SizedBox(height: 6),
                          Text('HANG OUT & PARTY', style: TextStyle(fontWeight: FontWeight.w700)),
                        ]),
                      ),
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey[200]),
                        clipBehavior: Clip.hardEdge,
                        child: Image.asset(p1, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _imageFallback()),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _sectionHeader('Recommended', onSeeAll: () {}),
              const SizedBox(height: 12),
              if (!isDesktop) ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: horizontalPad),
                  child: Row(children: _recommended.map((p) => _productThumb(p)).toList()),
                ),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: horizontalPad),
                  child: LayoutBuilder(builder: (context, inner) {
                    final contentWidth = inner.maxWidth;
                    final int columns = (contentWidth ~/ 320).clamp(1, 3);
                    return GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: columns,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 3.4,
                      children: _recommended.map((p) {
                        return InkWell(
                          onTap: () => _openProduct(p),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey[100]),
                            child: Row(
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey[200]),
                                  clipBehavior: Clip.hardEdge,
                                  child: Image.asset(p['img']!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _imageFallback()),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                                    Text(p['title']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 6),
                                    Text(p['price']!, style: const TextStyle(color: Colors.grey)),
                                  ]),
                                ),
                                IconButton(onPressed: () {}, icon: const Icon(Icons.add_shopping_cart_outlined)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }),
                ),
              ],
              const SizedBox(height: 20),
              _sectionHeader('Top Collection', onSeeAll: () {}),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: horizontalPad),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey[100]),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                          Text('FOR SLIM & BEAUTY', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          SizedBox(height: 8),
                          Text('Most sexy & fabulous design', style: TextStyle(fontWeight: FontWeight.w700)),
                        ]),
                      ),
                      Container(
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey[200]),
                        clipBehavior: Clip.hardEdge,
                        child: Image.asset(p3, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _imageFallback()),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: horizontalPad),
                child: Container(
                  margin: const EdgeInsets.only(top: 0),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey[100]),
                  child: Row(
                    children: [
                      Container(
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey[200]),
                        clipBehavior: Clip.hardEdge,
                        child: Image.asset(p4, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _imageFallback()),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                          Text('Summer Collection 2021', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          SizedBox(height: 6),
                          Text('Most sexy & fabulous design', style: TextStyle(fontWeight: FontWeight.w700)),
                        ]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: horizontalPad),
                child: Row(
                  children: [
                    Expanded(child: _smallTile('The Office Life', 'assets/product_small1.png')),
                    const SizedBox(width: 12),
                    Expanded(child: _smallTile('Elegant Design', 'assets/product_small2.png')),
                  ],
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      );

      // small static unread count for badge — change as needed
      const int unreadCount = 2;

      // chat FAB
      final chatButton = FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
        },
        backgroundColor: Colors.blue.shade700,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      );

      if (isDesktop) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: null,
            title: const Text('GemStore', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700)),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none, color: Colors.black87),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                      },
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 6,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                          constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                          child: Center(child: Text(unreadCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Row(
            children: [
              Container(width: 300, decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.grey.shade100))), child: _drawerContent()),
              Expanded(child: content),
            ],
          ),
          floatingActionButton: chatButton,
        );
      } else {
        return Scaffold(
          backgroundColor: Colors.white,
          drawer: Drawer(child: _drawerContent()),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Builder(builder: (ctx) {
              return IconButton(icon: const Icon(Icons.menu, color: Colors.black87), onPressed: () => Scaffold.of(ctx).openDrawer());
            }),
            title: const Text('GemStore', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700)),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none, color: Colors.black87),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                      },
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 6,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                          constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                          child: Center(child: Text(unreadCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: content,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _bottomIndex,
            onTap: _onBottomTap,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            elevation: 8,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            items: [
              BottomNavigationBarItem(icon: Icon(_bottomIndex == 0 ? Icons.home : Icons.home_outlined), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(_bottomIndex == 1 ? Icons.search : Icons.search_outlined), label: 'Search'),
              BottomNavigationBarItem(icon: Icon(_bottomIndex == 2 ? Icons.shopping_bag : Icons.shopping_bag_outlined), label: 'Bag'),
              BottomNavigationBarItem(icon: Icon(_bottomIndex == 3 ? Icons.person : Icons.person_outline), label: 'Account'),
            ],
          ),
          floatingActionButton: chatButton,
        );
      }
    });
  }
}

// ---------------- Product Details (unchanged) ----------------
class ProductDetails extends StatelessWidget {
  final Map<String, String> product;
  const ProductDetails({super.key, required this.product});

  Widget _imageFallback({double? height}) {
    return Container(
      height: height,
      color: Colors.grey[100],
      child: const Center(child: Icon(Icons.image_not_supported, size: 44, color: Colors.grey)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = product['title'] ?? 'Product';
    final price = product['price'] ?? '';
    final img = product['img'];

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 320,
              width: double.infinity,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey[100]),
              clipBehavior: Clip.hardEdge,
              child: img != null
                  ? Hero(
                      tag: 'hero-${product['title']}',
                      child: Image.asset(img, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _imageFallback(height: 320)),
                    )
                  : _imageFallback(height: 320),
            ),
            const SizedBox(height: 18),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(price, style: const TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 14),
            const Text('Description', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text(
              'This is a sample product description. Replace this with real product details: sizes, materials, care instructions, and any other relevant information you want to show to customers.',
              style: TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart')));
                    },
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Add to cart'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, foregroundColor: Colors.black87),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    child: Text('Close'),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
