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

  String buildImagePath(String rawImage) {
    if (rawImage.isEmpty) return "";
    if (rawImage.startsWith('http')) {
      return rawImage;
    }
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
      body: StreamBuilder<QuerySnapshot>(
        stream: foodStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.hasData ? snapshot.data!.docs : [];

          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: docs.length + 1,
            itemBuilder: (ctx, index) {

              // === ITEM 0: HEADER (JUDUL & SUBTITLE) ===
              if (index == 0) {
                return Column(
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
                    if (docs.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 50.0),
                        child: Center(
                          child: Text("Tidak ada makanan di kategori ini"),
                        ),
                      ),
                  ],
                );
              }

              // === ITEM SELANJUTNYA: MAKANAN ===
              final foodIndex = index - 1;

              if (docs.isEmpty) return const SizedBox();

              final doc = docs[foodIndex];
              final data = doc.data() as Map<String, dynamic>;
              final foodId = doc.id;

              final String imagePath = buildImagePath(data['imageUrl'] ?? data['image'] ?? '');
              final String price = (data['price'] ?? 0).toString();
              final double rating = (data['rating'] ?? data['averageRating'] ?? 0.0).toDouble();

              return FoodCard(
                foodId: foodId,
                imageUrl: imagePath,
                title: data['name'] ?? 'Tanpa Nama',
                location: data['location'] ?? 'Tanpa Lokasi',
                rating: rating.toStringAsFixed(1),
                onTap: () {
                  // === PERBAIKAN ANIMASI DI SINI ===
                  // Ganti MaterialPageRoute dengan PageRouteBuilder (Duration.zero)
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => FoodDetailScreen(
                        originIndex: 0,
                        foodId: foodId,
                        imageUrl: imagePath,
                        title: data['name'] ?? 'Tanpa Nama',
                        price: "Rp $price",
                        location: data['location'] ?? 'Tanpa Lokasi',
                        description: data['description'] ?? 'Tanpa Deskripsi',
                      ),
                      // Ini kuncinya: durasi 0 agar instan (tanpa swipe)
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}