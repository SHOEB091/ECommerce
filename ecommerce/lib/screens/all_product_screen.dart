// import 'package:flutter/material.dart';
// import 'product_detail_screen.dart';
// import 'package:ecommerce/screens/home_screen.dart';

// class AllProductsScreen extends StatefulWidget {
//   const AllProductsScreen({super.key});

//   @override
//   State<AllProductsScreen> createState() => _AllProductsScreenState();
// }

// class _AllProductsScreenState extends State<AllProductsScreen> {
//   final List<Map<String, dynamic>> _allProducts = [
//     // --- Men's ---
//     {
//       "name": "Casual Shirt",
//       "price": 45.00,
//       "priceLabel": "\$45.00",
//       "image": "assets/shirt.jpg",
//       "rating": 4.5,
//       "reviews": 120
//     },
//     {
//       "name": "Denim Jacket",
//       "price": 65.00,
//       "priceLabel": "\$65.00",
//       "image": "assets/sample10.jpg",
//       "rating": 4.7,
//       "reviews": 98
//     },

//     // --- Women's ---
//     {
//       "name": "Linen Dress",
//       "price": 52.00,
//       "priceLabel": "\$52.00",
//       "image": "assets/sample5.jpg",
//       "rating": 4.5,
//       "reviews": 134
//     },
//     {
//       "name": "Maxi Dress",
//       "price": 68.00,
//       "priceLabel": "\$68.00",
//       "image": "assets/sample7.jpg",
//       "rating": 4.6,
//       "reviews": 146
//     },

//     // --- Accessories ---
//     {
//       "name": "Leather Wallet",
//       "price": 30.00,
//       "priceLabel": "\$30.00",
//       "image": "assets/purse.jpg",
//       "rating": 4.8,
//       "reviews": 145
//     },
//     {
//       "name": "Analog Watch",
//       "price": 75.00,
//       "priceLabel": "\$75.00",
//       "image": "assets/watch.jpg",
//       "rating": 4.6,
//       "reviews": 201
//     },

//     // --- More ---
//     {
//       "name": "Perfume",
//       "price": 40.00,
//       "priceLabel": "\$40.00",
//       "image": "assets/perfume.jpg",
//       "rating": 4.3,
//       "reviews": 132
//     },
//     {
//       "name": "Gift Box",
//       "price": 50.00,
//       "priceLabel": "\$50.00",
//       "image": "assets/giftbox.jpg",
//       "rating": 4.4,
//       "reviews": 158
//     },
//   ];

//   late List<Map<String, dynamic>> _filteredProducts;

//   // Filter controls
//   double _minRating = 0.0;
//   double _maxPrice = 200.0;
//   String _sort = 'none'; // 'none', 'price_asc', 'price_desc', 'rating_desc'

//   @override
//   void initState() {
//     super.initState();
//     _filteredProducts = List<Map<String, dynamic>>.from(_allProducts);
//   }

//   void _applyFilters() {
//     List<Map<String, dynamic>> temp = _allProducts.where((p) {
//       final ratingOk = (p['rating'] as double) >= _minRating;
//       final priceOk = (p['price'] as double) <= _maxPrice;
//       return ratingOk && priceOk;
//     }).toList();

//     if (_sort == 'price_asc') {
//       temp.sort((a, b) => (a['price'] as double).compareTo(b['price'] as double));
//     } else if (_sort == 'price_desc') {
//       temp.sort((a, b) => (b['price'] as double).compareTo(a['price'] as double));
//     } else if (_sort == 'rating_desc') {
//       temp.sort((a, b) => (b['rating'] as double).compareTo(a['rating'] as double));
//     }

//     setState(() {
//       _filteredProducts = temp;
//     });
//   }

//   void _openFilterSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) {
//         double localMinRating = _minRating;
//         double localMaxPrice = _maxPrice;
//         String localSort = _sort;

