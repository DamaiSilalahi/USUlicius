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
    if (_commentController.text.trim().isEmpty) return;

    try {
      await FirebaseFirestore.instance.collection('reviews').add({
        'comment': _commentController.text.trim(),
        'rating': _rating,
        'foodID': _foodID,
        'userID': _userID,
        'date': Timestamp.now(),
      });

      _commentController.clear();
      setState(() => _rating = 0);
      print('✅ Review berhasil ditambahkan!');
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
                    final d = doc.data() as Map<String, dynamic>;

                    String tanggal = "";
                    if (d['date'] != null) {
                      final Timestamp t = d['date'];
                      final DateTime dt = t.toDate();

                      final bulan = [
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
                        "Desember"
                      ];

                      tanggal =
                          "${dt.day} ${bulan[dt.month - 1]} ${dt.year} – "
                          "${dt.hour.toString().padLeft(2, '0')}:"
                          "${dt.minute.toString().padLeft(2, '0')}";
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
                                fontSize: 12, color: Colors.grey),
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
