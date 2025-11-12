// lib/screens/home_screen.dart
// Updated: tapping a category opens a CategoryProductsPage that shows only
// products for that category. The category page tries /products?category=<id>
// and falls back to fetching all products then filtering client-side.

import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:ecommerce/screens/all_product_screen.dart';
import 'package:ecommerce/screens/more_product_list_screen.dart';
import 'package:ecommerce/screens/notofications_screen.dart';
import 'package:ecommerce/screens/profile_page.dart';
import 'package:ecommerce/screens/settingPage.dart';
import 'package:ecommerce/screens/orders_page.dart';
import 'package:ecommerce/screens/help_support_screen.dart';
import 'package:ecommerce/screens/chat_screen.dart';
import 'package:ecommerce/screens/discover_page.dart';
import 'package:ecommerce/screens/admin/admin_panel.dart';
import 'package:ecommerce/screens/mens_product_list_screen.dart';
import 'package:ecommerce/screens/womens_product_list_screen.dart';
import 'package:ecommerce/screens/accessories_product_list_screen.dart';

// Models (adjust import path if needed)
import 'package:ecommerce/screens/admin/category_model.dart';
import 'package:ecommerce/screens/admin/product_model.dart';

// Cart service & Cart screen
import 'package:ecommerce/services/cart_service.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bottomIndex = 0;

  // Assets
  static const String promo = 'assets/promo.png';
  static const String promo2 = 'assets/promo2.png';
  static const String promo3 = 'assets/promo3.png';
  static const String p1 = 'assets/product1.png';
  static const String p2 = 'assets/product2.png';
  static const String p3 = 'assets/product3.png';
  static const String p4 = 'assets/product4.png';

  // dynamic state
  List<Category> _categories = [];
  List<Product> _featured = [];
  List<Product> _recommended = [];
  bool _loading = true;
  String? _error;

  // banners
  late final List<String> _banners = [promo, promo2, promo3];
  late PageController _bannerController;
  int _currentBanner = 0;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _bannerController = PageController(initialPage: _banners.length * 1000);
    _currentBanner = _bannerController.initialPage % _banners.length;
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_bannerController.hasClients) return;
      _bannerController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    });

    _loadData();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  // ---------------- PLATFORM-DEPENDENT API BASE ----------------
  String getApiBase({int port = 5000}) {
    if (kIsWeb) return 'http://localhost:$port/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:$port/api'; // Android emulator
    return 'http://localhost:$port/api';
  }

  // ---------------- API helpers ----------------
  Future<List<Category>> _fetchCategories() async {
    final uri = Uri.parse('${getApiBase()}/categories');
    final resp = await http.get(uri, headers: {'Accept': 'application/json'});
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final decoded = json.decode(resp.body);
      final raw = (decoded is Map && decoded.containsKey('data')) ? decoded['data'] : decoded;
      if (raw is List) return raw.map((e) => Category.fromJson(e)).toList();
      throw Exception('Unexpected categories response');
    }
    throw Exception('Failed to load categories');
  }

  Future<List<Product>> _fetchProducts({String? categoryId}) async {
    final q = categoryId != null ? '?category=$categoryId' : '';
    final uri = Uri.parse('${getApiBase()}/products$q');
    final resp = await http.get(uri, headers: {'Accept': 'application/json'});
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final decoded = json.decode(resp.body);
      final raw = (decoded is Map && decoded.containsKey('data')) ? decoded['data'] : decoded;
      if (raw is List) return raw.map((e) => Product.fromJson(e)).toList();
      throw Exception('Unexpected products response');
    }
    throw Exception('Failed to load products');
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cats = await _fetchCategories();
      final allProducts = await _fetchProducts();
      setState(() {
        _categories = cats;
        _featured = allProducts.take(4).toList();
        _recommended = allProducts.take(8).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // Navigate to CategoryProductsPage for a given category
  void _openCategoryPage(Category category) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryProductsPage(category: category)));
  }

  // open product detail
  void _openProduct(Map<String, String> product) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetails(product: product)));
  }

  void _openProductFromModel(Product p) {
    debugPrint('Open product: id=${p.id}, name=${p.name}');
    _openProduct({
      'img': p.imageUrl ?? '',
      'title': p.name,
      'price': p.price.toStringAsFixed(2),
      'description': p.description ?? '',
    });
  }

  // ---------- visuals / helpers ----------
  double _resolveVisualWidth(BoxConstraints constraints, double? providedWidth) {
    if (providedWidth != null && providedWidth.isFinite) return providedWidth;
    if (constraints.maxWidth.isFinite && constraints.maxWidth > 0) return constraints.maxWidth;
    final double fallback = MediaQuery.of(context).size.width * 0.9;
    return fallback > 0 ? fallback : 360.0;
  }

  Widget _imageFallback({double? height, double? width}) {
    return Container(height: height, width: width, color: Colors.grey[100], child: const Center(child: Icon(Icons.image_not_supported, size: 34, color: Colors.grey)));
  }

  Widget _CachedAssetImage(String assetPath, {double? targetWidth, double? targetHeight, BoxFit fit = BoxFit.cover, double borderRadius = 12}) {
    return LayoutBuilder(builder: (context, constraints) {
      final double visualWidth = _resolveVisualWidth(constraints, targetWidth);
      final dpr = MediaQuery.of(context).devicePixelRatio;
      final cacheW = max(1, (visualWidth * dpr).round());
      return Container(
        height: targetHeight,
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(borderRadius)),
        clipBehavior: Clip.hardEdge,
        child: Image.asset(assetPath, width: visualWidth, height: targetHeight, fit: fit, cacheWidth: cacheW, frameBuilder: (context, child, frame, wasSync) {
          if (wasSync) return child;
          return AnimatedOpacity(opacity: frame == null ? 0 : 1, duration: const Duration(milliseconds: 200), child: child);
        }, errorBuilder: (_, __, ___) => _imageFallback(height: targetHeight, width: targetWidth)),
      );
    });
  }

  Widget _sectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: const Text(
                'Show all',
                style: TextStyle(color: Colors.blue),
              ),
            ),
        ],
      ),
    );
  }

  // -------------- Modal (All categories) --------------
  void _openAllCategoriesModal() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
                  children: [
                    Container(height: 6, width: 60, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(6))),
                    const SizedBox(height: 12),
                    const Text('All Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _categories.isEmpty
                          ? const Center(child: Text('No categories'))
                          : GridView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.all(8),
                              itemCount: _categories.length,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 1,
                              ),
                              itemBuilder: (ctx, i) {
                                final c = _categories[i];
                                final display = (c.name.isNotEmpty) ? (c.name.length >= 2 ? c.name.substring(0, 2).toUpperCase() : c.name.toUpperCase()) : 'N/A';
                                return InkWell(
                                  onTap: () {
                                    Navigator.of(ctx).pop(); // close sheet first
                                    debugPrint('open category from modal: ${c.id} / ${c.name}');
                                    _openCategoryPage(c);
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey[100]),
                                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                      CircleAvatar(radius: 22, backgroundColor: Colors.blue.shade50, child: Text(display)),
                                      const SizedBox(height: 8),
                                      Padding(padding: const EdgeInsets.symmetric(horizontal: 6.0), child: Text(c.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12))),
                                    ]),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ------------ Product Card widgets (with Add to cart) -------------
  Widget productCardWithCart(Product p, {double? width}) {
    return LayoutBuilder(builder: (context, constraints) {
      final cardWidth = _resolveVisualWidth(constraints, width);
      final imageHeight = (cardWidth * 0.6).clamp(120.0, 260.0);

      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            debugPrint('productCard tapped: id=${p.id}, name=${p.name}');
            try {
              _openProductFromModel(p);
            } catch (e, st) {
              debugPrint('open product failed: $e\n$st');
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to open product: ${e.toString()}')));
            }
          },
          child: Container(
            width: width,
            margin: const EdgeInsets.only(right: 14, bottom: 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Stack(children: [
                Container(
                  height: imageHeight,
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                  clipBehavior: Clip.hardEdge,
                  child: (p.imageUrl != null && p.imageUrl!.isNotEmpty)
                      ? Image.network(p.imageUrl!, fit: BoxFit.cover, width: cardWidth, height: imageHeight, errorBuilder: (_, __, ___) => _imageFallback(height: imageHeight))
                      : _imageFallback(height: imageHeight),
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Material(
                    color: Colors.white70,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: IconButton(
                      icon: const Icon(Icons.add_shopping_cart_outlined),
                      onPressed: () async {
                        final ok = await CartService.instance.addItem(p.id, qty: 1);
                        if (ok) {
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart')));
                        } else {
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add to cart — please login')));
                        }
                      },
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text('\$${p.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 6),
              Text(p.description ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black87, fontSize: 12)),
            ]),
          ),
        ),
      );
    });
  }

  Widget productThumbWithCart(Product p) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          debugPrint('productThumb tapped: id=${p.id}, name=${p.name}');
          try {
            _openProductFromModel(p);
          } catch (e, st) {
            debugPrint('open product failed: $e\n$st');
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to open product: ${e.toString()}')));
          }
        },
        child: Container(
          width: 160,
          margin: const EdgeInsets.only(right: 12),
          child: Row(children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey[200]),
              clipBehavior: Clip.hardEdge,
              child: (p.imageUrl != null && p.imageUrl!.isNotEmpty) ? Image.network(p.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _imageFallback(height: 72)) : _imageFallback(height: 72),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(p.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Text('\$${p.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey)),
            ])),
            IconButton(
              onPressed: () async {
                final ok = await CartService.instance.addItem(p.id, qty: 1);
                if (ok) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add to cart — login required')));
                }
              },
              icon: const Icon(Icons.add_shopping_cart_outlined),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _smallTile(String title, String asset) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey[100]),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 8), const Text('Browse', style: TextStyle(color: Colors.grey))])),
        AspectRatio(aspectRatio: 1, child: Container(margin: const EdgeInsets.only(left: 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey[200]), clipBehavior: Clip.hardEdge, child: _CachedAssetImage(asset, borderRadius: 10))),
      ]),
    );
  }

  Widget _drawerContent() {
    return SafeArea(
      child: Column(children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: const BorderRadius.only(bottomRight: Radius.circular(18))),
          child: Row(children: [
            const CircleAvatar(radius: 30, backgroundColor: Colors.grey),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('Hello, Guest', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)), SizedBox(height: 4), Text('guest@example.com', style: TextStyle(color: Colors.grey))])),
            IconButton(onPressed: () {}, icon: const Icon(Icons.edit, size: 20, color: Colors.black54)),
          ]),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView(padding: const EdgeInsets.symmetric(vertical: 8), children: [
            ListTile(leading: const Icon(Icons.person_outline), title: const Text('Profile'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage())); }),
            ListTile(leading: const Icon(Icons.shopping_bag_outlined), title: const Text('Orders'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersPage())); }),
            const Divider(),
            ListTile(leading: const Icon(Icons.settings_outlined), title: const Text('Settings'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingPage())); }),
            ListTile(leading: const Icon(Icons.help_outline), title: const Text('Help & Support'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen())); }),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
          child: Row(children: [
            Expanded(child: ElevatedButton.icon(icon: const Icon(Icons.login_outlined), label: const Text('Sign In'), onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign In tapped'))); }, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)))),
            const SizedBox(width: 10),
            IconButton(onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Log out tapped'))); }, icon: const Icon(Icons.logout), tooltip: 'Log out'),
          ]),
        ),
        const SizedBox(height: 8),
      ]),
    );
  }

  Widget _buildPromoCarousel(bool isDesktop) {
    const double horizontalPad = 18.0;
    final double height = isDesktop ? 240 : 140;

    final bannerWidgets = [
      Container(color: Colors.blue.shade300, child: Center(child: Text('BIG SALE\nUP TO 50% OFF', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: isDesktop ? 28 : 18, fontWeight: FontWeight.bold)))),
      Container(color: Colors.purple.shade300, child: Center(child: Text('NEW ARRIVALS\nSHOP NOW', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: isDesktop ? 28 : 18, fontWeight: FontWeight.bold)))),
      Container(color: Colors.orange.shade300, child: Center(child: Text('LIMITED OFFER\nFREE SHIPPING', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: isDesktop ? 28 : 18, fontWeight: FontWeight.bold)))),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalPad),
      child: SizedBox(
        height: height,
        child: Stack(children: [
          PageView.builder(
            controller: _bannerController,
            onPageChanged: (idx) {
              setState(() {
                _currentBanner = idx % bannerWidgets.length;
              });
            },
            itemBuilder: (context, index) {
              final bannerIndex = index % bannerWidgets.length;
              final widget = bannerWidgets[bannerIndex];
              return GestureDetector(onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Clicked banner #${bannerIndex + 1}'))), child: Container(margin: EdgeInsets.zero, decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: Colors.grey[100]), clipBehavior: Clip.hardEdge, child: ClipRRect(borderRadius: BorderRadius.circular(14), child: widget)));
            },
          ),
          Positioned(left: 0, right: 0, bottom: 10, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(bannerWidgets.length, (i) {
            final active = i == _currentBanner;
            return AnimatedContainer(duration: const Duration(milliseconds: 250), margin: const EdgeInsets.symmetric(horizontal: 4), width: active ? 18 : 8, height: 8, decoration: BoxDecoration(color: active ? Colors.white : Colors.white70, borderRadius: BorderRadius.circular(8), boxShadow: [if (active) BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4, offset: const Offset(0, 1))]));
          }))),
        ]),
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
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (_loading) const Padding(padding: EdgeInsets.all(18.0), child: Center(child: CircularProgressIndicator())),
            if (_error != null) Padding(padding: const EdgeInsets.symmetric(horizontal: 18.0), child: Text('Error: $_error', style: const TextStyle(color: Colors.red))),

            // --- CATEGORIES ROW (show up to 5 + More) ---
            if (!isDesktop)
              SizedBox(
                height: 110,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 8),
                  itemCount: min(5, _categories.length) + 1, // +1 for "More" tile
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, i) {
                    if (i < min(5, _categories.length)) {
                      return _categoryTileObj(_categories[i], index: i);
                    } else {
                      // More tile
                      return GestureDetector(
                        onTap: _openAllCategoriesModal,
                        child: Container(
                          width: 72,
                          margin: const EdgeInsets.only(right: 12),
                          child: Column(children: [
                            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.grey.shade200)), child: const Icon(Icons.more_horiz, color: Colors.black54)),
                            const SizedBox(height: 8),
                            const Text('More', style: TextStyle(fontSize: 12, color: Colors.black54)),
                          ]),
                        ),
                      );
                    }
                  },
                ),
              ),

            if (isDesktop)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 12),
                child: Wrap(spacing: 12, runSpacing: 8, children: [
                  for (var i = 0; i < min(5, _categories.length); i++) _categoryTileObj(_categories[i], index: i, size: 96),
                  GestureDetector(
                    onTap: _openAllCategoriesModal,
                    child: Container(width: 96, height: 96, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.more_horiz), SizedBox(height: 6), Text('More')])),
                  ),
                ]),
              ),

            const SizedBox(height: 6),
            _buildPromoCarousel(isDesktop),
            const SizedBox(height: 18),

            _sectionHeader('Feature Products', onSeeAll: () {}),
            const SizedBox(height: 12),

            if (!isDesktop)
              SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: horizontalPad), child: Row(children: _featured.map((f) => SizedBox(width: 160, child: productCardWithCart(f))).toList()))
            else
              LayoutBuilder(builder: (context, inner) {
                final contentWidth = inner.maxWidth - horizontalPad * 2;
                final int columns = (contentWidth ~/ 220).clamp(2, 6);
                final double itemWidth = (contentWidth - (columns - 1) * 14) / columns;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: horizontalPad),
                  child: GridView.count(physics: const NeverScrollableScrollPhysics(), shrinkWrap: true, crossAxisCount: columns, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 0.72, children: _featured.map((f) => productCardWithCart(f, width: itemWidth)).toList()),
                );
              }),

            const SizedBox(height: 18),
            Padding(padding: const EdgeInsets.symmetric(horizontal: horizontalPad), child: Container(height: 92, padding: const EdgeInsets.all(12), decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey[100]), child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('NEW COLLECTION', style: TextStyle(fontSize: 12, color: Colors.grey)), SizedBox(height: 6), Text('HANG OUT & PARTY', style: TextStyle(fontWeight: FontWeight.w700))])),
              Container(width: 76, height: 76, decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey[200]), clipBehavior: Clip.hardEdge, child: _CachedAssetImage(p1, targetWidth: 76, targetHeight: 76, borderRadius: 10)),
            ]))),
            const SizedBox(height: 18),

            _sectionHeader('Recommended', onSeeAll: () {}),
            const SizedBox(height: 12),

            if (!isDesktop)
              SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: horizontalPad), child: Row(children: _recommended.map((p) => productThumbWithCart(p)).toList()))
            else
              Padding(padding: const EdgeInsets.symmetric(horizontal: horizontalPad), child: LayoutBuilder(builder: (context, inner) {
                final contentWidth = inner.maxWidth;
                final int columns = (contentWidth ~/ 320).clamp(1, 3);
                return GridView.count(physics: const NeverScrollableScrollPhysics(), shrinkWrap: true, crossAxisCount: columns, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 3.4, children: _recommended.map((p) {
                  return InkWell(onTap: () => _openProductFromModel(p), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey[100]), child: Row(children: [
                    Container(width: 72, height: 72, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey[200]), clipBehavior: Clip.hardEdge, child: (p.imageUrl != null && p.imageUrl!.isNotEmpty) ? Image.network(p.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _imageFallback(height: 72)) : _imageFallback(height: 72)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 6), Text('\$${p.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey))])),
                    IconButton(onPressed: () async {
                      final ok = await CartService.instance.addItem(p.id, qty: 1);
                      if (ok) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart')));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add to cart')));
                      }
                    }, icon: const Icon(Icons.add_shopping_cart_outlined)),
                  ])));
                }).toList());
              })),

            const SizedBox(height: 20),
            _sectionHeader('Top Collection', onSeeAll: () {}),
            const SizedBox(height: 12),

            Padding(padding: const EdgeInsets.symmetric(horizontal: horizontalPad), child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey[100]), child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('FOR SLIM & BEAUTY', style: TextStyle(color: Colors.grey, fontSize: 12)), SizedBox(height: 8), Text('Most sexy & fabulous design', style: TextStyle(fontWeight: FontWeight.w700))])),
              Container(width: 86, height: 86, decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey[200]), clipBehavior: Clip.hardEdge, child: _CachedAssetImage(p3, targetWidth: 86, targetHeight: 86, borderRadius: 10)),
            ]))),
            const SizedBox(height: 18),

            Padding(padding: const EdgeInsets.symmetric(horizontal: horizontalPad), child: Container(margin: const EdgeInsets.only(top: 0), padding: const EdgeInsets.all(14), decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey[100]), child: Row(children: [
              Container(width: 86, height: 86, decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey[200]), clipBehavior: Clip.hardEdge, child: _CachedAssetImage(p4, targetWidth: 86, targetHeight: 86, borderRadius: 10)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('Summer Collection 2021', style: TextStyle(fontSize: 12, color: Colors.grey)), SizedBox(height: 6), Text('Most sexy & fabulous design', style: TextStyle(fontWeight: FontWeight.w700))])),
            ]))),
            const SizedBox(height: 18),

            Padding(padding: const EdgeInsets.symmetric(horizontal: horizontalPad), child: Row(children: [Expanded(child: _smallTile('The Office Life', 'assets/product_small1.png')), const SizedBox(width: 12), Expanded(child: _smallTile('Elegant Design', 'assets/product_small2.png'))])),
            const SizedBox(height: 28),
          ]),
        ),
      );

      const int unreadCount = 2;
      final chatButton = FloatingActionButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())), backgroundColor: Colors.blue.shade700, child: const Icon(Icons.chat_bubble_outline, color: Colors.white));

      // AppBar actions: notifications + live cart icon
      final appBarActions = [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 6.0), child: Stack(children: [
          IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black87), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
          if (unreadCount > 0) Positioned(right: 6, top: 8, child: Container(padding: const EdgeInsets.all(3), decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle), constraints: const BoxConstraints(minWidth: 18, minHeight: 18), child: Center(child: Text(unreadCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))))),
        ])),
        // Cart icon with live badge from CartService.items
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ValueListenableBuilder<List<CartItem>>(
            valueListenable: CartService.instance.items,
            builder: (context, items, _) {
              final count = items.length;
              return IconButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
                icon: Stack(clipBehavior: Clip.none, children: [
                  const Icon(Icons.shopping_cart_outlined, color: Colors.black87),
                  if (count > 0)
                    Positioned(right: -6, top: -8, child: CircleAvatar(radius: 9, backgroundColor: Colors.red, child: Text('$count', style: const TextStyle(fontSize: 10, color: Colors.white)))),
                ]),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
      ];

      if (isDesktop) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: null,
            title: const Text('GemStore', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700)),
            centerTitle: true,
            actions: appBarActions,
          ),
          body: Row(children: [Container(width: 300, decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.grey.shade100))), child: _drawerContent()), Expanded(child: content)]),
          floatingActionButton: chatButton,
        );
      } else {
        return Scaffold(
          backgroundColor: Colors.white,
          drawer: Drawer(child: _drawerContent()),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.menu, color: Colors.black87), onPressed: () => Scaffold.of(ctx).openDrawer())),
            title: const Text('GemStore', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700)),
            centerTitle: true,
            actions: appBarActions,
          ),
          body: content,
          bottomNavigationBar: BottomNavigationBar(currentIndex: _bottomIndex, onTap: _onBottomTap, showSelectedLabels: false, showUnselectedLabels: false, elevation: 8, selectedItemColor: Colors.blue, unselectedItemColor: Colors.grey, items: [
            BottomNavigationBarItem(icon: Icon(_bottomIndex == 0 ? Icons.home : Icons.home_outlined), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(_bottomIndex == 1 ? Icons.search : Icons.search_outlined), label: 'Search'),
            BottomNavigationBarItem(icon: Icon(_bottomIndex == 2 ? Icons.shopping_bag : Icons.shopping_bag_outlined), label: 'Bag'),
            BottomNavigationBarItem(icon: Icon(_bottomIndex == 3 ? Icons.person : Icons.person_outline), label: 'Account'),
          ]),
          floatingActionButton: chatButton,
        );
      }
    });
  }

  void _onBottomTap(int idx) {
    setState(() => _bottomIndex = idx);
    if (idx == 0) return;
    if (idx == 1) {
      // Navigator.push(context, MaterialPageRoute(builder: (_) => const DiscoverPage()));
    } else if (idx == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
    }
  }

  // Category tile navigates to CategoryProductsPage when tapped.
  Widget _categoryTileObj(Category category, {double size = 72, int? index}) {
    return GestureDetector(
      onTap: () => _openCategoryPage(category),
      child: Container(
        width: size,
        margin: const EdgeInsets.only(right: 12),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 40,
                height: 40,
                child: Center(
                  child: Text(
                    category.name.length > 2 ? category.name.substring(0, 2).toUpperCase() : category.name.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: size,
            child: Text(category.name, style: const TextStyle(fontSize: 12, color: Colors.black54), overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
          ),
        ]),
      ),
    );
  }
}

