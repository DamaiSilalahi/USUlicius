import 'package:flutter/material.dart';
import 'package:usulicius_kelompok_lucky/screens/login_screen.dart';
import 'package:usulicius_kelompok_lucky/widgets/status_dialog.dart';

const Color kPrimaryMaroon = Color(0xFF800020);
const Color kDialogSuccess = Color(0xFF388E3C);
const Color kDialogError = Color(0xFFD32F2F);

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

  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleVerifyPassword() async { 
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _newPasswordError = null;
      _confirmPasswordError = null;
    });

    bool isValid = true;
    
    if (newPassword.isEmpty) {
      setState(() => _newPasswordError = "New Password cannot be empty");
      isValid = false;
    }
    if (confirmPassword.isEmpty) {
      setState(() => _confirmPasswordError = "Confirm New Password cannot be empty");
      isValid = false;
    }
    if (!isValid) return;

    if (newPassword != confirmPassword) {
      setState(() => _confirmPasswordError = "The password you entered are not the same");
      isValid = false;
    }
    if (newPassword.length < 6) {
       setState(() => _newPasswordError = "Password must be at least 6 characters");
       isValid = false;
    }
    if (!isValid) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);

    if (mounted) {
      await showStatusDialog(
        context: context,
        title: 'Verification Successful',
        message: 'Your password has been reset.\nPlease log in again',
        icon: Icons.check_circle, 
        iconColor: kDialogSuccess,
      );
    }

    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryMaroon,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          },
        ),
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: kPrimaryMaroon,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.35 - kToolbarHeight, 
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.gif',
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
            top: MediaQuery.of(context).size.height * 0.33, 
            left: 0,
            right: 0,
            bottom: 0.0,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 0, left: 10, right: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFBC8F9B).withOpacity(0.5),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                  ),
                ),
                
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 30),
                    child: Column(
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
                        
                        _buildPasswordField(
                          controller: _newPasswordController,
                          errorText: _newPasswordError,
                          hintText: 'New Password',
                          isObscure: _obscureNewPassword,
                          toggleObscure: () {
                            setState(() => _obscureNewPassword = !_obscureNewPassword);
                          },
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

                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          errorText: _confirmPasswordError,
                          hintText: 'Confirm New Password',
                          isObscure: _obscureConfirmPassword,
                          toggleObscure: () {
                            setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                          },
                        ),
                        
                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleVerifyPassword,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Text(
                                    'Verify',
                                    style: TextStyle(
                                      fontSize: 16, 
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String? errorText,
    required String hintText,
    required bool isObscure,
    required VoidCallback toggleObscure,
  }) {
    final bool hasError = errorText != null;

    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontFamily: 'Roboto Flex',
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        hintText: hasError ? errorText : hintText,
        hintStyle: TextStyle(
          color: hasError ? kDialogError : Colors.grey.shade600,
          fontWeight: hasError ? FontWeight.w500 : FontWeight.normal,
        ),
        errorText: null,
        helperText: ' ',
        helperStyle: const TextStyle(height: 0.01),
        errorStyle: const TextStyle(height: 0.01),

        suffixIcon: IconButton(
          icon: Icon(
            isObscure ? Icons.visibility_off : Icons.visibility,
            color: kPrimaryMaroon,
          ),
          onPressed: toggleObscure,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: hasError ? kDialogError : kPrimaryMaroon, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: hasError ? kDialogError : kPrimaryMaroon, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: hasError ? kDialogError : kPrimaryMaroon, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kDialogError, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kDialogError, width: 2),
        ),
      ),
    );
  }
}
