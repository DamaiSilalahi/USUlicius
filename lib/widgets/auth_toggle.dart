import 'package:flutter/material.dart';
import 'package:usulicius_kelompok_lucky/constants.dart';

class AuthToggle extends StatelessWidget {
  final bool isLogin;
  final VoidCallback onLoginTap;
  final VoidCallback onRegisterTap;

  const AuthToggle({
    super.key,
    required this.isLogin,
    required this.onLoginTap,
    required this.onRegisterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, 
      height: 60, 
      decoration: BoxDecoration(
        color: kLightGreyBackground, 
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onLoginTap,
              child: Container(
                margin: const EdgeInsets.all(4), 
                decoration: BoxDecoration(
                  color: isLogin ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: isLogin
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            spreadRadius: 1, 
                            offset: const Offset(0, 3), 
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: isLogin ? Colors.black : Colors.black.withOpacity(0.5),
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      fontFamily: 'Roboto Flex',
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onRegisterTap,
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: !isLogin ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: !isLogin
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            spreadRadius: 1,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    'Register',
                    style: TextStyle(
                      color: !isLogin ? Colors.black : Colors.black.withOpacity(0.5),
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      fontFamily: 'Roboto Flex',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}