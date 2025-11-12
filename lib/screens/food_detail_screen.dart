import 'package:flutter/material.dart';

class FoodDetailScreen extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String price;
  final int rating;
  final String location;
  final String description;

  const FoodDetailScreen({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.rating,
    required this.location,
    required this.description,
  });

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  bool _isFavorited = false;
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageHeader(),
            _buildContent(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 0) {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          }
          // else if (index == 1) { ... ke favorite }
          // else if (index == 2) { ... ke settings }
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

  Widget _buildImageHeader() {
    return Stack(
      children: [
        Container(
          height: 350,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0),
            ),
            image: DecorationImage(
              image: NetworkImage(widget.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),
                gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.4]
                )
            ),
          ),
        ),

        Positioned(
          top: 40,
          left: 10,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.3)
            ),
          ),
        ),

        Positioned(
          bottom: 20,
          right: 20,
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)]
            ),
            child: IconButton(
              icon: Icon(
                _isFavorited ? Icons.favorite : Icons.favorite_border,
                color: Colors.red,
                size: 28,
              ),
              onPressed: () {
                setState(() {
                  _isFavorited = !_isFavorited;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Harga
          Text(
            widget.price,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),

          // Rating
          Row(
            children: [
              ...List.generate(
                widget.rating,
                    (index) => const Icon(Icons.star, color: Colors.amber, size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                '(${widget.rating.toString()})',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(width: 12),

              InkWell(
                onTap: () {
                  _showReviewSheet(context);
                },
                child: Text(
                  'Lihat Review',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Lokasi
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.grey[600], size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.location,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Deskripsi
          const Text(
            'Deskripsi :',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEEE4E4),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Text(
              widget.description,
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // === FUNGSI BOTTOM SHEET (Lihat Review) ===

  void _showReviewSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetContext) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              _buildSheetHeader(sheetContext),
              const SizedBox(height: 16),

              Expanded(
                child: ListView(
                  children: [
                    _buildReviewItem(
                      'Asna',
                      '29 September 2025',
                      'Sangat rekomendasi buat pelajar',
                    ),
                    _buildReviewItem(
                      'Damai',
                      '28 September 2025',
                      'Rasanya enakkk!!!!!!!!',
                    ),
                    _buildReviewItem(
                      'Katherine',
                      '28 September 2025',
                      'Harganya murah, cocok untuk anak kost.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSheetHeader(BuildContext sheetContext) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.close, size: 28),
          onPressed: () {
            Navigator.pop(sheetContext);
          },
        ),
        const Text(
          'Review',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            // 1. Tutup bottom sheet
            Navigator.pop(sheetContext);
            // 2. Buka dialog baru
            _showAddReviewDialog(context);
          },
          child: Text(
            'Tambah Review',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewItem(String name, String date, String comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.5), width: 1.5),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Icon(Icons.person, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    date,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 5),
          Divider(
            color: Colors.grey[300],
            thickness: 1,
          ),
          const SizedBox(height: 5),
          Text(
            comment,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  // === INI FUNGSI DIALOG DENGAN JUDUL MAROON ===
  void _showAddReviewDialog(BuildContext context) {
    final TextEditingController _reviewController = TextEditingController();
    int _rating = 0;

    // State error
    String _reviewHintText = 'Review';
    bool _hasReviewError = false;
    String? _ratingErrorText;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, stateSetter) {

            final Color errorColor = Theme.of(context).colorScheme.error;
            final Color primaryColor = Theme.of(context).primaryColor;
            final Color greyColor = Colors.grey[600]!;

            // Definisikan padding yang sama untuk kedua tombol
            const EdgeInsets buttonPadding = EdgeInsets.symmetric(vertical: 16, horizontal: 24);

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 20.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. Judul
                    Text( // <-- 'const' DIHAPUS
                      'Tambah Review',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor, // <-- WARNA MAROON
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. Konten (Text Field & Rating)
                    TextField(
                      controller: _reviewController,
                      decoration: InputDecoration(
                        hintText: _reviewHintText,
                        hintStyle: TextStyle(
                          color: _hasReviewError ? errorColor : greyColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: _hasReviewError ? errorColor : (Theme.of(context).inputDecorationTheme.enabledBorder?.borderSide.color ?? Colors.grey),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: _hasReviewError ? errorColor : primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    Text(
                      _ratingErrorText ?? 'Rate this food',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _ratingErrorText != null
                            ? errorColor
                            : Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < _rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            stateSetter(() {
                              _rating = index + 1;
                              _ratingErrorText = null;
                            });
                          },
                        );
                      }),
                    ),

                    const SizedBox(height: 16),

                    // 3. Tombol (Actions)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor,
                            side: BorderSide(color: Theme.of(context).primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: buttonPadding, // <-- Padding sama
                          ),
                          child: const Text('Batal'),
                          onPressed: () {
                            Navigator.pop(dialogContext);
                          },
                        ),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: buttonPadding, // <-- Padding sama
                          ),
                          child: const Text('Kirim'),
                          onPressed: () {
                            bool isValid = true;
                            final String reviewText = _reviewController.text;

                            stateSetter(() {
                              if (reviewText.isEmpty) {
                                _reviewHintText = 'Review cannot be empty';
                                _hasReviewError = true;
                                isValid = false;
                              } else {
                                _reviewHintText = 'Review';
                                _hasReviewError = false;
                              }

                              if (_rating == 0) {
                                _ratingErrorText = 'Rating cannot be empty';
                                isValid = false;
                              } else {
                                _ratingErrorText = null;
                              }
                            });

                            if (isValid) {
                              // TODO: Logika simpan
                              Navigator.pop(dialogContext);
                            }
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}