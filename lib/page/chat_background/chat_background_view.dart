import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'chat_background_logic.dart';
import 'chat_background_state.dart';

class ChatBackgroundPage extends StatefulWidget {
  @override
  _ChatBackgroundPageState createState() => _ChatBackgroundPageState();
}

class _ChatBackgroundPageState extends State<ChatBackgroundPage> {
  final logic = Get.find<ChatBackgroundLogic>();
  final ChatBackgroundState state = Get.find<ChatBackgroundLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  void dispose() {
    Get.delete<ChatBackgroundLogic>();
    super.dispose();
  }
}
