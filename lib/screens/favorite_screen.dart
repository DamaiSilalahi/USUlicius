import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usulicius_kelompok_lucky/providers/food_provider.dart';
import 'package:usulicius_kelompok_lucky/widgets/food_card.dart';
import 'package:usulicius_kelompok_lucky/screens/food_detail_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => FavoriteScreenState();
}

class FavoriteScreenState extends State<FavoriteScreen> {
  // 1. Buat ScrollController
  final ScrollController _scrollController = ScrollController();

  // 2. Fungsi Scroll to Top
  void scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String buildImagePath(String rawImage) {
    if (rawImage.isEmpty) return "";
    // Cek http juga biar konsisten
    if (rawImage.startsWith('http')) {
      return rawImage;
    }
    return rawImage.startsWith("assets/")
        ? rawImage
        : "assets/images/${rawImage.split('/').last}";
  }

  @override
  Widget build(BuildContext context) {
    final foodProvider = Provider.of<FoodProvider>(context);
    final likedFoodIds = foodProvider.likedFoods;

    if (likedFoodIds.isEmpty) {
      return const EmptyFavoriteState();
    }

    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('foods').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Data makanan tidak ditemukan."));
          }

          final allFoods = snapshot.data!.docs;

          final favoriteItems = allFoods.where((doc) {
            return likedFoodIds.contains(doc.id);
          }).toList();

          if (favoriteItems.isEmpty) {
            return const EmptyFavoriteState();
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(top: 8.0),
            itemCount: favoriteItems.length,
            itemBuilder: (ctx, index) {
              final doc = favoriteItems[index];
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
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => FoodDetailScreen(
                        originIndex: 2,
                        foodId: foodId,
                        imageUrl: imagePath,
                        title: data['name'] ?? 'Tanpa Nama',
                        price: "Rp $price",
                        location: data['location'] ?? 'Tanpa Lokasi',
                        description: data['description'] ?? 'Tanpa Deskripsi',
                      ),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
              );
            },
          );
        }
    );
  }
}

class EmptyFavoriteState extends StatelessWidget {
  const EmptyFavoriteState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 150,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.folder_open,
                  size: 120,
                  color: Color(0xFFFBC02D),
                ),
                Positioned(
                  bottom: 5,
                  right: 25,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Favorite data is still empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}