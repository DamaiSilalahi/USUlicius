import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:usulicius_kelompok_lucky/screens/login_screen.dart';
import 'package:usulicius_kelompok_lucky/widgets/status_dialog.dart';
import 'package:usulicius_kelompok_lucky/screens/home_screen.dart';
import 'package:cloud_functions/cloud_functions.dart';

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
  // [PERUBAHAN] Ubah list menjadi 4 digit
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 4; i++) {
      _controllers[i].addListener(() {
        // [PERUBAHAN] Pindah fokus otomatis jika index < 3 (karena max index adalah 3)
        if (_controllers[i].text.length == 1 && i < 3) {
          _focusNodes[i + 1].requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var n in _focusNodes) n.dispose();
    super.dispose();
  }

  void _handleVerify() async {
    String code = _controllers.map((c) => c.text).join();

    // [PERUBAHAN] Validasi panjang kode harus 4
    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Masukkan 4 digit kode.")));
      return;
    }

    setState(() { _isLoading = true; });
    FocusScope.of(context).unfocus();

    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('verifyOtp');
      final result = await callable.call(<String, dynamic>{
        'email': widget.email,
        'code': code,
      });

      final data = result.data as Map<String, dynamic>;
      final bool success = data['success'] ?? false;
      final String message = data['message'] ?? 'Verifikasi gagal.';

      if (success) {
        if (mounted) {
          showStatusDialog(
            context: context,
            title: 'Berhasil!',
            message: message,
            icon: Icons.check_circle,
            iconColor: kDialogSuccess,
          ).then((_) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => HomeScreen()),
                  (route) => false,
            );
          });
        }
      } else {
        if (mounted) {
          showStatusDialog(
              context: context, title: 'Gagal', message: message, icon: Icons.error, iconColor: kDialogError
          );
          for (var c in _controllers) c.clear();
          _focusNodes[0].requestFocus();
        }
      }

    } catch (e) {
      print("Error verifying: $e");
      if (mounted) {
        showStatusDialog(
            context: context, title: 'Error', message: 'Terjadi kesalahan sistem.', icon: Icons.error, iconColor: kDialogError
        );
      }
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  void _resendCode() async {
    setState(() { _isLoading = true; });
    try {
      await FirebaseFunctions.instance.httpsCallable('sendOtpEmail').call({'email': widget.email});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kode baru dikirim ke ${widget.email}')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mengirim ulang kode.')));
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryMaroon,
      appBar: AppBar(backgroundColor: kPrimaryMaroon, elevation: 0, leading: const BackButton(color: Colors.white)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.mark_email_read_outlined, color: Colors.white, size: 80),
              const SizedBox(height: 20),
              const Text('Verifikasi OTP', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text('Masukkan 4 digit kode yang dikirim ke:\n${widget.email}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 30),

              // [PERUBAHAN] INPUT 4 DIGIT (Lebar kotak diperbesar jadi 60 agar pas)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) => SizedBox(
                  width: 60, height: 65,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      counterText: "",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (val) {
                      if (val.isEmpty && index > 0) _focusNodes[index - 1].requestFocus();
                    },
                  ),
                )),
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleVerify,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15), backgroundColor: Colors.white, foregroundColor: kPrimaryMaroon),
                  child: _isLoading ? const CircularProgressIndicator() : const Text('Verifikasi'),
                ),
              ),
              TextButton(onPressed: _isLoading ? null : _resendCode, child: const Text("Kirim Ulang Kode", style: TextStyle(color: Colors.white)))
            ],
          ),
        ),
      ),
    );
  }
}