import 'package:flutter/material.dart';
import 'package:usulicius_kelompok_lucky/screens/register_screen.dart';
import 'package:usulicius_kelompok_lucky/widgets/auth_toggle.dart';
import 'package:usulicius_kelompok_lucky/screens/forgot_password_screen.dart'; 

const Color kPrimaryMaroon = Color(0xFF800020);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _rememberMe = false;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    print('Login Berhasil! (Username: ${_usernameController.text}, Password: ${_passwordController.text})');
    print('Remember Me: $_rememberMe');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      mainAxisSize: MainAxisSize.min, 
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AuthToggle(
                          isLogin: true,
                          onLoginTap: () {},
                          onRegisterTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const RegisterScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 30),
                        _buildFormFields(),
                        const SizedBox(height: 16),
                        _buildLoginExtras(),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _handleLogin,
                            child: const Text('Login'),
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

  Widget _buildFormFields() {
    return Column(
      children: [
        TextFormField(
          controller: _usernameController,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'Roboto Flex',
            fontWeight: FontWeight.w700,
          ),
          decoration: const InputDecoration(
            hintText: 'Username',
            prefixIcon: Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'Roboto Flex',
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: 'Password',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: kPrimaryMaroon,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
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