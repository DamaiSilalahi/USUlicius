// lib/screens/category_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:usulicius_kelompok_lucky/screens/food_detail_screen.dart';
import 'package:usulicius_kelompok_lucky/widgets/food_card.dart';

class CategoryScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final String category;

  const CategoryScreen({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.category,
  }) : super(key: key);

  // Fungsi helper dari test_makanan_page.dart
  String buildImagePath(String rawImage) {
    if (rawImage.isEmpty) return "";
    return rawImage.startsWith("assets/")
        ? rawImage
        : "assets/images/${rawImage.split('/').last}";
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> foodStream = FirebaseFirestore.instance
        .collection('foods')
        .where('category', isEqualTo: category)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        // ... (AppBar tidak berubah)
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        toolbarHeight: 86,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/images/Logo.png',
              width: 85,
              height: 85,
            ),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 4.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: foodStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("Tidak ada makanan di kategori ini"));
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8.0),
                  itemCount: docs.length,
                  itemBuilder: (ctx, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final foodId = doc.id;

                    // === PERUBAHAN DI SINI ===
                    final String imagePath = buildImagePath(data['image'] ?? '');
                    final String price = (data['price'] ?? 0).toString();
                    final double rating = (data['averageRating'] ?? 0.0).toDouble();

                    return FoodCard(
                      foodId: foodId,
                      imageUrl: imagePath, // <-- Kirim path asset
                      title: data['name'] ?? 'Tanpa Nama',
                      location: data['location'] ?? 'Tanpa Lokasi',
                     rating: rating.toStringAsFixed(1),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FoodDetailScreen(
                              originIndex: 0,
                              foodId: foodId,
                              imageUrl: imagePath,
                              title: data['name'] ?? 'Tanpa Nama',
                              price: "Rp $price",
                              // rating: rating, // <-- HAPUS BARIS INI
                              location: data['location'] ?? 'Tanpa Lokasi',
                              description: data['description'] ?? 'Tanpa Deskripsi',
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}