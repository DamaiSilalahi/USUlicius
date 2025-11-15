import 'package:flutter/material.dart';

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

  void _onNextPressed() {
    setState(() {
      _emailErrorText = null; 
    });

    if (_emailController.text.isEmpty) {
      setState(() {
        _emailErrorText = 'Email cannot be empty';
      });
      return;
    }

    if (!_emailController.text.contains('@') || !_emailController.text.contains('.')) {
      setState(() {
        _emailErrorText = 'Please enter a valid email address';
      });
      return;
    }

    setState(() {
      _emailEntered = true;
      _emailErrorText = null;
      _codeController.clear(); 
    });
  }

  void _onVerifyPressed(BuildContext context) {
    setState(() {
      _codeErrorText = null; 
    });

    if (_codeController.text.isEmpty) {
      setState(() {
        _codeErrorText = 'Confirmation code cannot be empty';
      });
      return;
    }

    if (_codeController.text == '123456') {
      Navigator.of(context).pop(_emailController.text);
    } else {
      setState(() {
        _codeErrorText = 'Invalid code. Please try again';
      });
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
                        hintText: emailErrorActive ? _emailErrorText : 'Enter an email address',
                        hintStyle: TextStyle(
                          color: emailErrorActive ? maroonColor : Colors.grey,
                          fontWeight: emailErrorActive ? FontWeight.w500 : FontWeight.normal,
                        ),
                        errorText: emailErrorActive ? ' ' : null,
                        errorStyle: const TextStyle(fontSize: 0, height: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: emailErrorActive ? maroonColor : Colors.grey,
                            width: emailErrorActive ? 2.0 : 1.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: emailErrorActive ? maroonColor : Colors.grey.shade400,
                            width: emailErrorActive ? 2.0 : 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: maroonColor,
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end, 
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: maroonColor, 
                            side: const BorderSide(color: maroonColor), 
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _onNextPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: maroonColor,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          child: const Text('Next', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                )
              
              else
                Column(
                  children: [
                    Text(
                      "We've just sent your confirmation code to ${_emailController.text}",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: codeErrorActive ? _codeErrorText : 'Please enter the confirmation code',
                        hintStyle: TextStyle(
                          color: codeErrorActive ? maroonColor : Colors.grey,
                          fontWeight: codeErrorActive ? FontWeight.w500 : FontWeight.normal,
                        ),
                        errorText: codeErrorActive ? ' ' : null,
                        errorStyle: const TextStyle(fontSize: 0, height: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                           borderSide: BorderSide(
                            color: codeErrorActive ? maroonColor : Colors.grey,
                            width: codeErrorActive ? 2.0 : 1.0,
                          ),
                        ),
                         enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: codeErrorActive ? maroonColor : Colors.grey.shade400,
                            width: codeErrorActive ? 2.0 : 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: maroonColor,
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end, 
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: maroonColor,
                            side: const BorderSide(color: maroonColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _onVerifyPressed(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: maroonColor,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          child: const Text('Verify', style: TextStyle(color: Colors.white)),
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