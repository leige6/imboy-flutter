import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imboy/config/init.dart';
import 'package:imboy/helper/http/http_client.dart';
import 'package:imboy/helper/http/http_response.dart';
import 'package:imboy/page/chat/chat_view.dart';
import 'package:imboy/page/contact_detail/contact_detail_view.dart';

import 'contacts_model.dart';
import 'contacts_state.dart';

class ContactsLogic extends GetxController {
  final state = ContactsState();

  listFriend() async {
    List<ContactModel> contacts = [];
    // return contacts;
    // final contactsData = await SharedUtil.instance.getString(Keys.contacts);
    var _dio = Get.find<HttpClient>();
    HttpResponse resp = await _dio.get(API.friendList,
        options: Options(
          contentType: "application/x-www-form-urlencoded",
        ));

    if (!resp.ok) {
      return contacts;
    }
    List<dynamic> dataMap = resp.payload['friend'];
    int dLength = dataMap.length;
    for (int i = 0; i < dLength; i++) {
      ContactModel model = ContactModel.fromJson(dataMap[i]);
      contacts.insert(0, model);
    }
    return contacts;
  }

  Widget getWeChatListItem(
    BuildContext context,
    ContactModel model, {
    double susHeight = 40,
    Color? defHeaderBgColor,
  }) {
    return getWeChatItem(context, model, defHeaderBgColor: defHeaderBgColor);
  }

  Widget getWeChatItem(
    BuildContext context,
    ContactModel model, {
    Color? defHeaderBgColor,
  }) {
    DecorationImage? image;
    if (model.avatar != null && model.avatar!.isNotEmpty) {
      image = DecorationImage(
        image: model.avatar == 'assets/images/def_avatar.png'
            ? AssetImage(model.avatar!) as ImageProvider
            : CachedNetworkImageProvider(model.avatar!),
        fit: BoxFit.cover,
      );
    }

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(4.0),
          color: model.bgColor ?? defHeaderBgColor,
          image: image,
        ),
        child: model.iconData == null
            ? null
            : Icon(
                model.iconData,
                color: Colors.white,
                size: 20,
              ),
      ),
      title: Text(model.nickname),
      onTap: () {
        Get.to(ContactDetailPage(
          id: model.id!,
          nickname: model.nickname,
          avatar: model.avatar!,
          account: model.account!,
        ));
        // Get.snackbar(
        //   "onItemClick : ${model.nickname}",
        //   'onItemClick : ${model}',
        // );
      },
      onLongPress: () {
        Get.to(
          ChatPage(id: model.id!, title: model.nickname, type: 'C2C'),
        );
      },
    );
  }

  Widget getSusItem(BuildContext context, String tag, {double susHeight = 40}) {
    if (tag == '★') {
      tag = '★ 热门城市';
    }
    return Container(
      height: susHeight,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(left: 16.0),
      color: Color(0xFFF3F4F5),
      alignment: Alignment.centerLeft,
      child: Text(
        '$tag',
        softWrap: false,
        style: TextStyle(
          fontSize: 14.0,
          color: Color(0xFF666666),
        ),
      ),
    );
  }
}
