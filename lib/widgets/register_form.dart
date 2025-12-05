import 'package:flutter/material.dart';
import 'package:usulicius_kelompok_lucky/screens/verification_screen.dart';
import 'package:usulicius_kelompok_lucky/widgets/status_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

const Color kPrimaryMaroon = Color(0xFF800020);
const Color kDialogError = Color(0xFFD32F2F);

class RegisterForm extends StatefulWidget {
  // Callback opsional jika parent perlu tahu status loading
  final Function(bool)? onRegisterLoading;

  const RegisterForm({Key? key, this.onRegisterLoading}) : super(key: key);

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  bool _obscurePassword = true;
  bool _isLoading = false; // State loading internal untuk tombol

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Variable Error per field
  String? _usernameError;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _setLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
    if (widget.onRegisterLoading != null) {
      widget.onRegisterLoading!(value);
    }
  }

  void _handleRegister() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Reset error sebelum validasi
    setState(() {
      _usernameError = null;
      _emailError = null;
      _passwordError = null;
    });

    // 1. VALIDASI INPUT KOSONG
    bool hasError = false;
    if (username.isEmpty) {
      setState(() => _usernameError = 'Username cannot be empty');
      hasError = true;
    }
    if (email.isEmpty) {
      setState(() => _emailError = 'Email cannot be empty');
      hasError = true;
    }
    if (password.isEmpty) {
      setState(() => _passwordError = 'Password cannot be empty');
      hasError = true;
    }

    if (hasError) return;

    // Mulai Loading
    _setLoading(true);

    try {
      // 2. CEK USERNAME UNIK DI FIRESTORE
      final usernameCheck = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (usernameCheck.docs.isNotEmpty) {
        throw FirebaseAuthException(code: 'username-already-in-use');
      }

      // 3. BUAT AKUN DI FIREBASE AUTH
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user != null) {
        // 4. SIMPAN PROFIL KE FIRESTORE
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'username': username,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // 5. [PERBAIKAN] KIRIM OTP VIA CLOUD FUNCTION (Bukan Link!)
        try {
          await FirebaseFunctions.instance
              .httpsCallable('sendOtpEmail')
              .call({'email': email});
          print("OTP sent via Cloud Function!");
        } catch (e) {
          print("Error Cloud Function: $e");
          throw FirebaseAuthException(code: 'otp-failed', message: 'Gagal mengirim OTP.');
        }

        if (mounted) {
          showStatusDialog(
            context: context,
            title: 'OTP Terkirim',
            message: 'Kode 4 digit telah dikirim ke $email. Silakan cek inbox Anda.',
            icon: Icons.mark_email_read,
            iconColor: kPrimaryMaroon,
          ).then((_) {
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => VerificationScreen(email: email),
                ),
                    (route) => false,
              );
            }
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      // Mapping Error Firebase ke Field yang sesuai
      if (e.code == 'weak-password') {
        setState(() => _passwordError = 'Password terlalu lemah (minimal 6 karakter).');
      } else if (e.code == 'email-already-in-use') {
        setState(() => _emailError = 'Email ini sudah terdaftar.');
      } else if (e.code == 'invalid-email') {
        setState(() => _emailError = 'Format email tidak valid.');
      } else if (e.code == 'username-already-in-use') {
        setState(() => _usernameError = 'Username "$username" sudah dipakai.');
      } else if (e.code == 'otp-failed') {
        // Error umum tampilkan di dialog karena bukan salah input user
        if (mounted) {
          showStatusDialog(
            context: context,
            title: 'Gagal',
            message: 'Gagal mengirim kode OTP. Cek koneksi internet.',
            icon: Icons.error,
            iconColor: kDialogError,
          );
        }
      } else {
        setState(() => _passwordError = 'Terjadi kesalahan. Coba lagi.');
        print('Firebase Error: ${e.message}');
      }
    } finally {
      if (mounted) {
        _setLoading(false);
      }
    }
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
            onPressed: _isLoading ? null : _handleRegister,
            child: _isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            )
                : const Text('Register'),
          ),
        ),
      ],
    );
  }

  // Widget TextField yang dimodifikasi (Reusability)
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
    final Color currentColor = hasError ? kDialogError : kPrimaryMaroon;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
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
            hintText: hintText,
            hintStyle: TextStyle(
              color: currentColor.withOpacity(0.7),
              fontWeight: FontWeight.normal,
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

            // Konfigurasi Error Text
            errorText: hasError ? errorText : null,
            errorStyle: const TextStyle(
              color: kDialogError,
              fontSize: 12,
              fontFamily: 'Roboto Flex',
            ),

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
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        _buildAuthTextField(
          controller: _usernameController,
          hintText: 'Username',
          prefixIcon: Icons.person,
          errorText: _usernameError,
        ),
        const SizedBox(height: 16),
        _buildAuthTextField(
          controller: _emailController,
          hintText: 'Email',
          prefixIcon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          errorText: _emailError,
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
      ],
    );
  }
}