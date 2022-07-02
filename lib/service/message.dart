import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imboy/component/extension/device_ext.dart';
import 'package:imboy/config/init.dart';
import 'package:imboy/page/contact/contact_logic.dart';
import 'package:imboy/page/conversation/conversation_logic.dart';
import 'package:imboy/page/friend/new_friend_logic.dart';
import 'package:imboy/page/passport/passport_view.dart';
import 'package:imboy/service/websocket.dart';
import 'package:imboy/store/model/contact_model.dart';
import 'package:imboy/store/model/conversation_model.dart';
import 'package:imboy/store/model/message_model.dart';
import 'package:imboy/store/provider/contact_provider.dart';
import 'package:imboy/store/repository/contact_repo_sqlite.dart';
import 'package:imboy/store/repository/conversation_repo_sqlite.dart';
import 'package:imboy/store/repository/message_repo_sqlite.dart';
import 'package:imboy/store/repository/user_repo_local.dart';

class MessageService extends GetxService {
  static MessageService get to => Get.find();
  final ContactLogic ctlogic = Get.find();
  final NewFriendLogic nflogic = Get.find();
  final ConversationLogic cvlogic = Get.find();

  @override
  void onInit() {
    super.onInit();
    eventBus.on<Map>().listen((Map data) async {
      debugPrint(">>> on MessageService onInit: " + data.toString());
      String dtype = data['type'] ?? 'error';
      dtype = dtype.toUpperCase();
      switch (dtype) {
        case 'C2C':
          await reciveC2CMessage(data);
          break;
        case 'C2C_SERVER_ACK': // C2C 服务端消息确认
          await reciveC2CServerAckMessage(data);
          break;
        case 'C2C_REVOKE': // 对端撤回消息
          await reciveC2CRevokeMessage(data);
          break;
        case 'C2C_REVOKE_ACK': // 对端撤回消息ACK
          await reciveC2CRevokeAckMessage(dtype, data);
          break;
        case 'SERVER_ACK_GROUP': // 服务端消息确认 GROUP TODO
          break;
        case 'S2C':
          var payload = data['payload'] ?? {};
          if (payload is String) {
            payload = json.decode(payload);
          }
          var msgType = payload['msg_type'] ?? '';
          switch (msgType.toString()) {
            // case 705: // token无效、刷新token 这里不处理，不发送消息
            case "apply_friend": // 添加好友申请
              nflogic.receivedAddFriend(data);
              break;
            case "apply_friend_confirm": // 添加好友申请确认
              // 接受消息人（to）新增联系人
              ctlogic.receivedConfirFriend(data['payload']);
              // 修正好友申请状态
              nflogic.receivedConfirFriend(true, data);
              break;
            case "706": // 需要重新登录
              {
                Get.off(() => PassportPage());
              }
              break;
            case "786": // 在其他地方上线
              {
                String currentdid = await DeviceExt.did;
                String did = payload['did'] ?? '';
                if (did != currentdid) {
                  String dname = payload['dname'] ?? '';
                  int serverTs = data['server_ts'] ?? 0;
                  WSService.to.closeSocket();
                  UserRepoLocal.to.logout();
                  Get.off(() => PassportPage(), arguments: {
                    "msgtype": "786",
                    "server_ts": serverTs,
                    "dname": dname,
                  });
                }
              }
              break;
            case "1019": // 好友上线提现
              // TODO
              break;
          }
          break;
      }
    });
  }

  /// Called before [onDelete] method. [onClose] might be used to
  /// dispose resources used by the controller. Like closing events,
  /// or streams before the controller is destroyed.
  /// Or dispose objects that can potentially create some memory leaks,
  /// like TextEditingControllers, AnimationControllers.
  /// Might be useful as well to persist some data on disk.
  @override
  void onClose() {
    super.onClose();
  }

