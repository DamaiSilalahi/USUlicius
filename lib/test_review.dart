import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TestReviewPage extends StatelessWidget {
  const TestReviewPage({super.key});

  Future<void> tambahReview() async {
    try {
      await FirebaseFirestore.instance.collection('review').add({
        'comment': 'Rasanya enak!!!',
        'foodID': 'ayam_geprek_mahasiswa',
        'rating': 4.5,
        'tanggal': '28 September 2025',
        'userID': 'dummy_user_001',
        'userName': 'Damai',
      });

      print('✅ Review berhasil ditambahkan!');
    } catch (e) {
      print('❌ Gagal menambahkan review: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tes Tambah Review')),
      body: Center(
        child: ElevatedButton(
          onPressed: tambahReview,
          child: const Text('Tambah Review ke Firestore'),
        ),
      ),
    );
  }
}
