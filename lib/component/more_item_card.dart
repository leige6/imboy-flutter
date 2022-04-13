import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imboy/component/ui/common.dart';
import 'package:imboy/config/const.dart';

class MoreItemCard extends StatelessWidget {
  final String? name, icon;
  final VoidCallback? onPressed;
  final double? keyboardHeight;

  MoreItemCard({this.name, this.icon, this.onPressed, this.keyboardHeight});

  @override
  Widget build(BuildContext context) {
    double _margin = keyboardHeight! != null && keyboardHeight! != 0.0
        ? keyboardHeight!
        : 0.0;
    double _top = _margin != 0.0 ? _margin / 10 : 20.0;

    return new Container(
      padding: EdgeInsets.only(top: _top, bottom: 5.0),
      width: (Get.width - 70) / 4,
      child: new Column(
        children: <Widget>[
          new Container(
            width: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            child: new TextButton(
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: EdgeInsets.zero,
                backgroundColor: Colors.white,
              ),
              onPressed: () {
                if (onPressed != null) {
                  onPressed!();
                }
              },
              // shape: RoundedRectangleBorder(
              //   borderRadius: BorderRadius.all(
              //     Radius.circular(10.0),
              //   ),
              // ),
              child: new Container(
                width: 50.0,
                child: new Image(image: AssetImage(icon!), fit: BoxFit.cover),
              ),
            ),
          ),
          new Space(width: mainSpace / 2),
          new Text(
            name ?? '',
            style: TextStyle(color: AppColors.MainTextColor, fontSize: 11),
          ),
        ],
      ),
    );
  }
}