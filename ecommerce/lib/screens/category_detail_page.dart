import 'package:flutter/material.dart';

class CategoryDetailPage extends StatelessWidget {
  final String title;
  const CategoryDetailPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    
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
          'image': 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246',
          'desc': 'Chic dresses to elevate your wardrobe.'
        },
        {
          'name': 'Sweaters',
          'count': 24,
          'image': 'https://images.unsplash.com/photo-1503341455253-b2e723bb3dbb',
          'desc': 'Soft and cozy sweaters for comfort and warmth.'
        },
        {
          'name': 'Jeans',
          'count': 14,
          'image': 'https://images.unsplash.com/photo-1514995669114-6081e934b693',
          'desc': 'Classic denim styles for everyday wear.'
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
        {
          'name': 'Boots',
          'count': 33,
          'image': 'https://images.unsplash.com/photo-1606813902914-8c7bd7e389b6',
          'desc': 'Stylish boots perfect for all weather.'
        },
      ],
      'Accessories': [
        {
          'name': 'Handbags',
          'count': 64,
          'image': 'https://images.unsplash.com/photo-1584917865442-de89df76afd3',
          'desc': 'Premium handbags for every occasion.'
        },
        {
          'name': 'Watches',
          'count': 37,
          'image': 'https://images.unsplash.com/photo-1519741497674-611481863552',
          'desc': 'Timeless pieces to match your style.'
        },
        {
          'name': 'Scarves',
          'count': 19,
          'image': 'https://images.unsplash.com/photo-1520974735194-611481863552',
          'desc': 'Soft scarves that add charm to your look.'
        },
      ],
      'Collection': [
        {
          'name': 'Spring Collection',
          'count': 48,
          'image': 'https://images.unsplash.com/photo-1521335629791-ce4aec67dd47',
          'desc': 'Fresh spring styles to rejuvenate your wardrobe.'
        },
        {
          'name': 'Summer Collection',
          'count': 39,
          'image': 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d',
          'desc': 'Bright and breezy summer wear for sunny days.'
        },
        {
          'name': 'Winter Collection',
          'count': 27,
          'image': 'https://images.unsplash.com/photo-1512428559087-560fa5ceab42',
          'desc': 'Warm winter fashion made to keep you cozy.'
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
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              elevation: 1.5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/placeholder.png',
                    image: item['image'],
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(item['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Text(item['desc'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
                trailing: Text('${item['count']} items',
                    style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
                onTap: () {},
              ),
            );
          },
        ),
      ),
    );
  }
}
