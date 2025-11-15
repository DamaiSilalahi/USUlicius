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
        : (isEditable &&
                (controller == null ? initialValue.isEmpty : controller!.text.isEmpty)
            ? 'Enter ${label.toLowerCase()}'
            : null);

    final Color errorColor = const Color(0xFF940128);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            initialValue: showCustomErrorInBox ? null : (isEditable ? null : displayValue),
            readOnly: !isEditable,
            obscureText: isSensitive,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
              filled: !isEditable,
              fillColor: Colors.grey.shade200,
              hintStyle: TextStyle(
                color: showCustomErrorInBox ? errorColor : Colors.grey,
                fontWeight:
                    showCustomErrorInBox ? FontWeight.w500 : FontWeight.normal,
              ),
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
                  color: showCustomErrorInBox
                      ? errorColor
                      : const Color.fromARGB(255, 112, 34, 34),
                  width: showCustomErrorInBox ? 2.0 : 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color:
                      showCustomErrorInBox ? errorColor : Theme.of(context).primaryColor,
                  width: 2.0,
                ),
              ),
              hintText: inputHintText,
              errorText: showCustomErrorInBox ? ' ' : null,
              errorStyle: const TextStyle(fontSize: 0, height: 0),
              suffixIcon: onEditPressed != null
                  ? TextButton(
                      onPressed: onEditPressed,
                      child: const Text('Change'),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
