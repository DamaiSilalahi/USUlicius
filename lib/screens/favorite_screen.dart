import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usulicius_kelompok_lucky/providers/food_provider.dart';
import 'package:usulicius_kelompok_lucky/widgets/food_card.dart';
import 'package:usulicius_kelompok_lucky/screens/food_detail_screen.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final foodProvider = Provider.of<FoodProvider>(context);
    final favoriteItems = foodProvider.favoriteItems;

    return favoriteItems.isEmpty
        ? const EmptyFavoriteState()
        : ListView.builder(
      padding: const EdgeInsets.only(top: 23.0),
      itemCount: favoriteItems.length,
      itemBuilder: (ctx, index) {
        final food = favoriteItems[index];
        return FoodCard(
          imageUrl: food.imageUrl,
          title: food.title,
          location: food.location,
          rating: food.rating.toString(),
          isFavorite: food.isFavorite,
          onFavoritePressed: () {
            foodProvider.toggleFavoriteStatus(food.id);
          },
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FoodDetailScreen(
                  originIndex: 1,
                  foodId: food.id,
                  imageUrl: food.imageUrl,
                  title: food.title,
                  price: food.price,
                  rating: food.rating,
                  location: food.location,
                  description: food.description,
                ),
              ),
            );
          },
        );
      },
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