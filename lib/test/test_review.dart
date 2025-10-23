import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TestReview extends StatefulWidget {
  const TestReview({super.key});

  @override
  State<TestReview> createState() => _TestReviewState();
}

class _TestReviewState extends State<TestReview> {
  final TextEditingController _commentController = TextEditingController();
  double _rating = 0;
  final String _foodID = 'ayam_geprek_mahasiswa'; // contoh, nanti bisa dinamis
  final String _userID = 'dummy_user_001';
  final String _userName = 'Damai';

  // 🔹 Tambah Review
  Future<void> tambahReview() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      await FirebaseFirestore.instance.collection('review').add({
        'comment': _commentController.text.trim(),
        'rating': _rating,
        'foodID': _foodID,
        'userID': _userID,
        'userName': _userName,
      });
      _commentController.clear();
      setState(() => _rating = 0);
      print('✅ Review berhasil ditambahkan!');
    } catch (e) {
      print('❌ Gagal menambahkan review: $e');
    }
  }

  // 🔄 Ambil semua review berdasarkan foodID
  Stream<QuerySnapshot> getReviews() {
    return FirebaseFirestore.instance
        .collection('review')
        .where('foodID', isEqualTo: _foodID)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tes Review & Komentar')),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // ⭐ Rating Input
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: () {
                  setState(() => _rating = index + 1.0);
                },
                icon: Icon(
                  Icons.star,
                  color: _rating >= index + 1 ? Colors.amber : Colors.grey,
                ),
              );
            }),
          ),

          // 💬 Textfield untuk komentar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Tulis komentar...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // 🔘 Tombol kirim
          ElevatedButton(
            onPressed: tambahReview,
            child: const Text('Kirim Review'),
          ),
          const Divider(),

          // 📋 Daftar review dari Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getReviews(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Belum ada review.'));
                }

                final data = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final doc = data[index];
                    return ListTile(
                      title: Text(doc.data().toString().contains('userName')
    ? doc['userName']
    : 'Anonim'),
subtitle: Text(doc.data().toString().contains('comment')
    ? doc['comment']
    : '-'),
trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: List.generate(
    (doc.data().toString().contains('rating')
        ? doc['rating'].toInt()
        : 0),
    (i) => const Icon(Icons.star, color: Colors.amber, size: 18),
  ),
),

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
