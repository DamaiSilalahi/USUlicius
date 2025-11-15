import 'package:flutter/material.dart';
import 'package:usulicius_kelompok_lucky/widgets/account_field.dart';
import 'package:usulicius_kelompok_lucky/screens/change_email_screen.dart';
import 'package:usulicius_kelompok_lucky/widgets/upload_picture_dialog.dart';
import 'package:usulicius_kelompok_lucky/widgets/photo_profile.dart';
import 'package:usulicius_kelompok_lucky/widgets/delete_account.dart';
import 'package:usulicius_kelompok_lucky/screens/login_screen.dart';

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
  late String _currentName;
  late String _currentEmail;
  late String _currentPassword;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();

  bool _isPasswordChanging = false;
  final _formKey = GlobalKey<FormState>();
  String? _successMessage;
  String? _nameError;
  String? _newPasswordError;
  String? _confirmNewPasswordError;

  @override
  void initState() {
    super.initState();
    _currentName = widget.initialName;
    _currentEmail = widget.initialEmail;
    _currentPassword = widget.initialPassword;
    _nameController.text = _currentName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    setState(() {
      _nameError = null;
      _successMessage = null;
      _newPasswordError = null;
      _confirmNewPasswordError = null;
    });

    bool validationPassed = true;

    if (_nameController.text.isEmpty) {
      setState(() {
        _nameError = 'Name cannot be empty';
      });
      validationPassed = false;
    }

    if (_isPasswordChanging) {
      if (_newPasswordController.text.isEmpty) {
        setState(() {
          _newPasswordError = 'New Password cannot be empty';
        });
        validationPassed = false;
      }
      if (_confirmNewPasswordController.text.isEmpty) {
        setState(() {
          _confirmNewPasswordError = 'Confirm New Password cannot be empty';
        });
        validationPassed = false;
      }
    }

    if (!validationPassed) {
      return;
    }

    if (_nameController.text != _currentName) {
      setState(() {
        _currentName = _nameController.text;
        _successMessage = 'Name updated successfully.';
      });
      Navigator.pop(context);
      return;
    }

    if (_isPasswordChanging) {
      if (_newPasswordController.text == _confirmNewPasswordController.text) {
        setState(() {
          _currentPassword = '••••••••••';
          _isPasswordChanging = false;
          _successMessage = 'Password updated successfully.';
          _newPasswordController.clear();
          _confirmNewPasswordController.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New passwords do not match.')),
        );
        return;
      }
    }

    if (_successMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No changes detected.')),
      );
    }
  }

  Future<void> _showChangeEmailDialog() async {
    final newEmail = await showDialog<String>(
      context: context,
      builder: (context) => ChangeEmailScreen(currentEmail: _currentEmail),
    );

    if (newEmail != null) {
      setState(() {
        _currentEmail = newEmail;
        _successMessage = 'Verification successfull.';
      });
    }
  }

  Future<void> _showUploadPictureDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => const UploadPictureDialog(),
    );

    if (result == 'file_chosen' && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Picture uploaded (simulation)!')),
      );
    }
  }

  Future<void> _showDeleteAccountDialog() async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => const DeleteAccount(),
    );

    if (shouldDelete == true && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(
            initialMessage: "Account deleted. We're sad to see you go~",
          ),
        ),
        (Route<dynamic> route) => false,
      );
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
              const ProfileAvatar(radius: 60, iconSize: 70),
              const SizedBox(height: 10),
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: _showUploadPictureDialog,
                  child: const Text('Upload a picture'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B0000),
                  ),
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
                initialValue: _currentPassword,
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
                onEditPressed: _showChangeEmailDialog,
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
                        'Deleting your account will remove all your personal data and preferences. This action cannot be reversed.',
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
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: Colors.black)),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.grey.shade400,
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      child: const Text('Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B0000),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
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
