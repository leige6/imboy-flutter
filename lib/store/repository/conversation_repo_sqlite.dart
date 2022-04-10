import 'package:flutter/material.dart';
import 'package:imboy/component/helper/sqflite.dart';
import 'package:imboy/store/model/conversation_model.dart';

class ConversationRepo {
  static String tablename = 'conversation';

  static String id = 'id';
  static String typeId = 'type_id';
  static String avatar = 'avatar';
  static String title = 'title';
  static String subtitle = 'subtitle';
  static String lasttime = 'lasttime';
  static String lastMsgId = 'last_msg_id';
  static String lastMsgStatus = 'last_msg_status';
  static String unreadNum = 'unread_num';
  // 等价与 msg type: C2C C2G 等等，根据type显示item
  static String type = 'type';
  // enum MessageType { custom, file, image, text, unsupported }
  static String msgtype = 'msgtype';
  static String isShow = "is_show";

  Sqlite _db = Sqlite.instance;

  // 插入一条数据
  Future<int> insert(ConversationModel obj) async {
    Map<String, dynamic> insert = {
      'id': obj.id,
      'type_id': obj.typeId,
      'avatar': obj.avatar,
      'title': obj.title,
      'subtitle': obj.subtitle,
      // 单位毫秒，13位时间戳  1561021145560
      'lasttime': obj.lasttime ?? DateTime.now().millisecond,
      'last_msg_id': obj.lastMsgId,
      'last_msg_status': obj.lastMsgStatus ?? 11,
      'unread_num': obj.unreadNum > 0 ? obj.unreadNum : 0,
      'type': obj.type,
      'msgtype': obj.msgtype,
      'is_show': obj.isShow,
    };
    int lastInsertId = await _db.insert(ConversationRepo.tablename, insert);
    return lastInsertId;
  }

  Future<int> updateById(int id, Map<String, dynamic> data) async {
    return await _db.update(
      ConversationRepo.tablename,
      data,
      where: '${ConversationRepo.id} = ?',
      whereArgs: [id],
    );
  }

  // 更新信息
  Future<int> updateByTypeId(String typeId, Map<String, dynamic> data) async {
    data.remove(ConversationRepo.id);
    return await _db.update(
      ConversationRepo.tablename,
      data,
      where: '${ConversationRepo.typeId} = ?',
      whereArgs: [typeId],
    );
  }

  // 存在就更新，不存在就插入
  Future<ConversationModel> save(ConversationModel obj) async {
    String where = '${ConversationRepo.typeId} = ?';
    ConversationModel? oldObj = await this.findByTypeId(obj.typeId);
    int unreadNumOld = oldObj == null ? 0 : oldObj.unreadNum;
    obj.unreadNum = obj.unreadNum + unreadNumOld;
    if (oldObj == null) {
      obj.id = (await maxId()) + 1;
      insert(obj);
    } else {
      updateByTypeId(obj.typeId, obj.toJson());
    }
    int? id = await _db.pluck(
      ConversationRepo.id,
      ConversationRepo.tablename,
      where: where,
      whereArgs: [obj.typeId],
    );
    obj.id = id!;
    return obj;
  }

  Future<int> maxId() async {
    int? id = await _db.pluck(
      "max(${ConversationRepo.id}) as maxId",
      ConversationRepo.tablename,
    );
    return id == null ? 0 : id;
  }

  //
  Future<List<ConversationModel>> search(
      String where, List<Object?>? whereArgs) async {
    List<Map<String, dynamic>> maps = await _db.query(
      ConversationRepo.tablename,
      columns: [
        ConversationRepo.typeId,
        ConversationRepo.avatar,
        ConversationRepo.title,
        ConversationRepo.subtitle,
        ConversationRepo.lasttime,
        ConversationRepo.lastMsgId,
        ConversationRepo.lastMsgStatus,
        ConversationRepo.unreadNum,
        ConversationRepo.type,
        ConversationRepo.msgtype,
      ],
      where: where,
      whereArgs: whereArgs,
      orderBy: "${ConversationRepo.lasttime} DESC",
    );

    if (maps.length == 0) {
      return [];
    }

    List<ConversationModel> items = [];
    for (int i = 0; i < maps.length; i++) {
      items.add(ConversationModel.fromJson(maps[i]));
    }
    return items;
  }

  //
  Future<List<ConversationModel>> all() async {
    List<Map<String, dynamic>> items = await _db.query(
      ConversationRepo.tablename,
      columns: [
        ConversationRepo.id,
        ConversationRepo.typeId,
        ConversationRepo.avatar,
        ConversationRepo.title,
        ConversationRepo.subtitle,
        ConversationRepo.lasttime,
        ConversationRepo.lastMsgId,
        ConversationRepo.lastMsgStatus,
        ConversationRepo.unreadNum,
        ConversationRepo.type,
        ConversationRepo.msgtype,
      ],
      where: '${ConversationRepo.isShow} = ?',
      whereArgs: [1],
      orderBy: "${ConversationRepo.lasttime} DESC",
    );
    debugPrint(">>> on ConversationRepo/all ${items.length} items " +
        items.toString());
    if (items.length == 0) {
      return [];
    }
    List<ConversationModel> item2 = [];
    items.forEach((element) {
      item2.add(ConversationModel.fromJson(element));
    });
    debugPrint(">>> on ConversationRepo/all ${item2.length} item2 " +
        item2.toString());
    return item2;
  }

  Future<ConversationModel?> findById(int id) async {
    debugPrint(">>> on ConversationRepo/findById id {$id}");
    List<Map<String, dynamic>> maps = await _db.query(
      ConversationRepo.tablename,
      columns: [
        ConversationRepo.id,
        ConversationRepo.typeId,
        ConversationRepo.avatar,
        ConversationRepo.title,
        ConversationRepo.subtitle,
        ConversationRepo.lasttime,
        ConversationRepo.lastMsgId,
        ConversationRepo.lastMsgStatus,
        ConversationRepo.unreadNum,
        ConversationRepo.type,
        ConversationRepo.msgtype,
      ],
      where: 'id=?',
      whereArgs: [id],
      orderBy: "${ConversationRepo.lasttime} DESC",
    );

    if (maps.length > 0) {
      return ConversationModel.fromJson(maps.first);
    }
    return null;
  }

  //
  Future<ConversationModel?> findByTypeId(String typeId) async {
    List<Map<String, dynamic>> maps = await _db.query(
      ConversationRepo.tablename,
      columns: [
        ConversationRepo.id,
        ConversationRepo.typeId,
        ConversationRepo.title,
        ConversationRepo.subtitle,
        ConversationRepo.avatar,
        ConversationRepo.lasttime,
        ConversationRepo.lastMsgId,
        ConversationRepo.lastMsgStatus,
        ConversationRepo.msgtype,
        ConversationRepo.unreadNum,
      ],
      where: '${ConversationRepo.typeId} = ?',
      whereArgs: [typeId],
    );
    if (maps.length > 0) {
      return ConversationModel.fromJson(maps.first);
    }
    return null;
  }

  // 根据ID删除信息
  Future<int> delete(String typeId) async {
    return await _db.delete(
      ConversationRepo.tablename,
      where: '${ConversationRepo.typeId} = ?',
      whereArgs: [typeId],
    );
  }

  // 记得及时关闭数据库，防止内存泄漏
  close() async {
    //await _db.close();
  }
}
