// lib/screens/home_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:usulicius_kelompok_lucky/screens/category_screen.dart';
import 'package:usulicius_kelompok_lucky/widgets/category_item.dart';
import 'package:usulicius_kelompok_lucky/widgets/food_card.dart';
import 'package:usulicius_kelompok_lucky/screens/food_detail_screen.dart';
import 'package:usulicius_kelompok_lucky/screens/favorite_screen.dart';
import 'package:usulicius_kelompok_lucky/screens/settings_screen.dart';

final GlobalKey<_HomeScreenState> homeScreenKey = GlobalKey<_HomeScreenState>();

// Key Global untuk Konten Home (Food)
final GlobalKey<HomeContentState> homeContentKey = GlobalKey<HomeContentState>();

// === TAMBAHAN BARU: Key Global untuk Favorite Screen ===
final GlobalKey<FavoriteScreenState> favoriteScreenKey = GlobalKey<FavoriteScreenState>();


class HomeScreen extends StatefulWidget {
  HomeScreen() : super(key: homeScreenKey);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeContent(key: homeContentKey),
      // Pasang Key pada FavoriteScreen
      FavoriteScreen(key: favoriteScreenKey),
      const SettingsScreen(),
    ];
  }

  void navigateToPage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
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
        currentIndex: _currentIndex,
        onTap: (index) {
          // === LOGIKA SCROLL TO TOP ===

          // 1. Jika klik Food (index 0) saat di Food
          if (index == 0 && _currentIndex == 0) {
            homeContentKey.currentState?.scrollToTop();
          }
          // 2. Jika klik Favorite (index 1) saat di Favorite
          else if (index == 1 && _currentIndex == 1) {
            favoriteScreenKey.currentState?.scrollToTop();
          }
          // 3. Pindah halaman biasa
          else {
            navigateToPage(index);
          }
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

// === HomeContent (Tidak ada perubahan logika dari yang terakhir disimpan) ===
class HomeContent extends StatefulWidget {
  HomeContent({super.key});

  @override
  State<HomeContent> createState() => HomeContentState();
}

class HomeContentState extends State<HomeContent> {
  String searchQuery = "";
  final ScrollController _scrollController = ScrollController();

  void scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String buildImagePath(String rawImage) {
    if (rawImage.isEmpty) return "";
    return rawImage.startsWith("assets/")
        ? rawImage
        : "assets/images/${rawImage.split('/').last}";
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('foods').snapshots(),
      builder: (context, snapshot) {
        List<DocumentSnapshot> docs = [];
        if (snapshot.hasData) {
          docs = snapshot.data!.docs;
        }

        final filtered = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = (data['name'] ?? '').toString().toLowerCase();
          return name.contains(searchQuery);
        }).toList();

        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.zero,
          itemCount: filtered.length + 2,
          itemBuilder: (ctx, index) {

            if (index == 0) {
              return Padding(
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
              );
            }

            if (index == 1) {
              return _buildCategories(context);
            }

            final foodIndex = index - 2;

            if (filtered.isEmpty) {
              if (foodIndex == 0) {
                return const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Center(child: Text("Makanan tidak ditemukan")),
                );
              } else {
                return const SizedBox();
              }
            }

            final doc = filtered[foodIndex];
            final data = doc.data() as Map<String, dynamic>;
            final foodId = doc.id;

            final String imagePath = buildImagePath(data['image'] ?? '');
            final String price = (data['price'] ?? 0).toString();
            final double rating = (data['averageRating'] ?? 0.0).toDouble();

            return FoodCard(
              foodId: foodId,
              imageUrl: imagePath,
              title: data['name'] ?? 'Tanpa Nama',
              location: data['location'] ?? 'Tanpa Lokasi',
              rating: rating.toStringAsFixed(1),
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
                      subtitle: 'Bikin nagih, menggugah selera, dan penuh sensasi.',
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
                      subtitle: 'Rasa legit, bikin bahagia, dan selalu jadi favorit',
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
                      subtitle: 'Rasanya pas, mengenyangkan, dan cocok untuk semua selera',
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