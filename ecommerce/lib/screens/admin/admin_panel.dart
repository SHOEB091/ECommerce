import 'package:flutter/material.dart';
import 'add_product_page.dart';
import 'product_model.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final List<Product> _products = [
    Product(
      id: '1',
      name: 'Classic Jacket',
      description: 'Stylish winter jacket with soft lining.',
      price: 79.99,
      imageUrl: 'https://images.unsplash.com/photo-1521335629791-ce4aec67dd47',
    ),
    Product(
      id: '2',
      name: 'Summer Dress',
      description: 'Light floral dress for warm weather.',
      price: 49.99,
      imageUrl: 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246',
    ),
  ];

  int selectedIndex = 0;

  void _addOrEditProduct([Product? product]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddProductPage(product: product)),
    );

    if (result != null && result is Product) {
      setState(() {
        if (product == null) {
          _products.add(result);
        } else {
          final index = _products.indexWhere((p) => p.id == product.id);
          _products[index] = result;
        }
      });
    }
  }

  void _deleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() => _products.remove(product));
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Sidebar / Drawer menu items
  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.dashboard, 'label': 'Dashboard'},
    {'icon': Icons.shopping_bag_outlined, 'label': 'Products'},
    {'icon': Icons.bar_chart_outlined, 'label': 'Analytics'},
    {'icon': Icons.people_alt_outlined, 'label': 'Users'},
    {'icon': Icons.settings_outlined, 'label': 'Settings'},
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 850;

    return Scaffold(
      drawer: !isWide ? _buildDrawer() : null,
      body: Row(
        children: [
          if (isWide) _buildSideMenu(), // Sidebar visible on desktop/tablet
          Expanded(
            child: Scaffold(
              backgroundColor: const Color(0xFFF5F6FA),
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 1,
                iconTheme: const IconThemeData(color: Colors.black87),
                title: const Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                centerTitle: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: 'Add Product',
                    onPressed: () => _addOrEditProduct(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    tooltip: 'Logout',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDashboardStats(),
                    const SizedBox(height: 20),
                    const Text(
                      'Product Management',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    _buildProductGrid(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Sidebar for larger screens
  Widget _buildSideMenu() {
    return Container(
      width: 220,
      color: Colors.black87,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.centerLeft,
            child: const Text(
              'ADMIN PANEL',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          ),
          const Divider(color: Colors.white24, thickness: 1),
          ...List.generate(_menuItems.length, (index) {
            final selected = selectedIndex == index;
            final item = _menuItems[index];
            return ListTile(
              leading: Icon(item['icon'] as IconData,
                  color: selected ? Colors.white : Colors.white70),
              title: Text(item['label'] as String,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.white70,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  )),
              tileColor: selected ? Colors.white10 : Colors.transparent,
              onTap: () => setState(() => selectedIndex = index),
            );
          }),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              '© 2025 GemStore Admin',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Drawer for small screens (hamburger menu)
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.black87,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.centerLeft,
              child: const Text(
                'ADMIN PANEL',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const Divider(color: Colors.white24, thickness: 1),
            ...List.generate(_menuItems.length, (index) {
              final item = _menuItems[index];
              return ListTile(
                leading: Icon(item['icon'] as IconData, color: Colors.white70),
                title: Text(item['label'] as String,
                    style: const TextStyle(color: Colors.white70)),
                onTap: () {
                  setState(() => selectedIndex = index);
                  Navigator.pop(context);
                },
              );
            }),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                '© 2025 GemStore Admin',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dashboard Stats Cards
  Widget _buildDashboardStats() {
    final stats = [
      {'title': 'Total Products', 'value': _products.length.toString(), 'icon': Icons.shopping_bag_outlined},
      {'title': 'Total Revenue', 'value': '\$12,430', 'icon': Icons.attach_money},
      {'title': 'Orders Today', 'value': '23', 'icon': Icons.receipt_long_outlined},
      {'title': 'Users Online', 'value': '18', 'icon': Icons.people_alt_outlined},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isWide ? 4 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.5,
          children: stats
              .map((stat) => _DashboardCard(
                    title: stat['title'] as String,
                    value: stat['value'] as String,
                    icon: stat['icon'] as IconData,
                  ))
              .toList(),
        );
      },
    );
  }

  // Product Grid
  Widget _buildProductGrid() {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 1200
        ? 4
        : width > 900
            ? 3
            : width > 600
                ? 2
                : 1;

    if (_products.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Text(
            'No products yet. Tap + to add one.',
            style: TextStyle(color: Colors.black54, fontSize: 16),
          ),
        ),
      );
    }

    return GridView.builder(
      itemCount: _products.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        final product = _products[index];
        return _HoverableProductCard(
          product: product,
          onEdit: () => _addOrEditProduct(product),
          onDelete: () => _deleteProduct(product),
        );
      },
    );
  }
}

// Dashboard Stat Card
class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.black.withOpacity(0.85),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(value,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// Product Card with Hover Animation
class _HoverableProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _HoverableProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_HoverableProductCard> createState() => _HoverableProductCardState();
}

class _HoverableProductCardState extends State<_HoverableProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: (_isHovered ? (Matrix4.identity()..scale(1.02)) : Matrix4.identity()),
        child: Card(
          elevation: _isHovered ? 8 : 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(widget.product.imageUrl, fit: BoxFit.cover),
                    ),
                    if (_isHovered)
                      Container(
                        color: Colors.black26,
                        child: const Center(
                          child: Icon(Icons.search, color: Colors.white70, size: 36),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black)),
                    const SizedBox(height: 4),
                    Text('₹${widget.product.price.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.black54, fontSize: 13)),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton.icon(
                    onPressed: widget.onEdit,
                    icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 18),
                    label: const Text('Edit', style: TextStyle(color: Colors.blueAccent)),
                  ),
                  TextButton.icon(
                    onPressed: widget.onDelete,
                    icon: const Icon(Icons.delete, color: Colors.redAccent, size: 18),
                    label: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
