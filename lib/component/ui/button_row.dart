import 'package:flutter/material.dart';
import 'package:imboy/config/const.dart';

class ButtonRow extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  final String? text;
  final TextStyle style;
  final VoidCallback? onPressed;
  final bool isBorder;
  final double lineWidth;

  ButtonRow({
    this.margin,
    this.text,
    this.style = const TextStyle(
        color: AppColors.ButtonTextColor,
        fontWeight: FontWeight.w600,
        fontSize: 16),
    this.onPressed,
    this.isBorder = false,
    this.lineWidth = mainLineWidth,
  });

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: margin,
      decoration: BoxDecoration(
        border: isBorder
            ? Border(
                bottom:
                    BorderSide(color: AppColors.LineColor, width: lineWidth),
              )
            : null,
      ),
      child: new TextButton(
        style: TextButton.styleFrom(
          minimumSize: Size.zero,
          padding: EdgeInsets.zero,
          backgroundColor: Colors.white,
        ),
        autofocus: true,
        onPressed: onPressed ?? () {},
        child: new Container(
          padding: EdgeInsets.symmetric(vertical: 15.0),
          alignment: Alignment.center,
          child: new Text(text!, style: style),
        ),
      ),
    );
  }
}
