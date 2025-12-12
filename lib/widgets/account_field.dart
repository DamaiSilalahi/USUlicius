import 'package:flutter/material.dart';

class AccountField extends StatelessWidget {
  final String label;
  final String initialValue;
  final bool isSensitive;
  final TextEditingController? controller;
  final bool isEditable;
  final String? errorText;
  final VoidCallback? onEditPressed;

  const AccountField({
    super.key,
    required this.label,
    required this.initialValue,
    this.isSensitive = false,
    this.controller,
    this.isEditable = true,
    this.errorText,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = isSensitive ? '•' * initialValue.length : initialValue;
    final bool isCustomErrorField = label.contains('Name') || label.contains('Password');
    final bool showCustomErrorInBox = errorText != null && isCustomErrorField;

    final String? inputHintText = showCustomErrorInBox
        ? errorText
        : (isEditable && (controller == null ? initialValue.isEmpty : controller!.text.isEmpty)
            ? 'Enter ${label.toLowerCase()}'
            : null);

    final Color maroonColor = const Color(0xFF8B0000);
    final Color errorColor = const Color(0xFF940128);

    return Padding(
      // UBAH: Mengurangi jarak bawah antar field dari 16.0 menjadi 10.0
      padding: const EdgeInsets.only(bottom: 10.0), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          // UBAH: Mengurangi jarak antara Label dan Kotak dari 8 menjadi 5
          const SizedBox(height: 5), 

          TextFormField(
            controller: controller,
            initialValue: (controller == null && !showCustomErrorInBox) ? displayValue : null,
            readOnly: !isEditable,
            obscureText: isSensitive && isEditable,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              // UBAH: Sedikit menipiskan padding dalam kotak
              contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
              filled: !isEditable,
              fillColor: Colors.grey.shade200,
              hintText: inputHintText,
              hintStyle: TextStyle(
                color: showCustomErrorInBox ? errorColor : Colors.grey,
                fontWeight: showCustomErrorInBox ? FontWeight.w500 : FontWeight.normal,
              ),
              errorText: showCustomErrorInBox ? ' ' : null,
              errorStyle: const TextStyle(fontSize: 0, height: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: showCustomErrorInBox ? errorColor : Colors.grey,
                  width: showCustomErrorInBox ? 2.0 : 1.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: showCustomErrorInBox ? errorColor : const Color.fromARGB(255, 112, 34, 34),
                  width: showCustomErrorInBox ? 2.0 : 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: showCustomErrorInBox ? errorColor : maroonColor,
                  width: 2.0,
                ),
              ),
            ),
          ),

          if (onEditPressed != null)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                // UBAH: Mengurangi jarak tulisan "Change" ke kotak
                padding: const EdgeInsets.only(top: 2.0), 
                child: InkWell(
                  onTap: onEditPressed,
                  child: Text(
                    'Change',
                    style: TextStyle(
                      color: maroonColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
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