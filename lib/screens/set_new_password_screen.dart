import 'package:flutter/material.dart';
import 'package:usulicius_kelompok_lucky/screens/login_screen.dart';
import 'package:usulicius_kelompok_lucky/widgets/status_dialog.dart';

const Color kPrimaryMaroon = Color(0xFF800020);
const Color kDialogSuccess = Color(0xFF388E3C);

class SetNewPasswordScreen extends StatefulWidget {
  final String? email;
  const SetNewPasswordScreen({super.key, this.email});

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  String? _newPasswordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleVerifyPassword() {
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _newPasswordError = null;
      _confirmPasswordError = null;
    });

    bool isValid = true;
    if (newPassword.isEmpty) {
      setState(() {
        _newPasswordError = "New Password cannot be empty";
      });
      isValid = false;
    }
    if (confirmPassword.isEmpty) {
      setState(() {
        _confirmPasswordError = "Confirm New Password cannot be empty";
      });
      isValid = false;
    }
    if (isValid && newPassword != confirmPassword) {
      setState(() {
        _confirmPasswordError = "The password you entered are not the same";
      });
      isValid = false;
    }

    if (!isValid) return;

    print("Resetting password for email: ${widget.email}");
    print("New Password: $newPassword");

    showStatusDialog(
      context: context,
      title: 'Verification Successful',
      message: 'Your password has been reset.\nPlease log in again',
      icon: Icons.check_circle,
      iconColor: kDialogSuccess,
    ).then((_) {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryMaroon,
      appBar: AppBar(
        backgroundColor: kPrimaryMaroon,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.35,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'asset/logo.gif',
                    width: 60,
                    height: 60,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'USULicius',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 35,
                      fontFamily: 'Roboto Flex',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.30,
            left: 0,
            right: 0,
            bottom: 0,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFBC8F9B).withOpacity(0.5),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            'Set a new password',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontFamily: 'Roboto Flex',
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Center(
                          child: Text(
                            'Your new password must be different\nfrom previously used password',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                              height: 1.4,
                              fontFamily: 'Roboto Flex',
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          'New Password',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Roboto Flex',
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _newPasswordController,
                          obscureText: _obscureNewPassword,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'Roboto Flex',
                            fontWeight: FontWeight.w700,
                          ),
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureNewPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: kPrimaryMaroon,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureNewPassword = !_obscureNewPassword;
                                });
                              },
                            ),
                            errorText: _newPasswordError,
                            errorStyle:
                                const TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Confirm New Password',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Roboto Flex',
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'Roboto Flex',
                            fontWeight: FontWeight.w700,
                          ),
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: kPrimaryMaroon,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                            errorText: _confirmPasswordError,
                            errorStyle:
                                const TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ),
                        if (_confirmPasswordError != null &&
                            _confirmPasswordError!.contains("not the same"))
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _confirmPasswordError!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 13,
                                  fontFamily: 'Roboto Flex',
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _handleVerifyPassword,
                            child: const Text('Verify'),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