//         return StatefulBuilder(builder: (context, setModalState) {
//           return Padding(
//             padding: EdgeInsets.only(
//               bottom: MediaQuery.of(context).viewInsets.bottom,
//               left: 16,
//               right: 16,
//               top: 20,
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text('Filter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                     TextButton(
//                       onPressed: () {
//                         setModalState(() {
//                           localMinRating = 0.0;
//                           localMaxPrice = 200.0;
//                           localSort = 'none';
//                         });
//                       },
//                       child: const Text('Reset'),
//                     )
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 const Text('Minimum rating'),
//                 Slider(
//                   min: 0,
//                   max: 5,
//                   divisions: 5,
//                   value: localMinRating,
//                   label: localMinRating.toStringAsFixed(1),
//                   onChanged: (v) => setModalState(() => localMinRating = v),
//                 ),
//                 const SizedBox(height: 8),
//                 const Text('Max price (\$)'),
//                 Slider(
//                   min: 0,
//                   max: 200,
//                   divisions: 20,
//                   value: localMaxPrice,
//                   label: localMaxPrice.toStringAsFixed(0),
//                   onChanged: (v) => setModalState(() => localMaxPrice = v),
//                 ),
//                 const SizedBox(height: 8),
//                 const Text('Sort by'),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: RadioListTile<String>(
//                         contentPadding: EdgeInsets.zero,
//                         value: 'none',
//                         groupValue: localSort,
//                         title: const Text('None'),
//                         onChanged: (v) => setModalState(() => localSort = v!),
//                       ),
//                     ),
//                     Expanded(
//                       child: RadioListTile<String>(
//                         contentPadding: EdgeInsets.zero,
//                         value: 'price_asc',
//                         groupValue: localSort,
//                         title: const Text('Price ↑'),
//                         onChanged: (v) => setModalState(() => localSort = v!),
//                       ),
//                     ),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: RadioListTile<String>(
//                         contentPadding: EdgeInsets.zero,
//                         value: 'price_desc',
//                         groupValue: localSort,
//                         title: const Text('Price ↓'),
//                         onChanged: (v) => setModalState(() => localSort = v!),
//                       ),
//                     ),
//                     Expanded(
//                       child: RadioListTile<String>(
//                         contentPadding: EdgeInsets.zero,
//                         value: 'rating_desc',
//                         groupValue: localSort,
//                         title: const Text('Rating'),
//                         onChanged: (v) => setModalState(() => localSort = v!),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed: () {
//                           _minRating = localMinRating;
//                           _maxPrice = localMaxPrice;
//                           _sort = localSort;
//                           _applyFilters();
//                           Navigator.of(context).pop();
//                         },
//                         child: const Text('Apply'),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           );
//         });
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
//           onPressed: () {
//             Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(builder: (_) => const HomeScreen()),
//               (route) => false,
//             );
//           },
//         ),
//         title: const Text(
//           "All Products",
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 8),
//             child: IconButton(
//               icon: const Icon(Icons.filter_list_rounded, color: Colors.black),
//               onPressed: _openFilterSheet,
//             ),
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Found ${_filteredProducts.length} Results",
//                 style: const TextStyle(fontSize: 15, color: Colors.grey),
//               ),
//               const SizedBox(height: 10),
//               Expanded(
//                 child: GridView.builder(
//                   physics: const BouncingScrollPhysics(),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     mainAxisSpacing: 20,
//                     crossAxisSpacing: 15,
//                     childAspectRatio: 0.58, // slightly taller cards
//                   ),
//                   itemCount: _filteredProducts.length,
//                   itemBuilder: (context, index) {
//                     final product = _filteredProducts[index];
//                     return GestureDetector(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => ProductDetailScreen(product: product),
//                           ),
//                         );
//                       },
//                       child: Container(
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(12),
//                           color: Colors.white,
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.05),
//                               blurRadius: 4,
//                               offset: const Offset(0, 2),
//                             )
//                           ],
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Expanded(
//                               child: Stack(
//                                 children: [
//                                   ClipRRect(
//                                     borderRadius: const BorderRadius.only(
//                                       topLeft: Radius.circular(12),
//                                       topRight: Radius.circular(12),
//                                     ),
//                                     child: Image.asset(
//                                       product["image"],
//                                       fit: BoxFit.cover,
//                                       width: double.infinity,
//                                     ),
//                                   ),
//                                   const Positioned(
//                                     top: 8,
//                                     right: 8,
//                                     child: CircleAvatar(
//                                       radius: 14,
//                                       backgroundColor: Colors.white,
//                                       child: Icon(
//                                         Icons.favorite_border,
//                                         color: Colors.black,
//                                         size: 18,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     product["name"],
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 14,
//                                     ),
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     product["priceLabel"],
//                                     style: const TextStyle(
//                                       color: Colors.black,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Row(
//                                     children: [
//                                       const Icon(Icons.star, color: Colors.amber, size: 16),
//                                       const SizedBox(width: 3),
//                                       Text("${product["rating"]}", style: const TextStyle(fontSize: 13)),
//                                       const SizedBox(width: 3),
//                                       Text("(${product["reviews"]})", style: const TextStyle(fontSize: 12, color: Colors.grey)),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
