// lib/providers/food_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FoodProvider with ChangeNotifier {
  // Kita akan gunakan ID user dummy dari file tes Anda
  final String _userID = 'dummy_user_001';

  // Set untuk menyimpan ID makanan yang disukai.
  Set<String> _likedFoods = {};

  // Constructor: Panggil loadFavorites() saat provider dibuat
  FoodProvider() {
    loadFavorites();
  }

  // Getter untuk UI
  Set<String> get likedFoods => _likedFoods;

  // 1. Ambil daftar favorit dari Firestore
  Future<void> loadFavorites() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('favorites')
          .where('userID', isEqualTo: _userID)
          .get();

      _likedFoods = snapshot.docs
          .map((doc) => doc['foodID'] as String)
          .toSet();

      notifyListeners(); // Beri tahu UI
    } catch (e) {
      print("Gagal load favorites: $e");
    }
  }

  // 2. Tambah favorit ke Firestore
  Future<void> addFavorite(String foodID) async {
    try {
      // Update state lokal dulu agar UI cepat
      _likedFoods.add(foodID);
      notifyListeners();

      // Kirim ke Firestore
      await FirebaseFirestore.instance.collection('favorites').add({
        'foodID': foodID,
        'userID': _userID,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Jika gagal, batalkan
      _likedFoods.remove(foodID);
      notifyListeners();
      print("Gagal tambah favorit: $e");
    }
  }

  // 3. Hapus favorit dari Firestore
  Future<void> removeFavorite(String foodID) async {
    try {
      // Update state lokal dulu
      _likedFoods.remove(foodID);
      notifyListeners();

      // Hapus dari Firestore
      final query = await FirebaseFirestore.instance
          .collection('favorites')
          .where('foodID', isEqualTo: foodID)
          .where('userID', isEqualTo: _userID)
          .get();

      for (var doc in query.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      // Jika gagal, kembalikan
      _likedFoods.add(foodID);
      notifyListeners();
      print("Gagal hapus favorit: $e");
    }
  }

  // 4. Fungsi Toggle (yang akan dipanggil UI)
  void toggleFavoriteStatus(String foodID) {
    if (_likedFoods.contains(foodID)) {
      removeFavorite(foodID);
    } else {
      addFavorite(foodID);
    }
    // notifyListeners() sudah dipanggil di dalam add/remove
  }

// File food.dart sekarang tidak diperlukan lagi
// karena kita akan membaca data langsung dari Firestore.
}