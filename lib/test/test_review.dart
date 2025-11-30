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

  final String _foodID = 'ayam_geprek_mahasiswa';
  final String _userID = 'dummy_user_001';

  Future<void> tambahReview() async {
    if (_commentController.text.trim().isEmpty || _rating == 0) return;

    try {
      // 🔹 Simpan review ke koleksi 'reviews'
      await FirebaseFirestore.instance.collection('reviews').add({
        'comment': _commentController.text.trim(),
        'rating': _rating,
        'foodID': _foodID,
        'userID': _userID,
        'date': Timestamp.now(),
      });

      // 🔥 Update data summary rating di tabel 'foods'
      final foodRef = FirebaseFirestore.instance.collection('foods').doc(_foodID);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(foodRef);

        final currentCount = snapshot.data()?['ratingsCount'] is num
            ? snapshot.data()!['ratingsCount']
            : 0;
        final currentSum = snapshot.data()?['ratingsSum'] is num
            ? snapshot.data()!['ratingsSum']
            : 0;

        final newCount = currentCount + 1;
        final newSum = currentSum + _rating.toInt();
        final newAverage = newSum / newCount;

        transaction.update(foodRef, {
          'ratingsCount': newCount,
          'ratingsSum': newSum,
          'averageRating': newAverage,
        });
      });

      _commentController.clear();
      setState(() => _rating = 0);
      print('✅ Review + Rating berhasil ditambahkan!');
    } catch (e) {
      print('❌ Gagal menambahkan review: $e');
    }
  }

  Stream<QuerySnapshot> getReviews() {
    return FirebaseFirestore.instance
        .collection('reviews')
        .where('foodID', isEqualTo: _foodID)
        .orderBy('date', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tes Review & Komentar')),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // ⭐ Pilih rating
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

          ElevatedButton(
            onPressed: tambahReview,
            child: const Text('Kirim Review'),
          ),

          const Divider(),

          // 🔹 Daftar review
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
                    final d = data[index].data() as Map<String, dynamic>;

                    String tanggal = "";
                    if (d['date'] != null) {
                      final t = (d['date'] as Timestamp).toDate();
                      const bulan = [
                        "Januari",
                        "Februari",
                        "Maret",
                        "April",
                        "Mei",
                        "Juni",
                        "Juli",
                        "Agustus",
                        "September",
                        "Oktober",
                        "November",
                        "Desember",
                      ];
                      tanggal =
                          "${t.day} ${bulan[t.month - 1]} ${t.year} – "
                          "${t.hour.toString().padLeft(2, '0')}:"
                          "${t.minute.toString().padLeft(2, '0')}";
                    }

                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text("User: ${d['userID']}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d['comment'] ?? '-'),
                          const SizedBox(height: 4),
                          Text(
                            tanggal,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          d['rating'] != null ? d['rating'].toInt() : 0,
                          (i) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 18,
                          ),
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
