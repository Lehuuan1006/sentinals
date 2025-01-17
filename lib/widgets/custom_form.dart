import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool enabled;
  final bool readonly;
  final bool isPassword;
  final bool passwordVisible;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? textInputFormatter;
  final Function()? onTap;
  final Widget? suffixIcon;
  final Widget? suffix;
  final String? suffixText;
  final Widget? prefixIcon;
  final Function(PointerDownEvent)? onTapOutside;
  final Function()? onEditingComplete;
  final Function(String)? onChange;
  final double opacityHintText;
  final String? labelText;
  final int minLines;
  final int maxLines;
  final TextInputAction? textInputAction;

  const CustomTextFormField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.enabled = true,
    this.readonly = false,
    this.isPassword = false, // New field for password
    this.passwordVisible = false, // New field for password visibility
    this.validator,
    this.keyboardType,
    this.textInputFormatter,
    this.onTap,
    this.suffix,
    this.suffixIcon,
    this.suffixText,
    this.prefixIcon,
    this.onTapOutside,
    this.onEditingComplete,
    this.onChange,
    this.opacityHintText = 0.5,
    this.labelText,
    this.minLines = 1,
    this.maxLines = 1,
    this.textInputAction,
  }) : super(key: key);

  @override
  _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    isPasswordVisible = widget.passwordVisible;
  }

  void togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextInputType effectiveKeyboardType =
        widget.textInputAction == TextInputAction.newline
            ? TextInputType.multiline
            : (widget.keyboardType ?? TextInputType.text);

    return TextFormField(
      onChanged: (value) {
        if (widget.onChange != null) {
          widget.onChange!(value);
        }
      },
      onEditingComplete: widget.onEditingComplete,
      enabled: widget.enabled,
      readOnly: widget.readonly,
      onTap: widget.onTap,
      inputFormatters: widget.textInputFormatter,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      textInputAction: widget.textInputAction,
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus?.unfocus();
        if (widget.onTapOutside != null) {
          widget.onTapOutside!(event);
        }
      },
      controller: widget.controller,
      obscureText:
          widget.isPassword ? !isPasswordVisible : false, // For password
      obscuringCharacter: '*', // Customize the obscuring character if needed
      style: TextStyle(
        fontSize: 14.sp,
        color: Colors.black,
      ),
      cursorColor: Theme.of(context).colorScheme.primary,
      validator: widget.validator,
      keyboardType: effectiveKeyboardType,
      decoration: InputDecoration(
        labelText: widget.labelText,
        fillColor: Theme.of(context).colorScheme.primary,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2.w,
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: Theme.of(context)
              .colorScheme
              .onBackground
              .withOpacity(widget.opacityHintText),
          fontSize: 14.sp,
        ),
        isDense: true,
        contentPadding: EdgeInsets.all(20.w),
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: togglePasswordVisibility,
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  size: 24.sp,
                ),
              )
            : widget.suffixIcon,
        suffix: widget.suffix,
        suffixText: widget.suffixText,
        prefixIcon: widget.prefixIcon,
      ),
    );
  }
}
