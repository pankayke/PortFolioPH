// lib/presentation/widgets/glass/glass_input_field.dart
// ─────────────────────────────────────────────────────────────────────────────
// Premium glassmorphic input field with icon, validation, and focus effects
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:portfolioph/core/constants/app_constants.dart';

class GlassInputField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? minLines;
  final bool isPassword;
  final bool showPasswordToggle;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final double blurStrength;
  final double opacity;

  const GlassInputField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.minLines,
    this.isPassword = false,
    this.showPasswordToggle = false,
    this.onChanged,
    this.onEditingComplete,
    this.textInputAction,
    this.autofillHints,
    this.blurStrength = 12.0,
    this.opacity = 0.15,
  });

  @override
  State<GlassInputField> createState() => _GlassInputFieldState();
}

class _GlassInputFieldState extends State<GlassInputField> {
  late bool _obscureText;
  late FocusNode _focusNode;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {});
    if (!_focusNode.hasFocus && widget.controller != null) {
      final error = widget.validator?.call(widget.controller!.text);
      setState(() => _errorText = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = _focusNode.hasFocus;
    final hasError = _errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.label!,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: AppConstants.primaryColor,
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isFocused
                  ? AppConstants.primaryColor.withAlpha(180)
                  : Colors.white.withAlpha(64),
              width: 1.0,
            ),
            boxShadow: [
              if (isFocused)
                BoxShadow(
                  blurRadius: 12,
                  color: AppConstants.primaryColor.withAlpha(40),
                ),
              if (hasError)
                BoxShadow(
                  blurRadius: 12,
                  color: AppConstants.errorColor.withAlpha(30),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(
                sigmaX: widget.blurStrength,
                sigmaY: widget.blurStrength,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((widget.opacity * 255).toInt()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  autofillHints: widget.autofillHints,
                  obscureText: _obscureText,
                  maxLines: _obscureText ? 1 : widget.maxLines,
                  minLines: widget.minLines,
                  onChanged: (value) {
                    widget.onChanged?.call(value);
                    setState(() {});
                  },
                  onEditingComplete: widget.onEditingComplete,
                  validator: (value) {
                    final error = widget.validator?.call(value);
                    if (error != null) {
                      _errorText = error;
                    }
                    return error;
                  },
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppConstants.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: TextStyle(
                      color: AppConstants.textSecondary.withAlpha(128),
                    ),
                    prefixIcon: widget.prefixIcon,
                    suffixIcon: widget.showPasswordToggle
                        ? GestureDetector(
                            onTap: () {
                              setState(() => _obscureText = !_obscureText);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: _obscureText
                                  ? Icon(
                                      Icons.visibility_outlined,
                                      size: 20,
                                      color: AppConstants.primaryColor,
                                    )
                                  : Icon(
                                      Icons.visibility_off_outlined,
                                      size: 20,
                                      color: AppConstants.primaryColor,
                                    ),
                            ),
                          )
                        : widget.suffixIcon,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    errorStyle: const TextStyle(fontSize: 0, height: 0),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _errorText!,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppConstants.errorColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
