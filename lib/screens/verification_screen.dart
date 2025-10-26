import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:usulicius_kelompok_lucky/screens/login_screen.dart';
import 'package:usulicius_kelompok_lucky/widgets/status_dialog.dart';
import 'package:usulicius_kelompok_lucky/screens/set_new_password_screen.dart';

const Color kPrimaryMaroon = Color(0xFF800020);
const Color kDialogError = Color(0xFFD32F2F);
const Color kDialogSuccess = Color(0xFF388E3C);

enum VerificationType { emailVerification, passwordReset }

class VerificationScreen extends StatefulWidget {
  final String email;
  final VerificationType type;

  const VerificationScreen({
    super.key,
    required this.email,
    this.type = VerificationType.emailVerification,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 4; i++) {
      _controllers[i].addListener(() {
        if (_controllers[i].text.length == 1 && i < 3) {
          _focusNodes[i + 1].requestFocus();
        } else if (_controllers[i].text.length == 1 && i == 3) {
          _focusNodes[i].unfocus();
        }
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleVerify() {
    String code = _controllers.map((c) => c.text).join();
    FocusScope.of(context).unfocus();

    if (code == '1234') {
      showStatusDialog(
        context: context,
        title: 'Verification Successful',
        message: widget.type == VerificationType.passwordReset
            ? 'Your email has been verified.'
            : 'Please log in to continue',
        icon: Icons.check_circle,
        iconColor: kDialogSuccess,
      ).then((_) {
        if (mounted) {
          if (widget.type == VerificationType.passwordReset) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => SetNewPasswordScreen(email: widget.email),
              ),
            );
          } else {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        }
      });
    } else {
      showStatusDialog(
        context: context,
        title: 'Verification Failed',
        message: 'Please check your code and try again.',
        icon: Icons.error,
        iconColor: kDialogError,
      ).then((_) {
        if (mounted) {
          _focusNodes[0].requestFocus();
          for (var controller in _controllers) {
            controller.clear();
          }
        }
      });
    }
  }

  void _resendCode() {
    print('Resend code requested for ${widget.email}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Verification code resent to ${widget.email}'),
        backgroundColor: kDialogSuccess,
      ),
    );
    if (mounted) {
      _focusNodes[0].requestFocus();
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
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: SingleChildScrollView(
                    padding:
                        const EdgeInsets.fromLTRB(24, 40, 24, 30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Verify your email',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontFamily: 'Roboto Flex',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Please enter 4 digit code sent to \n${widget.email}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                            height: 1.4,
                            fontFamily: 'Roboto Flex',
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildOtpInput(),
                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: _resendCode,
                          child: const Text(
                            'Resend code',
                            style: TextStyle(
                              color: kPrimaryMaroon,
                              fontFamily: 'Roboto Flex',
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _handleVerify,
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

  Widget _buildOtpInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(4, (index) {
        return SizedBox(
          width: 55,
          height: 55,
          child: TextFormField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            cursorColor: kPrimaryMaroon,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontFamily: 'Roboto Flex',
            ),
            decoration: InputDecoration(
              counterText: '',
              contentPadding: EdgeInsets.zero,
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: Colors.grey.shade400, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: kPrimaryMaroon, width: 2),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < 3) {
                _focusNodes[index + 1].requestFocus();
              } else if (value.isEmpty && index > 0) {
                _focusNodes[index - 1].requestFocus();
              } else if (value.isNotEmpty && index == 3) {
                _handleVerify();
              }
            },
          ),
        );
      }),
    );
  }
}