  /// 收到C2C消息
  Future<void> reciveC2CMessage(data) async {
    var msgtype = data['payload']['msg_type'] ?? '';
    var text = data['payload']['text'] ?? '';
    debugPrint(">>> on reciveMessage " + data.toString());

    String subtitle = '';

    ContactModel? ct = await ContactRepo().findByUid(data['from']);
    // 如果没有联系人，同步去取
    ct ??= await (ContactProvider()).syncByUid(data['from']);
    String avatar = ct.avatar;
    String title = ct.nickname;

    subtitle = text;

    ConversationModel cobj = ConversationModel(
      typeId: data['from'],
      avatar: avatar,
      title: title,
      subtitle: subtitle,
      type: data['type'],
      msgtype: msgtype,
      lastMsgId: data['id'],
      lasttime: data['created_at'],
      unreadNum: 1,
      isShow: 1,
      id: 0,
    );
    cobj = await (ConversationRepo()).save(cobj);

    MessageModel msg = MessageModel(
      data['id'],
      type: data['type'],
      fromId: data['from'],
      toId: data['to'],
      payload: data['payload'],
      createdAt: data['created_at'],
      serverTs: data['server_ts'],
      conversationId: cobj.id,
      status: MessageStatus.delivered,
    );
    await (MessageRepo()).save(msg);

    eventBus.fire(cobj);

    // 收到一个消息，步增会话消息 1
    cvlogic.increaseConversationRemind(data['from'], 1);

    eventBus.fire(msg.toTypeMessage());
    // 确实消息
    String did = await DeviceExt.did;
    debugPrint(">>> on CLIENT_ACK,C2C,${data['id']},$did");
    WSService.to.sendMessage("CLIENT_ACK,C2C,${data['id']},$did");
    // WSService.to.sendMessage(json.encode({
    //   'id': data['id'],
    //   'type': 'C2C_CLIENT_ACK',
    //   'remark': 'recived',
    // }));
  }

  /// 收到C2C服务端确认消息
  Future<void> reciveC2CServerAckMessage(Map data) async {
    debugPrint(">>> on MessageService S_RECEIVED: msg:" + data.toString());
    MessageRepo repo = MessageRepo();
    String id = data['id'];
    int res = await repo.update({
      'id': id,
      'status': MessageStatus.send,
    });
    MessageModel? msg = await repo.find(id);
    debugPrint(">>> on MessageService S_RECEIVED:$res");
    // 更新会话状态
    List<ConversationModel> items =
        await ConversationLogic().updateLastMsgStatus(
      id,
      MessageStatus.send,
    );
    if (items.isNotEmpty) {
      for (var cobj in items) {
        // 更新会话
        cvlogic.replace(cobj);
        eventBus.fire(cobj);
      }
    }
    if (res > 0 && msg != null) {
      eventBus.fire([msg.toTypeMessage()]);
    }
  }

  /// 收到C2C撤回消息
  Future<void> reciveC2CRevokeMessage(data) async {
    ContactModel? c = await ContactRepo().findByUid(data['from']);
    // debugPrint(">> on reciveC2CRevokeMessage ${c.toJson().toString()}");
    MessageRepo repo = MessageRepo();
    String id = data['id'];
    await repo.update({
      'id': id,
      'status': MessageStatus.send,
      'payload': json.encode({
        "msg_type": "custom",
        "custom_type": "revoked",
        "from_name": c!.nickname
      }),
    });
    // msg = null 的时候数据已经被删除了
    MessageModel? msg = await repo.find(id);
    if (msg != null) {
      eventBus.fire([msg.toTypeMessage()]);
    }
    changeConversation(id, data['from'], false);

    // 通知服务器已撤销
    Map<String, dynamic> msg2 = {
      'id': id,
      'type': 'C2C_REVOKE_ACK',
      'from': data["to"],
      'to': data["from"],
    };
    WSService.to.sendMessage(json.encode(msg2));
  }

  /// 撤回消息修正相应会话记录
  Future<void> changeConversation(
    String msgId,
    String msgFromId,
    bool isack,
  ) async {
    ConversationRepo repo2 = ConversationRepo();
    ConversationModel? cobj = await repo2.findByTypeId(msgFromId);

    if (cobj != null && cobj.lastMsgId == msgId) {
      bool isCUid = UserRepoLocal.to.currentUid == msgFromId ? true : false;
      String subtitle = isCUid || isack ? '你撤回了一条消息' : '"${cobj.title}"撤回了一条消息';
      int res2 = await repo2.updateById(cobj.id, {
        'subtitle': subtitle,
      });
      if (res2 > 0) {
        cobj.subtitle = subtitle;
        eventBus.fire(cobj);
      }
    }
  }

  /// 收到C2C撤回ACK消息
  Future<void> reciveC2CRevokeAckMessage(dtype, data) async {
    MessageRepo repo = MessageRepo();
    MessageModel? msg = await repo.find(data['id']);

    msg!.payload = {
      "msg_type": "custom",
      "custom_type": "revoked",
      'text': msg.payload!['text'],
    };
    await repo.update({
      'id': data['id'],
      'type': dtype,
      'status': MessageStatus.send,
      'payload': json.encode(msg.payload),
    });
    eventBus.fire([msg.toTypeMessage()]);
    // 确认消息
    String did = await DeviceExt.did;
    WSService.to.sendMessage("CLIENT_ACK,C2C,${data['id']},$did");

    changeConversation(data['id'], data['from'], true);
  }
}
