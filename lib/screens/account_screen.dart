import 'package:flutter/material.dart';
import 'package:usulicius_kelompok_lucky/widgets/account_field.dart';
import 'package:usulicius_kelompok_lucky/screens/change_email_screen.dart';
import 'package:usulicius_kelompok_lucky/widgets/delete_account.dart';
import 'package:usulicius_kelompok_lucky/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';

class AccountScreen extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final String initialPassword;

  const AccountScreen({
    super.key,
    required this.initialName,
    required this.initialEmail,
    required this.initialPassword,
  });

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  bool _isLoading = false;
  late String _currentName;
  late String _currentEmail;
  String? _currentPhotoUrl;

  File? _pickedImageFile;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();

  bool _showPasswordFields = false;
  String? _successMessage;
  String? _nameError;
  String? _oldPasswordError;
  String? _newPasswordError;
  String? _confirmNewPasswordError;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _currentName = widget.initialName;
    _currentEmail = widget.initialEmail;
    _nameController.text = _currentName;
    _currentPhotoUrl = _user?.photoURL;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxWidth: 600,
      );

      if (pickedFile != null) {
        setState(() {
          _pickedImageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil gambar: $e')),
      );
    }
  }

  void _resetPasswordFields() {
    _oldPasswordController.clear();
    _newPasswordController.clear();
    _confirmNewPasswordController.clear();
    setState(() {
      _oldPasswordError = null;
      _newPasswordError = null;
      _confirmNewPasswordError = null;
    });
  }


  void _saveChanges() async {
    setState(() {
      _nameError = null;
      _successMessage = null;
      _oldPasswordError = null;
      _newPasswordError = null;
      _confirmNewPasswordError = null;
      _isLoading = true;
    });

    final newName = _nameController.text.trim();
    bool isNameChanged = newName != _currentName;
    bool isPhotoChanged = _pickedImageFile != null;
    bool isPasswordChanged = _showPasswordFields;
    bool validationPassed = true;
    String successMessage = '';

    if (newName.isEmpty) {
      setState(() => _nameError = 'Name cannot be empty');
      validationPassed = false;
    }

    if (isPasswordChanged) {
      final oldPassword = _oldPasswordController.text;
      final newPassword = _newPasswordController.text;
      final confirmPassword = _confirmNewPasswordController.text;

      if (oldPassword.isEmpty) {
        setState(() => _oldPasswordError = 'Old Password cannot be empty');
        validationPassed = false;
      }
      if (newPassword.isEmpty) {
        setState(() => _newPasswordError = 'New Password cannot be empty');
        validationPassed = false;
      }
      if (confirmPassword.isEmpty) {
        setState(() => _confirmNewPasswordError = 'Confirm cannot be empty');
        validationPassed = false;
      }

      if (validationPassed) {
        if (newPassword.length < 6) {
          setState(() => _newPasswordError = 'Password min 6 chars');
          validationPassed = false;
        }
        if (newPassword != confirmPassword) {
          setState(() => _confirmNewPasswordError = 'Passwords do not match');
          validationPassed = false;
        }

        if (newPassword == oldPassword) {
          setState(() => _newPasswordError = 'New password cannot be the same as old password');
          validationPassed = false;
        }
      }
    }

    if (!validationPassed) {
      setState(() => _isLoading = false);
      return;
    }


    if (!isNameChanged && !isPasswordChanged && !isPhotoChanged) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No changes detected.')),
      );
      return;
    }

    try {
      if (_user == null) throw Exception("No user logged in.");

      if (isPasswordChanged) {
        final credential = EmailAuthProvider.credential(
          email: _user.email!,
          password: _oldPasswordController.text,
        );

        await _user.reauthenticateWithCredential(credential);
        await _user.updatePassword(_newPasswordController.text);

        setState(() {
          _showPasswordFields = false;
          _resetPasswordFields();
        });

        successMessage += 'Password changed. ';
      }

      if (isPhotoChanged) {
        final storageRef = _storage
            .ref()
            .child('user_profile_images')
            .child('${_user.uid}.jpg');

        await storageRef.putFile(_pickedImageFile!);
        final imageUrl = await storageRef.getDownloadURL();

        await _user.updatePhotoURL(imageUrl);
        await _firestore.collection('users').doc(_user.uid).update({
          'photoURL': imageUrl
        });

        setState(() => _currentPhotoUrl = imageUrl);
        successMessage += 'Photo updated. ';
      }

      if (isNameChanged) {
        await _user.updateDisplayName(newName);
        await _firestore.collection('users').doc(_user.uid).update({
          'username': newName
        });

        setState(() => _currentName = newName);
        successMessage += 'Name updated. ';
      }

      setState(() {
        _isLoading = false;
        _successMessage = successMessage.trim();
        _pickedImageFile = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(_successMessage!),
        ),
      );
    } on FirebaseAuthException catch (e) {
      // ---------------------------------------------------------
      // BAGIAN PENTING: HANDLING ERROR
      // ---------------------------------------------------------
      
      // Cek apakah error karena password salah (wrong-password) 
      // ATAU kredensial tidak valid (invalid-credential)
      if ((e.code == 'wrong-password' || e.code == 'invalid-credential') && isPasswordChanged) {
        setState(() {
          // Set pesan error langsung di bawah field Old Password
          _oldPasswordError = 'your password is incorrect'; 
          _isLoading = false;
        });
        // STOP eksekusi di sini agar SnackBar TIDAK muncul
        return; 
      } 
      
      // Handle password lemah
      else if (e.code == 'weak-password') {
        setState(() {
          _newPasswordError = 'Password too weak.';
          _isLoading = false;
        });
        return;
      }
      
      // Handle session expired
      else if (e.code == 'requires-recent-login') {
         setState(() {
          _oldPasswordError = 'Session expired. Please relogin.';
          _isLoading = false;
        });
        return;
      }

      // Jika errornya BUKAN karena password/validasi field, 
      // baru tampilkan SnackBar (misal error koneksi internet)
      String errorMessage = e.message ?? 'An unknown error occurred.';
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text('Error: $errorMessage')),
      );

    } catch (e) {
      // Error umum non-firebase
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text('Error: $e')),
      );
    }
  }

  Widget _buildSmartAvatar() {
    ImageProvider? backgroundImage;

    if (_pickedImageFile != null) {
      backgroundImage = FileImage(_pickedImageFile!);
    } else if (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty) {
      backgroundImage = NetworkImage(_currentPhotoUrl!);
    }

    return CircleAvatar(
      radius: 60,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: backgroundImage,
      child: backgroundImage == null
          ? Icon(Icons.person, size: 70, color: Colors.grey.shade400)
          : null,
    );
  }

  Future<void> _showDeleteAccountDialog() async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => const DeleteAccount(),
    );

    if (shouldDelete == true) {
      try {
        setState(() => _isLoading = true);

        try {
          await _storage
              .ref()
              .child('user_profile_images')
              .child('${_user!.uid}.jpg')
              .delete();
        } catch (_) {}

        await _firestore.collection('users').doc(_user!.uid).delete();

        await _user.delete();

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const LoginScreen(
                initialMessage: "Account deleted successfully.",
              ),
            ),
                (Route<dynamic> route) => false,
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (e is FirebaseAuthException && e.code == 'requires-recent-login') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please Log Out and Log In again to delete account.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: ${e.toString()}')),
          );
        }
      }
    }
  }

  void _openChangeEmailDialog() async {
    final newEmail = await showDialog<String>(
      context: context,
      builder: (context) => ChangeEmailScreen(currentEmail: _currentEmail),
    );

    if (newEmail != null && newEmail.isNotEmpty && mounted) {
      try {
        setState(() => _isLoading = true);
        await FirebaseFunctions.instance
            .httpsCallable('updateUserEmail')
            .call({'newEmail': newEmail});

        await _firestore.collection('users').doc(_user!.uid).update({
          'email': newEmail
        });

        setState(() {
          _currentEmail = newEmail;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Email berhasil diubah secara otomatis!'),
          ),
        );
      } catch (e) {
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    const Color maroonColor = Color(0xFF8B0000);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Your account', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildSmartAvatar(),
              const SizedBox(height: 15),
              SizedBox(
                width: 160,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: maroonColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Upload a picture', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 30),
              AccountField(
                label: 'Your Name',
                initialValue: _nameController.text,
                controller: _nameController,
                isEditable: true,
                errorText: _nameError,
              ),
              AccountField(
                label: 'Password',
                initialValue: '••••••••••',
                isSensitive: true,
                isEditable: false,
                onEditPressed: () {
                  setState(() {
                    _showPasswordFields = !_showPasswordFields;
                    if (!_showPasswordFields) {
                      _resetPasswordFields();
                    }
                  });
                },
              ),
              if (_showPasswordFields)
                Column(
                  children: [
                    AccountField(
                      label: 'Old Password',
                      initialValue: '',
                      isSensitive: true,
                      controller: _oldPasswordController,
                      isEditable: true,
                      errorText: _oldPasswordError,
                    ),
                    AccountField(
                      label: 'New Password',
                      initialValue: '',
                      isSensitive: true,
                      controller: _newPasswordController,
                      isEditable: true,
                      errorText: _newPasswordError,
                    ),
                    AccountField(
                      label: 'Confirm New Password',
                      initialValue: '',
                      isSensitive: true,
                      controller: _confirmNewPasswordController,
                      isEditable: true,
                      errorText: _confirmNewPasswordError,
                    ),
                  ],
                ),
              AccountField(
                label: 'Email Address',
                initialValue: _currentEmail,
                isEditable: false,
                onEditPressed: _isLoading || _showPasswordFields ? null : _openChangeEmailDialog,
              ),
              const SizedBox(height: 10),
              Align(
  alignment: Alignment.centerLeft,
  child: InkWell(
    onTap: _isLoading ? null : _showDeleteAccountDialog, // Memanggil fungsi
    borderRadius: BorderRadius.circular(8.0),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delete Your Account',
            style: TextStyle(
              color: Colors.red.shade700, 
              fontWeight: FontWeight.bold, 
              fontSize: 16
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Deleting your account will remove all your personal data and preferences. This action cannot be reversed.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    ),
  ),
),
// --- AKHIR BAGIAN DELETE ACCOUNT ---

const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.grey.shade600,
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: maroonColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                          : const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              
            ],
          ),
        ),
      ),
    );
  }
}