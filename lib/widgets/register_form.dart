import 'package:flutter/material.dart';
import 'package:usulicius_kelompok_lucky/screens/verification_screen.dart';
import 'package:usulicius_kelompok_lucky/widgets/status_dialog.dart';

const Color kPrimaryMaroon = Color(0xFF800020);

class RegisterForm extends StatefulWidget {
  const RegisterForm({Key? key}) : super(key: key);

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  bool _obscurePassword = true;
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() {

    showStatusDialog(
      context: context,
      title: 'Check Your Email',
      message: 'A verification code has been sent to your email.',
      icon: Icons.email,
      iconColor: kPrimaryMaroon,
    ).then((_) {
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VerificationScreen(
              email: _emailController.text.isNotEmpty
                  ? _emailController.text
                  : 'your-email@example.com',
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFormFields(),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _handleRegister,
            child: const Text('Register'),
          ),
        ),
        const SizedBox(height: 20),
      ],
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
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'Roboto Flex',
            fontWeight: FontWeight.w700,
          ),
          decoration: const InputDecoration(
            hintText: 'Email',
            prefixIcon: Icon(Icons.email),
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
}