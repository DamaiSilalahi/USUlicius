import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

class ChangeEmailScreen extends StatefulWidget {
  final String currentEmail;

  const ChangeEmailScreen({super.key, required this.currentEmail});

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailDialogState();
}

class _ChangeEmailDialogState extends State<ChangeEmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  String? _emailErrorText;
  String? _codeErrorText;

  bool _emailEntered = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _onNextPressed() async {
    final email = _emailController.text.trim();

    setState(() {
      _emailErrorText = null;
    });

    if (email.isEmpty) {
      setState(() => _emailErrorText = 'Email cannot be empty');
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _emailErrorText = 'Please enter a valid email address');
      return;
    }

    if (email == widget.currentEmail) {
      setState(() => _emailErrorText = 'Please enter a different email address');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFunctions.instance
          .httpsCallable('sendOtpEmail')
          .call({'email': email});

      if (mounted) {
        setState(() {
          _emailEntered = true;
          _emailErrorText = null;
          _codeController.clear();
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error sending OTP: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _emailErrorText = "Failed to send verification code. Try again.";
        });
      }
    }
  }

  void _onVerifyPressed(BuildContext context) async {
    final code = _codeController.text.trim();
    final newEmail = _emailController.text.trim();

    setState(() {
      _codeErrorText = null;
    });

    if (code.isEmpty) {
      setState(() => _codeErrorText = 'Code cannot be empty');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('verifyOtp');
      final result = await callable.call(<String, dynamic>{
        'email': newEmail,
        'code': code,
      });

      final data = result.data as Map<String, dynamic>;
      final bool success = data['success'] ?? false;
      final String message = data['message'] ?? 'Verification failed';

      if (success) {
        if (mounted) {
          Navigator.of(context).pop(newEmail);
        }
      } else {
        if (mounted) {
          setState(() {
            _codeErrorText = message;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error verify: $e");
      if (mounted) {
        setState(() {
          _codeErrorText = "System error. Please try again.";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const Color maroonColor = Color(0xFF8B0000);

    final bool emailErrorActive = _emailErrorText != null;
    final bool codeErrorActive = _codeErrorText != null;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),

      child: Container(
        width: screenWidth * 0.85,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Change Your Email',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 16),

              if (!_emailEntered)
                Column(
                  children: [
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: emailErrorActive ? _emailErrorText : 'Enter new email address',
                        hintStyle: TextStyle(
                          color: emailErrorActive ? maroonColor : Colors.grey,
                          fontWeight: emailErrorActive ? FontWeight.w500 : FontWeight.normal,
                        ),
                        // ... (Styling border Anda tetap saya pertahankan, sangat bagus) ...
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: emailErrorActive ? maroonColor : Colors.grey)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: emailErrorActive ? maroonColor : Colors.grey.shade400)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: maroonColor, width: 2.0)),
                      ),
                    ),
                    // Tampilkan Error Text secara eksplisit jika ada (opsional, karena sudah di hint)
                    if (_emailErrorText != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(_emailErrorText!, style: TextStyle(color: maroonColor, fontSize: 12)),
                      ),

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: maroonColor,
                            side: const BorderSide(color: maroonColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                          ),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _onNextPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: maroonColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                          ),
                          child: _isLoading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Next', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                )

              else
                Column(
                  children: [
                    Text(
                      "We've just sent a confirmation code to ${_emailController.text}",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      maxLength: 4,
                      decoration: InputDecoration(
                        counterText: "",
                        hintText: codeErrorActive ? _codeErrorText : 'Enter 4-digit code',
                        hintStyle: TextStyle(
                          color: codeErrorActive ? maroonColor : Colors.grey,
                          fontWeight: codeErrorActive ? FontWeight.w500 : FontWeight.normal,
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: codeErrorActive ? maroonColor : Colors.grey)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: codeErrorActive ? maroonColor : Colors.grey.shade400)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: maroonColor, width: 2.0)),
                      ),
                    ),

                    if (_codeErrorText != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(_codeErrorText!, style: TextStyle(color: maroonColor, fontSize: 12)),
                      ),

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: _isLoading ? null : () {
                            setState(() {
                              _emailEntered = false;
                              _isLoading = false;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: maroonColor,
                            side: const BorderSide(color: maroonColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                          ),
                          child: const Text('Back'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isLoading ? null : () => _onVerifyPressed(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: maroonColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                          ),
                          child: _isLoading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Verify', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}