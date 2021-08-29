import 'package:flutter/material.dart';
import 'package:imboy/config/const.dart';
import 'package:imboy/helper/func.dart';
import 'package:imboy/helper/win_media.dart';

class SearchTileView extends StatelessWidget {
  final String text;
  final int type;
  final VoidCallback onPressed;

  SearchTileView(this.text, {this.type = 0, this.onPressed});

  @override
  Widget build(BuildContext context) {
    var bt = new TextButton(
      onPressed: onPressed ?? () {},
      child: new Row(
        children: <Widget>[
          new Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: new Icon(
              Icons.map,
              color: Colors.green,
              size: 50.0,
            ),
          ),
          new Text('搜索：'),
          new Text(
            text,
            style: TextStyle(color: Colors.green),
          ),
        ],
      ),
    );

    var row = new Row(
      children: <Widget>[
        new Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: new Icon(Icons.map, color: Colors.green, size: 50.0),
        ),
        new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new Text('搜一搜：'),
                new Text(
                  text,
                  style: TextStyle(color: Colors.green),
                ),
              ],
            ),
            new Text(
              '小程序、公众号、文章、朋友圈、和表情等',
              style: TextStyle(color: mainTextColor),
            )
          ],
        )
      ],
    );

    if (type == 0) {
      return new Container(
        decoration: BoxDecoration(
            color: strNoEmpty(text) ? Colors.white : appBarColor,
            border: Border(
                top: BorderSide(
                    color: Colors.grey.withOpacity(0.2), width: 0.5))),
        width: winWidth(context),
        height: 65.0,
        child: strNoEmpty(text) ? bt : new Container(),
      );
    } else {
      return new Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.withOpacity(0.2), width: 0.5),
          ),
        ),
        width: winWidth(context),
        height: 65.0,
        child: new TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 15.0),
            backgroundColor: Colors.white,
          ),
          onPressed: () {},
          child: row,
        ),
      );
    }
  }
}
