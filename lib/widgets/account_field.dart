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
    final displayValue =
    isSensitive ? '•' * initialValue.length : initialValue;

    const Color maroonColor = Color(0xFF8B0000);
    const Color errorColor = Color(0xFF940128);

    final bool hasError =
        errorText != null && errorText!.isNotEmpty;

    final String? inputHintText =
    (isEditable &&
        (controller == null
            ? initialValue.isEmpty
            : controller!.text.isEmpty))
        ? 'Enter ${label.toLowerCase()}'
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: controller,
            initialValue: (controller == null) ? displayValue : null,
            readOnly: !isEditable,
            obscureText: isSensitive && isEditable,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 12.0,
              ),
              filled: !isEditable,
              fillColor: Colors.grey.shade200,
              hintText: inputHintText,
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.normal,
              ),
              errorStyle: const TextStyle(height: 0, fontSize: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: hasError ? errorColor : Colors.grey,
                  width: hasError ? 1.5 : 1.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: hasError
                      ? errorColor
                      : const Color.fromARGB(255, 112, 34, 34),
                  width: hasError ? 1.5 : 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: hasError ? errorColor : maroonColor,
                  width: 2.0,
                ),
              ),
            ),
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 6.0, left: 2.0),
              child: Text(
                errorText!,
                style: const TextStyle(
                  color: errorColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          if (onEditPressed != null)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: InkWell(
                  onTap: onEditPressed,
                  child: const Text(
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