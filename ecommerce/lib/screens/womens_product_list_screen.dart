import 'package:flutter/material.dart';
import 'product_detail_screen.dart';

class WomenProductListScreen extends StatefulWidget {
  const WomenProductListScreen({super.key});

  @override
  State<WomenProductListScreen> createState() => _WomenProductListScreenState();
}

class _WomenProductListScreenState extends State<WomenProductListScreen> {
  final List<Map<String, dynamic>> _allProducts = const [
    {
      "name": "Linen Dress",
      "price": 52.00,
      "priceLabel": "\$52.00",
      "image": "assets/sample5.jpg",
      "rating": 4.5,
      "reviews": 134
    },
    {
      "name": "Fitted Waist Dress",
      "price": 47.99,
      "priceLabel": "\$47.99",
      "image": "assets/sample6.jpg",
      "rating": 4.2,
      "reviews": 119
    },
    {
      "name": "Maxi Dress",
      "price": 68.00,
      "priceLabel": "\$68.00",
      "image": "assets/sample7.jpg",
      "rating": 4.6,
      "reviews": 146
    },
    {
      "name": "Front Tie Mini Dress",
      "price": 59.00,
      "priceLabel": "\$59.00",
      "image": "assets/sample8.jpg",
      "rating": 4.0,
      "reviews": 118
    },
    {
      "name": "Ohara Dress",
      "price": 85.00,
      "priceLabel": "\$85.00",
      "image": "assets/sample9.jpg",
      "rating": 4.7,
      "reviews": 203
    },
    {
      "name": "Tie Back Mini Dress",
      "price": 67.00,
      "priceLabel": "\$67.00",
      "image": "assets/sample_img4.jpg",
      "rating": 4.3,
      "reviews": 179
    },
    {
      "name": "Leaves Green Dress",
      "price": 64.00,
      "priceLabel": "\$64.00",
      "image": "assets/sample_img3.jpg",
      "rating": 4.8,
      "reviews": 213
    },
    {
      "name": "Off Shoulder Dress",
      "price": 78.99,
      "priceLabel": "\$78.99",
      "image": "assets/sample_image1.jpg",
      "rating": 4.5,
      "reviews": 191
    },
  ];

  late List<Map<String, dynamic>> _filteredProducts;

  double _minRating = 0.0;
  double _maxPrice = 200.0;
  String _sort = 'none';

  @override
  void initState() {
    super.initState();
    _filteredProducts = List<Map<String, dynamic>>.from(_allProducts);
  }

  void _applyFilters() {
    List<Map<String, dynamic>> temp = _allProducts.where((p) {
      final ratingOk = (p['rating'] as double) >= _minRating;
      final priceOk = (p['price'] as double) <= _maxPrice;
      return ratingOk && priceOk;
    }).toList();

    if (_sort == 'price_asc') {
      temp.sort((a, b) => (a['price'] as double).compareTo(b['price'] as double));
    } else if (_sort == 'price_desc') {
      temp.sort((a, b) => (b['price'] as double).compareTo(a['price'] as double));
    } else if (_sort == 'rating_desc') {
      temp.sort((a, b) => (b['rating'] as double).compareTo(a['rating'] as double));
    }

    setState(() {
      _filteredProducts = temp;
    });
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        double localMinRating = _minRating;
        double localMaxPrice = _maxPrice;
        String localSort = _sort;

        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Filter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () {
                        setModalState(() {
                          localMinRating = 0.0;
                          localMaxPrice = 200.0;
                          localSort = 'none';
                        });
                      },
                      child: const Text('Reset'),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Minimum rating'),
                Slider(
                  min: 0,
                  max: 5,
                  divisions: 5,
                  value: localMinRating,
                  label: localMinRating.toStringAsFixed(1),
                  onChanged: (v) => setModalState(() => localMinRating = v),
                ),
                const SizedBox(height: 8),
                const Text('Max price (\$)'),
                Slider(
                  min: 0,
                  max: 200,
                  divisions: 20,
                  value: localMaxPrice,
                  label: localMaxPrice.toStringAsFixed(0),
                  onChanged: (v) => setModalState(() => localMaxPrice = v),
                ),
                const SizedBox(height: 8),
                const Text('Sort by'),
                Wrap(
                  spacing: 10,
                  children: [
                    ChoiceChip(
                      label: const Text('None'),
                      selected: localSort == 'none',
                      onSelected: (_) => setModalState(() => localSort = 'none'),
                    ),
                    ChoiceChip(
                      label: const Text('Price ↑'),
                      selected: localSort == 'price_asc',
                      onSelected: (_) => setModalState(() => localSort = 'price_asc'),
                    ),
                    ChoiceChip(
                      label: const Text('Price ↓'),
                      selected: localSort == 'price_desc',
                      onSelected: (_) => setModalState(() => localSort = 'price_desc'),
                    ),
                    ChoiceChip(
                      label: const Text('Rating'),
                      selected: localSort == 'rating_desc',
                      onSelected: (_) => setModalState(() => localSort = 'rating_desc'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _minRating = localMinRating;
                    _maxPrice = localMaxPrice;
                    _sort = localSort;
                    _applyFilters();
                    Navigator.of(context).pop();
                  },
                  child: const Center(child: Text('Apply')),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      int crossAxisCount = 2;
      double aspectRatio = 0.6;

      if (width >= 1200) {
        crossAxisCount = 5;
        aspectRatio = 0.8;
      } else if (width >= 800) {
        crossAxisCount = 4;
        aspectRatio = 0.7;
      } else if (width >= 600) {
        crossAxisCount = 3;
        aspectRatio = 0.65;
      }

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Dresses",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: IconButton(
                icon: const Icon(Icons.filter_list_rounded, color: Colors.black),
                onPressed: _openFilterSheet,
              ),
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width > 900 ? 60 : 16,
            vertical: 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Found ${_filteredProducts.length} Results",
                style: const TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 15,
                    childAspectRatio: aspectRatio,
                  ),
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(product: product),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  product["image"],
                                  fit: BoxFit.cover,
                                  height: width > 900 ? 260 : 210,
                                  width: double.infinity,
                                ),
                              ),
                              const Positioned(
                                top: 8,
                                right: 8,
                                child: CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.favorite_border, color: Colors.black, size: 18),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            product["name"],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            product["priceLabel"],
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 3),
                              Text("${product["rating"]}", style: const TextStyle(fontSize: 13)),
                              const SizedBox(width: 3),
                              Text(
                                "(${product["reviews"]})",
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
