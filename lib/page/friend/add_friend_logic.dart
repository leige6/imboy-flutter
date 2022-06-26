import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:imboy/component/helper/datetime.dart';
import 'package:imboy/component/http/http_client.dart';
import 'package:imboy/component/http/http_response.dart';
import 'package:imboy/config/const.dart';

class AddFriendLogic extends GetxController {
  // 聊天、朋友圈、运动数据等
  // role 可能的值 all justchat
  RxString role = "all".obs;

  RxBool visibilityLook = true.obs;
  //  不让他（她）看
  RxBool donotlethimlook = false.obs;
  // 不看他（她）
  RxBool donotlookhim = false.obs;

  void setRole(String role) {
    // debugPrint(">>> on AddFriendLogic/setRole1 ${this.role.value} = ${role}");
    this.role.value = role;
    update([this.role]);

    // debugPrint(">>> on AddFriendLogic/setRole2 ${this.role.value} = ${role}");
  }

  /// 申请成为好友
  Future<void> apply(String to, Map<String, dynamic> payload) async {
    payload["msg_type"] = "apply_as_a_friend";
    Map<String, dynamic> msg = {
      "to": to,
      "payload": json.encode(payload),
      "created_at": DateTimeHelper.currentTimeMillis(),
    };

    EasyLoading.show(
      status: '正在发送...'.tr,
    );

    // Future.delayed(Duration(milliseconds: 800), () {
    //   EasyLoading.showSuccess("已发送".tr);
    //   Get.close(1);
    // });
    IMBoyHttpResponse resp = await HttpClient.client.post(
      "${API_BASE_URL}${API.addfriend}",
      data: msg,
      options: Options(
        contentType: "application/x-www-form-urlencoded",
      ),
    );
    if (resp.ok) {
      EasyLoading.showSuccess("已发送".tr);
      Get.close(1);
    } else {
      EasyLoading.showError("网络故障，请重试！".tr);
    }
  }
}