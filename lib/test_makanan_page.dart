// INI CONTOH KALIAN FRONT END AMBIL DATA DARI FIREBASE YA... 

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TestMakananPage extends StatelessWidget {
  const TestMakananPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Makanan')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('makanan').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final data = snapshot.data!.docs;

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final makanan = data[index];
              return ListTile(
                leading: Image.asset(makanan['gambar']),
                title: Text(makanan['nama']),
                subtitle: Text(makanan['deskripsi']),
              );
            },
          );
        },
      ),
    );
  }
}
