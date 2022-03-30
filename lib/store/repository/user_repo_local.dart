import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:imboy/component/helper/func.dart';
import 'package:imboy/component/helper/sqflite.dart';
import 'package:imboy/config/const.dart';
import 'package:imboy/service/storage.dart';
import 'package:imboy/service/websocket.dart';
import 'package:imboy/store/model/user_model.dart';
import 'package:imboy/store/provider/user_provider.dart';

class UserRepoLocal extends GetxController {
  static UserRepoLocal get to => Get.find();

  bool get isLogin => accessToken.isNotEmpty;
  bool get hasToken => accessToken.isNotEmpty;

  // 令牌 token
  String get accessToken => StorageService.to.getString(Keys.tokenKey);
  String get currentUid => StorageService.to.getString(Keys.currentUid);
  UserModel get currentUser => UserModel.fromJson(
        StorageService.to.getMap(Keys.currentUser),
      );

  @override
  void onInit() {
    super.onInit();
    update();
  }

  Future<bool> loginAfter(Map<String, dynamic> payload) async {
    debugPrint(">>> on user loginAfter");
    await StorageService.to.setString(Keys.tokenKey, payload['token']);
    await StorageService.to.setString(Keys.currentUid, payload['uid']);
    await StorageService.to.setMap(Keys.currentUser, payload);
    update();
    Sqlite.instance.database;
    // 初始化 WebSocket 链接
    WSService.to.openSocket();
    return true;
  }

  Future<bool> logout() async {
    WSService.to.sendMessage("logout");
    sleep(Duration(seconds: 1));
    await StorageService.to.remove(Keys.tokenKey);
    await StorageService.to.remove(Keys.currentUid);
    await StorageService.to.remove(Keys.currentUser);

    WSService.to.closeSocket();
    Sqlite.instance.close();
    return true;
  }

  /**
   * 刷新token
   */
  Future<void> refreshtoken() async {
    String newToken = await (UserProvider()).refreshtoken(
      UserRepoLocal.to.currentUser.refreshtoken!,
    );
    if (strNoEmpty(newToken)) {
      await StorageService.to.setString(Keys.tokenKey, newToken);
    }
  }

  @override
  void dispose() {
    debugPrint(">>> on user UserRepoSP disponse");
    super.dispose();
  }
}
