import 'package:flutter/material.dart';

/// A text input styled from [InputDecorationTheme] (rounded, bordered,
/// filled — see `app_theme.dart`). Used for the email and pseudo fields in
/// onboarding.
class PfTextField extends StatelessWidget {
  const PfTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.prefixText,
    this.keyboardType,
    this.autofocus = false,
    this.maxLength,
    this.onChanged,
  });

  final TextEditingController controller;
  final String? hintText;
  final String? prefixText;
  final TextInputType? keyboardType;
  final bool autofocus;
  final int? maxLength;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      autofocus: autofocus,
      maxLength: maxLength,
      onChanged: onChanged,
      style: Theme.of(context).textTheme.titleMedium,
      decoration: InputDecoration(
        hintText: hintText,
        prefixText: prefixText,
        counterText: '',
      ),
    );
  }
}
