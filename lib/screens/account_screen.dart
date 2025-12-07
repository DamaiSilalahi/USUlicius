import 'package:flutter/material.dart';
import 'package:usulicius_kelompok_lucky/widgets/account_field.dart';
import 'package:usulicius_kelompok_lucky/widgets/photo_profile.dart';
import 'package:usulicius_kelompok_lucky/widgets/delete_account.dart';
import 'package:usulicius_kelompok_lucky/screens/login_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordChanging = false;
  String? _successMessage;
  String? _nameError;
  String? _newPasswordError;
  String? _confirmNewPasswordError;

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

  void _saveChanges() async {
    setState(() {
      _nameError = null;
      _successMessage = null;
      _newPasswordError = null;
      _confirmNewPasswordError = null;
      _isLoading = true;
    });

    final newName = _nameController.text.trim();
    bool isNameChanged = newName != _currentName;
    bool isPhotoChanged = _pickedImageFile != null;
    bool validationPassed = true;
    String successMessage = '';

    // 1. VALIDASI
    if (newName.isEmpty) {
      setState(() => _nameError = 'Name cannot be empty');
      validationPassed = false;
    }

    if (_isPasswordChanging) {
      final newPassword = _newPasswordController.text;
      final confirmPassword = _confirmNewPasswordController.text;

      if (newPassword.isEmpty) {
        setState(() => _newPasswordError = 'New Password cannot be empty');
        validationPassed = false;
      }
      if (confirmPassword.isEmpty) {
        setState(() => _confirmNewPasswordError = 'Confirm cannot be empty');
        validationPassed = false;
      }
      if (validationPassed && newPassword.length < 6) {
        setState(() => _newPasswordError = 'Password min 6 chars');
        validationPassed = false;
      }
      if (validationPassed && newPassword != confirmPassword) {
        setState(() => _confirmNewPasswordError = 'Passwords do not match');
        validationPassed = false;
      }
    }

    if (!validationPassed) {
      setState(() => _isLoading = false);
      return;
    }

    if (!isNameChanged && !_isPasswordChanging && !isPhotoChanged) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No changes detected.')));
      return;
    }

    try {
      if (_user == null) throw Exception("No user logged in.");

      if (isPhotoChanged) {
        final storageRef = _storage
            .ref()
            .child('user_profile_images')
            .child('${_user!.uid}.jpg');

        await storageRef.putFile(_pickedImageFile!);

        final imageUrl = await storageRef.getDownloadURL();

        await _user!.updatePhotoURL(imageUrl);
        await _firestore.collection('users').doc(_user!.uid).update({
          'photoURL': imageUrl
        });

        successMessage += 'Photo updated. ';
      }

      if (isNameChanged) {
        await _user!.updateDisplayName(newName);
        await _firestore.collection('users').doc(_user!.uid).update({
          'username': newName
        });
        setState(() => _currentName = newName);
        successMessage += 'Name updated. ';
      }

      if (_isPasswordChanging) {
        await _user!.updatePassword(_newPasswordController.text);
        setState(() {
          _isPasswordChanging = false;
          _newPasswordController.clear();
          _confirmNewPasswordController.clear();
        });
        successMessage += 'Password changed. ';
      }

      setState(() {
        _isLoading = false;
        _successMessage = successMessage.trim();
        _pickedImageFile = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.green, content: Text(_successMessage!)),
      );

      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      String msg = e.message ?? 'Auth Error';
      if (e.code == 'requires-recent-login') msg = 'Please relogin to change password.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text(msg)));
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text('Error: $e')));
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
          ? const Icon(Icons.person, size: 70, color: Colors.grey)
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
          await _storage.ref().child('user_profile_images').child('${_user!.uid}.jpg').delete();
        } catch (_) {
        }

        await _firestore.collection('users').doc(_user!.uid).delete();
        await _user!.delete();

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const LoginScreen(
                initialMessage: "Account deleted.",
              ),
            ),
                (Route<dynamic> route) => false,
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: ${e.toString()}. Try relogin.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your account'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildSmartAvatar(),

              const SizedBox(height: 10),

              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B0000),
                  ),
                  child: const Text('Upload a picture'),
                ),
              ),

              const SizedBox(height: 30),

              AccountField(
                label: 'Your Name',
                initialValue: _currentName,
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
                    _isPasswordChanging = !_isPasswordChanging;
                  });
                },
              ),

              if (_isPasswordChanging)
                Column(
                  children: [
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
              ),

              InkWell(
                onTap: _showDeleteAccountDialog,
                borderRadius: BorderRadius.circular(8.0),
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 20, left: 4, right: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delete Your Account',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'This action cannot be reversed.',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 60),

              if (_successMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    _successMessage!,
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.grey.shade400,
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B0000),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                          : const Text('Save'),
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