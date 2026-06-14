// lib/widgets/app_text_field.dart
import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String?   label;
  final String?   hint;
  final bool      obscureText;
  final TextInputType? keyboardType;
  final Widget?   prefixIcon;
  final Widget?   suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final int?      maxLines;
  final int?      maxLength;
  final bool      readOnly;
  final VoidCallback? onTap;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool      autofocus;
  final String?   initialValue;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.obscureText          = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.maxLines             = 1,
    this.maxLength,
    this.readOnly             = false,
    this.onTap,
    this.textCapitalization   = TextCapitalization.none,
    this.textInputAction,
    this.focusNode,
    this.autofocus            = false,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller:           controller,
      initialValue:         initialValue,
      obscureText:          obscureText,
      keyboardType:         keyboardType,
      validator:            validator,
      onChanged:            onChanged,
      onFieldSubmitted:     onSubmitted,
      maxLines:             maxLines,
      maxLength:            maxLength,
      readOnly:             readOnly,
      onTap:                onTap,
      textCapitalization:   textCapitalization,
      textInputAction:      textInputAction,
      focusNode:            focusNode,
      autofocus:            autofocus,
      decoration: InputDecoration(
        labelText:   label,
        hintText:    hint,
        prefixIcon:  prefixIcon,
        suffixIcon:  suffixIcon,
        counterText: '',
      ),
    );
  }
}
