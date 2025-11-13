// lib/models/food.dart

// Kita buat enum untuk mempermudah filter kategori
enum FoodCategory { Pedas, Manis, PilihanMahasiswa }

class Food {
  final String id;
  final String title;
  final String imageUrl;
  final String price;
  final int rating;
  final String location;
  final String description;
  final List<FoodCategory> categories;
  bool isFavorite; // Ini yang akan kita ubah-ubah

  Food({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.rating,
    required this.location,
    required this.description,
    required this.categories,
    this.isFavorite = false,
  });
}