import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:usulicius_kelompok_lucky/screens/login_screen.dart';
import 'package:usulicius_kelompok_lucky/widgets/status_dialog.dart';

const Color kPrimaryMaroon = Color(0xFF800020);
const Color kDialogError = Color(0xFFD32F2F);
const Color kDialogSuccess = Color(0xFF388E3C);

class VerificationScreen extends StatefulWidget {
  final String email;

  const VerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  bool _isLoading = false;
  Future<void> _handleCheckVerification() async {
    if (_isLoading) return;
    setState(() { _isLoading = true; });

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
      return;
    }

    await user.reload();
    user = FirebaseAuth.instance.currentUser;

    if (user!.emailVerified) {
      if (mounted) {
        showStatusDialog(
          context: context,
          title: 'Verifikasi Berhasil',
          message: 'Akun Anda telah terverifikasi. Silakan login.',
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
    } else {
      if (mounted) {
        showStatusDialog(
          context: context,
          title: 'Verifikasi Gagal',
          message: 'Email Anda belum terverifikasi. Silakan cek inbox Anda dan klik link yang kami kirim.',
          icon: Icons.error,
          iconColor: kDialogError,
        );
      }
    }

    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _resendCode() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email verifikasi baru telah dikirim.'),
            backgroundColor: kDialogSuccess,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryMaroon,
      appBar: AppBar(
        backgroundColor: kPrimaryMaroon,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 255, 255, 255)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.email_outlined, color: Color.fromARGB(255, 255, 255, 255), size: 100),
              const SizedBox(height: 30),

              const Text(
                'Verifikasi Email Anda',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontFamily: 'Roboto Flex',
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Kami telah mengirimkan link verifikasi ke email:\n${widget.email}\n\nSilakan klik link tersebut untuk mengaktifkan akun Anda.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color.fromARGB(179, 255, 255, 255),
                  fontSize: 16,
                  height: 1.5,
                  fontFamily: 'Roboto Flex',
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleCheckVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: kPrimaryMaroon,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: kPrimaryMaroon, strokeWidth: 3)
                      : const Text('Saya Sudah Verifikasi, Lanjutkan'),
                ),
              ),
              const SizedBox(height: 20),

              TextButton(
                onPressed: _resendCode,
                child: const Text(
                  'Kirim Ulang Email',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Roboto Flex',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}