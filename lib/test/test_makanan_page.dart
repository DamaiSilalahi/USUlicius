import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TestMakananPage extends StatefulWidget {
  const TestMakananPage({super.key});

  @override
  State<TestMakananPage> createState() => _TestMakananPageState();
}

class _TestMakananPageState extends State<TestMakananPage> {
  String selectedCategory = "Semua";
  String searchQuery = "";
  Set<String> likedFoods = {};

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('favorites')
        .where('userID', isEqualTo: 'dummy_user_001')
        .get();

    setState(() {
      likedFoods = snapshot.docs
          .map((doc) => doc['foodID'] as String)
          .toSet();
    });
  }

  Future<void> addFavorite(String foodID) async {
    await FirebaseFirestore.instance.collection('favorites').add({
      'foodID': foodID,
      'userID': 'dummy_user_001',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFavorite(String foodID) async {
    final query = await FirebaseFirestore.instance
        .collection('favorites')
        .where('foodID', isEqualTo: foodID)
        .where('userID', isEqualTo: 'dummy_user_001')
        .get();

    for (var doc in query.docs) {
      await doc.reference.delete();
    }
  }

  // ---------------------------------------------------------
  // 🔥 FIREBASE RATING FUNCTION
  // ---------------------------------------------------------
Future<void> submitRating({
  required String foodID,
  required int rating,
}) async {
  final userID = "dummy_user_001";

  await FirebaseFirestore.instance.collection("reviews").add({
    "foodID": foodID,
    "userID": userID,
    "rating": rating,
    "comment": "",
    "date": FieldValue.serverTimestamp(),
  });

  final foodRef =
      FirebaseFirestore.instance.collection("foods").doc(foodID);

  await FirebaseFirestore.instance.runTransaction((transaction) async {
    final snapshot = await transaction.get(foodRef);

    final rawCount = snapshot.data()?["ratingsCount"];
    final rawSum = snapshot.data()?["ratingsSum"];

    final currentCount = rawCount is num ? rawCount : 0;
    final currentSum = rawSum is num ? rawSum : 0;

    final newCount = currentCount + 1;
    final newSum = currentSum + rating;
    final newAverage = newSum / newCount;

    transaction.update(foodRef, {
      "ratingsCount": newCount,
      "ratingsSum": newSum,
      "averageRating": newAverage,
    });
  });
}

  // ---------------------------------------------------------
  // ⭐ FIXED: POPUP RATING — TIDAK ADA DUPLIKAT
  // ---------------------------------------------------------
  void showRatingDialog(String foodID) {
    int selectedRating = 5;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Beri Rating"),
              content: DropdownButton<int>(
                value: selectedRating,
                items: List.generate(
                  5,
                  (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text("${i + 1} Bintang"),
                  ),
                ),
                onChanged: (v) {
                  setStateDialog(() {
                    selectedRating = v!;
                  });
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await submitRating(
                      foodID: foodID,
                      rating: selectedRating,
                    );
                  },
                  child: const Text("Kirim"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------
  // UI
  // ---------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Makanan')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text("Kategori:  "),
                DropdownButton<String>(
                  value: selectedCategory,
                  items: const [
                    DropdownMenuItem(value: "Semua", child: Text("Semua")),
                    DropdownMenuItem(value: "Pedas", child: Text("Pedas")),
                    DropdownMenuItem(value: "Manis", child: Text("Manis")),
                    DropdownMenuItem(
                        value: "Pilihan Manusia", child: Text("Pilihan Manusia")),
                  ],
                  onChanged: (v) => setState(() => selectedCategory = v!),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Cari makanan...",
              ),
              onChanged: (v) => setState(() => searchQuery = v.toLowerCase()),
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: StreamBuilder(
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
                  final name = doc['name'].toString().toLowerCase();
                  final category = doc['category'];
                  final okSearch = name.contains(searchQuery);
                  final okCat =
                      selectedCategory == "Semua" || category == selectedCategory;
                  return okSearch && okCat;
                }).toList();

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final doc = filtered[i];
                    final id = doc.id;

                    final rawImage = doc['image'];
                    final imagePath = rawImage.startsWith("assets/")
                        ? rawImage
                        : "assets/images/${rawImage.split('/').last}";

                    return ListTile(
                      leading: Image.asset(
                        imagePath,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) =>
                            const Icon(Icons.broken_image, size: 50),
                      ),

                      title: Text(
                        doc['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Deskripsi: ${doc['description']}"),
                          Text("Lokasi: ${doc['location']}"),
                          Text("Harga: Rp ${doc['price']}"),
                          Text(
                              "Rating: ${(doc['averageRating'] ?? 0).toDouble().toStringAsFixed(1)} ⭐"),
                        ],
                      ),

                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              likedFoods.contains(id)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: likedFoods.contains(id)
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                            onPressed: () async {
                              final alreadyLiked = likedFoods.contains(id);

                              setState(() {
                                if (alreadyLiked) {
                                  likedFoods.remove(id);
                                } else {
                                  likedFoods.add(id);
                                }
                              });

                              if (!alreadyLiked) {
                                await addFavorite(id);
                              } else {
                                await removeFavorite(id);
                              }
                            },
                          ),

                          IconButton(
                            icon: const Icon(Icons.star_border),
                            onPressed: () => showRatingDialog(id),
                          ),
                        ],
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
