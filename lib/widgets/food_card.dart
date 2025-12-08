import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usulicius_kelompok_lucky/providers/food_provider.dart';

class FoodCard extends StatelessWidget {
  final String foodId;
  final String imageUrl;
  final String title;
  final String location;
  final String rating;
  final VoidCallback? onTap;

  const FoodCard({
    Key? key,
    required this.foodId,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.rating,
    this.onTap,
  }) : super(key: key);

  String cleanRating(String r) {
    if (r.endsWith('.0')) return r.replaceAll('.0', '');
    return r;
  }

  Widget _buildImage() {
    if (imageUrl.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Icon(Icons.fastfood, color: Colors.grey, size: 35),
      );
    }

    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, color: Colors.grey, size: 35),
          );
        },
      );
    } else {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: const Icon(Icons.fastfood, color: Colors.grey, size: 35),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final foodProvider = Provider.of<FoodProvider>(context);
    final bool isFavorite = foodProvider.likedFoods.contains(foodId);

    return InkWell(
      onTap: onTap,
      splashColor: Colors.red[100],
      borderRadius: BorderRadius.circular(15.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(
              color: Colors.red[100]!,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipOval(
                child: SizedBox(
                  width: 70,
                  height: 70,
                  child: _buildImage(),
                ),
              ),

              const SizedBox(width: 16),

              // INFO TEXT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            size: 14, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          cleanRating(rating),
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.red[300],
                  size: 28,
                ),
                onPressed: () {
                  Provider.of<FoodProvider>(context, listen: false)
                      .toggleFavoriteStatus(foodId);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}