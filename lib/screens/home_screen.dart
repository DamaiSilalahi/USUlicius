import 'package:flutter/material.dart';
import 'package:usulicius_kelompok_lucky/screens/category_screen.dart';
import 'package:usulicius_kelompok_lucky/widgets/category_item.dart';
import 'package:usulicius_kelompok_lucky/widgets/custom_search_bar.dart';
import 'package:usulicius_kelompok_lucky/widgets/food_card.dart';
import 'package:usulicius_kelompok_lucky/screens/food_detail_screen.dart';

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

          FoodCard(
            imageUrl: 'https://cdn-2.tstatic.net/medan/foto/bank/images/Ayam-geprek-bensu-medan.jpg',
            title: 'Ayam geprek mahasiswa',
            location: 'Berdikari',
            rating: '5',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FoodDetailScreen(
                    imageUrl: 'https://cdn-2.tstatic.net/medan/foto/bank/images/Ayam-geprek-bensu-medan.jpg',
                    title: 'Ayam Geprek Mahasiswa',
                    price: 'Rp. 10.000',
                    rating: 5,
                    location: 'Jl. Pembangunan No.117Padang, BulanKec, Kec. Medan Baru, Kota Medan',
                    description: 'Ayam geprek Mahasiswa disajikan bersama nasi hangat, lengkap dengan tambahan lauk seperti tempe, terong goreng dan segelas teh manis dingin yang menyegarkan. Dengan harga yang sangat terjangkau, Geprek Mahasiswa menawarkan perpaduan rasa yang nikmat, porsi yang mengenyangkan, serta suasana santai yang membuatnya semakin cocok sebagai tempat makan sehari-hari bagi mahasiswa.',
                  ),
                ),
              );
            },
          ),
          FoodCard(
            imageUrl: 'https://picsum.photos/id/45/200',
            title: 'Pancong Lumer USU',
            location: 'Pintu 4, USU',
            rating: '5',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FoodDetailScreen(
                    imageUrl: 'https://picsum.photos/id/45/200',
                    title: 'Pancong Lumer USU',
                    price: 'Rp. 12.000',
                    rating: 5,
                    location: 'Pintu 4, USU',
                    description: 'Deskripsi lengkap untuk Pancong Lumer USU...',
                  ),
                ),
              );
            },
          ),
          FoodCard(
            imageUrl: 'https://picsum.photos/id/21/200',
            title: 'Nasi baby cumi sambal ijo',
            location: 'Jl. Sei Serayu No.97',
            rating: '5',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FoodDetailScreen(
                    imageUrl: 'https://picsum.photos/id/21/200',
                    title: 'Nasi baby cumi sambal ijo',
                    price: 'Rp. 18.000',
                    rating: 5,
                    location: 'Jl. Sei Serayu No.97',
                    description: 'Deskripsi lengkap untuk Nasi baby cumi...',
                  ),
                ),
              );
            },
          ),
          FoodCard(
            imageUrl: 'https://picsum.photos/id/36/200',
            title: 'Ayam geprek',
            location: 'Berdikari',
            rating: '5',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FoodDetailScreen(
                    imageUrl: 'https://cdn-2.tstatic.net/medan/foto/bank/images/Ayam-geprek-bensu-medan.jpg',
                    title: 'Ayam Geprek Mahasiswa',
                    price: 'Rp. 10.000',
                    rating: 5,
                    location: 'Jl. Pembangunan No.117Padang, BulanKec, Kec. Medan Baru, Kota Medan',
                    description: 'Ayam geprek Mahasiswa disajikan bersama nasi hangat...',
                  ),
                ),
              );
            },
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
                  builder: (context) => CategoryScreen(
                    title: 'Makanan Pedas',
                    subtitle:
                    'Bikin nagih, menggugah selera, dan penuh sensasi.',
                    foodCards: [
                      FoodCard(
                        imageUrl: 'https://cdn-2.tstatic.net/medan/foto/bank/images/Ayam-geprek-bensu-medan.jpg',
                        title: 'Ayam geprek mahasiswa',
                        location: 'Berdikari',
                        rating: '5',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => const FoodDetailScreen(
                              imageUrl: 'https://cdn-2.tstatic.net/medan/foto/bank/images/Ayam-geprek-bensu-medan.jpg',
                              title: 'Ayam Geprek Mahasiswa',
                              price: 'Rp. 10.000',
                              rating: 5,
                              location: 'Jl. Pembangunan No.117Padang, BulanKec, Kec. Medan Baru, Kota Medan',
                              description: 'Ayam geprek Mahasiswa disajikan bersama nasi hangat...',
                            ),
                          ));
                        },
                      ),
                      FoodCard(
                        imageUrl: 'https://picsum.photos/id/102/200',
                        title: 'Mie bakso mercon',
                        location: 'Jalan Pembangunan',
                        rating: '5',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => const FoodDetailScreen(
                              imageUrl: 'https://picsum.photos/id/102/200',
                              title: 'Mie bakso mercon',
                              price: 'Rp. 15.000',
                              rating: 5,
                              location: 'Jalan Pembangunan',
                              description: 'Deskripsi lengkap untuk Mie Bakso Mercon...',
                            ),
                          ));
                        },
                      ),
                      FoodCard( // 'const' dihapus
                        imageUrl: 'https://picsum.photos/id/21/200',
                        title: 'Nasi baby cumi sambal ijo',
                        location: 'Jl. Sei Serayu No.97',
                        rating: '5',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => const FoodDetailScreen(
                              imageUrl: 'https://picsum.photos/id/21/200',
                              title: 'Nasi baby cumi sambal ijo',
                              price: 'Rp. 18.000',
                              rating: 5,
                              location: 'Jl. Sei Serayu No.97',
                              description: 'Deskripsi lengkap untuk Nasi baby cumi...',
                            ),
                          ));
                        },
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
                  builder: (context) => CategoryScreen(
                    title: 'Makanan Manis',
                    subtitle:
                    'Rasa legit, bikin bahagia, dan selalu jadi favorit',
                    foodCards: [
                      FoodCard(
                        imageUrl: 'https://picsum.photos/id/45/200',
                        title: 'Pancong Lumer USU',
                        location: 'Pintu 4, USU',
                        rating: '5',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => const FoodDetailScreen(
                              imageUrl: 'https://picsum.photos/id/45/200',
                              title: 'Pancong Lumer USU',
                              price: 'Rp. 12.000',
                              rating: 5,
                              location: 'Pintu 4, USU',
                              description: 'Deskripsi lengkap untuk Pancong Lumer USU...',
                            ),
                          ));
                        },
                      ),
                      FoodCard(
                        imageUrl: 'https://picsum.photos/id/106/200',
                        title: 'Pancake Durian',
                        location: 'Dr. mansyur',
                        rating: '5',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => const FoodDetailScreen(
                              imageUrl: 'https://picsum.photos/id/106/200',
                              title: 'Pancake Durian',
                              price: 'Rp. 15.000',
                              rating: 5,
                              location: 'Dr. mansyur',
                              description: 'Deskripsi lengkap untuk Pancake Durian...',
                            ),
                          ));
                        },
                      ),
                      FoodCard(
                        imageUrl: 'https://picsum.photos/id/107/200',
                        title: 'Napoleon Cake',
                        location: 'Jl. Sei Serayu No.97',
                        rating: '5',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => const FoodDetailScreen(
                              imageUrl: 'https://picsum.photos/id/107/200',
                              title: 'Napoleon Cake',
                              price: 'Rp. 20.000', // TODO: Ganti harga
                              rating: 5,
                              location: 'Jl. Sei Serayu No.97',
                              description: 'Deskripsi lengkap untuk Napoleon Cake...',
                            ),
                          ));
                        },
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
                  builder: (context) => CategoryScreen(
                    title: 'Makanan Pilihan',
                    subtitle:
                    'Rasanya pas, mengenyangkan, dan cocok untuk semua selera',
                    foodCards: [
                      FoodCard(
                        imageUrl: 'https://cdn-2.tstatic.net/medan/foto/bank/images/Ayam-geprek-bensu-medan.jpg',
                        title: 'Ayam geprek mahasiswa',
                        location: 'Berdikari',
                        rating: '5',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => const FoodDetailScreen(
                              imageUrl: 'https://cdn-2.tstatic.net/medan/foto/bank/images/Ayam-geprek-bensu-medan.jpg',
                              title: 'Ayam Geprek Mahasiswa',
                              price: 'Rp. 10.000',
                              rating: 5,
                              location: 'Jl. Pembangunan No.117Padang, BulanKec, Kec. Medan Baru, Kota Medan',
                              description: 'Ayam geprek Mahasiswa disajikan bersama nasi hangat...',
                            ),
                          ));
                        },
                      ),
                      FoodCard(
                        imageUrl: 'https://picsum.photos/id/45/200',
                        title: 'Pancong Lumer USU',
                        location: 'Pintu 4, USU',
                        rating: '5',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => const FoodDetailScreen(
                              imageUrl: 'https://picsum.photos/id/45/200',
                              title: 'Pancong Lumer USU',
                              price: 'Rp. 12.000',
                              rating: 5,
                              location: 'Pintu 4, USU',
                              description: 'Deskripsi lengkap untuk Pancong Lumer USU...',
                            ),
                          ));
                        },
                      ),
                      FoodCard(
                        imageUrl: 'https://picsum.photos/id/21/200',
                        title: 'Nasi baby cumi sambal ijo',
                        location: 'Jl. Sei Serayu No.97',
                        rating: '5',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => const FoodDetailScreen(
                              imageUrl: 'https://picsum.photos/id/21/200',
                              title: 'Nasi baby cumi sambal ijo',
                              price: 'Rp. 18.000',
                              rating: 5,
                              location: 'Jl. Sei Serayu No.97',
                              description: 'Deskripsi lengkap untuk Nasi baby cumi...',
                            ),
                          ));
                        },
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