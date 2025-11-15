// lib/screens/home_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usulicius_kelompok_lucky/providers/food_provider.dart';
import 'package:usulicius_kelompok_lucky/screens/category_screen.dart';
import 'package:usulicius_kelompok_lucky/widgets/category_item.dart';
import 'package:usulicius_kelompok_lucky/widgets/custom_search_bar.dart';
import 'package:usulicius_kelompok_lucky/widgets/food_card.dart';
import 'package:usulicius_kelompok_lucky/screens/food_detail_screen.dart';
import 'package:usulicius_kelompok_lucky/screens/favorite_screen.dart';
import 'package:usulicius_kelompok_lucky/screens/settings_screen.dart';

final GlobalKey<_HomeScreenState> homeScreenKey = GlobalKey<_HomeScreenState>();

class HomeScreen extends StatefulWidget {
  HomeScreen() : super(key: homeScreenKey);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomeContent(),
    const FavoriteScreen(),
    const SettingsScreen(),
  ];

  void navigateToPage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        // ... (AppBar tidak berubah)
        backgroundColor: primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 86,
        title: const Text(
          'USULicius',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/images/Logo.png',
              width: 85,
              height: 85,
            ),
          )
        ],
      ),

      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        // ... (BottomNav tidak berubah)
        currentIndex: _currentIndex,
        onTap: (index) {
          navigateToPage(index);
        },
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/food.png',
              width: 24,
              height: 24,
              color: Colors.grey,
            ),
            activeIcon: Image.asset(
              'assets/images/food.png',
              width: 24,
              height: 24,
              color: primaryColor,
            ),
            label: 'Food',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// === HomeContent DI REFAKTOR ===
class HomeContent extends StatefulWidget {
  HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String searchQuery = "";

  // Fungsi helper dari test_makanan_page.dart
  String buildImagePath(String rawImage) {
    if (rawImage.isEmpty) return "";
    // Jika path sudah benar, gunakan. Jika tidak, bangun path-nya.
    return rawImage.startsWith("assets/")
        ? rawImage
        : "assets/images/${rawImage.split('/').last}";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Cari makanan...',
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
            ),
            onChanged: (v) => setState(() => searchQuery = v.toLowerCase()),
          ),
        ),

        _buildCategories(context),

        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('foods').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("Tidak ada makanan"));
              }

              final docs = snapshot.data!.docs;

              final filtered = docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = (data['name'] ?? '').toString().toLowerCase();
                return name.contains(searchQuery);
              }).toList();

              if (filtered.isEmpty) {
                return const Center(child: Text("Makanan tidak ditemukan"));
              }

              return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: filtered.length,
                itemBuilder: (ctx, index) {
                  final doc = filtered[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final foodId = doc.id;

                  // === PERUBAHAN DI SINI ===
                  // Ambil field 'image' (bukan 'imageURL')
                  final String imagePath = buildImagePath(data['image'] ?? '');
                  final String price = (data['price'] ?? 0).toString();
                  final int rating = (data['rating'] ?? 0.0).toInt();

                  return FoodCard(
                    foodId: foodId,
                    imageUrl: imagePath, // <-- Kirim path asset
                    title: data['name'] ?? 'Tanpa Nama',
                    location: data['location'] ?? 'Tanpa Lokasi',
                    rating: rating.toString(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FoodDetailScreen(
                            originIndex: 0,
                            foodId: foodId,
                            imageUrl: imagePath,
                            title: data['name'] ?? 'Tanpa Nama',
                            price: "Rp $price",
                            // rating: rating, // <-- HAPUS BARIS INI
                            location: data['location'] ?? 'Tanpa Lokasi',
                            description: data['description'] ?? 'Tanpa Deskripsi',
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategories(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: CategoryItem(
              label: 'Pedas',
              color: Colors.red,
              imageAsset: 'assets/images/pedas.png',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryScreen(
                      title: 'Makanan Pedas',
                      subtitle:
                      'Bikin nagih, menggugah selera, dan penuh sensasi.',
                      category: "Pedas",
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CategoryItem(
              label: 'Manis',
              color: Colors.orange,
              imageAsset: 'assets/images/Manis.png',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryScreen(
                      title: 'Makanan Manis',
                      subtitle:
                      'Rasa legit, bikin bahagia, dan selalu jadi favorit',
                      category: "Manis",
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CategoryItem(
              label: 'Pilihan Mahasiswa',
              color: Colors.blue,
              imageAsset: 'assets/images/PilihanMahasiswa.png',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryScreen(
                      title: 'Makanan Pilihan',
                      subtitle:
                      'Rasanya pas, mengenyangkan, dan cocok untuk semua selera',
                      category: "Pilihan Mahasiswa",
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}