import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usulicius_kelompok_lucky/models/food.dart';
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
    const HomeContent(),
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
          navigateToPage(index);
        },
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.fastfood),
            label: 'Food',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final foodProvider = Provider.of<FoodProvider>(context);
    final recommendedItems = foodProvider.recommendedItems;

    return ListView(
      children: [
        const CustomSearchBar(),
        _buildCategories(context),

        ...recommendedItems.map((food) {
          return FoodCard(
            imageUrl: food.imageUrl,
            title: food.title,
            location: food.location,
            rating: food.rating.toString(),
            isFavorite: food.isFavorite,
            onFavoritePressed: () {
              foodProvider.toggleFavoriteStatus(food.id);
            },
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FoodDetailScreen(
                    originIndex: 0,
                    foodId: food.id,
                    imageUrl: food.imageUrl,
                    title: food.title,
                    price: food.price,
                    rating: food.rating,
                    location: food.location,
                    description: food.description,
                  ),
                ),
              );
            },
          );
        }).toList(),

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
                    builder: (context) => const CategoryScreen(
                      title: 'Makanan Pedas',
                      subtitle:
                      'Bikin nagih, menggugah selera, dan penuh sensasi.',
                      category: FoodCategory.Pedas,
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
                    builder: (context) => const CategoryScreen(
                      title: 'Makanan Manis',
                      subtitle:
                      'Rasa legit, bikin bahagia, dan selalu jadi favorit',
                      category: FoodCategory.Manis,
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
                    builder: (context) => const CategoryScreen(
                      title: 'Makanan Pilihan',
                      subtitle:
                      'Rasanya pas, mengenyangkan, dan cocok untuk semua selera',
                      category: FoodCategory.PilihanMahasiswa,
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