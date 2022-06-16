import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imboy/component/ui/button_row.dart';
import 'package:imboy/component/ui/common.dart';
import 'package:imboy/component/ui/common_bar.dart';
import 'package:imboy/component/ui/friend_item_dialog.dart';
import 'package:imboy/component/ui/label_row.dart';
import 'package:imboy/config/const.dart';
import 'package:imboy/page/chat/chat_view.dart';
import 'package:imboy/page/contact_detail/widget/contact_card.dart';
import 'package:imboy/page/friend_circle/friend_circle_view.dart';
import 'package:imboy/store/repository/user_repo_local.dart';

class ScannerResultPage extends StatelessWidget {
  final String id; // 用户ID
  final String nickname;
  final String avatar;
  final String region;
  final String sign;
  final bool is_friend;
  String source;
  int gender;

  ScannerResultPage({
    required this.id,
    required this.nickname,
    required this.avatar,
    required this.is_friend,
    this.region = "",
    this.sign = "",
    this.gender = 0,
    this.source = 'uqrcode',
  });

  List<Widget> body(bool itself) {
    debugPrint("_ContactDetailPageState >>>>>>> ${this.region}");
    return [
      ContactCard(
        id: this.id,
        nickname: this.nickname,
        gender: this.gender,
        account: '',
        avatar: this.avatar,
        region: this.region,
        isBorder: true,
      ),
      Visibility(
        visible: !itself,
        child: LabelRow(
          label: '设置备注和标签'.tr,
          onPressed: () {},
        ),
      ),
      Space(),
      LabelRow(
        label: '朋友圈'.tr,
        isLine: false,
        onPressed: () => Get.to(FriendCirclePage()),
      ),
      ButtonRow(
        margin: EdgeInsets.only(top: 10.0),
        text: '发消息',
        isBorder: true,
        onPressed: () => Get.to(
          ChatPage(
            id: 0,
            toId: this.id,
            title: this.nickname,
            avatar: this.avatar,
            type: 'C2C',
          ),
        ),
      ),
      is_friend
          ? Visibility(
              visible: !itself,
              child: ButtonRow(
                text: '音视频通话',
                onPressed: () => Get.snackbar('', '敬请期待'),
              ),
            )
          : Visibility(
              visible: !itself,
              child: ButtonRow(
                text: '添加到通讯录'.tr,
                onPressed: () => Get.snackbar('', '敬请期待'),
              ),
            ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // final global = Provider.of<GlobalModel>(context, listen: false);
    var currentUser = UserRepoLocal.to.currentUser;
    bool isSelf = currentUser.uid == this.id;
    var rWidget = [
      SizedBox(
        width: 60,
        child: FlatButton(
          padding: EdgeInsets.all(0),
          onPressed: () =>
              friendItemDialog(context, userId: this.id, suCc: (v) {
            if (v) Navigator.of(context).maybePop();
          }),
          child: Image(
            image: AssetImage(contactAssets + 'ic_contacts_details.png'),
          ),
        ),
      )
    ];

    return Scaffold(
      backgroundColor: AppColors.ChatBg,
      appBar: PageAppBar(
        title: '',
        backgroundColor: Colors.white,
        rightDMActions: isSelf ? [] : rWidget,
      ),
      body: SingleChildScrollView(
        child: Column(children: body(isSelf)),
      ),
    );
  }
}
