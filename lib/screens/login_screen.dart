import 'package:flutter/material.dart';
import 'package:usulicius_kelompok_lucky/screens/verification_screen.dart';
import 'package:usulicius_kelompok_lucky/widgets/auth_toggle.dart';
import 'package:usulicius_kelompok_lucky/screens/forgot_password_screen.dart';
import 'package:usulicius_kelompok_lucky/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:usulicius_kelompok_lucky/widgets/register_form.dart';

const Color kPrimaryMaroon = Color(0xFF800020);
const Color kDialogSuccess = Color(0xFF388E3C);
const Color kDialogError = Color(0xFFD32F2F);

class LoginScreen extends StatefulWidget {
  final String? initialMessage;

  const LoginScreen({super.key, this.initialMessage});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin = true;

  bool _obscurePassword = true;
  bool _rememberMe = false;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  String? _usernameError;
  String? _passwordError;
  String? _generalError;
  
  String? _successMessage; 
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialMessage != null) {
      _successMessage = widget.initialMessage;
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _successMessage = null;
          });
        }
      });
    }
  }

  void _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _usernameError = null;
      _passwordError = null;
      _generalError = null;
      _successMessage = null;
      _isLoading = true;
    });

    bool hasError = false;
    if (username.isEmpty) {
      setState(() => _usernameError = 'Username cannot be empty');
      hasError = true;
    }
    if (password.isEmpty) {
      setState(() => _passwordError = 'Password cannot be empty');
      hasError = true;
    }

    if (hasError) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() => _usernameError = "Username tidak ditemukan!");
        throw Exception('Username not found');
      }

      final userDoc = querySnapshot.docs.first;
      final email = userDoc.data() as Map<String, dynamic>;

      if (email['email'] == null) {
        setState(() => _generalError = "Terjadi kesalahan: Email tidak terdaftar.");
        throw Exception('Email field missing');
      }

      final userEmail = email['email'];

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: userEmail, password: password);

      User? user = userCredential.user;

      if (user != null) {
        if (user.emailVerified) {
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => HomeScreen()),
              (route) => false,
            );
          }
        } else {
          if (context.mounted) {
            await user.sendEmailVerification();
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => VerificationScreen(email: userEmail)),
            );
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        setState(() => _passwordError = "Password salah!");
      } else {
        setState(() => _generalError = "Terjadi kesalahan. Silakan coba lagi.");
      }
    } catch (e) {
      print(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kPrimaryMaroon,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.40,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
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
            top: MediaQuery.of(context).size.height * 0.38,
            left: 0,
            right: 0,
            bottom: 0.0,
            child: Stack(
              fit: StackFit.expand,
              alignment: Alignment.topCenter,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 0,
                    left: 10,
                    right: 10,
                  ),
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
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: SingleChildScrollView(
                    padding:
                        const EdgeInsets.fromLTRB(24, 30, 24, 30).copyWith(
                      bottom: 30 + MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AuthToggle(
                          isLogin: _isLogin,
                          onLoginTap: () {
                            if (!_isLogin) {
                              setState(() => _isLogin = true);
                            }
                          },
                          onRegisterTap: () {
                            if (_isLogin) {
                              setState(() => _isLogin = false);
                            }
                          },
                        ),
                        const SizedBox(height: 30),

                        if (_successMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              decoration: BoxDecoration(
                                color: kDialogSuccess.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _successMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: kDialogSuccess,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Roboto Flex',
                                ),
                              ),
                            ),
                          ),

                        if (_generalError != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _generalError!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 13,
                                  fontFamily: 'Roboto Flex',
                                ),
                              ),
                            ),
                          ),

                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          child: _isLogin
                              ? _buildLoginForm(key: const ValueKey('login'))
                              : RegisterForm(
                                  key: const ValueKey('register'),
                                  onRegisterLoading: (isLoading) {
                                    setState(() => _isLoading = isLoading);
                                  },
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

  Widget _buildAuthTextField({
    required TextEditingController controller,
    required String hintText,
    String? errorText,
    required IconData prefixIcon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleObscure,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final bool hasError = errorText != null;
    final String currentLabel = hasError ? errorText : hintText;
    final Color currentColor = hasError ? kDialogError : kPrimaryMaroon;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontFamily: 'Roboto Flex',
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: currentLabel,
        labelStyle: TextStyle(
          color: currentColor,
          fontWeight: hasError ? FontWeight.w500 : FontWeight.normal,
        ),
        
        prefixIcon: Icon(prefixIcon, color: currentColor.withOpacity(0.8)),
        
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: kPrimaryMaroon,
                ),
                onPressed: onToggleObscure,
              )
            : null,
        
        errorText: hasError ? ' ' : null,
        errorStyle: const TextStyle(fontSize: 0, height: 0),

        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: kPrimaryMaroon.withOpacity(0.4), width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: kPrimaryMaroon, width: 2.0),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: kDialogError, width: 2.0),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: kDialogError, width: 2.0),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildLoginForm({Key? key}) {
    return Column(
      key: key,
      children: [
        _buildAuthTextField(
          controller: _usernameController,
          hintText: 'Username',
          prefixIcon: Icons.person,
          errorText: _usernameError,
        ),
        const SizedBox(height: 16),
        _buildAuthTextField(
          controller: _passwordController,
          hintText: 'Password',
          prefixIcon: Icons.lock,
          errorText: _passwordError,
          isPassword: true,
          obscureText: _obscurePassword,
          onToggleObscure: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        const SizedBox(height: 16),
        _buildLoginExtras(),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            child: _isLoading
                ? const CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 3)
                : const Text('Login'),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginExtras() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (val) {
                  setState(() {
                    _rememberMe = val ?? false;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Remember me',
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontFamily: 'Roboto Flex',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
            );
          },
          child: const Text(
            'Forgot Password?',
            style: TextStyle(
              color: kPrimaryMaroon,
              fontSize: 12,
              fontFamily: 'Roboto Flex',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