/// CategoryProductsPage
/// Dedicated page that fetches products for the given category and displays them.
/// Attempts GET /products?category=<id> first; if that fails it fetches all products and filters client-side.
class CategoryProductsPage extends StatefulWidget {
  final Category category;
  const CategoryProductsPage({super.key, required this.category});

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  List<Product> _products = [];
  bool _loading = true;
  String? _error;

  String getApiBase({int port = 5000}) {
    if (kIsWeb) return 'http://localhost:$port/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:$port/api';
    return 'http://localhost:$port/api';
  }

  // Try to fetch with query param; if that fails, fetch all and filter client-side.
  Future<List<Product>> _fetchProductsForCategory(String categoryId) async {
    final queryUri = Uri.parse('${getApiBase()}/products?category=$categoryId');

    try {
      final resp = await http.get(queryUri, headers: {'Accept': 'application/json'});
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final decoded = json.decode(resp.body);
        final raw = (decoded is Map && decoded.containsKey('data')) ? decoded['data'] : decoded;
        if (raw is List) {
          // Successful: backend returned filtered list
          return raw.map((e) => Product.fromJson(e)).toList();
        }
      } else {
        debugPrint('Query-by-category returned status ${resp.statusCode}, falling back to full fetch.');
      }
    } catch (e) {
      debugPrint('Query-by-category failed: $e — falling back to fetching all products.');
    }

