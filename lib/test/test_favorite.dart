import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TestFavorite extends StatelessWidget {
  const TestFavorite({super.key});

  // ➕ Tambah data favorite
  Future<void> tambahFavorite() async {
    try {
      await FirebaseFirestore.instance.collection('favorite').add({
        'userID': 'dummy_user_001',
        'foodID': 'ayam_geprek_mahasiswa',
      });
      print('✅ Favorite berhasil ditambahkan!');
    } catch (e) {
      print('❌ Gagal menambahkan favorite: $e');
    }
  }

  // ❌ Hapus data favorite berdasarkan ID dokumen
  Future<void> hapusFavorite(String docID) async {
    try {
      await FirebaseFirestore.instance
          .collection('favorite')
          .doc(docID)
          .delete();
      print('✅ Favorite berhasil dihapus!');
    } catch (e) {
      print('❌ Gagal menghapus favorite: $e');
    }
  }

  // 🔄 Stream daftar favorite (real-time dari Firestore)
  Stream<QuerySnapshot> getFavorites() {
    return FirebaseFirestore.instance.collection('favorite').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tes Favorite')),
      body: Column(
        children: [
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: tambahFavorite,
            child: const Text('Tambah Favorite'),
          ),
          const SizedBox(height: 20),
          const Text('Daftar Favorite di Firestore:', style: TextStyle(fontSize: 16)),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getFavorites(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final data = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final doc = data[index];
                    return ListTile(
                      title: Text(doc['foodID']),
                      subtitle: Text('User: ${doc['userID']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => hapusFavorite(doc.id),
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
