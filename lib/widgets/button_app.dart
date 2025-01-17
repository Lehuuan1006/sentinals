import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ButtonApp extends StatelessWidget {
  final Function event;
  final String text;
  final String fontFamily;
  final FontWeight fontWeight;
  final double fontsize;
  final double radius;
  final Color colorText;
  final Color backgroundColor;
  final Color outlineColor;
  final double line;
  final IconData? icon;
  final double? iconSize;

  ButtonApp({
    super.key,
    required this.event,
    required this.text,
    required this.colorText,
    required this.backgroundColor,
    required this.outlineColor,
    this.radius = 0,
    this.fontsize = 0,
    this.fontFamily = "OpenSans",
    this.fontWeight = FontWeight.normal,
    this.line = 1,
    this.icon,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius == 0 ? 10.r : radius),
        ),
        backgroundColor: backgroundColor,
        side: BorderSide(color: outlineColor, width: line),
      ),
      onPressed: () {
        event();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Padding(
              padding: EdgeInsets.only(right: 8.r),
              child: Icon(
                icon,
                size: iconSize ?? 24.sp, // Use default size if not specified
                color: colorText,
              ),
            ),
          Container(
            margin: EdgeInsets.all(8.w),
            child: Text(
              text.toUpperCase(),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: fontsize == 0 ? 14.sp : fontsize,
                color: colorText,
                fontFamily: fontFamily,
                fontWeight: fontWeight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