    // Fallback: fetch all products and filter client-side
    final allUri = Uri.parse('${getApiBase()}/products');
    final respAll = await http.get(allUri, headers: {'Accept': 'application/json'});
    if (respAll.statusCode >= 200 && respAll.statusCode < 300) {
      final decoded = json.decode(respAll.body);
      final rawList = (decoded is Map && decoded.containsKey('data')) ? decoded['data'] : decoded;
      if (rawList is List) {
        // Filter using common shapes: 'category' (id or object), 'categoryId', nested category.id
        final filteredRaw = rawList.where((item) {
          if (item == null || item is! Map) return false;
          return _matchesCategoryRaw(item as Map, categoryId);
        }).toList();

        return filteredRaw.map((e) => Product.fromJson(e)).toList();
      }
      throw Exception('Unexpected products response on fallback');
    }
    throw Exception('Failed to load products (both query & fallback failed)');
  }

  // Return true if raw product JSON appears to belong to categoryId.
  bool _matchesCategoryRaw(Map raw, String categoryId) {
    try {
      // direct field 'categoryId'
      if (raw.containsKey('categoryId')) {
        final val = raw['categoryId'];
        if (val is String && val == categoryId) return true;
        if (val is Map && val['_id'] == categoryId) return true;
      }

      // direct field 'category'
      if (raw.containsKey('category')) {
        final c = raw['category'];
        if (c is String && c == categoryId) return true;
        if (c is Map) {
          if (c.containsKey('id') && c['id'] == categoryId) return true;
          if (c.containsKey('_id') && c['_id'] == categoryId) return true;
        }
      }

      // sometimes product has 'categories' as list
      if (raw.containsKey('categories') && raw['categories'] is List) {
        final List list = raw['categories'];
        for (final el in list) {
          if (el is String && el == categoryId) return true;
          if (el is Map && (el['id'] == categoryId || el['_id'] == categoryId)) return true;
        }
      }

      // last resort: if product contains a 'category_id' or similarly-named keys
      if (raw.containsKey('category_id') && raw['category_id'] == categoryId) return true;
    } catch (e) {
      debugPrint('matching error: $e');
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _loadCategoryProducts();
  }

  Future<void> _loadCategoryProducts() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final list = await _fetchProductsForCategory(widget.category.id);
      setState(() {
        _products = list;
        _loading = false;
      });
    } catch (e, st) {
      debugPrint('Failed to load category products: $e\n$st');
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _openProduct(Product p) {
    Navigator.push(context, MaterialPageRoute(builder: (ctx) => ProductDetails(product: {
      'img': p.imageUrl ?? '',
      'title': p.name,
      'price': p.price.toStringAsFixed(2),
      'description': p.description ?? '',
    })));
  }

  Widget _imageFallback({double? height}) {
    return Container(height: height, color: Colors.grey[100], child: const Center(child: Icon(Icons.image_not_supported, size: 34, color: Colors.grey)));
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.category.name;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 800;

    return Scaffold(
      appBar: AppBar(title: Text(title, style: const TextStyle(color: Colors.black87)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black87)),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
                : _products.isEmpty
                    ? Center(child: Text('No products in "$title"'))
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: isDesktop
                            ? LayoutBuilder(builder: (context, constraints) {
                                final contentWidth = constraints.maxWidth;
                                final int columns = (contentWidth ~/ 220).clamp(2, 6);
                                final double itemWidth = (contentWidth - (columns - 1) * 14) / columns;
                                return GridView.count(
                                  crossAxisCount: columns,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  childAspectRatio: 0.72,
                                  children: _products.map((p) {
                                    return GestureDetector(
                                      onTap: () => _openProduct(p),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey[100]),
                                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey[200]),
                                              clipBehavior: Clip.hardEdge,
                                              child: (p.imageUrl != null && p.imageUrl!.isNotEmpty) ? Image.network(p.imageUrl!, fit: BoxFit.cover) : _imageFallback(),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                                          const SizedBox(height: 4),
                                          Text('\$${p.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey)),
                                        ]),
                                      ),
                                    );
                                  }).toList(),
                                );
                              })
                            : ListView.separated(
                                itemCount: _products.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (ctx, i) {
                                  final p = _products[i];
                                  return ListTile(
                                    onTap: () => _openProduct(p),
                                    contentPadding: const EdgeInsets.all(8),
                                    tileColor: Colors.grey[100],
                                    leading: Container(width: 72, height: 72, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey[200]), clipBehavior: Clip.hardEdge, child: (p.imageUrl != null && p.imageUrl!.isNotEmpty) ? Image.network(p.imageUrl!, fit: BoxFit.cover) : _imageFallback(height: 72)),
                                    title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                    subtitle: Text('\$${p.price.toStringAsFixed(2)}'),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.add_shopping_cart_outlined),
                                      onPressed: () async {
                                        final ok = await CartService.instance.addItem(p.id, qty: 1);
                                        if (ok) {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart')));
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add to cart — login required')));
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),
     ) );
  }
}

