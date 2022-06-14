import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:imboy/component/helper/func.dart';
import 'package:imboy/component/ui/common_bar.dart';
import 'package:imboy/config/const.dart';
import 'package:imboy/store/repository/user_repo_local.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'uqrcode_logic.dart';

class UqrcodePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final logic = Get.put(UqrcodeLogic());
    final state = Get.find<UqrcodeLogic>().state;

    // API_BASE_URL=https://dev.imboy.pub
    String qrdata = "${API_BASE_URL}/uqrcode/${UserRepoLocal.to.currentUid}";

    String gender = UserRepoLocal.to.currentUser.gender;
    var trailing = Icon(
      Icons.battery_unknown,
      color: Colors.lightBlueAccent,
    );
    switch (gender) {
      case "1":
        trailing = Icon(
          Icons.man,
          color: Colors.lightBlueAccent,
        );
        break;
      case "2":
        trailing = Icon(
          Icons.woman,
          color: Colors.lightBlueAccent,
        );
        break;
      case "3":
        trailing = Icon(
          Icons.security,
          color: Colors.lightBlueAccent,
        );
        break;
    }
    return Scaffold(
      backgroundColor: AppColors.AppBarColor,
      appBar: PageAppBar(
        title: "二维码名片".tr,
        rightDMActions: <Widget>[
          InkWell(
            child: Padding(
              padding: EdgeInsets.only(left: 20, right: 10),
              child: Text(
                "...",
                style: TextStyle(
                  fontSize: 28,
                ),
              ),
            ),
            onTap: () {
              Get.bottomSheet(
                Container(
                  width: Get.width,
                  height: Get.height * 0.25,
                  child: Wrap(
                    children: <Widget>[
                      Center(
                        child: TextButton(
                          child: Text(
                            '保持图片'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              // color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          onPressed: () async {
                            //generate the qr code in bytes
                            ByteData? qrBytes = await QrPainter(
                              data: qrdata,
                              gapless: true,
                              version: QrVersions.auto,
                              color: Color.fromRGBO(0, 118, 191, 1),
                              emptyColor: Colors.white,
                            ).toImageData(878);
                            //save the orignal image
                            File qrFile = await SaveNetworkImage().saveImage(
                                qrBytes,
                                code.qid); //<--- see below for this function
                          },
                        ),
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () => {},
                          child: Text(
                            '扫描二维码'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              // color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                      Divider(),
                      Center(
                        child: TextButton(
                          onPressed: () => Get.back(),
                          child: Text(
                            'button_cancel'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              // color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                backgroundColor: Colors.white,
                //改变shape这里即可
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(
          left: 20,
          top: 60,
          right: 20,
          bottom: 20,
        ),
        child: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusDirectional.circular(20)),
          clipBehavior: Clip.antiAlias,
          child: Container(
            width: Get.width,
            height: Get.height * 0.65,
            color: Colors.white,
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(10.0),
                      // color: defHeaderBgColor,
                      image: dynamicAvatar(UserRepoLocal.to.currentUser.avatar),
                    ),
                  ),
                  title: Text(UserRepoLocal.to.currentUser.nickname),
                  subtitle: Text(UserRepoLocal.to.currentUser.region),
                  trailing: trailing,
                ),
                Expanded(
                  child: Center(
                    child: QrImage(
                      data: qrdata,
                      version: QrVersions.auto,
                      size: 320,
                      padding: EdgeInsets.only(
                        left: 10,
                        right: 10,
                        top: 10,
                        // bottom: 10,
                      ),
                      gapless: false,
                      embeddedImage: avatarImageProvider(
                          UserRepoLocal.to.currentUser.avatar),
                      // embeddedImage: AssetImage('assets/images/logo.png'),

                      embeddedImageStyle: QrEmbeddedImageStyle(
                        size: Size(64, 64),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20)
                      .copyWith(bottom: 20),
                  child: Text("扫一扫上面的二维码图案，加我为朋友"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}