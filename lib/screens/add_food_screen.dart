import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  File? _selectedImage;
  bool _isImageMissing = false;
  bool _isLoading = false;

  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxWidth: 800,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _isImageMissing = false;
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  // === FUNGSI RESET FORM ===
  void _resetForm() {
    FocusScope.of(context).unfocus(); // Tutup keyboard
    _formKey.currentState?.reset();   // Reset validator

    setState(() {
      _autovalidateMode = AutovalidateMode.disabled;
      _selectedImage = null;
      _isImageMissing = false;
      _isLoading = false;

      // Bersihkan teks
      _nameController.text = "";
      _locationController.text = "";
      _priceController.text = "";
      _descriptionController.text = "";
    });
  }

  // Fungsi Submit Form
  void _submitForm() async {
    setState(() {
      _autovalidateMode = AutovalidateMode.onUserInteraction;
      _isImageMissing = _selectedImage == null;
    });

    if (!_formKey.currentState!.validate() || _isImageMissing) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Upload Gambar
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('food_images')
          .child(fileName);

      await storageRef.putFile(_selectedImage!);
      final String imageUrl = await storageRef.getDownloadURL();

      // 2. Simpan ke Firestore
      await FirebaseFirestore.instance.collection('food_requests').add({
        'name': _nameController.text.trim(),
        'location': _locationController.text.trim(),
        'price': int.parse(_priceController.text.replaceAll(RegExp(r'[^0-9]'), '')),
        'description': _descriptionController.text.trim(),
        'imageUrl': imageUrl,
        'rating': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
        'uploadedBy': FirebaseAuth.instance.currentUser?.uid ?? 'anonymous',
      });

      // 3. Tampilkan pesan sukses
      if (mounted) {
        _showSuccessDialog();
      }

    } catch (e) {
      print("Error uploading food: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mengirim: ${e.toString()}"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text("Berhasil Dikirim"),
            ],
          ),
          content: const Text(
            "Rekomendasi Anda telah masuk ke sistem kami dan sedang menunggu persetujuan Developer sebelum tampil di menu utama.",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Future.delayed(const Duration(milliseconds: 100), () {
                  _resetForm();
                });
              },
              child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
          child: Form(
            key: _formKey,
            autovalidateMode: _autovalidateMode,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // === JUDUL BERWARNA HITAM ===
                const Text(
                  "Add Recommendation",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // <-- Sudah diubah jadi Hitam
                  ),
                ),
                const SizedBox(height: 30),
                // ============================

                _buildImageUploadCard(),
                if (_isImageMissing)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0, left: 12.0),
                    child: Text('Wajib upload foto makanan', style: TextStyle(color: Colors.red[700], fontSize: 12)),
                  ),
                const SizedBox(height: 20),

                _buildTextFormField(
                    controller: _nameController,
                    label: 'Nama Makanan',
                    hint: 'Nasi Goreng Spesial',
                    errorText: 'Nama makanan wajib diisi'
                ),
                const SizedBox(height: 16),

                _buildTextFormField(
                    controller: _locationController,
                    label: 'Lokasi',
                    hint: 'Kantin Teknik',
                    errorText: 'Lokasi wajib diisi',
                    prefixIcon: Icons.location_on_outlined
                ),
                const SizedBox(height: 16),

                _buildTextFormField(
                    controller: _priceController,
                    label: 'Harga',
                    hint: '15000',
                    errorText: 'Harga wajib diisi',
                    prefixIcon: Icons.attach_money,
                    inputType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly]
                ),
                const SizedBox(height: 16),

                _buildTextFormField(
                    controller: _descriptionController,
                    label: 'Deskripsi',
                    hint: 'Ceritakan rasanya...',
                    errorText: 'Deskripsi wajib diisi',
                    maxLines: 5
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Kirim Rekomendasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadCard() {
    return InkWell(
      onTap: _pickImage,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _isImageMissing ? Colors.red : Colors.black54, width: _isImageMissing ? 2.0 : 1.0),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: _selectedImage != null
              ? Image.file(_selectedImage!, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.upload_file, size: 50, color: _isImageMissing ? Colors.red : Colors.grey[400]),
              const SizedBox(height: 10),
              Text('Ketuk untuk upload foto', style: TextStyle(color: _isImageMissing ? Colors.red : Colors.grey[600], fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String errorText,
    IconData? prefixIcon,
    int maxLines = 1,
    TextInputType inputType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: inputType,
          inputFormatters: inputFormatters,
          validator: (value) => (value == null || value.trim().isEmpty) ? errorText : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.grey) : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black54, width: 1.0)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black, width: 2.0)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 2.0)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 2.5)),
          ),
        ),
      ],
    );
  }
}