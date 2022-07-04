import 'package:azlistview/azlistview.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imboy/component/helper/assets.dart';
import 'package:imboy/component/ui/common_bar.dart';
import 'package:imboy/component/ui/nodata_view.dart';
import 'package:imboy/page/bottom_navigation/bottom_navigation_logic.dart';
import 'package:imboy/page/friend/new_friend_view.dart';
import 'package:imboy/page/search/search_view.dart';
import 'package:imboy/store/model/contact_model.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:niku/namespace.dart' as n;

import 'contact_logic.dart';

// ignore: must_be_immutable
class ContactPage extends StatelessWidget {
  RxBool contactIsEmpty = true.obs;

  late List<ContactModel> topList;
  final ContactLogic logic = Get.find();
  final BottomNavigationLogic bnLogic = Get.find();

  ContactPage({Key? key}) : super(key: key);

  void loadData() async {
    topList = [
      ContactModel(
        nickname: '新的朋友'.tr,
        nameIndex: '↑',
        bgColor: Colors.orange,
        iconData: Badge(
          showBadge: bnLogic.newFriendRemindCounter.value > 0,
          shape: BadgeShape.square,
          borderRadius: BorderRadius.circular(10),
          position: BadgePosition.topStart(top: 0, start: 128),
          padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
          child: const Icon(Icons.person_add),
          badgeContent: Container(
            color: Colors.red,
            alignment: Alignment.center,
            child: Text(
              bnLogic.newFriendRemindCounter.value.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
              ),
            ),
          ),
        ),
        onPressed: () {
          Get.to(() => NewFriendPage());
        },
      ),
      ContactModel(
        nickname: '群聊'.tr,
        nameIndex: '↑',
        bgColor: Colors.green,
        iconData: const Icon(
          Icons.people,
          color: Colors.white,
          size: 20,
        ),
      ),
      ContactModel(
        nickname: '标签'.tr,
        nameIndex: '↑',
        bgColor: Colors.blue,
        iconData: const Icon(
          Icons.local_offer,
          color: Colors.white,
          size: 20,
        ),
      ),
      // ContactModel(
      //     nickname: '公众号',
      //     nameIndex: '↑',
      //     bgColor: Colors.blueAccent,
      //     iconData: Icons.person,
      // ),
    ];

    // 加载联系人列表
    logic.contactList.value = await logic.listFriend();
    // debugPrint(">>> on contactList ${logic.contactList.toString()}");
    contactIsEmpty.value = logic.contactList.isEmpty;
    _handleList(logic.contactList);
  }

  void _handleList(List<ContactModel> list) {
    for (int i = 0; i < list.length; i++) {
      String pinyin = PinyinHelper.getPinyinE(list[i].title);
      String tag = pinyin.substring(0, 1).toUpperCase();
      list[i].namePinyin = pinyin;
      if (RegExp("[A-Z]").hasMatch(tag)) {
        list[i].nameIndex = tag;
      } else {
        list[i].nameIndex = "#";
      }
    }
    // A-Z sort.
    SuspensionUtil.sortListBySuspensionTag(logic.contactList);

    // show sus tag.
    SuspensionUtil.setShowSuspensionStatus(logic.contactList);

    // add topList.
    logic.contactList.insertAll(0, topList);
  }

  @override
  Widget build(BuildContext context) {
    loadData();
    return Scaffold(
      appBar: NavAppBar(
        title: "联系人".tr,
        rightDMActions: <Widget>[
          InkWell(
            child: const SizedBox(
              width: 60.0,
              child: Image(
                image: AssetImage('assets/images/search_black.webp'),
              ),
            ),
            onTap: () => Get.to(() => const SearchPage()),
          ),
        ],
      ),
      body: Obx(
        () => n.Stack([
          AzListView(
            data: logic.contactList,
            itemCount: logic.contactList.length,
            itemBuilder: (BuildContext context, int index) {
              ContactModel model = logic.contactList[index];
              return logic.getChatListItem(
                context,
                model,
                defHeaderBgColor: const Color(0xFFE5E5E5),
              );
            },
            physics: const BouncingScrollPhysics(),
            susItemBuilder: (BuildContext context, int index) {
              ContactModel model = logic.contactList[index];
              if ('↑' == model.getSuspensionTag()) {
                return Container();
              }
              return logic.getSusItem(context, model.getSuspensionTag());
            },
            indexBarData: const ['↑', ...kIndexBarData],
            indexBarOptions: IndexBarOptions(
              needRebuild: true,
              ignoreDragCancel: true,
              downTextStyle: const TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
              downItemDecoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green,
              ),
              indexHintWidth: 128 / 2,
              indexHintHeight: 128 / 2,
              indexHintDecoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    Assets.getImgPath('ic_index_bar_bubble_gray'),
                  ),
                  fit: BoxFit.contain,
                ),
              ),
              indexHintAlignment: Alignment.centerRight,
              indexHintChildAlignment: const Alignment(-0.25, 0.0),
              indexHintOffset: const Offset(-20, 0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: contactIsEmpty.isTrue
                ? NoDataView(text: '无联系人'.tr)
                : const SizedBox.shrink(),
          ),
        ]),
      ),
    );
  }
}
