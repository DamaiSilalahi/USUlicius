import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TestMakananFilterPage extends StatefulWidget {
  const TestMakananFilterPage({super.key});

  @override
  State<TestMakananFilterPage> createState() => _TestMakananFilterPageState();
}

class _TestMakananFilterPageState extends State<TestMakananFilterPage> {
  String kategoriDipilih = "Pedas";
  String keyword = "";
  List<Map<String, dynamic>> hasil = [];

  Future<void> ambilMakanan() async {
    Query query = FirebaseFirestore.instance.collection('makanan');

    // filter kategori (jika tidak kosong)
    if (kategoriDipilih.isNotEmpty) {
      query = query.where('kategori', isEqualTo: kategoriDipilih);
    }

    // filter pencarian (berdasarkan nama)
    if (keyword.isNotEmpty) {
      query = query
          .where('nama', isGreaterThanOrEqualTo: keyword)
          .where('nama', isLessThanOrEqualTo: '$keyword\uf8ff');
    }

    final snapshot = await query.get();
    setState(() {
      hasil = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    ambilMakanan(); // ambil awal kategori default
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Filter & Cari Makanan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown kategori
            DropdownButton<String>(
              value: kategoriDipilih,
              items: const [
                DropdownMenuItem(value: "Pedas", child: Text("Pedas")),
                DropdownMenuItem(value: "Manis", child: Text("Manis")),
                DropdownMenuItem(value: "Asin", child: Text("Asin")),
              ],
              onChanged: (value) {
                setState(() {
                  kategoriDipilih = value!;
                });
                ambilMakanan();
              },
            ),

            // TextField pencarian
            TextField(
              decoration: const InputDecoration(
                labelText: "Cari makanan...",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (val) {
                keyword = val;
                ambilMakanan();
              },
            ),

            const SizedBox(height: 20),

            // Hasil
            Expanded(
              child: ListView.builder(
                itemCount: hasil.length,
                itemBuilder: (context, index) {
                  final makanan = hasil[index];
                  return ListTile(
                    leading: Image.asset(makanan['gambar'], width: 50),
                    title: Text(makanan['nama']),
                    subtitle: Text(
                      "Harga: Rp ${makanan['harga']}\nKategori: ${makanan['kategori']}",
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