/// ProductDetails (kept here for completeness)
class ProductDetails extends StatelessWidget {
  final Map<String, String> product;
  const ProductDetails({super.key, required this.product});

  Widget _imageFallback({double? height}) {
    return Container(height: height, color: Colors.grey[100], child: const Center(child: Icon(Icons.image_not_supported, size: 44, color: Colors.grey)));
  }

  @override
  Widget build(BuildContext context) {
    final title = product['title'] ?? 'Product';
    final price = product['price'] ?? '';
    final img = product['img'];

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    if (isDesktop) {
      final double leftWidth = min(520, screenWidth * 0.42);
      final double imgHeight = leftWidth * 0.95;

      return Scaffold(
        appBar: AppBar(title: Text(title, style: const TextStyle(color: Colors.black87)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black87)),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(
                  width: leftWidth,
                  child: Column(children: [
                    Container(height: imgHeight, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey[100]), clipBehavior: Clip.hardEdge, child: img != null && img.isNotEmpty ? Image.network(img, fit: BoxFit.contain, width: leftWidth, height: imgHeight, errorBuilder: (_, __, ___) => _imageFallback(height: imgHeight)) : _imageFallback(height: imgHeight)),
                    const SizedBox(height: 12),
                  ]),
                ),
                const SizedBox(width: 28),
                Expanded(child: SizedBox(height: MediaQuery.of(context).size.height - kToolbarHeight - 40, child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  Text(price, style: const TextStyle(fontSize: 20, color: Colors.grey)),
                  const SizedBox(height: 14),
                  const Text('Description', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(product['description'] ?? 'No description provided', style: const TextStyle(color: Colors.black87, height: 1.45)),
                  const SizedBox(height: 18),
                  Row(children: [
                    Expanded(child: ElevatedButton.icon(onPressed: () { ScaffoldMessenger.of(context).removeCurrentSnackBar(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart'))); }, icon: const Icon(Icons.add_shopping_cart), label: const Text('Add to cart'), style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)))),
                    const SizedBox(width: 12),
                    OutlinedButton(onPressed: () => Navigator.pop(context), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)), child: const Text('Close')),
                  ]),
                  const SizedBox(height: 12),
                ])))),
              ]),
            ),
          ),
        ),
      );
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = (screenHeight * 0.45).clamp(260.0, 520.0);

    return Scaffold(
      appBar: AppBar(title: Text(title, style: const TextStyle(color: Colors.black87)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black87)),
      body: SingleChildScrollView(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(height: imageHeight, width: double.infinity, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey[100]), clipBehavior: Clip.hardEdge, child: img != null && img.isNotEmpty ? Image.network(img, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _imageFallback(height: imageHeight)) : _imageFallback(height: imageHeight)),
        const SizedBox(height: 18),
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(price, style: const TextStyle(fontSize: 18, color: Colors.grey)),
        const SizedBox(height: 14),
        const Text('Description', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(product['description'] ?? 'No description provided', style: const TextStyle(color: Colors.black87)),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(child: ElevatedButton.icon(onPressed: () { ScaffoldMessenger.of(context).removeCurrentSnackBar(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart'))); }, icon: const Icon(Icons.add_shopping_cart), label: const Text('Add to cart'), style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)))),
          const SizedBox(width: 12),
          ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, foregroundColor: Colors.black87), child: const Padding(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14), child: Text('Close'))),
        ]),
      ])),
    );
  }
}
