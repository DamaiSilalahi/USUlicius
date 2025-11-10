import 'package:flutter/material.dart';
import 'package:usulicius_kelompok_lucky/screens/category_screen.dart';
import 'package:usulicius_kelompok_lucky/widgets/category_item.dart';
import 'package:usulicius_kelompok_lucky/widgets/custom_search_bar.dart';
import 'package:usulicius_kelompok_lucky/widgets/food_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

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
      body: ListView(
        children: [
          const CustomSearchBar(),
          _buildCategories(context),
          const FoodCard(
            imageUrl: 'https://picsum.photos/id/32/200',
            title: 'Ayam geprek mahasiswa',
            location: 'Berdikari',
            rating: '5',
          ),
          const FoodCard(
            imageUrl: 'https://picsum.photos/id/45/200',
            title: 'Pancong Lumer USU',
            location: 'Pintu 4, USU',
            rating: '5',
          ),
          const FoodCard(
            imageUrl: 'https://picsum.photos/id/21/200',
            title: 'Nasi baby cumi sambal ijo',
            location: 'Jl. Sei Serayu No.97',
            rating: '5',
          ),
          const FoodCard(
            imageUrl: 'https://picsum.photos/id/36/200',
            title: 'Ayam geprek',
            location: 'Berdikari',
            rating: '5',
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
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
  Widget _buildCategories(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CategoryItem(
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
                    foodCards: [
                      FoodCard(
                        imageUrl: 'https://picsum.photos/id/32/200',
                        title: 'Ayam geprek mahasiswa',
                        location: 'Berdikari',
                        rating: '5',
                      ),
                      FoodCard(
                        imageUrl: 'https://picsum.photos/id/102/200',
                        title: 'Mie bakso mercon',
                        location: 'Jalan Pembangunan',
                        rating: '5',
                      ),
                      FoodCard(
                        imageUrl: 'https://picsum.photos/id/21/200',
                        title: 'Nasi baby cumi sambal ijo',
                        location: 'Jl. Sei Serayu No.97',
                        rating: '5',
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          CategoryItem(
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
                    foodCards: [
                      FoodCard(
                        imageUrl: 'https://picsum.photos/id/45/200',
                        title: 'Pancong Lumer USU',
                        location: 'Pintu 4, USU',
                        rating: '5',
                      ),
                      FoodCard(
                        imageUrl: 'https://picsum.photos/id/106/200',
                        title: 'Pancake Durian',
                        location: 'Dr. mansyur',
                        rating: '5',
                      ),
                      FoodCard(
                        imageUrl: 'https://picsum.photos/id/107/200',
                        title: 'Napoleon Cake',
                        location: 'Jl. Sei Serayu No.97',
                        rating: '5',
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          CategoryItem(
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
                    foodCards: [
                      FoodCard(
                        imageUrl: 'https://picsum.photos/id/32/200',
                        title: 'Ayam geprek mahasiswa',
                        location: 'Berdikari',
                        rating: '5',
                      ),
                      FoodCard(
                        imageUrl: 'https://picsum.photos/id/45/200',
                        title: 'Pancong Lumer USU',
                        location: 'Pintu 4, USU',
                        rating: '5',
                      ),
                      FoodCard(
                        imageUrl: 'https://picsum.photos/id/21/200',
                        title: 'Nasi baby cumi sambal ijo',
                        location: 'Jl. Sei Serayu No.97',
                        rating: '5',
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}