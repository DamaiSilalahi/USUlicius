// lib/screens/home_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:usulicius_kelompok_lucky/screens/add_food_screen.dart';
import 'package:usulicius_kelompok_lucky/screens/category_screen.dart';
import 'package:usulicius_kelompok_lucky/widgets/category_item.dart';
import 'package:usulicius_kelompok_lucky/widgets/food_card.dart';
import 'package:usulicius_kelompok_lucky/screens/food_detail_screen.dart';
import 'package:usulicius_kelompok_lucky/screens/favorite_screen.dart';
import 'package:usulicius_kelompok_lucky/screens/settings_screen.dart';

final GlobalKey<_HomeScreenState> homeScreenKey = GlobalKey<_HomeScreenState>();
final GlobalKey<HomeContentState> homeContentKey = GlobalKey<HomeContentState>();
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
      const AddFoodScreen(),
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
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 0 && _currentIndex == 0) {
            homeContentKey.currentState?.scrollToTop();
          }
          else if (index == 2 && _currentIndex == 2) {
            favoriteScreenKey.currentState?.scrollToTop();
          }
          else {
            navigateToPage(index);
          }
        },
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/food.png',
              width: 24,
              height: 24,
              color: _currentIndex == 0 ? primaryColor : Colors.grey,
            ),
            label: 'Food',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Add',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

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
    if (rawImage.startsWith('http')) {
      return rawImage;
    }

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

            final String imagePath = buildImagePath(data['imageUrl'] ?? data['image'] ?? '');

            final String price = (data['price'] ?? 0).toString();
            final double rating = (data['rating'] ?? data['averageRating'] ?? 0.0).toDouble();

            return FoodCard(
              foodId: foodId,
              imageUrl: imagePath,
              title: data['name'] ?? 'Tanpa Nama',
              location: data['location'] ?? 'Tanpa Lokasi',
              rating: rating.toStringAsFixed(1),
              onTap: () {
                // === NAVIGASI FOOD CARD (SUDAH BENAR) ===
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => FoodDetailScreen(
                      originIndex: 0,
                      foodId: foodId,
                      imageUrl: imagePath,
                      title: data['name'] ?? 'Tanpa Nama',
                      price: "Rp $price",
                      location: data['location'] ?? 'Tanpa Lokasi',
                      description: data['description'] ?? 'Tanpa Deskripsi',
                    ),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
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
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const CategoryScreen(
                      title: 'Makanan Pedas',
                      subtitle: 'Bikin nagih, menggugah selera, dan penuh sensasi.',
                      category: "Pedas",
                    ),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
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
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const CategoryScreen(
                      title: 'Makanan Manis',
                      subtitle: 'Rasa legit, bikin bahagia, dan selalu jadi favorit',
                      category: "Manis",
                    ),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CategoryItem(
              label: 'Pilihan Mhs',
              color: Colors.blue,
              imageAsset: 'assets/images/PilihanMahasiswa.png',
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const CategoryScreen(
                      title: 'Makanan Pilihan',
                      subtitle: 'Rasanya pas, mengenyangkan, dan cocok untuk semua selera',
                      category: "Pilihan Mahasiswa",
                    ),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
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