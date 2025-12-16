import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FoodProvider with ChangeNotifier {

  // Ambil UID user yang login
  String get _userId => FirebaseAuth.instance.currentUser!.uid;

  Set<String> _likedFoods = {};

  FoodProvider() {
    loadFavorites();
  }

  Set<String> get likedFoods => _likedFoods;

  // 1. Load favorites dari Firestore
  Future<void> loadFavorites() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('favorites')
          .where('userId', isEqualTo: _userId)
          .get();

      _likedFoods = snapshot.docs
          .map((doc) => doc['foodID'] as String)
          .toSet();

      notifyListeners();
    } catch (e) {
      print("Gagal load favorites: $e");
    }
  }

  // 2. Tambah favorit
  Future<void> addFavorite(String foodID) async {
    try {
      _likedFoods.add(foodID);
      notifyListeners();

      await FirebaseFirestore.instance.collection('favorites').add({
        'foodID': foodID,
        'userId': _userId,                     // <-- FIX
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _likedFoods.remove(foodID);
      notifyListeners();
      print("Gagal tambah favorit: $e");
    }
  }

  // 3. Hapus favorit
  Future<void> removeFavorite(String foodID) async {
    try {
      _likedFoods.remove(foodID);
      notifyListeners();

      final query = await FirebaseFirestore.instance
          .collection('favorites')
          .where('foodID', isEqualTo: foodID)
          .where('userId', isEqualTo: _userId)    // <-- FIX
          .get();

      for (var doc in query.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      _likedFoods.add(foodID);
      notifyListeners();
      print("Gagal hapus favorit: $e");
    }
  }

  // 4. Toggle favorit
  void toggleFavoriteStatus(String foodID) {
    if (_likedFoods.contains(foodID)) {
      removeFavorite(foodID);
    } else {
      addFavorite(foodID);
    }
  }
}
