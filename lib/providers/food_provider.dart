// lib/providers/food_provider.dart
import 'package:flutter/material.dart';
import '../models/food.dart';

class FoodProvider with ChangeNotifier {
  // Ini adalah "database" utama kita.
  // Saya ambil semua data dummy dari file-file Anda dan satukan di sini.
  final List<Food> _items = [
    Food(
      id: 'm1',
      title: 'Ayam Geprek Mahasiswa',
      imageUrl: 'https://cdn-2.tstatic.net/medan/foto/bank/images/Ayam-geprek-bensu-medan.jpg',
      price: 'Rp. 10.000',
      rating: 5,
      location: 'Jl. Pembangunan No.117Padang, BulanKec, Kec. Medan Baru, Kota Medan',
      description: 'Ayam geprek Mahasiswa disajikan bersama nasi hangat, lengkap dengan tambahan lauk seperti tempe, terong goreng dan segelas teh manis dingin yang menyegarkan. Dengan harga yang sangat terjangkau, Geprek Mahasiswa menawarkan perpaduan rasa yang nikmat, porsi yang mengenyangkan, serta suasana santai yang membuatnya semakin cocok sebagai tempat makan sehari-hari bagi mahasiswa.',
      categories: [FoodCategory.Pedas, FoodCategory.PilihanMahasiswa],
    ),
    Food(
      id: 'm2',
      title: 'Pancong Lumer USU',
      imageUrl: 'https://picsum.photos/id/45/200',
      price: 'Rp. 12.000',
      rating: 5,
      location: 'Pintu 4, USU',
      description: 'Deskripsi lengkap untuk Pancong Lumer USU...',
      categories: [FoodCategory.Manis, FoodCategory.PilihanMahasiswa],
    ),
    Food(
      id: 'm3',
      title: 'Nasi baby cumi sambal ijo',
      imageUrl: 'https://picsum.photos/id/21/200',
      price: 'Rp. 18.000',
      rating: 5,
      location: 'Jl. Sei Serayu No.97',
      description: 'Deskripsi lengkap untuk Nasi baby cumi...',
      categories: [FoodCategory.Pedas, FoodCategory.PilihanMahasiswa],
    ),
    Food(
      id: 'm4',
      title: 'Mie bakso mercon',
      imageUrl: 'https://picsum.photos/id/102/200',
      price: 'Rp. 15.000',
      rating: 5,
      location: 'Jalan Pembangunan',
      description: 'Deskripsi lengkap untuk Mie Bakso Mercon...',
      categories: [FoodCategory.Pedas],
    ),
    Food(
      id: 'm5',
      title: 'Pancake Durian',
      imageUrl: 'https://picsum.photos/id/106/200',
      price: 'Rp. 15.000',
      rating: 5,
      location: 'Dr. mansyur',
      description: 'Deskripsi lengkap untuk Pancake Durian...',
      categories: [FoodCategory.Manis],
    ),
    Food(
      id: 'm6',
      title: 'Napoleon Cake',
      imageUrl: 'https://picsum.photos/id/107/200',
      price: 'Rp. 20.000',
      rating: 5,
      location: 'Jl. Sei Serayu No.97',
      description: 'Deskripsi lengkap untuk Napoleon Cake...',
      categories: [FoodCategory.Manis],
    ),
  ];

  // Getter untuk mengambil semua item makanan
  List<Food> get items {
    return [..._items];
  }

  // Getter untuk mengambil HANYA item yang difavoritkan
  // Ini yang akan digunakan oleh FavoriteScreen
  List<Food> get favoriteItems {
    return _items.where((item) => item.isFavorite).toList();
  }

  // Getter untuk mengambil item rekomendasi di home (saya ambil 4)
  List<Food> get recommendedItems {
    return _items.take(4).toList();
  }

  // Getter untuk mengambil item berdasarkan kategori
  List<Food> getItemsByCategory(FoodCategory category) {
    return _items.where((item) => item.categories.contains(category)).toList();
  }

  // Getter untuk mencari 1 item berdasarkan ID
  Food findById(String id) {
    return _items.firstWhere((item) => item.id == id);
  }

  // FUNGSI UTAMA: Mengubah status favorit
  void toggleFavoriteStatus(String id) {
    final food = findById(id);
    food.isFavorite = !food.isFavorite; // Ubah statusnya
    notifyListeners(); // Beri tahu semua widget yang mendengarkan
  }
}